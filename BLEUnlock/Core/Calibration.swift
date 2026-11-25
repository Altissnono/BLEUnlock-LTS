import Foundation

/// Suggests lock/unlock RSSI thresholds from two short measurements: sitting where you work ("near")
/// and standing where the Mac should lock ("far"). Pure function, unit-tested.
enum Calibration {
    struct Result: Equatable {
        var unlockRSSI: Int
        var lockRSSI: Int
        var nearMedian: Int
        var farMedian: Int
    }
    enum Failure: Error, Equatable { case notEnoughSamples, tooSimilar }

    static let minSamples = 4
    static let minGap = 10          // dB between the weak end of "near" and the strong end of "far"

    /// Percentile (0...1) of the valid samples, nearest-rank.
    static func percentile(_ values: [Int], _ p: Double) -> Int {
        let s = values.sorted()
        let idx = Int((Double(s.count - 1) * p).rounded())
        return s[max(0, min(s.count - 1, idx))]
    }

    static func roundTo5(_ v: Int) -> Int { return Int((Double(v) / 5).rounded()) * 5 }

    static func propose(near rawNear: [Int], far rawFar: [Int]) -> Result? {
        return try? propose(near: rawNear, far: rawFar, throwing: ())
    }

    static func propose(near rawNear: [Int], far rawFar: [Int], throwing: Void) throws -> Result {
        let near = rawNear.compactMap(validRSSI), far = rawFar.compactMap(validRSSI)
        guard near.count >= minSamples, far.count >= minSamples else { throw Failure.notEnoughSamples }
        let nearWeak = percentile(near, 0.2)      // weakest typical reading while sitting
        let farStrong = percentile(far, 0.8)      // strongest typical reading while away
        let gap = nearWeak - farStrong
        guard gap >= minGap else { throw Failure.tooSimilar }
        var lock = roundTo5(Int((Double(farStrong) + Double(gap) * 0.4).rounded()))
        var unlock = roundTo5(Int((Double(nearWeak) - Double(gap) * 0.1).rounded()))
        // Menu range is -30 ... -95 in steps of 5; keep a hysteresis of at least 5 dB between lock and unlock.
        unlock = max(-95, min(-30, unlock))
        lock = max(-95, min(-35, lock))
        if unlock < lock + 5 { unlock = min(-30, lock + 5) }
        if unlock < lock + 5 { lock = unlock - 5 }
        return Result(unlockRSSI: unlock, lockRSSI: lock, nearMedian: percentile(near, 0.5), farMedian: percentile(far, 0.5))
    }
}
