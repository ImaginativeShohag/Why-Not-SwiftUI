//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import Moya

public extension Backend {
    convenience init(
        isStubbed: Bool = false,
        stubBehavior: StubBehavior = .immediate
    ) {
        print("debug1: aaa")
        self.init(
            isStubbed: isUITestEnvironment ? true : isStubbed,
            stubBehavior: stubBehavior,
            session: Env.shared.defaultSession
        )
    }
}

/// This command line argument will be used when run the app for UI Test.
public let uiTestArgEnable = "ui-testing-enable"
public let uiTestArgResponseSuccess = "ui-testing-response-success"
public let uiTestArgResponseSuccessWithEmptyData = "ui-testing-response-success-with-empty-data"
public let uiTestArgResponseFailure = "ui-testing-response-failure"
public let uiTestArgResponseError = "ui-testing-response-error"

public let uiTestEnvironmentKeyResponse = "ui-testing-response"
public let uiTestEnvKeyResponseStatusCode = "ui-testing-response-code"

let isUITestEnvironment = CommandLine.arguments.contains(uiTestArgEnable)
