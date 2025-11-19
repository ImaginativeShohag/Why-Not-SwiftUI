//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

@testable import Core
import XCTest

class EncodableToJsonStringTests: XCTestCase {
    func testToJSONString() {
        struct Person: Codable {
            let name: String
            let age: Int
        }

        let person = Person(name: "John Doe", age: 30)
        let expectedJSONString = "{\"age\":30,\"name\":\"John Doe\"}"
        XCTAssertEqual(try! person.toJSONString(), expectedJSONString)
    }

    func testToJSONStringWithNestedObjects() {
        struct Address: Codable {
            let street: String
            let city: String
        }

        struct Person: Codable {
            let name: String
            let age: Int
            let address: Address
        }

        let address = Address(street: "123 Main St", city: "New York")
        let person = Person(name: "John Doe", age: 30, address: address)
        let expectedJSONString = "{\"address\":{\"city\":\"New York\",\"street\":\"123 Main St\"},\"age\":30,\"name\":\"John Doe\"}"
        XCTAssertEqual(try! person.toJSONString(), expectedJSONString)
    }

    func testToJSONStringWithArray() {
        let numbers = [1, 2, 3, 4, 5]
        let expectedJSONString = "[1,2,3,4,5]"
        XCTAssertEqual(try! numbers.toJSONString(), expectedJSONString)
    }

    func testToJSONStringWithEmptyObject() {
        struct EmptyObject: Codable {}
        let emptyObject = EmptyObject()
        let expectedJSONString = "{}"
        XCTAssertEqual(try! emptyObject.toJSONString(), expectedJSONString)
    }

    func testToJSONStringWithEmptyArray() {
        let emptyArray: [String] = []
        let expectedJSONString = "[]"
        XCTAssertEqual(try! emptyArray.toJSONString(), expectedJSONString)
    }

    func testToJSONStringWithEmptyString() {
        let emptyString = ""
        let expectedJSONString = "\"\""
        XCTAssertEqual(try! emptyString.toJSONString(), expectedJSONString)
    }

    func testToJSONStringWithString() {
        let invalidJsonString = "lorem"
        let expectedJSONString = "\"lorem\""
        XCTAssertEqual(try! invalidJsonString.toJSONString(), expectedJSONString)
    }

    func testToJSONString_blankDataObject_shouldReturnBlankString() {
        struct InvalidData: Codable {
            let value: Data
        }

        let invalidData = InvalidData(value: Data())
        let expectedJSONString = "{\"value\":\"\"}"
        XCTAssertEqual(try! invalidData.toJSONString(), expectedJSONString)
    }

    func testToJSONString_infinity_shouldThrowsError() {
        struct Person: Codable {
            let name: String
            let age: Float
        }

        let person = Person(name: "John Doe", age: .infinity)

        XCTAssertThrowsError(try person.toJSONString())
    }
}
