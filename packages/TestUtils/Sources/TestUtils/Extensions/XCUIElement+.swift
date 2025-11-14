//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import XCTest

public extension XCUIElement {
    /// Checks if a loading indicator is present within the current UI hierarchy.
    ///
    /// This method detects any activity indicator, which is often used to determine if a loading process is in progress.
    ///
    /// - Returns: `true` if any activity indicator exists, otherwise `false`.
    ///
    /// ## Example Usage:
    /// ```swift
    /// let app = XCUIApplication()
    /// if app.isLoading() {
    ///     print("The app is currently loading...")
    /// } else {
    ///     print("Loading is complete.")
    /// }
    /// ```
    func isLoading() -> Bool {
        return activityIndicators.count > 0
    }
    
    /// Waits for an element with the specified identifier to appear within the given timeout.
    ///
    /// This function searches for any descendant element that matches the provided identifier
    /// and waits until it becomes visible or the timeout expires.
    ///
    /// - Parameters:
    ///   - identifier: The accessibility identifier or label of the element to wait for.
    ///   - timeout: The maximum time (in seconds) to wait for the element to appear.
    /// - Returns: `true` if the element appears within the timeout, otherwise `false`.
    ///
    /// ## Example Usage:
    ///
    /// ```swift
    /// let app = XCUIApplication()
    /// app.launch()
    ///
    /// // Wait for a button with identifier "submitButton"
    /// let didAppear = app.waitForElement(matching: "submitButton", timeout: 5)
    ///
    /// // Verify if the element appeared
    /// XCTAssertTrue(didAppear, "Submit button should appear within 5 seconds")
    /// ```
    ///
    /// ```swift
    /// // Wait for a label with text "Welcome"
    /// let welcomeLabelExists = app.staticTexts["Welcome"].waitForElement(matching: "Welcome", timeout: 3)
    ///
    /// XCTAssertTrue(welcomeLabelExists, "Welcome text should appear within 3 seconds")
    /// ```
    func waitForElement(matching identifier: String, timeout: TimeInterval) -> Bool {
        return descendants(matching: .any)[identifier].waitForExistence(timeout: timeout)
    }
}
