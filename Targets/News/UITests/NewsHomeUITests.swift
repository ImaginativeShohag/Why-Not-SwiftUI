//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import News
import XCTest

@MainActor
class NewsHomeUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
    }

    func test_headlineDate_shouldBeCurrentDate() {
        app.runApp()

        let headlineDate = app.staticTexts["headline_date"]
        XCTAssertTrue(headlineDate.waitForExistence(timeout: 5))

        XCTAssertTrue(headlineDate.label == Date().toString(dateFormat: "MMMM d"))
    }

    func test_whenSuccess_shouldShowNews() async throws {
        app.runApp(for: .success)

        // Test: Featured News
        let featuredTitle = app.staticTexts["headline_featured"]
        XCTAssertTrue(featuredTitle.waitForExistence(timeout: 5))

        let featuredScrollView = app.scrollViews["featured"]
        XCTAssertTrue(
            featuredScrollView.staticTexts["featured_news_item_1"].exists
        )

        // Test: Latest News
        let latestTitle = app.staticTexts["headline_latest"]
        XCTAssertTrue(latestTitle.waitForExistence(timeout: 5))

        XCTAssertTrue(app.staticTexts["news_item_1"].exists)
    }

    func test_whenError_shouldShowError() async throws {
        app.runApp(for: .error)

        let errorContainer = app.staticTexts["error_container"]
        XCTAssertTrue(errorContainer.waitForExistence(timeout: 5))

        XCTAssertTrue(app.staticTexts["Server error."].exists)
    }

    func test_whenFailure_shouldShowError() async throws {
        app.runApp(for: .failure)

        let errorContainer = app.staticTexts["error_container"]
        XCTAssertTrue(errorContainer.waitForExistence(timeout: 5))

        XCTAssertTrue(errorContainer.label.contains("500"))
    }
}

extension XCUIApplication {
    func runApp(for responseType: StubResponseType = .success) {
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

        // Go to the target module
        let newsAppBtn = staticTexts["🥭 News App"]

        while !newsAppBtn.exists {
            swipeUp()
        }

        newsAppBtn.tap()
    }
}
