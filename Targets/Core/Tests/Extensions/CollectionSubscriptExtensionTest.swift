//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

@testable import Core
import XCTest

final class CollectionSubscriptExtensionTest: XCTestCase {
    let testArray = ["Alice", "Bob", "Charlie", "David", "Eve"]

    func testSafeIndex_testArray_shouldReturnNil() {
        XCTAssertNil(testArray[safe: 5])
    }

    func testSafeIndex_testArray_shouldReturnValue() {
        XCTAssertNotNil(testArray[safe: 2])
        if let value = testArray[safe: 2] {
            XCTAssertEqual("Charlie", value)
        }
    }
}
