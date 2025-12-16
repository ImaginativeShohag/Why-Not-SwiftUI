//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// This command line argument will be used when run the app for UI Test.
public let uiTestArgEnable = "ui-testing-enable"

/// This environment key will be use to pass the status code.
public let uiTestEnvKeyResponseStatusCode = "ui-testing-response-code"

/// This environment key will be used to pass user data for UI tests.
public let uiTestEnvKeyUserData = "ui-testing-user-data"

/// This returns `true` if the UI testing flag passed to the argument.
public let isUITestEnvironment = CommandLine.arguments.contains(uiTestArgEnable)
