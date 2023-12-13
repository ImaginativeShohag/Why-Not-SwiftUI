//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ProjectDescription

// MARK: - Environment constants for App.

public enum BuildEnvironment: String, CaseIterable {
    case development, staging, production

    public var debugConfiguration: Configuration {
        switch self {
            case .development:
                return .debug(
                    name: "Debug Development",
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)-dev",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG DEVELOPMENT"
                    ],
                    xcconfig: "ConfigurationFiles/Development.xcconfig"
                )
            case .staging:
                return .debug(
                    name: "Debug Staging",
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)-uat",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG UAT"
                    ],
                    xcconfig: "ConfigurationFiles/Staging.xcconfig"
                )
            case .production:
                return .debug(
                    name: "Debug Production",
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG PRODUCTION"
                    ],
                    xcconfig: "ConfigurationFiles/Production.xcconfig"
                )
        }
    }

    public var releaseConfiguration: Configuration {
        switch self {
            case .development:
                return .release(
                    name: "Release Development",
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)-dev",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEVELOPMENT"
                    ],
                    xcconfig: "ConfigurationFiles/Development.xcconfig"
                )
            case .staging:
                return .release(
                    name: "Release Staging",
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)-uat",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "UAT"
                    ],
                    xcconfig: "ConfigurationFiles/Staging.xcconfig"
                )
            case .production:
                return .release(
                    name: "Release Production",
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "PRODUCTION"
                    ],
                    xcconfig: "ConfigurationFiles/Production.xcconfig"
                )
        }
    }

    public static let allConfigurations = Self.allCases.map(\.debugConfiguration) + Self.allCases.map(\.releaseConfiguration)
}

// MARK: - Environment constants for Targets.

public enum TargetBuildEnvironment: String, CaseIterable {
    case development, staging, production

    public var debugConfiguration: Configuration {
        switch self {
            case .development:
                return .debug(
                    name: "Debug Development",
                    settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG DEVELOPMENT"
                    ],
                    xcconfig: "ConfigurationFiles/Development.xcconfig"
                )
            case .staging:
                return .debug(
                    name: "Debug Staging",
                    settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG UAT"
                    ],
                    xcconfig: "ConfigurationFiles/Staging.xcconfig"
                )
            case .production:
                return .debug(
                    name: "Debug Production",
                    settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG PRODUCTION"
                    ],
                    xcconfig: "ConfigurationFiles/Production.xcconfig"
                )
        }
    }

    public var releaseConfiguration: Configuration {
        switch self {
            case .development:
                return .release(
                    name: "Release Development",
                    settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEVELOPMENT"
                    ],
                    xcconfig: "ConfigurationFiles/Development.xcconfig"
                )
            case .staging:
                return .release(
                    name: "Release Staging",
                    settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "UAT"
                    ],
                    xcconfig: "ConfigurationFiles/Staging.xcconfig"
                )
            case .production:
                return .release(
                    name: "Release Production",
                    settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "PRODUCTION"
                    ],
                    xcconfig: "ConfigurationFiles/Production.xcconfig"
                )
        }
    }

    public static let allConfigurations = Self.allCases.map(\.debugConfiguration) + Self.allCases.map(\.releaseConfiguration)
}

// MARK: - Environment constants for Notification Service Extension.

public enum NotificationServiceExtBuildEnvironment: String, CaseIterable {
    case development, staging, production

    public var debugConfiguration: Configuration {
        switch self {
            case .development:
                return .debug(
                    name: "Debug Development",
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)-dev.NotificationServiceExtension",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG DEVELOPMENT"
                    ],
                    xcconfig: "ConfigurationFiles/Development.xcconfig"
                )
            case .staging:
                return .debug(
                    name: "Debug Staging",
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)-uat.NotificationServiceExtension",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG UAT"
                    ],
                    xcconfig: "ConfigurationFiles/Staging.xcconfig"
                )
            case .production:
                return .debug(
                    name: "Debug Production",
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId).NotificationServiceExtension",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG PRODUCTION"
                    ],
                    xcconfig: "ConfigurationFiles/Production.xcconfig"
                )
        }
    }

    public var releaseConfiguration: Configuration {
        switch self {
            case .development:
                return .release(
                    name: "Release Development",
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)-dev.NotificationServiceExtension",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEVELOPMENT"
                    ],
                    xcconfig: "ConfigurationFiles/Development.xcconfig"
                )
            case .staging:
                return .release(
                    name: "Release Staging",
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)-uat.NotificationServiceExtension",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "UAT"
                    ],
                    xcconfig: "ConfigurationFiles/Staging.xcconfig"
                )
            case .production:
                return .release(
                    name: "Release Production",
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId).NotificationServiceExtension",
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "PRODUCTION"
                    ],
                    xcconfig: "ConfigurationFiles/Production.xcconfig"
                )
        }
    }

    public static let allConfigurations = Self.allCases.map(\.debugConfiguration) + Self.allCases.map(\.releaseConfiguration)
}
