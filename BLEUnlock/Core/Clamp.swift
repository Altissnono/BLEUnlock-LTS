import Foundation

/// Preference values are read from a user-writable plist: always range-check before use.
enum Clamp {
    static func rssi(_ v: Int) -> Int { return max(-100, min(-1, v)) }
    static func signalTimeout(_ v: Int) -> Double { return Double(max(3, min(600, v))) }
    static func lockDelay(_ v: Int) -> Double { return Double(max(2, min(300, v))) }
    static func confirmDelay(_ v: Int) -> Int { return max(0, min(10, v)) }
    static func maxAttempts(_ v: Int?) -> Int { guard let v = v else { return 3 }; return max(0, min(20, v)) }
}
