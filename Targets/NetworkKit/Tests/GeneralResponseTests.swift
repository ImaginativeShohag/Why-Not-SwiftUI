//
//  Copyright © 2024 Apple Inc. All rights reserved.
//

@testable import NetworkKit
import XCTest

final class GeneralResponseTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_getMessage_withValidMessage() {
        let message = "success"
        let generalResponse = GeneralResponse(success: true, message: message)
        XCTAssertEqual(generalResponse.getMessage(), message)
    }

    func test_getMessage_withEmptyMessage() {
        let generalResponse = GeneralResponse(success: true, message: "")
        XCTAssertEqual(generalResponse.getMessage(), "Something went wrong. Try again.")
    }

    func test_getMessage_withNilMessage() {
        let generalResponse = GeneralResponse(success: true, message: nil)
        XCTAssertEqual(generalResponse.getMessage(), "Something went wrong. Try again.")
    }
}
