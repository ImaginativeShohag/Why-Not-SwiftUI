//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ProjectDescription

let appExtensions = [
    Target(
        name: "NotificationServiceExtension",
        destinations: [.iPhone, .iPad, .macWithiPadDesign, .appleVisionWithiPadDesign],
        product: .appExtension,
        bundleId: "\(Constants.bundleId).NotificationServiceExtension",
        deploymentTargets: .iOS("17.0"),
        infoPlist: .extendingDefault(with: [
            "CFBundleDisplayName": "$(PRODUCT_NAME)",
            "NSExtension": [
                "NSExtensionPointIdentifier": "com.apple.usernotifications.service",
                "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).NotificationService"
            ]
        ]),
        sources: "NotificationServiceExtension/**",
        dependencies: [],
        settings: .settings(
            configurations: BuildEnvironment.getConfigurations(for: .notificationServiceExtension)
        )
    )
]
