//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

@testable import LocalizeKitCore
import XCTest

/// Comprehensive test suite for LocalizeKit core functionality
final class LocalizeKitCoreTests: XCTestCase {
    // MARK: - Translation Models Tests

    func testTranslationValueSimpleEncoding() throws {
        let value = TranslationValue.simple("Hello World")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(value)
        let string = String(data: data, encoding: .utf8)

        XCTAssertNotNil(string)
        XCTAssertTrue(string!.contains("Hello World"))
    }

    func testTranslationValuePluralEncoding() throws {
        let plural = TranslationValue.plural([
            "one": "1 item",
            "other": "%d items"
        ])

        let encoder = JSONEncoder()
        let data = try encoder.encode(plural)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TranslationValue.self, from: data)

        if case .plural(let forms) = decoded {
            XCTAssertEqual(forms["one"], "1 item")
            XCTAssertEqual(forms["other"], "%d items")
        } else {
            XCTFail("Expected plural value")
        }
    }

    func testBaseTranslationFileEncoding() throws {
        let baseFile = BaseTranslationFile(
            version: 1,
            language: "en",
            generatedAt: "2025-12-04T00:00:00Z",
            modules: [
                "TestModule": [
                    "test_key": BaseTranslationEntry(
                        value: .simple("Test Value"),
                        type: .simple,
                        comment: "Test comment",
                        version: 1,
                        metadata: BaseMetadata(
                            addedInVersion: 1,
                            lastModifiedVersion: nil,
                            status: .new
                        )
                    )
                ]
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(baseFile)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(BaseTranslationFile.self, from: data)

        XCTAssertEqual(decoded.version, 1)
        XCTAssertEqual(decoded.language, "en")
        XCTAssertEqual(decoded.modules.count, 1)
        XCTAssertNotNil(decoded.modules["TestModule"])
    }

    func testTargetTranslationFileEncoding() throws {
        let targetFile = TargetTranslationFile(
            version: 1,
            modules: [
                "TestModule": [
                    "test_key": TargetTranslationEntry(
                        value: .simple("القيمة"),
                        comment: nil
                    )
                ]
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(targetFile)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TargetTranslationFile.self, from: data)

        XCTAssertEqual(decoded.version, 1)
        XCTAssertEqual(decoded.modules.count, 1)
    }

    // MARK: - Translation Type Tests

    func testTranslationType() {
        XCTAssertEqual(TranslationType.simple, TranslationType.simple)
        XCTAssertEqual(TranslationType.interpolation, TranslationType.interpolation)
        XCTAssertEqual(TranslationType.plural, TranslationType.plural)
        XCTAssertNotEqual(TranslationType.simple, TranslationType.interpolation)
    }

    func testTranslationStatus() {
        XCTAssertEqual(TranslationStatus.new, TranslationStatus.new)
        XCTAssertEqual(TranslationStatus.modified, TranslationStatus.modified)
        XCTAssertEqual(TranslationStatus.unchanged, TranslationStatus.unchanged)
    }

    // MARK: - File Loading Tests

    func testLoadTranslationFileFromJSON() throws {
        let jsonString = """
        {
            "version": 1,
            "language": "en",
            "generatedAt": "2025-12-04T00:00:00Z",
            "modules": {
                "Store": {
                    "store_welcome": {
                        "value": "Welcome!",
                        "type": "simple",
                        "comment": "Welcome message",
                        "version": 1,
                        "metadata": {
                            "addedInVersion": 1,
                            "status": "new"
                        }
                    }
                }
            }
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let baseFile = try decoder.decode(BaseTranslationFile.self, from: data)

        XCTAssertEqual(baseFile.version, 1)
        XCTAssertEqual(baseFile.language, "en")
        XCTAssertEqual(baseFile.modules.count, 1)

        let entry = baseFile.modules["Store"]?["store_welcome"]
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.version, 1)
        XCTAssertEqual(entry?.comment, "Welcome message")
    }

    func testLoadTargetFileFromJSON() throws {
        let jsonString = """
        {
            "version": 1,
            "modules": {
                "Store": {
                    "store_welcome": {
                        "value": "مرحبا"
                    }
                }
            }
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let targetFile = try decoder.decode(TargetTranslationFile.self, from: data)

        XCTAssertEqual(targetFile.version, 1)
        XCTAssertEqual(targetFile.modules.count, 1)

        let entry = targetFile.modules["Store"]?["store_welcome"]
        XCTAssertNotNil(entry)
        if case .simple(let value) = entry?.value {
            XCTAssertEqual(value, "مرحبا")
        }
    }

    // MARK: - Plural Forms Tests

    func testPluralFormsPreservation() throws {
        let pluralEntry = BaseTranslationEntry(
            value: .plural([
                "zero": "No items",
                "one": "1 item",
                "two": "2 items",
                "few": "%d items (few)",
                "many": "%d items (many)",
                "other": "%d items"
            ]),
            type: .plural,
            comment: "Item count",
            version: 1,
            metadata: BaseMetadata(
                addedInVersion: 1,
                lastModifiedVersion: nil,
                status: .new
            )
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(pluralEntry)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(BaseTranslationEntry.self, from: data)

        if case .plural(let forms) = decoded.value {
            XCTAssertEqual(forms.count, 6)
            XCTAssertEqual(forms["zero"], "No items")
            XCTAssertEqual(forms["one"], "1 item")
            XCTAssertEqual(forms["two"], "2 items")
            XCTAssertEqual(forms["few"], "%d items (few)")
            XCTAssertEqual(forms["many"], "%d items (many)")
            XCTAssertEqual(forms["other"], "%d items")
        } else {
            XCTFail("Expected plural value")
        }
    }

    // MARK: - Format Specifier Detection Tests

    func testFormatSpecifierDetection() {
        let stringWithAtSpecifier = "Hello, %@!"
        XCTAssertTrue(stringWithAtSpecifier.contains("%@"))

        let stringWithDSpecifier = "You have %d items"
        XCTAssertTrue(stringWithDSpecifier.contains("%d"))

        let simpleString = "Hello World"
        XCTAssertFalse(simpleString.contains("%@"))
        XCTAssertFalse(simpleString.contains("%d"))
    }

    // MARK: - Performance Tests

    func testTranslationValueEncodingPerformance() throws {
        let value = TranslationValue.simple("Test")

        measure {
            for _ in 0..<1000 {
                _ = try? JSONEncoder().encode(value)
            }
        }
    }

    func testBaseFileEncodingPerformance() throws {
        let baseFile = BaseTranslationFile(
            version: 1,
            language: "en",
            generatedAt: "2025-12-04T00:00:00Z",
            modules: [
                "Module1": [:],
                "Module2": [:],
                "Module3": [:]
            ]
        )

        measure {
            for _ in 0..<100 {
                _ = try? JSONEncoder().encode(baseFile)
            }
        }
    }
}
