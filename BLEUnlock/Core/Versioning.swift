import Foundation

/// A release tag accepted from the network: optional "v", 1–4 numeric components, optional "-suffix".
func isValidReleaseTag(_ tag: String) -> Bool {
    return tag.range(of: #"^v?\d{1,6}(\.\d{1,6}){0,3}(-[0-9A-Za-z.]{1,32})?$"#, options: .regularExpression) != nil
}

func versionComponents(_ v: String) -> [Int] {
    let trimmed = v.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
    let core = trimmed.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false).first ?? ""
    return core.split(separator: ".").map { Int($0) ?? 0 }
}

func isNewer(_ latest: String, than current: String) -> Bool {
    let a = versionComponents(latest), b = versionComponents(current)
    for i in 0..<max(a.count, b.count) {
        let x = i < a.count ? a[i] : 0, y = i < b.count ? b[i] : 0
        if x != y { return x > y }
    }
    return false
}
