import Foundation

/// Pure decision: may the password be typed right now? Every condition must hold.
struct UnlockContext {
    var unlockEnabled: Bool
    var manualLock: Bool
    var presence: Bool
    var unlockRSSIEnabled: Bool
    var systemSleep: Bool
    var displaySleep: Bool
    var wakeWithoutUnlocking: Bool
    var screenLocked: Bool
    var onConsole: Bool
    var frontWindowSafe: Bool
}

enum UnlockPolicy {
    static func mayTypePassword(_ c: UnlockContext) -> Bool {
        return c.unlockEnabled && !c.manualLock && c.presence && c.unlockRSSIEnabled
            && !c.systemSleep && !c.displaySleep && !c.wakeWithoutUnlocking
            && c.screenLocked && c.onConsole && c.frontWindowSafe
    }
}

/// Which application owns the front‑most large window when the password is about to be typed.
/// While the Mac is locked it must be the login window / screen saver; if a normal app is in front
/// (the screen was unlocked meanwhile, or something stole focus) the password must NOT be typed.
enum FrontWindowPolicy {
    static let safeOwners: Set<String> = ["loginwindow", "ScreenSaverEngine", "SecurityAgent", "UserNotificationCenter", "Window Server"]

    /// `owner == nil` means "could not determine": allowed (fail-open) because the other guards still apply.
    static func isSafe(owner: String?) -> Bool {
        guard let o = owner else { return true }
        return safeOwners.contains(o)
    }
}
