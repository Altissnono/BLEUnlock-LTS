import Foundation

enum DeviceKind: String {
    case watch, phone, tablet, computer, audio, tv, speaker, tag, other
}

struct DeviceEntry: Equatable {
    var id: UUID
    var kind: DeviceKind
    var named: Bool        // false when the only label is a raw UUID / MAC address
    var rssi: Int
    var title: String
}

/// Makes the (long, noisy) list of nearby BLE devices usable: recognises what a device is,
/// gives Apple model identifiers readable names, and puts the devices a person would actually
/// monitor (watch, phone, tablet) first, strongest signal on top.
enum DeviceCatalog {
    /// "Watch7,5" → "Apple Watch (Watch7,5)". nil if it does not look like an Apple model identifier.
    static func friendlyAppleModel(_ model: String) -> String? {
        guard model.range(of: #"^[A-Za-z]+\d+,\d+$"#, options: .regularExpression) != nil else { return nil }
        let prefixes: [(String, String)] = [("Watch", "Apple Watch"), ("iPhone", "iPhone"), ("iPad", "iPad"), ("Macmini", "Mac mini"),
                                            ("MacBookPro", "MacBook Pro"), ("MacBookAir", "MacBook Air"), ("MacBook", "MacBook"),
                                            ("iMac", "iMac"), ("Mac", "Mac"), ("AppleTV", "Apple TV"), ("AudioAccessory", "HomePod"),
                                            ("RealityDevice", "Apple Vision Pro")]
        for (p, name) in prefixes where model.hasPrefix(p) { return "\(name) (\(model))" }
        return nil
    }

    static func kind(manufacturer: String?, model: String?, name: String?) -> DeviceKind {
        if let m = model {
            if m.hasPrefix("Watch") { return .watch }
            if m.hasPrefix("iPhone") { return .phone }
            if m.hasPrefix("iPad") { return .tablet }
            if m.hasPrefix("AppleTV") { return .tv }
            if m.hasPrefix("AudioAccessory") { return .speaker }
            if m.hasPrefix("Mac") || m.hasPrefix("iMac") { return .computer }
        }
        let n = (name ?? "").lowercased()
        func has(_ words: [String]) -> Bool { return words.contains { n.contains($0) } }
        if has(["watch", "montre"]) { return .watch }
        if has(["iphone"]) { return .phone }
        if has(["ipad"]) { return .tablet }
        if has(["airpods", "buds", "headphone", "casque", "écouteur", "ecouteur", "beats"]) { return .audio }
        if has(["homepod", "speaker", "enceinte"]) { return .speaker }
        if has(["apple tv", "tv"]) { return .tv }
        if has(["macbook", "imac", "mac mini", "mac studio", "mac pro"]) { return .computer }
        if has(["airtag", "tag", "clés", "cles", "keys", "tile"]) { return .tag }
        return .other
    }

    static func looksLikeRawIdentifier(_ s: String) -> Bool {
        if UUID(uuidString: s) != nil { return true }
        return s.range(of: #"^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$"#, options: .regularExpression) != nil
    }

    static let personalKinds: Set<DeviceKind> = [.watch, .phone, .tablet]

    /// personal = watch/phone/tablet, strongest signal first. others = named devices first, then anonymous ones.
    static func partition(_ entries: [DeviceEntry]) -> (personal: [DeviceEntry], others: [DeviceEntry]) {
        func byRSSI(_ a: DeviceEntry, _ b: DeviceEntry) -> Bool {
            return a.rssi != b.rssi ? a.rssi > b.rssi : a.title < b.title
        }
        let personal = entries.filter { personalKinds.contains($0.kind) }.sorted(by: byRSSI)
        let rest = entries.filter { !personalKinds.contains($0.kind) }
        let others = rest.filter { $0.named }.sorted(by: byRSSI) + rest.filter { !$0.named }.sorted(by: byRSSI)
        return (personal, others)
    }

    static func symbol(for kind: DeviceKind) -> String {
        switch kind {
        case .watch: return "applewatch"
        case .phone: return "iphone"
        case .tablet: return "ipad"
        case .computer: return "laptopcomputer"
        case .audio: return "headphones"
        case .tv: return "tv"
        case .speaker: return "hifispeaker"
        case .tag: return "tag"
        case .other: return "dot.radiowaves.left.and.right"
        }
    }
}
