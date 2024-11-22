//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import XCTest

public extension XCUIApplication {
    func launchApp(with responses: [MockResponse] = []) {
        // Add UI test flag argument
        launchArguments += [uiTestArgEnable]

        // Target response list
        for response in responses {
            if let data = response.data {
                launchEnvironment["\(response.route)"] = data.toJsonString()
            }
            launchEnvironment["\(uiTestEnvKeyResponseStatusCode)-\(response.route)"] = "\(response.statusCode)"
        }

        // Launch the app
        launch()
    }
}
