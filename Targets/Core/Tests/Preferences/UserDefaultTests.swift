//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

@testable import Core
import Foundation
import XCTest

private extension Key {
    static let testKey: Key = "testKey"
}

final class UserDefaultTests: XCTestCase {
    struct TestCodable: Codable, Equatable {
        let value1: String
        let value2: [String]
        let value3: [String: String]
    }

    override func setUp() {
        UserDefaults.standard.removeObject(forKey: Key.testKey.rawValue)
    }

    func test_withData_shouldStore() {
        @UserDefault(key: .testKey, defaultValue: Data())
        var testValue: Data?

        XCTAssertEqual(testValue, Data())

        testValue = "LoremIpsum".data(using: .utf8)!
        XCTAssertEqual(testValue, "LoremIpsum".data(using: .utf8)!)
    }

    func test_withDataWithoutDefault_shouldStore() {
        @UserDefault(key: .testKey)
        var testValue: Data?

        XCTAssertEqual(testValue, nil)

        testValue = "LoremIpsum".data(using: .utf8)!
        XCTAssertEqual(testValue, "LoremIpsum".data(using: .utf8)!)
    }

    // MARK: -

    func test_withString_shouldStore() {
        @UserDefault(key: .testKey, defaultValue: "")
        var testValue: String?

        XCTAssertEqual(testValue, "")

        testValue = "LoremIpsum"
        XCTAssertEqual(testValue, "LoremIpsum")
    }

    func test_withStringWithoutDefault_shouldStore() {
        @UserDefault(key: .testKey)
        var testValue: String?

        XCTAssertEqual(testValue, nil)

        testValue = "LoremIpsum"
        XCTAssertEqual(testValue, "LoremIpsum")
    }

    // MARK: -

    func test_withDate_shouldStore() {
        @UserDefault(key: .testKey, defaultValue: Date(timeIntervalSince1970: 123))
        var testValue: Date?

        XCTAssertEqual(testValue, Date(timeIntervalSince1970: 123))

        testValue = Date(timeIntervalSince1970: 456)
        XCTAssertEqual(testValue, Date(timeIntervalSince1970: 456))
    }

    func test_withDateWithoutDefault_shouldStore() {
        @UserDefault(key: .testKey)
        var testValue: Date?

        XCTAssertEqual(testValue, nil)

        testValue = Date(timeIntervalSince1970: 123)
        XCTAssertEqual(testValue, Date(timeIntervalSince1970: 123))
    }

    // MARK: -

    func test_withBool_shouldStore() {
        @UserDefault(key: .testKey, defaultValue: false)
        var testValue: Bool?

        XCTAssertEqual(testValue, false)

        testValue = true
        XCTAssertEqual(testValue, true)
    }

    func test_withBoolWithoutDefault_shouldStore() {
        @UserDefault(key: .testKey)
        var testValue: Bool?

        XCTAssertEqual(testValue, nil)

        testValue = true
        XCTAssertEqual(testValue, true)
    }

    // MARK: -

    func test_withInt_shouldStore() {
        @UserDefault(key: .testKey, defaultValue: 0)
        var testValue: Int?

        XCTAssertEqual(testValue, 0)

        testValue = 123
        XCTAssertEqual(testValue, 123)
    }

    func test_withIntWithoutDefault_shouldStore() {
        @UserDefault(key: .testKey)
        var testValue: Int?

        XCTAssertEqual(testValue, nil)

        testValue = 123
        XCTAssertEqual(testValue, 123)
    }

    // MARK: -

    func test_withDouble_shouldStore() {
        @UserDefault(key: .testKey, defaultValue: 0.0)
        var testValue: Double?

        XCTAssertEqual(testValue, 0.0)

        testValue = 1.23
        XCTAssertEqual(testValue, 1.23)
    }

    func test_withDoubleWithoutDefault_shouldStore() {
        @UserDefault(key: .testKey)
        var testValue: Double?

        XCTAssertEqual(testValue, nil)

        testValue = 1.23
        XCTAssertEqual(testValue, 1.23)
    }

    // MARK: -

    func test_withFloat_shouldStore() {
        @UserDefault(key: .testKey, defaultValue: 0.0)
        var testValue: Float?

        XCTAssertEqual(testValue, 0.0)

        testValue = 4.56
        XCTAssertEqual(testValue, 4.56)
    }

    func test_withFloatWithoutDefault_shouldStore() {
        @UserDefault(key: .testKey)
        var testValue: Float?

        XCTAssertEqual(testValue, nil)

        testValue = 4.56
        XCTAssertEqual(testValue, 4.56)
    }

    // MARK: -

    func test_withArrayOfString_shouldStore() {
        @UserDefault(key: .testKey, defaultValue: [])
        var testValue: [String]?

        XCTAssertEqual(testValue, [])

        testValue = ["Lorem", "Ipsum"]
        XCTAssertEqual(testValue, ["Lorem", "Ipsum"])
    }

    func test_withArrayOfStringWithoutDefault_shouldStore() {
        @UserDefault(key: .testKey)
        var testValue: [String]?

        XCTAssertEqual(testValue, nil)

        testValue = ["Lorem", "Ipsum"]
        XCTAssertEqual(testValue, ["Lorem", "Ipsum"])
    }

    // MARK: -

    func test_withDictionaryOfStringWithString_shouldStore() {
        @UserDefault(key: .testKey, defaultValue: [:])
        var testValue: [String: String]?

        XCTAssertEqual(testValue, [:])

        testValue = ["Lorem": "Ipsum", "Dolor": "Sit"]
        XCTAssertEqual(testValue, ["Lorem": "Ipsum", "Dolor": "Sit"])
    }

    func test_withDictionaryOfStringWithStringWithoutDefault_shouldStore() {
        @UserDefault(key: .testKey)
        var testValue: [String: String]?

        XCTAssertEqual(testValue, nil)

        testValue = ["Lorem": "Ipsum", "Dolor": "Sit"]
        XCTAssertEqual(testValue, ["Lorem": "Ipsum", "Dolor": "Sit"])
    }

    // MARK: -

    func test_withCodable_shouldStore() {
        @CodableUserDefault(
            key: .testKey,
            defaultValue: TestCodable(
                value1: "",
                value2: [],
                value3: [:]
            )
        )
        var testValue: TestCodable?

        XCTAssertEqual(
            testValue,
            TestCodable(
                value1: "",
                value2: [],
                value3: [:]
            )
        )

        testValue = TestCodable(
            value1: "Lorem",
            value2: ["Lorem", "Ipsum"],
            value3: ["Lorem": "Ipsum", "Dolor": "Sit"]
        )
        XCTAssertEqual(
            testValue,
            TestCodable(
                value1: "Lorem",
                value2: ["Lorem", "Ipsum"],
                value3: ["Lorem": "Ipsum", "Dolor": "Sit"]
            )
        )
    }

    func test_withCodableWithoutDefault_shouldStore() {
        @CodableUserDefault(key: .testKey)
        var testValue: TestCodable?

        XCTAssertEqual(testValue, nil)

        testValue = TestCodable(
            value1: "Lorem",
            value2: ["Lorem", "Ipsum"],
            value3: ["Lorem": "Ipsum", "Dolor": "Sit"]
        )
        XCTAssertEqual(
            testValue,
            TestCodable(
                value1: "Lorem",
                value2: ["Lorem", "Ipsum"],
                value3: ["Lorem": "Ipsum", "Dolor": "Sit"]
            )
        )
    }
}
