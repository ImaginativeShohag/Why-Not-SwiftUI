//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NetworkKit
import XCTest

public extension XCUIApplication {
    /// Launches the application for UI testing with a specified set of mock network responses.
    ///
    /// This function configures the app's launch environment to simulate API responses,
    /// enabling deterministic UI tests without depending on a live server.
    ///
    /// ### Usage
    ///
    /// ```swift
    /// // Create a mock response payload.
    /// let payload = """
    /// { "token": "abc-123", "userId": "u-456" }
    /// """.data(using: .utf8)!
    ///
    /// let response = MockResponse(
    ///     route: AuthAPI.login,
    ///     data: payload,
    ///     statusCode: 200
    /// )
    ///
    /// // Launch the app with the mock response.
    /// app.launchApp(with: [response])
    ///
    /// ```
    ///
    /// - Parameters:
    ///   - responses: An array of `MockResponse` objects that define the mock network behavior for this launch.
    ///   - userData: Optional user data to be set in Preferences during UI tests.
    func launchApp(with responses: [MockResponse] = [], userData: (any Encodable)? = nil) {
        // Add UI test flag argument
        launchArguments += [uiTestArgEnable]

        // Target response list
        for response in responses {
            if let data = response.data {
                launchEnvironment["\(response.route)"] = try? data.toJSONString()
            }
            launchEnvironment["\(uiTestEnvKeyResponseStatusCode)-\(response.route)"] = "\(response.statusCode)"
        }

        // Set user data if provided
        if let userData = userData {
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(userData),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                launchEnvironment[uiTestEnvKeyUserData] = jsonString
            }
        }

        // Launch the app
        launch()
    }
}
