//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

let packages: [Package] = [
    .remote(url: "https://github.com/Alamofire/Alamofire", requirement: .upToNextMajor(from: "5.0.0")),
    .remote(url: "https://github.com/Moya/Moya", requirement: .upToNextMajor(from: "15.0.0")),
    .remote(url: "https://github.com/onevcat/Kingfisher", requirement: .upToNextMajor(from: "7.0.0")),
    .remote(url: "https://github.com/danielgindi/Charts", requirement: .upToNextMajor(from: "5.0.0")),
    .remote(url: "https://github.com/airbnb/lottie-ios", requirement: .upToNextMajor(from: "4.3.0")),
    .local(path: "packages/SwiftMacros")
]

let dependencies = Dependencies(
    swiftPackageManager: .init(
        packages,
        productTypes: [
            "Alamofire": .framework,
            "Moya": .framework,
            "CombineMoya": .framework,
            "Kingfisher": .framework,
            "DGCharts": .framework,
            "Lottie": .framework,
            "SwiftMacros": .framework
        ],
        baseSettings: Settings.settings(
            configurations: TargetBuildEnvironment.allConfigurations
        ),
        targetSettings: [:]
    ),
    platforms: [.iOS]
)
