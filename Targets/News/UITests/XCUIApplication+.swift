//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import XCTest

extension XCUIApplication {
    func launchApp(for responseType: StubResponseType = .success) {
        // Add UI test argument
        launchArguments += [uiTestArgEnable]

        // Add response type argument
        switch responseType {
        case .failure:
            launchArguments += [uiTestArgResponseFailure]

        case .error:
            launchArguments += [uiTestArgResponseError]

        default:
            launchArguments += [uiTestArgResponseSuccess]
        }

        // Launch the app
        launch()
    }
}
