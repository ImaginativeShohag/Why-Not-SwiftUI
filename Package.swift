// swift-tools-version: 5.9

//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PackageDescription

#if TUIST
    import ProjectDescription
    import ProjectDescriptionHelpers

    let packageSettings = PackageSettings(
        productTypes: [ // default is .staticFramework,
            "SwiftMacros": .framework,
            "Alamofire": .framework,
            "Moya": .framework,
            "CombineMoya": .framework,
            "Kingfisher": .framework,
            "DGCharts": .framework,
            "Lottie": .framework,
            "Shimmer": .framework,
            "RealmSwift": .framework,
            "MarkdownUI": .framework,
            "TestUtils": .framework
        ],
        baseSettings: Settings.settings(
            configurations: BuildEnvironment.getConfigurations(for: .target)
        )
    )
#endif

let package = Package(
    name: "PackageName",
    dependencies: [
        .package(path: "packages/SwiftMacros"),
        .package(path: "packages/TestUtils"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        .package(url: "https://github.com/Moya/Moya", from: "15.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.0.0"),
        .package(url: "https://github.com/danielgindi/Charts", from: "5.0.0"),
        .package(url: "https://github.com/airbnb/lottie-ios", from: "4.3.0"),
        .package(url: "https://github.com/markiv/SwiftUI-Shimmer", from: "1.4.2"),
        .package(url: "https://github.com/realm/realm-swift", from: "10.52.3"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.0")
    ]
)
