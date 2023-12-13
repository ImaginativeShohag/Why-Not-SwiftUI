//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ProjectDescription

let appExtensions = [
    Target(
        name: "NotificationServiceExtension",
        platform: .iOS,
        product: .appExtension,
        bundleId: "\(Constants.bundleId).NotificationServiceExtension",
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
            configurations: NotificationServiceExtBuildEnvironment.allConfigurations
        )
    )
]
