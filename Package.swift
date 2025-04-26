// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "YGCHealthService",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "YGCHealthService",
            targets: ["YGCHealthService"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "YGCHealthService",
            dependencies: [],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "YGCHealthServiceTests",
            dependencies: ["YGCHealthService"]),
    ]
) 