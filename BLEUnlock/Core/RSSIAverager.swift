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
