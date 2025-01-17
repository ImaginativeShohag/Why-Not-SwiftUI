//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

private let deploymentTargetVersion = "18.0"

let project = Project.app(
    name: Constants.projectName,
    deploymentTargets: .iOS(deploymentTargetVersion),
    destinations: [.iPhone, .iPad, .macWithiPadDesign, .appleVisionWithiPadDesign],
    baseSettings: [
        // Project supported platforms
        "SUPPORTED_PLATFORMS": "iphonesimulator iphoneos",

        // Signing
        "CODE_SIGN_STYLE": "Automatic",
        "DEVELOPMENT_TEAM": "UT4XSTUQLU",

        // Version
        "MARKETING_VERSION": appVersion,
        "CURRENT_PROJECT_VERSION": appBuild,

        "IPHONEOS_DEPLOYMENT_TARGET": "\(deploymentTargetVersion)",

        // Recommended by Xcode
        "ENABLE_USER_SCRIPT_SANDBOXING": true,

        // Strict concurrency checking
        // NOTE: Will try later to make app read for Swift 6.
        "SWIFT_STRICT_CONCURRENCY": "complete"
    ],
    infoPlist: [
        "CFBundleDisplayName": "$(XCC_PRODUCT_NAME)",
        "CFBundleShortVersionString": "$(MARKETING_VERSION)",
        "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
        "CFBundleName": "$(PRODUCT_NAME)",
        "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",

        // We need this to detect jail-broken device.
        "LSApplicationQueriesSchemes": ["cydia"],

        "UILaunchScreen": [
            "UILaunchScreen": []
        ],

        "UIAppFonts": [
            "SF-Pro-Rounded-Black.otf",
            "SF-Pro-Rounded-Bold.otf",
            "SF-Pro-Rounded-Heavy.otf",
            "SF-Pro-Rounded-Light.otf",
            "SF-Pro-Rounded-Medium.otf",
            "SF-Pro-Rounded-Regular.otf",
            "SF-Pro-Rounded-Semibold.otf",
            "SF-Pro-Rounded-Thin.otf",
            "SF-Pro-Rounded-Ultralight.otf",
            "RobotoSlab-VariableFont.ttf"
        ],

        "UIBackgroundModes": [
            "remote-notification"
        ],

        "LSRequiresIPhoneOS": "TRUE",
        "LSSupportsOpeningDocumentsInPlace": "TRUE",
        "NSAppTransportSecurity": [
            "NSAllowsArbitraryLoads": "TRUE"
        ],
        "UIFileSharingEnabled": "TRUE",
        "UIApplicationSupportsIndirectInputEvents": "TRUE",

        "NSCameraUsageDescription": "Camera permission is needed to record video.",
        "NSMicrophoneUsageDescription": "Microphone permission is needed to record audio.",
        "NSLocationWhenInUseUsageDescription": "Location permission is needed to show your current location."
    ],
    configInfoPlist: [
        "CONF_HOST_URL": "$(XCC_HOST_URL)"
    ],
    modules: [
        Module(
            name: "Core",
            hasResources: true,
            hasUnitTest: true,
            dependencies: ["SuperLog", "NetworkKit"]
        ),
        Module(
            name: "CommonUI",
            hasResources: true,
            hasUITest: true,
            dependencies: ["Core", "SuperLog"]
        ),
        Module(
            name: "NetworkKit",
            hasUnitTest: true,
            dependencies: ["SuperLog"]
        ),
        Module(
            name: "SuperLog"
        ),
        Module(
            name: "NavigationKit",
            hasUnitTest: true,
            dependencies: ["SuperLog"]
        ),
        Module(
            name: "Home",
            hasUnitTest: true,
            hasUITest: true,
            dependencies: ["Core", "CommonUI", "SuperLog", "Todo", "News"]
        ),
        Module(
            name: "Todo",
            dependencies: ["Core", "CommonUI", "SuperLog"]
        ),
        Module(
            name: "News",
            hasResources: true,
            hasUITest: true,
            dependencies: ["Core", "CommonUI", "SuperLog", "NetworkKit"]
        )
    ],
    externalDependencies: [
        .external(name: "SwiftMacros"),
        .external(name: "Alamofire"),
        .external(name: "Moya"),
        .external(name: "CombineMoya"),
        .external(name: "Kingfisher"),
        .external(name: "DGCharts"),
        .external(name: "Lottie"),
        .external(name: "Shimmer"),
        // We need both "RealmSwift" and "Realm" to solve the "Undefined symbol" issue.
        .external(name: "RealmSwift"),
        .external(name: "Realm"),
        .external(name: "MarkdownUI")
    ],
    coreDataModels: []
)
