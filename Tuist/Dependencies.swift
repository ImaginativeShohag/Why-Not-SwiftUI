//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

let dependencies = Dependencies(
    swiftPackageManager: .init(
        productTypes: [
            "SwiftMacros": .framework,
            "Alamofire": .framework,
            "Moya": .framework,
            "CombineMoya": .framework,
            "Kingfisher": .framework,
            "DGCharts": .framework,
            "Lottie": .framework,
            "Shimmer": .framework
        ],
        baseSettings: Settings.settings(
            configurations: BuildEnvironment.getConfigurations(for: .target)
        )
    ),
    platforms: [.iOS]
)
