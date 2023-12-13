//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

private let deploymentTarget = "17.0"

let project = Project.app(
    name: "Why-Not-SwiftUI",
    platform: .iOS,
    deploymentTarget: .iOS(
        targetVersion: deploymentTarget,
        devices: [.iphone, .ipad]
    ),
    baseSettings: [
        // Signing
        "CODE_SIGN_STYLE": "Automatic",
        "DEVELOPMENT_TEAM": "UT4XSTUQLU",

        // Version
        "MARKETING_VERSION": "1.0",
        "CURRENT_PROJECT_VERSION": "1",

        // Strict concurrency checking
        // NOTE: Will try later to make app read for Swift 6.
        // "SWIFT_STRICT_CONCURRENCY": "complete"

        "IPHONEOS_DEPLOYMENT_TARGET": "\(deploymentTarget)"
    ],
    additionalTargets: [
        Module(
            name: "Core",
            hasResources: true
        ),
        Module(
            name: "CommonUI",
            hasResources: true,
            dependencies: ["Core"]
        ),
        Module(
            name: "Home",
            dependencies: ["Core", "CommonUI"]
        )
    ],
    externalDependencies: [
        .external(name: "Alamofire"),
        .external(name: "Moya"),
        .external(name: "CombineMoya"),
        .external(name: "Kingfisher"),
        .external(name: "DGCharts"),
        .external(name: "Lottie"),
        // SwiftMacros depends on a Swift Macro, which is not yet supported.
        //.external(name: "SwiftMacros")
    ],
    infoPlist: [
        "CFBundleShortVersionString": "$(MARKETING_VERSION)",
        "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
        "UIMainStoryboardFile": "",
        "UILaunchStoryboardName": "LaunchScreen",
        "CFBundleName": "$(PRODUCT_NAME)",
        "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",

        // We need this to detect jail-broken device.
        "LSApplicationQueriesSchemes": ["cydia"],

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

        "NSCameraUsageDescription": "Record video",
        "NSMicrophoneUsageDescription": "Record audio",

        "CFBundleDisplayName": "$(XCC_PRODUCT_NAME)",
        "CONF_HOST_URL": "$(XCC_HOST_URL)"
    ]
)
