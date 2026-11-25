import Foundation

/// Moving average of the last `size` RSSI samples (smooths out bouncing).
struct RSSIAverager {
    let size: Int
    private(set) var samples: [Double] = []

    init(size: Int = 5) { self.size = max(1, size) }

    mutating func add(_ rssi: Int) -> Int {
        if samples.count >= size { samples.removeFirst() }
        samples.append(Double(rssi))
        return Int(samples.reduce(0, +) / Double(samples.count))
    }

    mutating func reset() { samples.removeAll() }
}

/// CoreBluetooth reports 127 when the RSSI is unavailable and an undefined value (often 0) when a read fails.
/// Such a reading must NEVER be interpreted as "the device is right next to the Mac" — that would keep the
/// Mac unlocked (or unlock it) while the device is actually gone. Returns nil for anything implausible.
func validRSSI(_ raw: Int) -> Int? {
    return (-127 ... -1).contains(raw) ? raw : nil
}
