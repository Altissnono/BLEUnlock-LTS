// swift-tools-version:5.7
// Used only to run the unit tests of the pure logic (`swift test`). The app itself is built with the Xcode project.
import PackageDescription

let package = Package(
    name: "BLEUnlockCore",
    platforms: [.macOS(.v12)],
    targets: [
        .target(name: "BLEUnlockCore", path: "BLEUnlock/Core"),
        .testTarget(name: "BLEUnlockCoreTests", dependencies: ["BLEUnlockCore"], path: "Tests/BLEUnlockCoreTests"),
    ]
)
