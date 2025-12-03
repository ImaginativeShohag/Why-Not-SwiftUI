// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LocalizeKit",
    platforms: [.macOS(.v14)],
    products: [
        .executable(
            name: "LocalizeKit",
            targets: ["LocalizeKit"]
        ),
        .library(
            name: "LocalizeKitCore",
            targets: ["LocalizeKitCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0")
    ],
    targets: [
        // Core library with all logic
        .target(
            name: "LocalizeKitCore",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ]
        ),
        // Executable CLI
        .executableTarget(
            name: "LocalizeKit",
            dependencies: [
                "LocalizeKitCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        ),
        // Test target
        .testTarget(
            name: "LocalizeKitTests",
            dependencies: ["LocalizeKitCore"]
        )
    ]
)
