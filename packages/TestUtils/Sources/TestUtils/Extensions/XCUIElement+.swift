//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import XCTest

public extension XCUIElement {
    /// Extension to provide a loading state check for XCUIElement.
    ///
    /// This method checks if any activity indicator exists within the current UI hierarchy, often used to determine if a loading process is in progress.
    ///
    /// - Returns: Boolean value indicating if loading is in progress.
    ///
    /// Example usage:
    ///
    /// ```swift
    /// let app = XCUIApplication()
    /// if app.isLoading() {
    ///     print("The app is currently loading...")
    /// } else {
    ///     print("Loading is complete.")
    /// }
    /// ```
    func isLoading() -> Bool {
        activityIndicators["1"].exists
    }

    /// An extension to `XCUIElement` to find and wait for a static text element to appear within a specified timeout period.
    /// Finds and waits for a static text element to exist within the given timeout.
    ///
    /// This function checks whether a static text element with the specified label exists in the UI
    /// within the specified timeout duration. It uses the `waitForExistence` method to perform this operation.
    ///
    /// - Parameters:
    ///   - staticText: A `String` representing the label of the static text element to find.
    ///   - timeout: A `TimeInterval` specifying the maximum amount of time to wait for the element to appear.
    /// - Returns: A `Bool` value indicating whether the element exists (`true`) or not (`false`) within the timeout period.
    ///
    /// Example usage:
    ///
    /// ```swift
    /// let app = XCUIApplication()
    /// app.launch()
    /// XCTAssertTrue(app.findAndWait(staticText: "Welcome", timeout: 5))
    /// ```
    func findAndWait(staticText: String, timeout: TimeInterval) -> Bool {
        return staticTexts[staticText].waitForExistence(timeout: timeout)
    }
}
