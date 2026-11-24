import Foundation

/// Strings coming from nearby BLE devices are untrusted: strip control characters and bidi overrides
/// and cap the length before they are shown in the menu (prevents menu spoofing / UI abuse).
func sanitizeDeviceString(_ s: String, max: Int = 64) -> String {
    let bidi: Set<UInt32> = [0x202A, 0x202B, 0x202C, 0x202D, 0x202E, 0x2066, 0x2067, 0x2068, 0x2069]
    let cleaned = s.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) && !bidi.contains($0.value) }
    return String(String.UnicodeScalarView(cleaned)).prefix(max).trimmingCharacters(in: .whitespaces)
}
