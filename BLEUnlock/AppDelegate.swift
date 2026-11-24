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
    var unlockAttempts: [TimeInterval] = []
    let confirmDelayMenu = NSMenu()
    let modeMenu = NSMenu()
    var unlockOnlyItems: [NSMenuItem] = []
    var updateMenuItem: NSMenuItem?
    let UNLOCK_DEFAULT = -60

    /// "full" = lock and unlock (password stored in Keychain), "lockOnly" = never stores a password.
    var unlockEnabled: Bool { return prefs.string(forKey: "mode") != "lockOnly" }
    let maxAttemptsMenu = NSMenu()

    func menuWillOpen(_ menu: NSMenu) {
        if menu == deviceMenu {
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
        if menu == deviceMenu {
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
    
    func newDevice(device: Device) {
        let menuItem = deviceMenu.addItem(withTitle: menuItemTitle(device: device), action:#selector(selectDevice), keyEquivalent: "")
        deviceDict[device.uuid] = menuItem
        if (device.uuid == ble.monitoredUUID) {
            menuItem.state = .on
        }
    }
    
    func updateDevice(device: Device) {
        if let menu = deviceDict[device.uuid] {
            menu.title = menuItemTitle(device: device)
        }
    }
    
    func removeDevice(device: Device) {
        if let menuItem = deviceDict[device.uuid] {
            menuItem.menu?.removeItem(menuItem)
        }
        deviceDict.removeValue(forKey: device.uuid)
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
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: file.path),
              attrs[.type] as? FileAttributeType == .typeRegular,
              (attrs[.ownerAccountID] as? NSNumber)?.uint32Value == getuid(),
              let perms = attrs[.posixPermissions] as? NSNumber,
              perms.intValue & 0o022 == 0 else {
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
        guard ble.presence else { return }
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
            guard self.unlockEnabled, self.isScreenLocked(), self.isSessionOnConsole() else { return }
            // Re-check presence after the confirmation delay: the device must still be near.
            guard self.ble.presence else { return }
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
        let limit = prefs.object(forKey: "maxUnlockAttempts") == nil ? 3 : prefs.integer(forKey: "maxUnlockAttempts")
        guard limit > 0 else { return true }
        let now = Date().timeIntervalSince1970
        unlockAttempts = unlockAttempts.filter { now - $0 < 120 }
        if unlockAttempts.count >= limit {
            print("Too many unlock attempts; auto-unlock paused until manual unlock")
            if unlockAttempts.count == limit {
                unlockAttempts.append(now)
                deliverNotification(id: lockNotificationId, subtitle: t("notification_unlock_paused"), body: t("notification_unlock_paused_info"))
            }
            return false
        }
        unlockAttempts.append(now)
        return true
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
        // Set activation policy to regular, so the CBCentralManager can scan for peripherals
        // when the Bluetooth will become on again.
        // This enables Dock icon but the screen is off anyway.
        NSApp.setActivationPolicy(.regular)
    }

    @objc func onUnlock() {
        unlockAttempts.removeAll()
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
    
    func storePassword(_ password: String) {
        let pw = password.data(using: .utf8)!
        
        let query: [String: Any] = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrAccount): NSUserName(),
            String(kSecAttrService): Bundle.main.bundleIdentifier ?? "BLEUnlock",
            String(kSecAttrLabel): "BLEUnlock",
            String(kSecValueData): pw,
            String(kSecAttrAccessible): kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            let err = SecCopyErrorMessageString(status, nil)
            errorModal("Failed to store password to Keychain", info: err as String? ?? "Status \(status)")
            return
        }
    }

    func fetchPassword(warn: Bool = false) -> String? {
        let query: [String: Any] = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrAccount): NSUserName(),
            String(kSecAttrService): Bundle.main.bundleIdentifier ?? "BLEUnlock",
            String(kSecReturnData): kCFBooleanTrue!,
            String(kSecMatchLimit): kSecMatchLimitOne,
        ]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if (status == errSecItemNotFound) {
            print("Password is not stored")
            if warn {
                errorModal(t("password_not_set"))
            }
            return nil
        }
        guard status == errSecSuccess else {
            let info = SecCopyErrorMessageString(status, nil)
            errorModal("Failed to retrieve password", info: info as String? ?? "Status \(status)")
            return nil
        }
        guard let data = item as? Data else {
            errorModal("Failed to convert password")
            return nil
        }
        return String(data: data, encoding: .utf8)
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
        let query: [String: Any] = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrAccount): NSUserName(),
            String(kSecAttrService): Bundle.main.bundleIdentifier ?? "BLEUnlock",
        ]
        SecItemDelete(query as CFDictionary)
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
        deviceMenu.addItem(withTitle: t("scanning"), action: nil, keyEquivalent: "")

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
        unlockOnlyItems += [setPw, rmPw, attemptsItem, wakeNoUnlock]

        // Options
        let optionsMenu = NSMenu()
        _ = submenu(t("options"), "gearshape", optionsMenu)
        let wakeProx = add(optionsMenu, t("wake_on_proximity"), #selector(toggleWakeOnProximity), symbol: "sun.max", state: on("wakeOnProximity"))
        unlockOnlyItems.append(wakeProx)
        add(optionsMenu, t("pause_now_playing"), #selector(togglePauseNowPlaying), symbol: "pause.circle", state: on("pauseItunes"))
        add(optionsMenu, t("use_screensaver_to_lock"), #selector(toggleUseScreensaver), symbol: "display", state: on("screensaver"))
        add(optionsMenu, t("sleep_display"), #selector(toggleSleepDisplay), symbol: "moon", state: on("sleepDisplay"))
        add(optionsMenu, t("passive_mode"), #selector(togglePassiveMode), symbol: "eye.slash", state: on("passiveMode"))
        optionsMenu.addItem(NSMenuItem.separator())
        add(optionsMenu, t("notifications"), #selector(toggleNotifications), symbol: "bell", state: notifOn)
        let notifyUnlock = add(optionsMenu, t("notify_on_unlock"), #selector(toggleNotifyOnUnlock), symbol: "bell.badge", state: on("notifyOnUnlock"))
        unlockOnlyItems.append(notifyUnlock)
        add(optionsMenu, t("show_rssi_in_menubar"), #selector(toggleShowRSSI), symbol: "number", state: on("showRSSI"))
        add(optionsMenu, t("launch_at_login"), #selector(toggleLaunchAtLogin), symbol: "power.circle", state: on("launchAtLogin"))

        mainMenu.addItem(NSMenuItem.separator())
        let upd = add(mainMenu, "", #selector(openReleases), symbol: "arrow.down.circle.fill")
        upd.isHidden = true
        updateMenuItem = upd
        add(mainMenu, t("check_for_updates"), #selector(checkUpdateNow), symbol: "arrow.triangle.2.circlepath")
        add(mainMenu, t("about"), #selector(showAboutBox), symbol: "info.circle")
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
        let thresholdRSSI = prefs.integer(forKey: "thresholdRSSI")
        if thresholdRSSI != 0 {
            ble.thresholdRSSI = max(-100, min(-1, thresholdRSSI))
        }
        let lockDelay = prefs.integer(forKey: "lockDelay")
        if lockDelay != 0 {
            ble.proximityTimeout = Double(max(2, min(300, lockDelay)))
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
