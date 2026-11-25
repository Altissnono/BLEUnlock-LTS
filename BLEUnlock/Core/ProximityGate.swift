import Foundation

/// Apple Watch / iPhone RSSI is very noisy: readings were observed to jump by 25–30 dB between two
/// consecutive samples (e.g. -40 then -69). Two small guards make decisions robust against that.

/// "Close" (→ possible unlock) requires at least 2 of the last 3 raw readings at or above the threshold,
/// so a single spike can never unlock the Mac.
struct CloseGate {
    private(set) var recent: [Int] = []

    mutating func add(_ rssi: Int) {
        recent.append(rssi)
        if recent.count > 3 { recent.removeFirst() }
    }
    func isClose(threshold: Int) -> Bool {
        return recent.count >= 2 && recent.filter { $0 >= threshold }.count >= 2
    }
    mutating func reset() { recent.removeAll() }
}

enum LockTimerPolicy {
    /// dB the filtered signal must rise ABOVE the lock threshold to cancel a pending lock.
    /// Without it, a signal hovering around the threshold keeps cancelling the lock and the Mac never locks.
    static let recoveryMargin = 5

    static func shouldCancel(estimated: Int, lockThreshold: Int) -> Bool {
        return estimated >= lockThreshold + recoveryMargin
    }
    /// Starting the timer uses the plain threshold.
    static func shouldStart(estimated: Int, lockThreshold: Int) -> Bool {
        return estimated < lockThreshold
    }
}
