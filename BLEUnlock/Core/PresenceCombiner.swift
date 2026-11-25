import Foundation

/// Two devices can be monitored (e.g. Apple Watch and iPhone). The Mac counts as "attended" when ANY
/// configured device is near, and is locked only when ALL configured devices are away.
/// `nil` = device not configured (ignored). No configured device at all = not attended.
enum PresenceCombiner {
    static func anyPresent(_ presences: [Bool?]) -> Bool {
        return presences.compactMap { $0 }.contains(true)
    }
}
