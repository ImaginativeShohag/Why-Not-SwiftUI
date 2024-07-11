//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import News
import XCTest

@MainActor
class NewsDetailsUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
    }

    func test_newsDetails() async throws {
        app.launchApp(for: .success)
        runAppAndGoToModule()

        // Click first news item
        let firstNewsItem = app.buttons["news_item_1"]
        XCTAssertTrue(firstNewsItem.waitForExistence(timeout: 5))
        
        let newsTitleLabel = firstNewsItem.staticTexts["title"].label
        let newsPublishedDateLabel = firstNewsItem.staticTexts["published_date"].label

        firstNewsItem.tap()
        
        // Check all element in details screen
        let thumbnail = app.images["thumbnail"]
        XCTAssertTrue(thumbnail.waitForExistence(timeout: 5))
        
        // Check title text with the text from previous screen
        let title = app.staticTexts["title"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        XCTAssertTrue(title.label == newsTitleLabel)
        
        // Check published date text with the text from previous screen
        let publishedDate = app.staticTexts["published_date"]
        XCTAssertTrue(publishedDate.waitForExistence(timeout: 5))
        XCTAssertTrue(publishedDate.label == newsPublishedDateLabel)
        
        let details = app.staticTexts["details"]
        XCTAssertTrue(details.waitForExistence(timeout: 5))
    }
    
    func runAppAndGoToModule() {
        let newsAppBtn = app.staticTexts["🥭 News App"]

        while !newsAppBtn.exists {
            app.swipeUp()
        }

        newsAppBtn.tap()
    }
}
