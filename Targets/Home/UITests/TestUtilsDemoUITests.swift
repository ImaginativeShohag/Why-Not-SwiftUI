//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import TestUtils
import XCTest

/// This is a demo test only to check if the `TestUtils` target can be imported and extensions inside it can be used in a test target.
final class TestUtilsDemoUITests: XCTestCase {
    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        
        // Launch the application.
        app.launch()
        
        let demoScreenBtn = app.buttons["TestUtils UI Tests Demo"]
        
        // Swipe up repeatedly until the "TestUtils UI Tests Demo" button becomes visible.
        while !demoScreenBtn.exists {
            app.swipeUp()
        }
 
        // Tap on the "TestUtils UI Tests Demo" button to navigate to the demo screen.
        demoScreenBtn.tap()
        
        // Verify that intially the "Welcome..." text does not exist.
        XCTAssertFalse(app.findAndWait(staticText: "Welcome...", timeout: 2))
        
        // Tap the button that shows the text.
        app.buttons["text_show_button"].tap()
        
        // Verify that the app is in a loading state after enabling the text.
        XCTAssertTrue(app.isLoading())
        
        // Verify that the "Welcome..." text exists.
        XCTAssertTrue(app.findAndWait(staticText: "Welcome...", timeout: 5))
        
        // Tap the button that hides the text.
        app.buttons["text_hide_button"].tap()
        
        // Verify that the "Welcome..." text no longer exists.
        XCTAssertFalse(app.findAndWait(staticText: "Welcome...", timeout: 2))
    }
}
