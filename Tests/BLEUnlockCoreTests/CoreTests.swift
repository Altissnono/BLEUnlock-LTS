import XCTest
import Foundation
@testable import BLEUnlockCore

final class SanitizeTests: XCTestCase {
    func testStripsControlCharactersAndBidiOverrides() {
        XCTAssertEqual(sanitizeDeviceString("Ph\u{0000}one\u{0007}\n"), "Phone")
        XCTAssertEqual(sanitizeDeviceString("a\u{202E}b\u{2066}c"), "abc")
    }
    func testCapsLength() {
        XCTAssertEqual(sanitizeDeviceString(String(repeating: "x", count: 10_000)).count, 64)
        XCTAssertEqual(sanitizeDeviceString("abcdef", max: 3), "abc")
    }
    func testEmptyAndWhitespace() {
        XCTAssertEqual(sanitizeDeviceString(""), "")
        XCTAssertEqual(sanitizeDeviceString("   "), "")
    }
    func testKeepsUnicodeAndEmoji() {
        XCTAssertEqual(sanitizeDeviceString("iPhone de Zoë 📱"), "iPhone de Zoë 📱")
    }
}

final class VersioningTests: XCTestCase {
    func testNewer() {
        XCTAssertTrue(isNewer("v2.0.10", than: "2.0.9"))
        XCTAssertTrue(isNewer("3.0.0", than: "2.9.9"))
        XCTAssertTrue(isNewer("2.0.1", than: "2.0"))
    }
    func testNotNewer() {
        XCTAssertFalse(isNewer("2.0.0", than: "2.0.0"))
        XCTAssertFalse(isNewer("v1.9.9", than: "2.0.0"))
        XCTAssertFalse(isNewer("garbage", than: "1.0.0"))
    }
    func testTagValidation() {
        for ok in ["v1.2.3", "1.2", "v10.0.0-beta.1", "2"] { XCTAssertTrue(isValidReleaseTag(ok), ok) }
        for bad in ["", "v", "latest", "1.2.3; rm -rf /", "v1.2.3\n", "1..2", "../../x", String(repeating: "1", count: 200),
                    "v1.2.3-" + String(repeating: "a", count: 33), "<script>"] {
            XCTAssertFalse(isValidReleaseTag(bad), bad)
        }
    }
}

final class UnlockLimiterTests: XCTestCase {
    func testAllowsUpToLimitThenDeniesOnceNotified() {
        var l = UnlockLimiter()
        XCTAssertEqual(l.request(limit: 3, now: 0), .allowed)
        XCTAssertEqual(l.request(limit: 3, now: 1), .allowed)
        XCTAssertEqual(l.request(limit: 3, now: 2), .allowed)
        XCTAssertEqual(l.request(limit: 3, now: 3), .deniedFirstTime)   // notification exactly once
        XCTAssertEqual(l.request(limit: 3, now: 4), .denied)
        XCTAssertEqual(l.request(limit: 3, now: 5), .denied)
    }
    func testWindowExpiryAllowsAgain() {
        var l = UnlockLimiter()
        for t in 0..<3 { _ = l.request(limit: 3, now: Double(t)) }
        XCTAssertEqual(l.request(limit: 3, now: 10), .deniedFirstTime)
        XCTAssertEqual(l.request(limit: 3, now: 500), .allowed)
    }
    func testResetOnManualUnlock() {
        var l = UnlockLimiter()
        for t in 0..<3 { _ = l.request(limit: 3, now: Double(t)) }
        l.reset()
        XCTAssertEqual(l.request(limit: 3, now: 4), .allowed)
    }
    func testUnlimited() {
        var l = UnlockLimiter()
        for t in 0..<100 { XCTAssertEqual(l.request(limit: 0, now: Double(t)), .allowed) }
    }
    func testLimitOne() {
        var l = UnlockLimiter()
        XCTAssertEqual(l.request(limit: 1, now: 0), .allowed)
        XCTAssertEqual(l.request(limit: 1, now: 1), .deniedFirstTime)
    }
}

final class UnlockPolicyTests: XCTestCase {
    private func ok() -> UnlockContext {
        UnlockContext(unlockEnabled: true, manualLock: false, presence: true, unlockRSSIEnabled: true,
                      systemSleep: false, displaySleep: false, wakeWithoutUnlocking: false,
                      screenLocked: true, onConsole: true, frontWindowSafe: true)
    }
    func testAllConditionsMetAllowsTyping() { XCTAssertTrue(UnlockPolicy.mayTypePassword(ok())) }

    /// Each single violated condition must block typing (would fail if any guard were dropped).
    func testEveryGuardBlocks() {
        let mutations: [(String, (inout UnlockContext) -> Void)] = [
            ("lock-only mode", { $0.unlockEnabled = false }),
            ("manual lock", { $0.manualLock = true }),
            ("device gone", { $0.presence = false }),
            ("unlock RSSI disabled", { $0.unlockRSSIEnabled = false }),
            ("system asleep", { $0.systemSleep = true }),
            ("display asleep", { $0.displaySleep = true }),
            ("wake without unlocking", { $0.wakeWithoutUnlocking = true }),
            ("screen not locked", { $0.screenLocked = false }),
            ("session not on console", { $0.onConsole = false }),
            ("front window unsafe", { $0.frontWindowSafe = false }),
        ]
        for (name, m) in mutations {
            var c = ok(); m(&c)
            XCTAssertFalse(UnlockPolicy.mayTypePassword(c), name)
        }
    }
}

final class FrontWindowPolicyTests: XCTestCase {
    func testLockScreenOwnersAreSafe() {
        for o in ["loginwindow", "ScreenSaverEngine", "SecurityAgent"] { XCTAssertTrue(FrontWindowPolicy.isSafe(owner: o), o) }
    }
    func testNormalAppsAreNotSafe() {
        for o in ["Terminal", "Safari", "Slack", "Finder", "Dock", "", "loginwindow2", "LoginWindow"] {
            XCTAssertFalse(FrontWindowPolicy.isSafe(owner: o), o)
        }
    }
    func testUnknownOwnerFailsOpenOnlyBecauseOtherGuardsApply() { XCTAssertTrue(FrontWindowPolicy.isSafe(owner: nil)) }
}

final class ClampTests: XCTestCase {
    func testRSSI() {
        XCTAssertEqual(Clamp.rssi(5000), -1); XCTAssertEqual(Clamp.rssi(-5000), -100); XCTAssertEqual(Clamp.rssi(-60), -60)
        XCTAssertEqual(Clamp.rssi(Int.max), -1); XCTAssertEqual(Clamp.rssi(Int.min), -100)
    }
    func testTimeoutsAndDelays() {
        XCTAssertEqual(Clamp.signalTimeout(0), 30); XCTAssertEqual(Clamp.signalTimeout(999_999), 600)
        XCTAssertEqual(Clamp.lockDelay(-5), 2); XCTAssertEqual(Clamp.lockDelay(10_000), 300)
        XCTAssertEqual(Clamp.confirmDelay(-1), 0); XCTAssertEqual(Clamp.confirmDelay(99), 10)
    }
    func testMaxAttempts() {
        XCTAssertEqual(Clamp.maxAttempts(nil), 3); XCTAssertEqual(Clamp.maxAttempts(-4), 0)
        XCTAssertEqual(Clamp.maxAttempts(1_000_000), 20); XCTAssertEqual(Clamp.maxAttempts(5), 5)
    }
}

final class RSSIAveragerTests: XCTestCase {
    func testAveragesLastN() {
        var a = RSSIAverager(size: 3)
        XCTAssertEqual(a.add(-60), -60)
        XCTAssertEqual(a.add(-70), -65)
        XCTAssertEqual(a.add(-80), -70)
        XCTAssertEqual(a.add(-90), -80)      // oldest (-60) dropped
        XCTAssertEqual(a.samples.count, 3)
    }
    func testResetAndMinimumSize() {
        var a = RSSIAverager(size: 0)         // coerced to 1
        XCTAssertEqual(a.add(-50), -50); XCTAssertEqual(a.add(-90), -90)
        a.reset(); XCTAssertTrue(a.samples.isEmpty)
    }
}

final class ValidRSSITests: XCTestCase {
    func testPlausibleValuesAccepted() {
        for v in [-1, -30, -60, -90, -100, -127] { XCTAssertEqual(validRSSI(v), v) }
    }
    /// 127 = "not available" and 0 = undefined value on a failed read: must never read as "very close".
    func testUnavailableAndErrorValuesRejected() {
        for v in [127, 0, 1, 5, 126, 128, -128, -1000, Int.max, Int.min] { XCTAssertNil(validRSSI(v), "\(v)") }
    }
}

final class MedianFilterTests: XCTestCase {
    func testMedianRejectsSingleSpike() {
        var a = RSSIAverager(size: 5); a.useMedian = true
        _ = a.add(-60); _ = a.add(-61); _ = a.add(-59); _ = a.add(-60)
        XCTAssertEqual(a.add(-100), -60)          // one dropout does not move the estimate
        var m = RSSIAverager(size: 5)             // legacy mean is dragged down
        _ = m.add(-60); _ = m.add(-61); _ = m.add(-59); _ = m.add(-60)
        XCTAssertEqual(m.add(-100), -68)
    }
    func testMedianEvenCountAndFollowsPersistentChange() {
        var a = RSSIAverager(size: 5); a.useMedian = true
        XCTAssertEqual(a.add(-60), -60)
        XCTAssertEqual(a.add(-70), -65)
        for _ in 0..<3 { _ = a.add(-90) }
        XCTAssertEqual(a.add(-90), -90)           // persistent change is followed
    }
}

final class CalibrationTests: XCTestCase {
    func testTypicalSeparation() throws {
        let near = [-45, -48, -50, -46, -52, -47, -49, -51]
        let far  = [-82, -85, -80, -88, -84, -86, -83, -90]
        let r = try Calibration.propose(near: near, far: far, throwing: ())
        XCTAssertGreaterThanOrEqual(r.unlockRSSI, r.lockRSSI + 5)         // hysteresis
        XCTAssertLessThanOrEqual(r.unlockRSSI, -45)                        // sitting position unlocks
        XCTAssertGreaterThan(r.lockRSSI, -82)                              // far position is below lock threshold
        XCTAssertEqual(r.unlockRSSI % 5, 0); XCTAssertEqual(r.lockRSSI % 5, 0)
    }
    func testNotEnoughSamples() {
        XCTAssertThrowsError(try Calibration.propose(near: [-50, -51], far: [-80, -81, -82, -83], throwing: ())) {
            XCTAssertEqual($0 as? Calibration.Failure, .notEnoughSamples)
        }
    }
    func testInvalidReadingsAreDiscarded() {
        // 127/0 readings must not count as samples
        XCTAssertThrowsError(try Calibration.propose(near: [127, 0, 127, 0, -50], far: [-80, -81, -82, -83], throwing: ()))
    }
    func testTooSimilar() {
        let a = [-60, -61, -62, -63, -60, -61]
        XCTAssertThrowsError(try Calibration.propose(near: a, far: a, throwing: ())) {
            XCTAssertEqual($0 as? Calibration.Failure, .tooSimilar)
        }
    }
    func testResultsStayInMenuRange() throws {
        let r = try Calibration.propose(near: [-31, -32, -33, -34, -30], far: [-90, -92, -95, -96, -99], throwing: ())
        XCTAssertTrue((-95 ... -30).contains(r.unlockRSSI)); XCTAssertTrue((-95 ... -35).contains(r.lockRSSI))
        XCTAssertGreaterThanOrEqual(r.unlockRSSI, r.lockRSSI + 5)
    }
}

final class PresenceCombinerTests: XCTestCase {
    func testAnyPresent() {
        XCTAssertTrue(PresenceCombiner.anyPresent([true, false]))
        XCTAssertTrue(PresenceCombiner.anyPresent([false, true]))
        XCTAssertFalse(PresenceCombiner.anyPresent([false, false]))
    }
    func testUnconfiguredDevicesIgnored() {
        XCTAssertTrue(PresenceCombiner.anyPresent([true, nil]))
        XCTAssertFalse(PresenceCombiner.anyPresent([false, nil]))
        XCTAssertFalse(PresenceCombiner.anyPresent([nil, nil]))   // nothing configured → never "attended"
        XCTAssertFalse(PresenceCombiner.anyPresent([]))
    }
}

final class DeviceCatalogTests: XCTestCase {
    func testFriendlyAppleModels() {
        XCTAssertEqual(DeviceCatalog.friendlyAppleModel("Watch7,5"), "Apple Watch (Watch7,5)")
        XCTAssertEqual(DeviceCatalog.friendlyAppleModel("iPhone19,7"), "iPhone (iPhone19,7)")
        XCTAssertEqual(DeviceCatalog.friendlyAppleModel("iPad15,5"), "iPad (iPad15,5)")
        XCTAssertEqual(DeviceCatalog.friendlyAppleModel("Mac14,13"), "Mac (Mac14,13)")
        XCTAssertEqual(DeviceCatalog.friendlyAppleModel("MacBookPro18,1"), "MacBook Pro (MacBookPro18,1)")
        XCTAssertEqual(DeviceCatalog.friendlyAppleModel("AudioAccessory6,1"), "HomePod (AudioAccessory6,1)")
        XCTAssertNil(DeviceCatalog.friendlyAppleModel("Foo"))
        XCTAssertNil(DeviceCatalog.friendlyAppleModel("Watch"))
        XCTAssertNil(DeviceCatalog.friendlyAppleModel("<script>1,2"))
    }
    func testKindFromModelAndName() {
        XCTAssertEqual(DeviceCatalog.kind(manufacturer: "Apple Inc.", model: "Watch7,5", name: nil), .watch)
        XCTAssertEqual(DeviceCatalog.kind(manufacturer: "Apple Inc.", model: "iPhone19,7", name: nil), .phone)
        XCTAssertEqual(DeviceCatalog.kind(manufacturer: nil, model: nil, name: "iPhone de Nolann"), .phone)
        XCTAssertEqual(DeviceCatalog.kind(manufacturer: nil, model: nil, name: "Apple Watch de Zoë"), .watch)
        XCTAssertEqual(DeviceCatalog.kind(manufacturer: nil, model: nil, name: "Montre de Léo"), .watch)
        XCTAssertEqual(DeviceCatalog.kind(manufacturer: nil, model: nil, name: "AirPods Max de Nolann"), .audio)
        XCTAssertEqual(DeviceCatalog.kind(manufacturer: nil, model: nil, name: "Clés de Nolann voiture"), .tag)
        XCTAssertEqual(DeviceCatalog.kind(manufacturer: nil, model: nil, name: "Govee_H6099_5979"), .other)
        XCTAssertEqual(DeviceCatalog.kind(manufacturer: nil, model: nil, name: nil), .other)
    }
    func testRawIdentifierDetection() {
        XCTAssertTrue(DeviceCatalog.looksLikeRawIdentifier("6A89725E-769F-2549-D53D-F3CF38B2B24D"))
        XCTAssertTrue(DeviceCatalog.looksLikeRawIdentifier("AA:BB:CC:DD:EE:FF"))
        XCTAssertFalse(DeviceCatalog.looksLikeRawIdentifier("iPhone 11"))
    }
    func testPartitionPutsWatchAndPhoneFirstStrongestOnTop() {
        func e(_ kind: DeviceKind, _ rssi: Int, _ title: String, named: Bool = true) -> DeviceEntry {
            DeviceEntry(id: UUID(), kind: kind, named: named, rssi: rssi, title: title)
        }
        let list = [e(.other, -40, "UUID-1", named: false), e(.audio, -39, "AirPods"), e(.phone, -33, "iPhone 11"),
                    e(.watch, -45, "Apple Watch"), e(.tablet, -72, "iPad"), e(.other, -61, "Aqara"), e(.phone, -42, "iPhone 17")]
        let r = DeviceCatalog.partition(list)
        XCTAssertEqual(r.personal.map { $0.title }, ["iPhone 11", "iPhone 17", "Apple Watch", "iPad"])
        XCTAssertEqual(r.others.map { $0.title }, ["AirPods", "Aqara", "UUID-1"])   // named first, anonymous last
    }
    func testPartitionIsStableOnTies() {
        let a = DeviceEntry(id: UUID(), kind: .phone, named: true, rssi: -50, title: "B")
        let b = DeviceEntry(id: UUID(), kind: .phone, named: true, rssi: -50, title: "A")
        XCTAssertEqual(DeviceCatalog.partition([a, b]).personal.map { $0.title }, ["A", "B"])
        XCTAssertTrue(DeviceCatalog.partition([]).personal.isEmpty)
    }
}

final class ScriptGuardTests: XCTestCase {
    private var dir: URL!
    override func setUpWithError() throws {
        dir = FileManager.default.temporaryDirectory.appendingPathComponent("bleunlock-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    override func tearDownWithError() throws { try? FileManager.default.removeItem(at: dir) }

    private func make(_ name: String, mode: Int) throws -> String {
        let p = dir.appendingPathComponent(name).path
        FileManager.default.createFile(atPath: p, contents: Data("#!/bin/sh\n".utf8), attributes: [.posixPermissions: mode])
        return p
    }
    func testAcceptsOwnedPrivateScript() throws { XCTAssertTrue(isSafeToRunScript(atPath: try make("ok", mode: 0o700))) }
    func testRejectsGroupWritable() throws { XCTAssertFalse(isSafeToRunScript(atPath: try make("g", mode: 0o770))) }
    func testRejectsWorldWritable() throws { XCTAssertFalse(isSafeToRunScript(atPath: try make("w", mode: 0o707))) }
    func testRejectsWrongOwner() throws { XCTAssertFalse(isSafeToRunScript(atPath: try make("o", mode: 0o700), uid: getuid() &+ 1)) }
    func testRejectsMissingAndDirectory() throws {
        XCTAssertFalse(isSafeToRunScript(atPath: dir.appendingPathComponent("nope").path))
        XCTAssertFalse(isSafeToRunScript(atPath: dir.path))
    }
    func testRejectsSymlink() throws {
        let target = try make("t", mode: 0o700)
        let link = dir.appendingPathComponent("link").path
        try FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: target)
        // attributesOfItem does not follow symlinks → type is .typeSymbolicLink
        XCTAssertFalse(isSafeToRunScript(atPath: link))
    }
}

final class PasswordStoreTests: XCTestCase {
    private func store() -> PasswordStore { PasswordStore(service: "bleunlock-test-\(UUID().uuidString)", account: "tester") }

    func testRoundTripAndDelete() throws {
        let s = store()
        defer { s.delete() }
        do { try s.store("p@ss wörd 🔑") } catch PasswordStore.Failure.status(let st) {
            throw XCTSkip("Keychain not usable in this environment (status \(st))")
        }
        XCTAssertEqual(try s.fetch(), "p@ss wörd 🔑")
        XCTAssertTrue(s.delete())
        XCTAssertNil(try s.fetch())
    }
    func testMissingItemIsNilNotError() throws {
        let s = store()
        do { XCTAssertNil(try s.fetch()) } catch PasswordStore.Failure.status(let st) {
            throw XCTSkip("Keychain not usable in this environment (status \(st))")
        }
    }
    func testEmptyPasswordRejected() {
        XCTAssertThrowsError(try store().store(""))
    }
    func testOverwriteReplaces() throws {
        let s = store(); defer { s.delete() }
        do { try s.store("one"); try s.store("two") } catch PasswordStore.Failure.status(let st) {
            throw XCTSkip("Keychain not usable in this environment (status \(st))")
        }
        XCTAssertEqual(try s.fetch(), "two")
    }
}

/// Every language must define every key of the base strings file (no missing translation → no English/raw key fallback).
final class LocalizationTests: XCTestCase {
    private func keys(_ path: String) -> Set<String> {
        guard let d = NSDictionary(contentsOfFile: path) as? [String: String] else { return [] }
        return Set(d.keys)
    }
    func testAllLanguagesComplete() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("BLEUnlock")
        let base = keys(root.appendingPathComponent("Base.lproj/Localizable.strings").path)
        XCTAssertGreaterThan(base.count, 60)
        let langs = try FileManager.default.contentsOfDirectory(atPath: root.path).filter { $0.hasSuffix(".lproj") && $0 != "Base.lproj" }
        XCTAssertGreaterThanOrEqual(langs.count, 9)
        var report: [String] = []
        for l in langs {
            let missing = base.subtracting(keys(root.appendingPathComponent("\(l)/Localizable.strings").path))
            if !missing.isEmpty { report.append("\(l): \(missing.sorted())") }
        }
        XCTAssertTrue(report.isEmpty, report.joined(separator: "\n"))
    }
}
