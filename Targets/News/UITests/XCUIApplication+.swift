//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import XCTest
@testable import News

struct MockResponse {
    let route: ApiEndpoint
    let statusCode: Int
    let response: Encodable
}

extension XCUIApplication {
    /// [`statusCode`: `response`]
    func launchApp(with responses: [MockResponse] = []) {
        // Add UI test flag argument
        launchArguments += [uiTestArgEnable]

        // Target response list
        for response in responses {
            launchEnvironment["\(response.route)"] = response.response.toJsonString()
            launchEnvironment[uiTestEnvironmentKeyResponseCode] = "\(response.statusCode)"
        }
        
        // Launch the app
        launch()
    }
}
