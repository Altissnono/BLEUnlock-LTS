import Cocoa
import UserNotifications
import os

let repoSlug = "Altissnono/BLEUnlock-LTS"
let releasesURL = URL(string: "https://github.com/\(repoSlug)/releases")!
let lockNotificationId = "ble.lock"
let unlockNotificationId = "ble.unlock"
let updateNotificationId = "ble.update"

private let KEY = "lastUpdateCheck"
private let INTERVAL = 24.0 * 60 * 60
private var notified = false
private var lastCheckAt = UserDefaults.standard.double(forKey: KEY)

/// Called on the main queue: (latestVersion if newer, isManualCheck, failed)
var updateResultHandler: ((String?, Bool, Bool) -> Void)?

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
        // Privacy: automatic (unprompted) network access happens only if the user opted in.
        guard UserDefaults.standard.bool(forKey: "updateChecks") else { return }
        guard !notified else { return }
        let now = NSDate().timeIntervalSince1970
        guard now - lastCheckAt >= INTERVAL else { return }
    }
    doCheckUpdate(force: force)
}

/// Refuses every HTTP redirect: the only host ever contacted is api.github.com.
private final class NoRedirect: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}
private let noRedirect = NoRedirect()

private let updateSession: URLSession = {
    // Ephemeral: no cookies, no disk cache, no credentials storage; nothing persisted about the request.
    let cfg = URLSessionConfiguration.ephemeral
    cfg.httpCookieStorage = nil
    cfg.urlCache = nil
    cfg.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    cfg.timeoutIntervalForRequest = 15
    cfg.timeoutIntervalForResource = 30
    cfg.waitsForConnectivity = false
    cfg.httpAdditionalHeaders = ["User-Agent": "BLEUnlock-LTS", "Accept": "application/vnd.github+json"]
    return URLSession(configuration: cfg, delegate: noRedirect, delegateQueue: nil)
}()

private func doCheckUpdate(force: Bool) {
    let url = URL(string: "https://api.github.com/repos/\(repoSlug)/releases/latest")!
    let task = updateSession.dataTask(with: URLRequest(url: url), completionHandler: { data, response, error in
        guard let http = response as? HTTPURLResponse, http.statusCode == 200,
              http.url?.host == "api.github.com",
              let jsondata = data, jsondata.count < 1_000_000,
              let dict = (try? JSONSerialization.jsonObject(with: jsondata)) as? [String: Any],
              let version = dict["tag_name"] as? String,
              isValidReleaseTag(version) else {
            DispatchQueue.main.async { updateResultHandler?(nil, force, true) }
            return
        }
        lastCheckAt = NSDate().timeIntervalSince1970
        UserDefaults.standard.set(lastCheckAt, forKey: KEY)
        DispatchQueue.main.async { compareVersionsAndNotify(version, force: force) }
    })
    task.resume()
}

private func compareVersionsAndNotify(_ latestVersion: String, force: Bool) {
    guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return }
    if isNewer(latestVersion, than: version) {
        if !notified {
            deliverNotification(id: updateNotificationId, subtitle: t("notification_update_available"), body: latestVersion)
        }
        notified = true
        updateResultHandler?(latestVersion, force, false)
    } else {
        updateResultHandler?(nil, force, false)
    }
}

#if !DEBUG
/// Release builds: no console logging (avoids leaking state into system logs).
@inline(__always) func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {}
#endif

/// Local diagnostics via the macOS unified log (Console.app / `log show`). Stays on this Mac.
/// Contains only signal numbers and decisions — never device names/identifiers, passwords or personal data.
let diagLog = Logger(subsystem: "io.github.altissnono.BLEUnlock", category: "presence")
