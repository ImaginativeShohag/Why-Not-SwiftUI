// The Swift Programming Language
// https://docs.swift.org/swift-book

import XCTest

public extension XCUIElement {
    func isLoading() -> Bool {
        activityIndicators["1"].exists
    }
}
