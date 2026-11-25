import Cocoa
import Quartz
import ServiceManagement
import UserNotifications

func t(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSMenuItemValidation, UNUserNotificationCenterDelegate, BLEDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let ble = BLE()
    let mainMenu = NSMenu()
    let deviceMenu = NSMenu()
    let lockRSSIMenu = NSMenu()
    let unlockRSSIMenu = NSMenu()
    let timeoutMenu = NSMenu()
    let lockDelayMenu = NSMenu()
    var deviceDict: [UUID: NSMenuItem] = [:]
    var monitorMenuItem : NSMenuItem?
    let prefs = UserDefaults.standard
    var displaySleep = false
    var systemSleep = false
    var connected = false
    var nowPlayingWasPlaying = false
    var aboutBox: AboutBox? = nil
    var wakeTimer: Timer?
    var manualLock = false
    var unlockedAt = 0.0
    var inScreensaver = false
    var lastRSSI: Int? = nil
    var limiter = UnlockLimiter()
    let confirmDelayMenu = NSMenu()
    let modeMenu = NSMenu()
    let device2Menu = NSMenu()
    var deviceDict2: [UUID: NSMenuItem] = [:]
    var knownDevices: [UUID: Device] = [:]
    var layoutKeys: [UUID: String] = [:]
    var rebuildTimer: Timer?
    var ble2: BLE?
    var proxy2: SecondaryBLEDelegate?
    var monitorMenuItem2: NSMenuItem?
    var unlockOnlyItems: [NSMenuItem] = []
    var updateMenuItem: NSMenuItem?
    let UNLOCK_DEFAULT = -60

    /// "full" = lock and unlock (password stored in Keychain), "lockOnly" = never stores a password.
    var unlockEnabled: Bool { return prefs.string(forKey: "mode") != "lockOnly" }
    let maxAttemptsMenu = NSMenu()

    func menuWillOpen(_ menu: NSMenu) {
        if menu == device2Menu || menu == deviceMenu {
            rebuildDeviceMenus()   // refresh order by current signal strength
            ble.startScanning()
        } else if menu == lockRSSIMenu {
            for item in menu.items {
                if item.tag == ble.lockRSSI {
                    item.state = .on
                } else {
                    item.state = .off
                }
            }
        } else if menu == unlockRSSIMenu {
            for item in menu.items {
                if item.tag == ble.unlockRSSI {
                    item.state = .on
                } else {
                    item.state = .off
                }
            }
        } else if menu == timeoutMenu {
            for item in menu.items {
                if item.tag == Int(ble.signalTimeout) {
                    item.state = .on
                } else {
                    item.state = .off
                }
            }
        } else if menu == modeMenu {
            for item in menu.items { item.state = (item.tag == (unlockEnabled ? 0 : 1)) ? .on : .off }
        } else if menu == confirmDelayMenu {
            for item in menu.items { item.state = item.tag == prefs.integer(forKey: "confirmDelay") ? .on : .off }
        } else if menu == maxAttemptsMenu {
            let cur = prefs.object(forKey: "maxUnlockAttempts") == nil ? 3 : prefs.integer(forKey: "maxUnlockAttempts")
            for item in menu.items { item.state = item.tag == cur ? .on : .off }
        } else if menu == lockDelayMenu {
            for item in menu.items {
                if item.tag == Int(ble.proximityTimeout) {
                    item.state = .on
                } else {
                    item.state = .off
                }
            }
        }
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.menu == lockRSSIMenu {
            return menuItem.tag <= ble.unlockRSSI
        } else if menuItem.menu == unlockRSSIMenu {
            return menuItem.tag >= ble.lockRSSI
        }
        return true
    }
    
    func menuDidClose(_ menu: NSMenu) {
        if menu == deviceMenu || menu == device2Menu {
            ble.stopScanning()
        }
    }
    
    func menuItemTitle(device: Device) -> String {
        var desc : String!
        if let mac = device.macAddr {
            let prettifiedMac = mac.replacingOccurrences(of: "-", with: ":").uppercased()
            desc = String(format: "%@ (%@)", device.description, prettifiedMac)
        } else {
            desc = device.description
        }
        return String(format: "%@ (%ddBm)", desc, device.rssi)
    }
    
    // MARK: Device lists (sorted, grouped, with icons)

    func layoutKey(_ device: Device) -> String {
        return "\(device.kind.rawValue)|\(!DeviceCatalog.looksLikeRawIdentifier(device.description))"
    }

    func newDevice(device: Device) {
        knownDevices[device.uuid] = device
        layoutKeys[device.uuid] = layoutKey(device)
        scheduleDeviceListRebuild()
    }

    func updateDevice(device: Device) {
        knownDevices[device.uuid] = device
        // Name/model arrive after the first sighting: re-layout only if the device's group changed.
        let key = layoutKey(device)
        if layoutKeys[device.uuid] != key {
            layoutKeys[device.uuid] = key
            scheduleDeviceListRebuild()
            return
        }
        let title = menuItemTitle(device: device)
        deviceDict[device.uuid]?.title = title
        deviceDict2[device.uuid]?.title = title
    }

    func removeDevice(device: Device) {
        knownDevices.removeValue(forKey: device.uuid)
        layoutKeys.removeValue(forKey: device.uuid)
        scheduleDeviceListRebuild()
    }

    /// Debounced: several devices appear within a fraction of a second when the menu opens.
    func scheduleDeviceListRebuild() {
        rebuildTimer?.invalidate()
        let t = Timer(timeInterval: 0.8, repeats: false) { [weak self] _ in self?.rebuildDeviceMenus() }
        RunLoop.main.add(t, forMode: .common)
        rebuildTimer = t
    }

    func rebuildDeviceMenus() {
        let entries = knownDevices.values.map { d in
            DeviceEntry(id: d.uuid, kind: d.kind, named: !DeviceCatalog.looksLikeRawIdentifier(d.description),
                        rssi: d.rssi, title: menuItemTitle(device: d))
        }
        let layout = DeviceCatalog.partition(entries)
        deviceDict = fill(deviceMenu, layout: layout, selected: ble.monitoredUUID, action: #selector(selectDevice), withNone: false)
        deviceDict2 = fill(device2Menu, layout: layout, selected: ble2?.monitoredUUID, action: #selector(selectSecondDevice), withNone: true)
    }

    func fill(_ menu: NSMenu, layout: (personal: [DeviceEntry], others: [DeviceEntry]), selected: UUID?,
              action: Selector, withNone: Bool) -> [UUID: NSMenuItem] {
        var dict: [UUID: NSMenuItem] = [:]
        menu.removeAllItems()
        if withNone {
            add(menu, t("none"), #selector(clearSecondDevice), symbol: "xmark.circle")
            menu.addItem(NSMenuItem.separator())
        }
        let tip = menu.addItem(withTitle: t("device_tip"), action: nil, keyEquivalent: "")
        tip.isEnabled = false
        symbol(tip, "lightbulb")
        menu.addItem(NSMenuItem.separator())

        func make(_ e: DeviceEntry, in m: NSMenu) {
            let item = m.addItem(withTitle: e.title, action: action, keyEquivalent: "")
            symbol(item, DeviceCatalog.symbol(for: e.kind))
            if e.id == selected { item.state = .on }
            dict[e.id] = item
        }
        if layout.personal.isEmpty && layout.others.isEmpty {
            menu.addItem(withTitle: t("scanning"), action: nil, keyEquivalent: "").isEnabled = false
            return dict
        }
        for e in layout.personal { make(e, in: menu) }
        if !layout.others.isEmpty {
            if !layout.personal.isEmpty { menu.addItem(NSMenuItem.separator()) }
            let sub = NSMenu()
            let parent = menu.addItem(withTitle: String(format: t("other_devices"), layout.others.count), action: nil, keyEquivalent: "")
            parent.submenu = sub
            symbol(parent, "ellipsis.circle")
            for e in layout.others { make(e, in: sub) }
        }
        return dict
    }

    func updateRSSI(rssi: Int?, active: Bool) {
        if let r = rssi {
            lastRSSI = r
            statusItem.button?.title = prefs.bool(forKey: "showRSSI") ? " \(r)" : ""
            monitorMenuItem?.title = String(format:"%ddBm", r) + (active ? " (Active)" : "")
            if (!connected) {
                connected = true
                statusItem.button?.image = NSImage(named: "StatusBarConnected")
            }
        } else {
            monitorMenuItem?.title = t("not_detected")
            if prefs.bool(forKey: "showRSSI") { statusItem.button?.title = " –" }
            if (connected) {
                connected = false
                statusItem.button?.image = NSImage(named: "StatusBarDisconnected")
            }
        }
    }

    func bluetoothPowerWarn() {
        errorModal(t("bluetooth_power_warn"))
    }

    /// Optional: lock when Bluetooth is turned off (the monitored device can no longer be seen).
    func bluetoothStateChanged(on: Bool) {
        guard !on, prefs.bool(forKey: "lockOnBluetoothOff"), ble.monitoredUUID != nil,
              ble.lockRSSI != ble.LOCK_DISABLED, !isScreenLocked() else { return }
        pauseNowPlaying()
        lockOrSaveScreen()
        notifyUser("lost")
        runScript("lost")
    }

    func updateRSSI2(rssi: Int?) {
        if let r = rssi {
            monitorMenuItem2?.title = String(format: "%@: %ddBm", t("device_2"), r)
        } else {
            monitorMenuItem2?.title = String(format: "%@: %@", t("device_2"), t("not_detected"))
        }
    }

    /// "Attended" = any configured device (watch or phone) is near. Unconfigured devices are ignored.
    func combinedPresence() -> Bool {
        return PresenceCombiner.anyPresent([
            ble.monitoredUUID != nil ? ble.presence : nil,
            ble2?.monitoredUUID != nil ? ble2?.presence : nil,
        ])
    }

    func notifyUser(_ reason: String) {
        guard prefs.object(forKey: "notifications") == nil || prefs.bool(forKey: "notifications") else { return }
        var subtitle = ""
        if reason == "lost" {
            subtitle = t("notification_lost_signal")
        } else if reason == "away" {
            subtitle = t("notification_device_away")
        }
        deliverNotification(id: lockNotificationId, subtitle: subtitle, body: t("notification_locked"), delay: 1)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == updateNotificationId {
            NSWorkspace.shared.open(releasesURL)
            center.removeDeliveredNotifications(withIdentifiers: [updateNotificationId])
        }
        completionHandler()
    }

    /// Runs the optional user script only if it is a regular file owned by the current user
    /// and not writable by group/others (prevents another account or process from swapping it).
    func runScript(_ arg: String) {
        guard let directory = try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return }
        let file = directory.appendingPathComponent("event")
        guard isSafeToRunScript(atPath: file.path) else {
            if FileManager.default.fileExists(atPath: file.path) {
                print("Refusing to run event script: must be a regular file owned by you and not group/world-writable")
            }
            return
        }
        let process = Process()
        process.executableURL = file
        if let r = lastRSSI {
            process.arguments = [arg, String(r)]
        } else {
            process.arguments = [arg]
        }
        try? process.run()
    }

    func pauseNowPlaying() {
        guard prefs.bool(forKey: "pauseItunes") else { return }
        MRMediaRemoteGetNowPlayingApplicationIsPlaying(
            DispatchQueue.main,
            { (playing) in
                self.nowPlayingWasPlaying = playing
                if self.nowPlayingWasPlaying {
                    print("pause")
                    MRMediaRemoteSendCommand(MRCommandPause, nil)
                }
            }
        )
    }
    
    func playNowPlaying() {
        guard prefs.bool(forKey: "pauseItunes") else { return }
        if nowPlayingWasPlaying {
            print("play")
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                MRMediaRemoteSendCommand(MRCommandPlay, nil)
                self.nowPlayingWasPlaying = false
            })
        }
    }

    func lockOrSaveScreen() {
        if prefs.bool(forKey: "screensaver") {
            let url = URL(fileURLWithPath: "/System/Library/CoreServices/ScreenSaverEngine.app")
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        } else {
            if SACLockScreenImmediate() != 0 {
                print("Failed to lock screen")
            }
            if prefs.bool(forKey: "sleepDisplay") {
                print("sleep display")
                sleepDisplay()
            }
        }
    }

    func updatePresence(presence: Bool, reason: String) {
        handlePresence(presence, reason)
    }

    func handlePresence(_ presence: Bool, _ reason: String) {
        if presence {
            if ble.unlockRSSI != ble.UNLOCK_DISABLED {
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [lockNotificationId])
                if displaySleep && !systemSleep && prefs.bool(forKey: "wakeOnProximity") {
                    print("Waking display")
                    wakeDisplay()
                    wakeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                        print("Retrying waking display")
                        wakeDisplay()
                    })
                }
                tryUnlockScreen()
            }
        } else {
            // With two devices the Mac is locked only when ALL of them are away.
            guard !combinedPresence() else { return }
            if (!isScreenLocked() && ble.lockRSSI != ble.LOCK_DISABLED) {
                pauseNowPlaying()
                lockOrSaveScreen()
                notifyUser(reason)
                runScript(reason)
            }
            manualLock = false
        }
    }

    func fakeKeyStrokes(_ string: String) {
        let src = CGEventSource(stateID: .hidSystemState)
        // Send 20 characters per keyboard event. That seems to be the limit.
        let PER = 20
        let uniCharCount = string.utf16.count
        var strIndex = string.utf16.startIndex
        for offset in stride(from: 0, to: uniCharCount, by: PER) {
            let pressEvent = CGEvent(keyboardEventSource: src, virtualKey: 49, keyDown: true)
            let len = offset + PER < uniCharCount ? PER : uniCharCount - offset
            let buffer = UnsafeMutablePointer<UniChar>.allocate(capacity: len)
            defer { buffer.initialize(repeating: 0, count: len); buffer.deallocate() }
            for i in 0..<len {
                buffer[i] = string.utf16[strIndex]
                strIndex = string.utf16.index(after: strIndex)
            }
            pressEvent?.keyboardSetUnicodeString(stringLength: len, unicodeString: buffer)
            pressEvent?.post(tap: .cghidEventTap)
            CGEvent(keyboardEventSource: src, virtualKey: 49, keyDown: false)?.post(tap: .cghidEventTap)
        }
        
        // Return key
        CGEvent(keyboardEventSource: src, virtualKey: 52, keyDown: true)?.post(tap: .cghidEventTap)
        CGEvent(keyboardEventSource: src, virtualKey: 52, keyDown: false)?.post(tap: .cghidEventTap)
    }

    /// False when another user's session is in front (fast user switching): never type a password then.
    func isSessionOnConsole() -> Bool {
        if let dict = CGSessionCopyCurrentDictionary() as? [String : Any],
           let onConsole = dict["kCGSSessionOnConsoleKey"] as? Bool {
            return onConsole
        }
        return true
    }

    func isScreenLocked() -> Bool {
        if let dict = CGSessionCopyCurrentDictionary() as? [String : Any] {
            if let locked = dict["CGSSessionScreenIsLocked"] as? Int {
                return locked == 1
            }
        }
        return false
    }
    
    func tryUnlockScreen() {
        guard unlockEnabled else { return }
        guard !manualLock else { return }
        guard combinedPresence() else { return }
        guard ble.unlockRSSI != ble.UNLOCK_DISABLED else { return }
        guard !systemSleep else { return }
        guard !displaySleep else { return }

        if inScreensaver {
            // In screensaver, make sure Login panel is displayed
            let src = CGEventSource(stateID: .hidSystemState)
            // Esc key down and up
            CGEvent(keyboardEventSource: src, virtualKey: 0x35, keyDown: true)?.post(tap: .cghidEventTap)
            CGEvent(keyboardEventSource: src, virtualKey: 0x35, keyDown: false)?.post(tap: .cghidEventTap)
        }

        guard !self.prefs.bool(forKey: "wakeWithoutUnlocking") else { return }

        let delay = max(0.5, Double(prefs.integer(forKey: "confirmDelay")))
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { _ in
            // Every guard is re-evaluated here, right before typing (see UnlockPolicy).
            guard UnlockPolicy.mayTypePassword(self.currentUnlockContext()) else { return }
            guard self.allowUnlockAttempt() else { return }
            guard let password = self.fetchPassword(warn: true) else { return }

            print("Entering password")
            self.unlockedAt = Date().timeIntervalSince1970
            self.fakeKeyStrokes(password)
            self.playNowPlaying()
            self.runScript("unlocked")
            if self.prefs.bool(forKey: "notifyOnUnlock") {
                deliverNotification(id: unlockNotificationId, subtitle: t("notification_unlocked"), body: "")
            }
        })
    }

    /// Brute-force / lockout protection: if auto-unlock failed several times in a row
    /// (e.g. the stored password is wrong), stop typing it until the user unlocks manually.
    func allowUnlockAttempt() -> Bool {
        let limit = Clamp.maxAttempts(prefs.object(forKey: "maxUnlockAttempts") == nil ? nil : prefs.integer(forKey: "maxUnlockAttempts"))
        switch limiter.request(limit: limit, now: Date().timeIntervalSince1970) {
        case .allowed:
            return true
        case .denied:
            return false
        case .deniedFirstTime:
            print("Too many unlock attempts; auto-unlock paused until manual unlock")
            deliverNotification(id: lockNotificationId, subtitle: t("notification_unlock_paused"), body: t("notification_unlock_paused_info"))
            return false
        }
    }

    func currentUnlockContext() -> UnlockContext {
        return UnlockContext(
            unlockEnabled: unlockEnabled, manualLock: manualLock, presence: combinedPresence(),
            unlockRSSIEnabled: ble.unlockRSSI != ble.UNLOCK_DISABLED, systemSleep: systemSleep,
            displaySleep: displaySleep, wakeWithoutUnlocking: prefs.bool(forKey: "wakeWithoutUnlocking"),
            screenLocked: isScreenLocked(), onConsole: isSessionOnConsole(),
            frontWindowSafe: !(prefs.object(forKey: "verifyFrontWindow") == nil || prefs.bool(forKey: "verifyFrontWindow"))
                || FrontWindowPolicy.isSafe(owner: frontWindowOwner()))
    }

    /// Owner of the front-most large on-screen window (front-to-back order). Reads only window metadata
    /// (owner name, size) — no screen content, no Screen Recording permission.
    func frontWindowOwner() -> String? {
        guard let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else { return nil }
        let screen = NSScreen.main?.frame.size ?? CGSize(width: 800, height: 600)
        for w in list {
            guard let owner = w[kCGWindowOwnerName as String] as? String,
                  let alpha = w[kCGWindowAlpha as String] as? Double, alpha > 0.05,
                  let b = w[kCGWindowBounds as String] as? [String: CGFloat],
                  let width = b["Width"], let height = b["Height"],
                  width >= screen.width * 0.5, height >= screen.height * 0.5 else { continue }
            return owner
        }
        return nil
    }

    @objc func onDisplayWake() {
        print("display wake")
        //unlockedAt = Date().timeIntervalSince1970
        displaySleep = false
        wakeTimer?.invalidate()
        wakeTimer = nil
        tryUnlockScreen()
    }

    @objc func onDisplaySleep() {
        print("display sleep")
        displaySleep = true
    }

    @objc func onSystemWake() {
        print("system wake")
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
            print("delayed system wake job")
            NSApp.setActivationPolicy(.accessory) // Hide Dock icon again
            self.systemSleep = false
            self.tryUnlockScreen()
        })
    }
    
    @objc func onSystemSleep() {
        print("system sleep")
        systemSleep = true
        if prefs.bool(forKey: "lockOnSleep") && !isScreenLocked() {
            // Lid closed / Mac put to sleep: lock now and do not auto-unlock until the user unlocks or the device leaves and returns.
            manualLock = true
            if SACLockScreenImmediate() != 0 { print("Failed to lock screen") }
        }
        // Set activation policy to regular, so the CBCentralManager can scan for peripherals
        // when the Bluetooth will become on again.
        // This enables Dock icon but the screen is off anyway.
        NSApp.setActivationPolicy(.regular)
    }

    @objc func onUnlock() {
        limiter.reset()
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
            print("onUnlock")
            if Date().timeIntervalSince1970 >= self.unlockedAt + 10 {
                if self.ble.unlockRSSI != self.ble.UNLOCK_DISABLED {
                    self.runScript("intruded")
                }
                self.playNowPlaying()
            }
        })
        manualLock = false
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
            checkUpdate()
        })
    }

    @objc func onScreensaverStart() {
        print("screensaver start")
        inScreensaver = true
    }

    @objc func onScreensaverStop() {
        print("screensaver stop")
        inScreensaver = false
    }

    @objc func selectDevice(item: NSMenuItem) {
        for (uuid, menuItem) in deviceDict {
            if menuItem == item {
                monitorDevice(uuid: uuid)
                prefs.set(uuid.uuidString, forKey: "device")
                menuItem.state = .on
            } else {
                menuItem.state = .off
            }
        }
    }

    @objc func selectSecondDevice(item: NSMenuItem) {
        guard let uuid = deviceDict2.first(where: { $0.value == item })?.key, uuid != ble.monitoredUUID else { return }
        startSecondDevice(uuid: uuid)
        prefs.set(uuid.uuidString, forKey: "device2")
        for (_, mi) in deviceDict2 { mi.state = (mi == item) ? .on : .off }
    }

    func startSecondDevice(uuid: UUID) {
        if ble2 == nil {
            let b = BLE()
            let proxy = SecondaryBLEDelegate(owner: self)
            b.delegate = proxy
            proxy2 = proxy
            ble2 = b
            ble.link(b)
        }
        ble2?.startMonitor(uuid: uuid)
        monitorMenuItem2?.title = String(format: "%@: %@", t("device_2"), t("not_detected"))
        monitorMenuItem2?.isHidden = false
    }

    @objc func clearSecondDevice() {
        prefs.removeObject(forKey: "device2")
        ble.follower = nil
        ble2?.shutdown()
        ble2 = nil
        proxy2 = nil
        monitorMenuItem2?.isHidden = true
        rebuildDeviceMenus()
    }

    func monitorDevice(uuid: UUID) {
        connected = false
        statusItem.button?.image = NSImage(named: "StatusBarDisconnected")
        monitorMenuItem?.title = t("not_detected")
        ble.startMonitor(uuid: uuid)
    }

    func errorModal(_ msg: String, info: String? = nil) {
        let alert = NSAlert()
        alert.messageText = msg
        alert.informativeText = info ?? ""
        alert.window.title = "BLEUnlock"
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
    
    var passwordStore: PasswordStore {
        return PasswordStore(service: Bundle.main.bundleIdentifier ?? "BLEUnlock", account: NSUserName())
    }

    func storePassword(_ password: String) {
        do { try passwordStore.store(password) }
        catch PasswordStore.Failure.status(let status) {
            let err = SecCopyErrorMessageString(status, nil)
            errorModal("Failed to store password to Keychain", info: err as String? ?? "Status \(status)")
        } catch {
            errorModal("Failed to store password to Keychain")
        }
    }

    func fetchPassword(warn: Bool = false) -> String? {
        do {
            if let pw = try passwordStore.fetch() { return pw }
            print("Password is not stored")
            if warn { errorModal(t("password_not_set")) }
            return nil
        } catch PasswordStore.Failure.status(let status) {
            let info = SecCopyErrorMessageString(status, nil)
            errorModal("Failed to retrieve password", info: info as String? ?? "Status \(status)")
            return nil
        } catch {
            errorModal("Failed to convert password")
            return nil
        }
    }

    @objc func askPassword() {
        let msg = NSAlert()
        msg.addButton(withTitle: t("ok"))
        msg.addButton(withTitle: t("cancel"))
        msg.messageText = t("enter_password")
        msg.informativeText = t("password_info")
        msg.window.title = "BLEUnlock"

        let txt = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 20))
        msg.accessoryView = txt
        txt.becomeFirstResponder()
        NSApp.activate(ignoringOtherApps: true)
        let response = msg.runModal()
        
        if (response == .alertFirstButtonReturn) {
            let pw = txt.stringValue
            guard !pw.isEmpty else { return }
            storePassword(pw)
        }
    }
    
    @objc func setRSSIThreshold() {
        let msg = NSAlert()
        msg.addButton(withTitle: t("ok"))
        msg.addButton(withTitle: t("cancel"))
        msg.messageText = t("enter_rssi_threshold")
        msg.informativeText = t("enter_rssi_threshold_info")
        msg.window.title = "BLEUnlock"
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 20))
        txt.placeholderString = String(ble.thresholdRSSI)
        msg.accessoryView = txt
        txt.becomeFirstResponder()
        NSApp.activate(ignoringOtherApps: true)
        let response = msg.runModal()
        
        if (response == .alertFirstButtonReturn) {
            let val = max(-100, min(-1, Int(txt.intValue)))
            ble.thresholdRSSI = val
            prefs.set(val, forKey: "thresholdRSSI")
        }
    }

    func deleteStoredPassword() {
        passwordStore.delete()
    }

    func confirm(_ msg: String, info: String, button: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = msg
        alert.informativeText = info
        alert.alertStyle = .warning
        alert.addButton(withTitle: button)
        alert.addButton(withTitle: t("cancel"))
        alert.window.title = "BLEUnlock"
        NSApp.activate(ignoringOtherApps: true)
        return alert.runModal() == .alertFirstButtonReturn
    }

    @objc func removePassword() {
        guard fetchPassword() != nil else { errorModal(t("password_not_set")); return }
        if confirm(t("remove_password_confirm"), info: t("remove_password_info"), button: t("remove")) {
            deleteStoredPassword()
        }
    }

    /// Applies the mode without persisting RSSI changes, so switching back restores the user's settings.
    func applyMode() {
        if unlockEnabled {
            let saved = prefs.integer(forKey: "unlockRSSI")
            ble.unlockRSSI = saved != 0 ? saved : UNLOCK_DEFAULT
        } else {
            ble.unlockRSSI = ble.UNLOCK_DISABLED
        }
        for item in unlockOnlyItems { item.isHidden = !unlockEnabled }
    }

    @objc func setMode(_ menuItem: NSMenuItem) {
        let wantUnlock = menuItem.tag == 0
        guard wantUnlock != unlockEnabled else { return }
        if wantUnlock {
            prefs.set("full", forKey: "mode")
            applyMode()
            checkAccessibility()
            if !prefs.bool(forKey: "wakeWithoutUnlocking") && fetchPassword() == nil { askPassword() }
        } else {
            if fetchPassword() != nil {
                guard confirm(t("lock_only_confirm"), info: t("lock_only_info"), button: t("switch")) else { return }
                deleteStoredPassword()
            }
            prefs.set("lockOnly", forKey: "mode")
            applyMode()
        }
    }

    /// First launch: let the user choose; nothing is stored in Keychain in "lock only" mode.
    func chooseModeIfNeeded() {
        guard prefs.string(forKey: "mode") == nil else { return }
        if fetchPassword() != nil || prefs.string(forKey: "device") != nil {
            prefs.set("full", forKey: "mode")  // existing user: keep current behaviour
            return
        }
        let alert = NSAlert()
        alert.messageText = t("welcome_title")
        alert.informativeText = t("welcome_info")
        alert.addButton(withTitle: t("mode_full"))
        alert.addButton(withTitle: t("mode_lock_only"))
        alert.window.title = "BLEUnlock"
        NSApp.activate(ignoringOtherApps: true)
        prefs.set(alert.runModal() == .alertFirstButtonReturn ? "full" : "lockOnly", forKey: "mode")
    }

    @objc func toggleWakeOnProximity(_ menuItem: NSMenuItem) {
        let value = !prefs.bool(forKey: "wakeOnProximity")
        menuItem.state = value ? .on : .off
        prefs.set(value, forKey: "wakeOnProximity")
    }

    @objc func setLockRSSI(_ menuItem: NSMenuItem) {
        let value = menuItem.tag
        prefs.set(value, forKey: "lockRSSI")
        ble.lockRSSI = value
    }
    
    @objc func setUnlockRSSI(_ menuItem: NSMenuItem) {
        let value = menuItem.tag
        prefs.set(value, forKey: "unlockRSSI")
        if unlockEnabled { ble.unlockRSSI = value }
    }

    @objc func setTimeout(_ menuItem: NSMenuItem) {
        let value = menuItem.tag
        prefs.set(value, forKey: "timeout")
        ble.signalTimeout = Double(value)
    }

    @objc func setLockDelay(_ menuItem: NSMenuItem) {
        let value = menuItem.tag
        prefs.set(value, forKey: "lockDelay")
        ble.proximityTimeout = Double(value)
    }

    @objc func toggleLaunchAtLogin(_ menuItem: NSMenuItem) {
        let launchAtLogin = !prefs.bool(forKey: "launchAtLogin")
        prefs.set(launchAtLogin, forKey: "launchAtLogin")
        menuItem.state = launchAtLogin ? .on : .off
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                errorModal("Failed to change login item", info: error.localizedDescription)
            }
        } else {
            SMLoginItemSetEnabled(Bundle.main.bundleIdentifier! + ".Launcher" as CFString, launchAtLogin)
        }
    }

    @objc func togglePauseNowPlaying(_ menuItem: NSMenuItem) {
        let pauseNowPlaying = !prefs.bool(forKey: "pauseItunes")
        prefs.set(pauseNowPlaying, forKey: "pauseItunes")
        menuItem.state = pauseNowPlaying ? .on : .off
    }
    
    @objc func toggleUseScreensaver(_ menuItem: NSMenuItem) {
        let value = !prefs.bool(forKey: "screensaver")
        prefs.set(value, forKey: "screensaver")
        menuItem.state = value ? .on : .off
    }

    @objc func toggleSleepDisplay(_ menuItem: NSMenuItem) {
        let value = !prefs.bool(forKey: "sleepDisplay")
        prefs.set(value, forKey: "sleepDisplay")
        menuItem.state = value ? .on : .off
    }
    
    @objc func togglePassiveMode(_ menuItem: NSMenuItem) {
        let passiveMode = !prefs.bool(forKey: "passiveMode")
        prefs.set(passiveMode, forKey: "passiveMode")
        menuItem.state = passiveMode ? .on : .off
        ble.setPassiveMode(passiveMode)
    }

    @objc func toggleWakeWithoutUnlocking(_ menuItem: NSMenuItem) {
        let wakeWithoutUnlocking = !prefs.bool(forKey: "wakeWithoutUnlocking")
        prefs.set(wakeWithoutUnlocking, forKey: "wakeWithoutUnlocking")
        menuItem.state = wakeWithoutUnlocking ? .on : .off
    }

    @objc func setConfirmDelay(_ menuItem: NSMenuItem) {
        prefs.set(menuItem.tag, forKey: "confirmDelay")
    }

    @objc func setMaxAttempts(_ menuItem: NSMenuItem) {
        prefs.set(menuItem.tag, forKey: "maxUnlockAttempts")
    }

    @objc func toggleShowRSSI(_ menuItem: NSMenuItem) {
        let value = !prefs.bool(forKey: "showRSSI")
        prefs.set(value, forKey: "showRSSI")
        menuItem.state = value ? .on : .off
        if !value { statusItem.button?.title = "" }
    }

    @objc func toggleNotifyOnUnlock(_ menuItem: NSMenuItem) {
        let value = !prefs.bool(forKey: "notifyOnUnlock")
        prefs.set(value, forKey: "notifyOnUnlock")
        menuItem.state = value ? .on : .off
    }

    @objc func toggleNotifications(_ menuItem: NSMenuItem) {
        let value = !(prefs.object(forKey: "notifications") == nil || prefs.bool(forKey: "notifications"))
        prefs.set(value, forKey: "notifications")
        menuItem.state = value ? .on : .off
    }

    @objc func checkUpdateNow() {
        checkUpdate(force: true)
    }

    @objc func toggleRobustFilter(_ menuItem: NSMenuItem) {
        let value = !prefs.bool(forKey: "robustFilter")
        prefs.set(value, forKey: "robustFilter")
        menuItem.state = value ? .on : .off
        ble.robustFilter = value
    }

    @objc func toggleLockOnSleep(_ menuItem: NSMenuItem) {
        let value = !prefs.bool(forKey: "lockOnSleep")
        prefs.set(value, forKey: "lockOnSleep")
        menuItem.state = value ? .on : .off
    }

    @objc func toggleLockOnBluetoothOff(_ menuItem: NSMenuItem) {
        let value = !prefs.bool(forKey: "lockOnBluetoothOff")
        prefs.set(value, forKey: "lockOnBluetoothOff")
        menuItem.state = value ? .on : .off
    }

    func prompt(_ msg: String, info: String, button: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = msg
        alert.informativeText = info
        alert.alertStyle = .informational
        alert.addButton(withTitle: button)
        alert.addButton(withTitle: t("cancel"))
        alert.window.title = "BLEUnlock"
        NSApp.activate(ignoringOtherApps: true)
        return alert.runModal() == .alertFirstButtonReturn
    }

    /// Calibration assistant: measure the signal where you sit and where the Mac should lock, then suggest thresholds.
    @objc func startCalibration() {
        guard ble.monitoredUUID != nil else { errorModal(t("device_not_set")); return }
        guard prompt(t("calibrate_near_title"), info: t("calibrate_near_info"), button: t("calibrate_start")) else { return }
        measureSignal(seconds: 12) { [weak self] near in
            guard let self = self else { return }
            guard self.prompt(t("calibrate_far_title"), info: t("calibrate_far_info"), button: t("calibrate_start")) else { return }
            self.measureSignal(seconds: 12) { far in self.finishCalibration(near: near, far: far) }
        }
    }

    func measureSignal(seconds: Int, completion: @escaping ([Int]) -> Void) {
        var samples: [Int] = []
        ble.onRawRSSI = { samples.append($0) }
        let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 340, height: 70), styleMask: [.titled], backing: .buffered, defer: false)
        panel.title = "BLEUnlock"
        panel.level = .floating
        let label = NSTextField(labelWithString: "")
        label.alignment = .center
        label.frame = NSRect(x: 10, y: 22, width: 320, height: 24)
        panel.contentView?.addSubview(label)
        panel.center()
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        var remaining = seconds
        label.stringValue = String(format: t("measuring"), remaining)
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] tm in
            remaining -= 1
            if remaining > 0 {
                label.stringValue = String(format: t("measuring"), remaining)
                return
            }
            tm.invalidate()
            self?.ble.onRawRSSI = nil
            panel.close()
            completion(samples)
        }
        RunLoop.main.add(timer, forMode: .common)
    }

    func finishCalibration(near: [Int], far: [Int]) {
        do {
            let r = try Calibration.propose(near: near, far: far, throwing: ())
            let info = String(format: t("calibrate_result_info"), r.unlockRSSI, r.lockRSSI, r.nearMedian, r.farMedian)
            guard prompt(t("calibrate_result_title"), info: info, button: t("apply")) else { return }
            prefs.set(r.lockRSSI, forKey: "lockRSSI")
            ble.lockRSSI = r.lockRSSI
            prefs.set(r.unlockRSSI, forKey: "unlockRSSI")
            if unlockEnabled { ble.unlockRSSI = r.unlockRSSI }
        } catch Calibration.Failure.notEnoughSamples {
            errorModal(t("calibrate_no_signal"))
        } catch {
            errorModal(t("calibrate_inseparable"))
        }
    }

    @objc func toggleVerifyFrontWindow(_ menuItem: NSMenuItem) {
        let value = !(prefs.object(forKey: "verifyFrontWindow") == nil || prefs.bool(forKey: "verifyFrontWindow"))
        prefs.set(value, forKey: "verifyFrontWindow")
        menuItem.state = value ? .on : .off
    }

    @objc func toggleAutoUpdates(_ menuItem: NSMenuItem) {
        let value = !prefs.bool(forKey: "updateChecks")
        prefs.set(value, forKey: "updateChecks")
        menuItem.state = value ? .on : .off
    }

    @objc func openPrivacy() {
        NSWorkspace.shared.open(URL(string: "https://github.com/\(repoSlug)/blob/master/PRIVACY.md")!)
    }

    /// GDPR right to erasure: removes the Keychain password, all settings and the login item, then quits.
    @objc func eraseAllData() {
        guard confirm(t("erase_data_confirm"), info: t("erase_data_info"), button: t("erase")) else { return }
        deleteStoredPassword()
        if #available(macOS 13.0, *) { try? SMAppService.mainApp.unregister() }
        else { SMLoginItemSetEnabled(Bundle.main.bundleIdentifier! + ".Launcher" as CFString, false) }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        if let id = Bundle.main.bundleIdentifier { prefs.removePersistentDomain(forName: id) }
        prefs.synchronize()
        NSApp.terminate(nil)
    }

    /// First launch: automatic update checks contact GitHub (IP address is transmitted), so they are opt-in.
    func askUpdateConsentIfNeeded() {
        guard prefs.object(forKey: "updateChecks") == nil else { return }
        let alert = NSAlert()
        alert.messageText = t("update_consent_title")
        alert.informativeText = t("update_consent_info")
        alert.addButton(withTitle: t("no_thanks"))
        alert.addButton(withTitle: t("allow"))
        alert.window.title = "BLEUnlock"
        NSApp.activate(ignoringOtherApps: true)
        prefs.set(alert.runModal() == .alertSecondButtonReturn, forKey: "updateChecks")
    }

    @objc func openReleases() {
        NSWorkspace.shared.open(releasesURL)
    }

    /// Reliable feedback for update checks: a menu item for automatic checks and an alert for manual ones
    /// (notifications alone can be silently disabled by the user or by macOS).
    func handleUpdateResult(latest: String?, manual: Bool, failed: Bool) {
        if let v = latest {
            updateMenuItem?.title = String(format: t("update_menu"), v)
            updateMenuItem?.isHidden = false
        }
        guard manual else { return }
        let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let alert = NSAlert()
        alert.window.title = "BLEUnlock"
        if failed {
            alert.messageText = t("update_check_failed")
            alert.addButton(withTitle: t("ok"))
        } else if let v = latest {
            alert.messageText = t("notification_update_available")
            alert.informativeText = String(format: t("update_available_info"), v, current)
            alert.addButton(withTitle: t("download"))
            alert.addButton(withTitle: t("later"))
        } else {
            alert.messageText = t("up_to_date")
            alert.informativeText = current
            alert.addButton(withTitle: t("ok"))
        }
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn && latest != nil { openReleases() }
    }

    @objc func lockNow() {
        guard !isScreenLocked() else { return }
        manualLock = true
        pauseNowPlaying()
        lockOrSaveScreen()
    }
    
    @objc func showAboutBox() {
        AboutBox.showAboutBox()
    }

    func constructRSSIMenu(_ menu: NSMenu, _ action: Selector) {
        menu.addItem(withTitle: t("closer"), action: nil, keyEquivalent: "")
        for proximity in stride(from: -30, to: -100, by: -5) {
            let item = menu.addItem(withTitle: String(format: "%ddBm", proximity), action: action, keyEquivalent: "")
            item.tag = proximity
        }
        menu.addItem(withTitle: t("farther"), action: nil, keyEquivalent: "")
        menu.delegate = self
    }

    func symbol(_ item: NSMenuItem, _ name: String) {
        if #available(macOS 11.0, *) {
            item.image = NSImage(systemSymbolName: name, accessibilityDescription: nil)
        }
    }

    @discardableResult
    func add(_ menu: NSMenu, _ title: String, _ action: Selector?, symbol name: String? = nil, state: Bool? = nil, tag: Int = 0) -> NSMenuItem {
        let item = menu.addItem(withTitle: title, action: action, keyEquivalent: "")
        item.tag = tag
        if let n = name { symbol(item, n) }
        if let st = state { item.state = st ? .on : .off }
        return item
    }

    func submenu(_ title: String, _ icon: String, _ menu: NSMenu) -> NSMenuItem {
        let item = mainMenu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        item.submenu = menu
        symbol(item, icon)
        return item
    }

    func constructMenu() {
        let on: (String) -> Bool = { self.prefs.bool(forKey: $0) }
        let notifOn = prefs.object(forKey: "notifications") == nil || prefs.bool(forKey: "notifications")

        monitorMenuItem = mainMenu.addItem(withTitle: t("device_not_set"), action: nil, keyEquivalent: "")
        symbol(monitorMenuItem!, "antenna.radiowaves.left.and.right")
        add(mainMenu, t("lock_now"), #selector(lockNow), symbol: "lock.fill")
        mainMenu.addItem(NSMenuItem.separator())

        // Device
        _ = submenu(t("device"), "iphone", deviceMenu)
        deviceMenu.delegate = self
        rebuildDeviceMenus()

        let secondItem = mainMenu.addItem(withTitle: t("second_device"), action: nil, keyEquivalent: "")
        secondItem.submenu = device2Menu
        symbol(secondItem, "applewatch")
        device2Menu.delegate = self
        rebuildDeviceMenus()
        monitorMenuItem2 = mainMenu.addItem(withTitle: "", action: nil, keyEquivalent: "")
        symbol(monitorMenuItem2!, "applewatch")
        monitorMenuItem2?.isHidden = true

        // Mode
        _ = submenu(t("mode"), "lock.shield", modeMenu)
        add(modeMenu, t("mode_full"), #selector(setMode), tag: 0)
        add(modeMenu, t("mode_lock_only"), #selector(setMode), tag: 1)
        modeMenu.delegate = self

        mainMenu.addItem(NSMenuItem.separator())

        // Proximity
        let proximityMenu = NSMenu()
        _ = submenu(t("proximity"), "dot.radiowaves.left.and.right", proximityMenu)

        let unlockRSSIItem = add(proximityMenu, t("unlock_rssi"), nil, symbol: "lock.open")
        unlockRSSIItem.submenu = unlockRSSIMenu
        add(unlockRSSIMenu, t("disabled"), #selector(setUnlockRSSI), tag: ble.UNLOCK_DISABLED)
        constructRSSIMenu(unlockRSSIMenu, #selector(setUnlockRSSI))
        unlockOnlyItems.append(unlockRSSIItem)

        let lockRSSIItem = add(proximityMenu, t("lock_rssi"), nil, symbol: "lock")
        lockRSSIItem.submenu = lockRSSIMenu
        constructRSSIMenu(lockRSSIMenu, #selector(setLockRSSI))
        add(lockRSSIMenu, t("disabled"), #selector(setLockRSSI), tag: ble.LOCK_DISABLED)

        let lockDelayItem = add(proximityMenu, t("lock_delay"), nil, symbol: "timer")
        lockDelayItem.submenu = lockDelayMenu
        for (n, unit, sec) in [(2, "seconds", 2), (5, "seconds", 5), (15, "seconds", 15), (30, "seconds", 30), (1, "minute", 60), (2, "minutes", 120), (5, "minutes", 300)] {
            add(lockDelayMenu, "\(n) " + t(unit), #selector(setLockDelay), tag: sec)
        }
        lockDelayMenu.delegate = self

        let timeoutItem = add(proximityMenu, t("timeout"), nil, symbol: "wifi.slash")
        timeoutItem.submenu = timeoutMenu
        for (n, unit, sec) in [(30, "seconds", 30), (1, "minute", 60), (2, "minutes", 120), (5, "minutes", 300), (10, "minutes", 600)] {
            add(timeoutMenu, "\(n) " + t(unit), #selector(setTimeout), tag: sec)
        }
        timeoutMenu.delegate = self

        let confirmItem = add(proximityMenu, t("confirm_delay"), nil, symbol: "hourglass")
        confirmItem.submenu = confirmDelayMenu
        add(confirmDelayMenu, t("immediate"), #selector(setConfirmDelay), tag: 0)
        for sec in [2, 3, 5, 10] { add(confirmDelayMenu, "\(sec) " + t("seconds"), #selector(setConfirmDelay), tag: sec) }
        confirmDelayMenu.delegate = self
        unlockOnlyItems.append(confirmItem)

        proximityMenu.addItem(NSMenuItem.separator())
        add(proximityMenu, t("calibrate"), #selector(startCalibration), symbol: "scope")
        add(proximityMenu, t("robust_filter"), #selector(toggleRobustFilter), symbol: "waveform.path.ecg", state: on("robustFilter"))
        add(proximityMenu, t("set_rssi_threshold"), #selector(setRSSIThreshold), symbol: "slider.horizontal.3")

        // Security
        let securityMenu = NSMenu()
        _ = submenu(t("security"), "lock.shield.fill", securityMenu)

        let setPw = add(securityMenu, t("set_password"), #selector(askPassword), symbol: "key.fill")
        let rmPw = add(securityMenu, t("remove_password"), #selector(removePassword), symbol: "trash")
        let attemptsItem = add(securityMenu, t("max_unlock_attempts"), nil, symbol: "exclamationmark.shield")
        attemptsItem.submenu = maxAttemptsMenu
        add(maxAttemptsMenu, t("unlimited"), #selector(setMaxAttempts), tag: 0)
        for n in [1, 2, 3, 5] { add(maxAttemptsMenu, "\(n)", #selector(setMaxAttempts), tag: n) }
        maxAttemptsMenu.delegate = self
        let wakeNoUnlock = add(securityMenu, t("wake_without_unlocking"), #selector(toggleWakeWithoutUnlocking), symbol: "moon.zzz", state: on("wakeWithoutUnlocking"))
        let verifyItem = add(securityMenu, t("verify_front_window"), #selector(toggleVerifyFrontWindow), symbol: "checkmark.shield", state: prefs.object(forKey: "verifyFrontWindow") == nil || prefs.bool(forKey: "verifyFrontWindow"))
        unlockOnlyItems += [setPw, rmPw, attemptsItem, wakeNoUnlock, verifyItem]
        securityMenu.addItem(NSMenuItem.separator())
        add(securityMenu, t("erase_data"), #selector(eraseAllData), symbol: "xmark.bin")

        // Options
        let optionsMenu = NSMenu()
        _ = submenu(t("options"), "gearshape", optionsMenu)
        let wakeProx = add(optionsMenu, t("wake_on_proximity"), #selector(toggleWakeOnProximity), symbol: "sun.max", state: on("wakeOnProximity"))
        unlockOnlyItems.append(wakeProx)
        add(optionsMenu, t("pause_now_playing"), #selector(togglePauseNowPlaying), symbol: "pause.circle", state: on("pauseItunes"))
        add(optionsMenu, t("use_screensaver_to_lock"), #selector(toggleUseScreensaver), symbol: "display", state: on("screensaver"))
        add(optionsMenu, t("sleep_display"), #selector(toggleSleepDisplay), symbol: "moon", state: on("sleepDisplay"))
        add(optionsMenu, t("lock_on_sleep"), #selector(toggleLockOnSleep), symbol: "laptopcomputer", state: on("lockOnSleep"))
        add(optionsMenu, t("lock_on_bt_off"), #selector(toggleLockOnBluetoothOff), symbol: "bolt.horizontal.circle", state: on("lockOnBluetoothOff"))
        add(optionsMenu, t("passive_mode"), #selector(togglePassiveMode), symbol: "eye.slash", state: on("passiveMode"))
        optionsMenu.addItem(NSMenuItem.separator())
        add(optionsMenu, t("notifications"), #selector(toggleNotifications), symbol: "bell", state: notifOn)
        let notifyUnlock = add(optionsMenu, t("notify_on_unlock"), #selector(toggleNotifyOnUnlock), symbol: "bell.badge", state: on("notifyOnUnlock"))
        unlockOnlyItems.append(notifyUnlock)
        add(optionsMenu, t("automatic_updates"), #selector(toggleAutoUpdates), symbol: "arrow.triangle.2.circlepath", state: on("updateChecks"))
        add(optionsMenu, t("show_rssi_in_menubar"), #selector(toggleShowRSSI), symbol: "number", state: on("showRSSI"))
        add(optionsMenu, t("launch_at_login"), #selector(toggleLaunchAtLogin), symbol: "power.circle", state: on("launchAtLogin"))

        mainMenu.addItem(NSMenuItem.separator())
        let upd = add(mainMenu, "", #selector(openReleases), symbol: "arrow.down.circle.fill")
        upd.isHidden = true
        updateMenuItem = upd
        add(mainMenu, t("check_for_updates"), #selector(checkUpdateNow), symbol: "arrow.triangle.2.circlepath")
        add(mainMenu, t("about"), #selector(showAboutBox), symbol: "info.circle")
        add(mainMenu, t("privacy_policy"), #selector(openPrivacy), symbol: "hand.raised")
        mainMenu.addItem(NSMenuItem.separator())
        add(mainMenu, t("quit"), #selector(NSApplication.terminate(_:)), symbol: "xmark.circle")
        statusItem.menu = mainMenu
    }

    func checkAccessibility() {
        let key = kAXTrustedCheckOptionPrompt.takeRetainedValue() as String
        if (!AXIsProcessTrustedWithOptions([key: true] as CFDictionary)) {
            // Sometimes Prompt option above doesn't work.
            // Actually trying to send key may open that dialog.
            let src = CGEventSource(stateID: .hidSystemState)
            // "Fn" key down and up
            CGEvent(keyboardEventSource: src, virtualKey: 63, keyDown: true)?.post(tap: .cghidEventTap)
            CGEvent(keyboardEventSource: src, virtualKey: 63, keyDown: false)?.post(tap: .cghidEventTap)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarDisconnected")
            constructMenu()
        }
        ble.delegate = self
        updateResultHandler = { [weak self] latest, manual, failed in self?.handleUpdateResult(latest: latest, manual: manual, failed: failed) }
        chooseModeIfNeeded()
        askUpdateConsentIfNeeded()
        if let str = prefs.string(forKey: "device") {
            if let uuid = UUID(uuidString: str) {
                monitorDevice(uuid: uuid)
            }
        }
        let lockRSSI = prefs.integer(forKey: "lockRSSI")
        if lockRSSI != 0 {
            ble.lockRSSI = lockRSSI
        }
        let unlockRSSI = prefs.integer(forKey: "unlockRSSI")
        if unlockRSSI != 0 {
            ble.unlockRSSI = unlockRSSI
        }
        applyMode()
        let timeout = prefs.integer(forKey: "timeout")
        if timeout != 0 {
            ble.signalTimeout = Double(max(30, min(600, timeout)))
        }
        ble.setPassiveMode(prefs.bool(forKey: "passiveMode"))
        ble.robustFilter = prefs.bool(forKey: "robustFilter")
        let thresholdRSSI = prefs.integer(forKey: "thresholdRSSI")
        if thresholdRSSI != 0 {
            ble.thresholdRSSI = max(-100, min(-1, thresholdRSSI))
        }
        let lockDelay = prefs.integer(forKey: "lockDelay")
        if lockDelay != 0 {
            ble.proximityTimeout = Double(max(2, min(300, lockDelay)))
        }

        if let str2 = prefs.string(forKey: "device2"), let uuid2 = UUID(uuidString: str2), uuid2 != ble.monitoredUUID {
            startSecondDevice(uuid: uuid2)
        }
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        let nc = NSWorkspace.shared.notificationCenter;
        nc.addObserver(self, selector: #selector(onDisplaySleep), name: NSWorkspace.screensDidSleepNotification, object: nil)
        nc.addObserver(self, selector: #selector(onDisplayWake), name: NSWorkspace.screensDidWakeNotification, object: nil)
        nc.addObserver(self, selector: #selector(onSystemSleep), name: NSWorkspace.willSleepNotification, object: nil)
        nc.addObserver(self, selector: #selector(onSystemWake), name: NSWorkspace.didWakeNotification, object: nil)

        let dnc = DistributedNotificationCenter.default
        dnc.addObserver(self, selector: #selector(onUnlock), name: NSNotification.Name(rawValue: "com.apple.screenIsUnlocked"), object: nil)
        dnc.addObserver(self, selector: #selector(onScreensaverStart), name: NSNotification.Name(rawValue: "com.apple.screensaver.didstart"), object: nil)
        dnc.addObserver(self, selector: #selector(onScreensaverStop), name: NSNotification.Name(rawValue: "com.apple.screensaver.didstop"), object: nil)

        if unlockEnabled {
            if !prefs.bool(forKey: "wakeWithoutUnlocking") && fetchPassword() == nil {
                askPassword()
            }
            checkAccessibility()  // only needed to type the password: lock-only mode asks for no permission
        }
        checkUpdate()

        // Hide dock icon.
        // This is required because we can't have LSUIElement set to true in Info.plist,
        // otherwise CBCentralManager.scanForPeripherals won't work.
        NSApp.setActivationPolicy(.accessory)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
}


/// Delegate of the second BLE instance: forwards presence and signal to the app; ignores device-list callbacks.
final class SecondaryBLEDelegate: BLEDelegate {
    weak var owner: AppDelegate?
    init(owner: AppDelegate) { self.owner = owner }
    func newDevice(device: Device) {}
    func updateDevice(device: Device) {}
    func removeDevice(device: Device) {}
    func updateRSSI(rssi: Int?, active: Bool) { owner?.updateRSSI2(rssi: rssi) }
    func updatePresence(presence: Bool, reason: String) { owner?.handlePresence(presence, reason) }
    func bluetoothPowerWarn() {}
    func bluetoothStateChanged(on: Bool) {}
}
