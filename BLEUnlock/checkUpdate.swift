import Cocoa
import UserNotifications

let repoSlug = "Altissnono/BLEUnlock-LTS"
let releasesURL = URL(string: "https://github.com/\(repoSlug)/releases")!
let lockNotificationId = "ble.lock"
let unlockNotificationId = "ble.unlock"
let updateNotificationId = "ble.update"

private let KEY = "lastUpdateCheck"
private let INTERVAL = 24.0 * 60 * 60
private var notified = false
private var lastCheckAt = UserDefaults.standard.double(forKey: KEY)

func deliverNotification(id: String, subtitle: String, body: String, delay: TimeInterval = 1) {
    let content = UNMutableNotificationContent()
    content.title = "BLEUnlock"
    content.subtitle = subtitle
    content.body = body
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(delay, 1), repeats: false)
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

func checkUpdate(force: Bool = false) {
    if !force {
        guard !notified else { return }
        let now = NSDate().timeIntervalSince1970
        guard now - lastCheckAt >= INTERVAL else { return }
    }
    doCheckUpdate(force: force)
}

private func doCheckUpdate(force: Bool) {
    var request = URLRequest(url: URL(string: "https://api.github.com/repos/\(repoSlug)/releases/latest")!)
    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    request.timeoutInterval = 15
    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
        guard let jsondata = data,
              let dict = (try? JSONSerialization.jsonObject(with: jsondata)) as? [String: Any],
              let version = dict["tag_name"] as? String,
              version.range(of: #"^v?\d+(\.\d+){0,3}(-[0-9A-Za-z.]+)?$"#, options: .regularExpression) != nil else {
            if force { DispatchQueue.main.async { deliverNotification(id: updateNotificationId, subtitle: t("update_check_failed"), body: "") } }
            return
        }
        lastCheckAt = NSDate().timeIntervalSince1970
        UserDefaults.standard.set(lastCheckAt, forKey: KEY)
        DispatchQueue.main.async { compareVersionsAndNotify(version, force: force) }
    })
    task.resume()
}

private func normalize(_ v: String) -> [Int] {
    return v.trimmingCharacters(in: CharacterSet(charactersIn: "vV")).split(separator: "-")[0]
        .split(separator: ".").map { Int($0) ?? 0 }
}

private func isNewer(_ latest: String, than current: String) -> Bool {
    let a = normalize(latest), b = normalize(current)
    for i in 0..<max(a.count, b.count) {
        let x = i < a.count ? a[i] : 0, y = i < b.count ? b[i] : 0
        if x != y { return x > y }
    }
    return false
}

private func compareVersionsAndNotify(_ latestVersion: String, force: Bool) {
    guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return }
    if isNewer(latestVersion, than: version) {
        deliverNotification(id: updateNotificationId, subtitle: t("notification_update_available"), body: latestVersion)
        notified = true
    } else if force {
        deliverNotification(id: updateNotificationId, subtitle: t("up_to_date"), body: version)
    }
}
