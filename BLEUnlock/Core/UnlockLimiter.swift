import Foundation

/// Brute-force / lockout protection: if auto-unlock fails several times in a row (e.g. the stored password
/// is wrong) stop typing it until the user unlocks manually. `limit <= 0` means unlimited.
struct UnlockLimiter {
    enum Decision: Equatable { case allowed, denied, deniedFirstTime }

    var window: TimeInterval = 120
    private(set) var attempts: [TimeInterval] = []

    mutating func request(limit: Int, now: TimeInterval) -> Decision {
        guard limit > 0 else { return .allowed }
        attempts = attempts.filter { now - $0 < window }
        if attempts.count >= limit {
            if attempts.count == limit {
                attempts.append(now)          // marks "already notified"
                return .deniedFirstTime
            }
            return .denied
        }
        attempts.append(now)
        return .allowed
    }

    mutating func reset() { attempts.removeAll() }
}
