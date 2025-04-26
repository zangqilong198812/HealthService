// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "HomeService",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "HomeService",
            targets: ["HomeService"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "HomeService",
            dependencies: [],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "HomeServiceTests",
            dependencies: ["HomeService"]),
    ]
) 