// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MinimizeAll",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "MinimizeAll",
            path: "Sources/MinimizeAll"
        )
    ]
)
