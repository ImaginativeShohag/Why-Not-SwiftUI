//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

@testable import Core
import NetworkKit
@testable import News
import XCTest

#if DEBUG

@MainActor
class NewsHomeUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
    }

    func test_headlineDate_shouldBeCurrentDate() {
        app.launchApp()
        runAppAndGoToModule()

        let headlineDate = app.staticTexts["headline_date"]
        XCTAssertTrue(headlineDate.waitForExistence(timeout: 5))

        XCTAssertTrue(headlineDate.label == Date().toString(dateFormat: "MMMM d"))
    }

    func test_whenSuccess_shouldShowNews() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: NewsAPI.allNews,
                    statusCode: 200,
                    data: AllNewsResponse.mockSuccessItem()
                ),
                MockResponse(
                    route: NewsAPI.newsTypes,
                    statusCode: 200,
                    data: NewsTypesResponse.mockSuccessItem()
                )
            ]
        )
        runAppAndGoToModule()

        // Test: Featured News
        let featuredTitle = app.staticTexts["headline_featured"]
        XCTAssertTrue(featuredTitle.waitForExistence(timeout: 5))

        let featuredScrollView = app.scrollViews["featured"]
        XCTAssertTrue(
            featuredScrollView.buttons["featured_news_item_2"].exists
        )

        // Test: Latest News
        let latestTitle = app.staticTexts["headline_latest"]
        XCTAssertTrue(latestTitle.waitForExistence(timeout: 5))

        XCTAssertTrue(app.buttons["news_item_1"].exists)
    }

    func test_whenError_shouldShowError() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: NewsAPI.allNews,
                    statusCode: 200,
                    data: AllNewsResponse.mockErrorItem()
                ),
                MockResponse(
                    route: NewsAPI.newsTypes,
                    statusCode: 200,
                    data: NewsTypesResponse.mockSuccessItem()
                )
            ]
        )
        runAppAndGoToModule()

        let errorContainer = app.staticTexts["error_container"]
        XCTAssertTrue(errorContainer.waitForExistence(timeout: 5), "Error container should be visible")

        XCTAssertTrue(app.staticTexts["Server error."].exists, "Error message should be visible")
    }

    func test_whenFailure_shouldShowError() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: NewsAPI.allNews,
                    statusCode: 500,
                    data: nil
                ),
                MockResponse(
                    route: NewsAPI.newsTypes,
                    statusCode: 200,
                    data: NewsTypesResponse.mockSuccessItem()
                )
            ]
        )
        runAppAndGoToModule()

        let errorContainer = app.staticTexts["error_container"]
        XCTAssertTrue(errorContainer.waitForExistence(timeout: 5), "Error container should be visible")

        XCTAssertTrue(errorContainer.label.contains("500"), "Error container should contain error message")
    }

    func runAppAndGoToModule() {
        let newsAppBtn = app.staticTexts["🥭 News App"]

        while !newsAppBtn.exists {
            app.swipeUp()
        }

        newsAppBtn.tap()
    }
}

#endif
