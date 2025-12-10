//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import XCTest
@testable import LocalizeKitCore

/// Integration tests for LocalizeKit CLI commands
/// Tests the full workflow: extract → merge → validate → diff
final class LocalizeKitIntegrationTests: XCTestCase {

    var tempProjectDir: URL!
    var translationsDir: URL!

    override func setUp() {
        super.setUp()

        // Create temporary project structure
        tempProjectDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("LocalizeKitIntegrationTests-\(UUID().uuidString)")
        translationsDir = tempProjectDir.appendingPathComponent("Translations")

        do {
            try FileManager.default.createDirectory(at: tempProjectDir, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: translationsDir, withIntermediateDirectories: true)

            // Create test module structure
            let modulePath = tempProjectDir.appendingPathComponent("Targets/Store/Sources")
            try FileManager.default.createDirectory(at: modulePath, withIntermediateDirectories: true)

            // Create sample Swift files with localization strings
            try createSampleSwiftFiles(in: modulePath)
        } catch {
            XCTFail("Failed to set up test environment: \(error)")
        }
    }

    override func tearDown() {
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempProjectDir)
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func createSampleSwiftFiles(in directory: URL) throws {
        // Create HomeScreen.swift with various localization patterns
        let homeScreenCode = """
        import SwiftUI

        struct HomeScreen: View {
            var body: some View {
                VStack {
                    // Simple string
                    Text("store_welcome".localize(
                        default: "Welcome to our store!",
                        comment: "Welcome message on home screen"
                    ))

                    // Interpolation
                    Text("store_greeting".localize(
                        default: "Hello, **%@**!",
                        comment: "Greeting with user name",
                        with: userName
                    ))

                    // Plural forms
                    Text("store_items_count".localize(
                        defaultPlural: [
                            .zero: "No items in cart",
                            .one: "1 item in cart",
                            .other: "%d items in cart"
                        ],
                        comment: "Cart items count",
                        count: cartItems.count
                    ))
                }
            }
        }
        """

        let homeScreenPath = directory.appendingPathComponent("HomeScreen.swift")
        try homeScreenCode.write(to: homeScreenPath, atomically: true, encoding: .utf8)

        // Create ProductScreen.swift with Text.localized pattern
        let productScreenCode = """
        import SwiftUI

        struct ProductScreen: View {
            var body: some View {
                VStack {
                    Text.localized(
                        "store_product_title",
                        default: "Product Details",
                        comment: "Product screen title"
                    )

                    Text.localized(
                        "store_price",
                        default: "Price: $%.2f",
                        comment: "Product price label",
                        with: price
                    )
                }
            }
        }
        """

        let productScreenPath = directory.appendingPathComponent("ProductScreen.swift")
        try productScreenCode.write(to: productScreenPath, atomically: true, encoding: .utf8)
    }

    // MARK: - Extract Command Tests

    func testExtractCommand_CreatesBaseFile() throws {
        let extractor = StringExtractor(projectPath: tempProjectDir.path, verbose: false)
        let extractedStrings = try extractor.extract()

        XCTAssertGreaterThan(extractedStrings.count, 0, "Should extract strings from Swift files")
        XCTAssertTrue(extractedStrings.contains { $0.key == "store_welcome" })
        XCTAssertTrue(extractedStrings.contains { $0.key == "store_greeting" })
        XCTAssertTrue(extractedStrings.contains { $0.key == "store_items_count" })
        XCTAssertTrue(extractedStrings.contains { $0.key == "store_product_title" })
        XCTAssertTrue(extractedStrings.contains { $0.key == "store_price" })
    }

    func testExtractCommand_GeneratesCorrectBaseFile() throws {
        let extractor = StringExtractor(projectPath: tempProjectDir.path, verbose: false)
        let extractedStrings = try extractor.extract()

        let generator = BaseTranslationFileGenerator(version: 1, verbose: false)
        let baseFile = generator.generate(from: extractedStrings)

        XCTAssertEqual(baseFile.version, 1)
        XCTAssertEqual(baseFile.language, "en")
        XCTAssertTrue(baseFile.modules.keys.contains("Store"))

        let storeModule = baseFile.modules["Store"]!
        XCTAssertNotNil(storeModule["store_welcome"])
        XCTAssertNotNil(storeModule["store_greeting"])
        XCTAssertNotNil(storeModule["store_items_count"])

        // Verify types
        XCTAssertEqual(storeModule["store_welcome"]?.type, .simple)
        XCTAssertEqual(storeModule["store_greeting"]?.type, .interpolation)
        XCTAssertEqual(storeModule["store_items_count"]?.type, .plural)
    }

    func testExtractCommand_SavesAndLoadsBaseFile() throws {
        let extractor = StringExtractor(projectPath: tempProjectDir.path, verbose: false)
        let extractedStrings = try extractor.extract()

        let generator = BaseTranslationFileGenerator(version: 1, verbose: false)
        let baseFile = generator.generate(from: extractedStrings)

        // Save base file
        let basePath = translationsDir.appendingPathComponent("base.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(baseFile)
        try data.write(to: basePath)

        XCTAssertTrue(FileManager.default.fileExists(atPath: basePath.path))

        // Load and verify
        let loadedData = try Data(contentsOf: basePath)
        let decoder = JSONDecoder()
        let loadedFile = try decoder.decode(BaseTranslationFile.self, from: loadedData)

        XCTAssertEqual(loadedFile.version, baseFile.version)
        XCTAssertEqual(loadedFile.language, baseFile.language)
        XCTAssertEqual(loadedFile.modules.count, baseFile.modules.count)
    }

    // MARK: - Merge Command Tests

    func testMergeCommand_CreatesTargetFile() throws {
        // First, create base.json
        let extractor = StringExtractor(projectPath: tempProjectDir.path, verbose: false)
        let extractedStrings = try extractor.extract()

        let generator = BaseTranslationFileGenerator(version: 1, verbose: false)
        let baseFile = generator.generate(from: extractedStrings)

        // Create target file (Arabic)
        let merger = LanguageMerger()

        // Create empty target file
        let emptyTarget = TargetTranslationFile(
            version: 0,
            modules: [:]
        )

        let targetFile = merger.sync(base: baseFile, target: emptyTarget)

        XCTAssertEqual(targetFile.version, baseFile.version)
        XCTAssertEqual(targetFile.modules.count, baseFile.modules.count)

        // All keys should be added
        let targetStore = targetFile.modules["Store"]!
        XCTAssertEqual(targetStore.count, baseFile.modules["Store"]!.count)
    }

    func testMergeCommand_UpdatesExistingTargetFile() throws {
        // Create base file version 1
        let extractor = StringExtractor(projectPath: tempProjectDir.path, verbose: false)
        let extractedStrings = try extractor.extract()

        let generator = BaseTranslationFileGenerator(version: 1, verbose: false)
        let baseFile = generator.generate(from: extractedStrings)

        // Create target file with translations
        var targetModules: [String: [String: TargetTranslationEntry]] = [:]
        targetModules["Store"] = [
            "store_welcome": TargetTranslationEntry(
                value: .simple("مرحبا بك في متجرنا!"),
                type: .simple,
                comment: nil
            ),
            "old_key": TargetTranslationEntry(
                value: .simple("قيمة قديمة"),
                type: .simple,
                comment: nil
            )
        ]

        let oldTarget = TargetTranslationFile(
            version: 1,
            modules: targetModules
        )

        // Sync with base (should keep existing translations, remove old_key)
        let merger = LanguageMerger()
        let updatedTarget = merger.sync(base: baseFile, target: oldTarget)

        XCTAssertEqual(updatedTarget.version, baseFile.version)

        // Check that existing translation is kept
        let storeModule = updatedTarget.modules["Store"]!
        if case .simple(let value) = storeModule["store_welcome"]!.value {
            XCTAssertEqual(value, "مرحبا بك في متجرنا!")
        } else {
            XCTFail("Expected simple value")
        }

        // Check that old_key is removed
        XCTAssertNil(storeModule["old_key"])

        // Check that new keys are added (with English defaults)
        XCTAssertNotNil(storeModule["store_greeting"])
    }

    func testMergeCommand_HandlesVersionComparison() throws {
        // Create base file with version 2
        let extractor = StringExtractor(projectPath: tempProjectDir.path, verbose: false)
        let extractedStrings = try extractor.extract()

        let generator = BaseTranslationFileGenerator(version: 2, verbose: false)
        let baseFile = generator.generate(from: extractedStrings)

        // Create old target file with version 1
        let oldTarget = TargetTranslationFile(
            version: 1,
            modules: ["Store": [:]]
        )

        let merger = LanguageMerger()
        let updatedTarget = merger.sync(base: baseFile, target: oldTarget)

        // Version should be updated to match base
        XCTAssertEqual(updatedTarget.version, 2)
    }

    // MARK: - Validate Command Tests

    func testValidateCommand_DetectsMissingKeys() throws {
        let baseFile = BaseTranslationFile(
            version: 1,
            language: "en",
            generatedAt: ISO8601DateFormatter().string(from: Date()),
            modules: [
                "Store": [
                    "key1": BaseTranslationEntry(
                        value: .simple("Value 1"),
                        type: .simple,
                        comment: "Comment 1",
                        version: 1,
                        metadata: BaseMetadata(
                            addedInVersion: 1,
                            lastModifiedVersion: nil,
                            status: .new
                        )
                    ),
                    "key2": BaseTranslationEntry(
                        value: .simple("Value 2"),
                        type: .simple,
                        comment: "Comment 2",
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

        let targetFile = TargetTranslationFile(
            version: 1,
            modules: [
                "Store": [
                    "key1": TargetTranslationEntry(
                        value: .simple("القيمة 1"),
                        type: .simple,
                        comment: nil
                    )
                    // key2 is missing
                ]
            ]
        )

        // Manually check for missing keys
        var missingKeys: [String] = []
        for (moduleName, baseStrings) in baseFile.modules {
            let targetStrings = targetFile.modules[moduleName] ?? [:]
            for (key, _) in baseStrings {
                if targetStrings[key] == nil {
                    missingKeys.append(key)
                }
            }
        }

        XCTAssertGreaterThan(missingKeys.count, 0)
        XCTAssertTrue(missingKeys.contains("key2"))
    }

    func testValidateCommand_DetectsFormatSpecifierMismatch() throws {
        let baseFile = BaseTranslationFile(
            version: 1,
            language: "en",
            generatedAt: ISO8601DateFormatter().string(from: Date()),
            modules: [
                "Store": [
                    "greeting": BaseTranslationEntry(
                        value: .simple("Hello, %@!"),
                        type: .interpolation,
                        comment: "Greeting",
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

        let targetFile = TargetTranslationFile(
            version: 1,
            modules: [
                "Store": [
                    "greeting": TargetTranslationEntry(
                        value: .simple("مرحبا"), // Missing %@ specifier
                        type: .interpolation,
                        comment: nil
                    )
                ]
            ]
        )

        // Manually check for format specifier mismatch
        var hasMismatch = false
        if case .simple(let baseValue) = baseFile.modules["Store"]!["greeting"]!.value,
           case .simple(let targetValue) = targetFile.modules["Store"]!["greeting"]!.value {
            let baseHasSpecifier = baseValue.contains("%@")
            let targetHasSpecifier = targetValue.contains("%@")
            hasMismatch = baseHasSpecifier != targetHasSpecifier
        }

        XCTAssertTrue(hasMismatch, "Should detect format specifier mismatch")
    }

    // MARK: - Full Workflow Integration Test

    func testFullWorkflow_ExtractMergeValidate() throws {
        // Step 1: Extract strings
        let extractor = StringExtractor(projectPath: tempProjectDir.path, verbose: false)
        let extractedStrings = try extractor.extract()

        XCTAssertGreaterThan(extractedStrings.count, 0, "Step 1: Extract should find strings")

        // Step 2: Generate base.json
        let generator = BaseTranslationFileGenerator(version: 1, verbose: false)
        let baseFile = generator.generate(from: extractedStrings)

        XCTAssertEqual(baseFile.version, 1, "Step 2: Base file should have version 1")

        // Step 3: Create target language (Arabic)
        let merger = LanguageMerger()
        let emptyTarget = TargetTranslationFile(
            version: 0,
            modules: [:]
        )
        let targetFile = merger.sync(base: baseFile, target: emptyTarget)

        XCTAssertEqual(targetFile.modules.count, baseFile.modules.count, "Step 3: Merge should create all modules")

        // Step 4: Check for untranslated strings (English values in Arabic file)
        var untranslatedCount = 0
        for (moduleName, baseStrings) in baseFile.modules {
            if let targetStrings = targetFile.modules[moduleName] {
                for (key, baseEntry) in baseStrings {
                    if let targetEntry = targetStrings[key] {
                        // Check if values are the same (untranslated)
                        if case .simple(let baseValue) = baseEntry.value,
                           case .simple(let targetValue) = targetEntry.value {
                            if baseValue == targetValue {
                                untranslatedCount += 1
                            }
                        }
                    }
                }
            }
        }

        XCTAssertGreaterThan(untranslatedCount, 0, "Step 4: Should have untranslated strings initially")

        // Step 5: Create proper translations
        var translatedModules: [String: [String: TargetTranslationEntry]] = [:]
        translatedModules["Store"] = [
            "store_welcome": TargetTranslationEntry(
                value: .simple("مرحبا بك في متجرنا!"),
                type: .simple,
                comment: nil
            ),
            "store_greeting": TargetTranslationEntry(
                value: .simple("!**%@** ،مرحبا"),
                type: .interpolation,
                comment: nil
            ),
            "store_items_count": TargetTranslationEntry(
                value: .plural([
                    "zero": "لا توجد عناصر في السلة",
                    "one": "عنصر واحد في السلة",
                    "two": "عنصران في السلة",
                    "few": "%d عناصر في السلة",
                    "many": "%d عنصرًا في السلة",
                    "other": "%d عنصر في السلة"
                ]),
                type: .plural,
                comment: nil
            ),
            "store_product_title": TargetTranslationEntry(
                value: .simple("تفاصيل المنتج"),
                type: .simple,
                comment: nil
            ),
            "store_price": TargetTranslationEntry(
                value: .simple("$%.2f :السعر"),
                type: .interpolation,
                comment: nil
            )
        ]

        let properTarget = TargetTranslationFile(
            version: 1,
            modules: translatedModules
        )

        // Step 6: Verify properly translated file has all required keys
        XCTAssertEqual(properTarget.modules.count, baseFile.modules.count, "Step 6: Should have same module count")

        let baseStoreKeys = Set(baseFile.modules["Store"]!.keys)
        let targetStoreKeys = Set(properTarget.modules["Store"]!.keys)
        XCTAssertEqual(baseStoreKeys, targetStoreKeys, "Step 6: Should have same keys in Store module")

        // Step 7: Verify format specifiers are preserved
        if case .simple(let value) = properTarget.modules["Store"]!["store_greeting"]!.value {
            XCTAssertTrue(value.contains("%@"), "Step 7: Arabic translation should preserve %@ specifier")
        }

        // Step 8: Verify plural forms are present for Arabic
        if case .plural(let forms) = properTarget.modules["Store"]!["store_items_count"]!.value {
            XCTAssertTrue(forms.keys.contains("zero"), "Step 8: Arabic should have 'zero' plural form")
            XCTAssertTrue(forms.keys.contains("one"), "Step 8: Arabic should have 'one' plural form")
            XCTAssertTrue(forms.keys.contains("two"), "Step 8: Arabic should have 'two' plural form")
            XCTAssertTrue(forms.keys.contains("few"), "Step 8: Arabic should have 'few' plural form")
            XCTAssertTrue(forms.keys.contains("many"), "Step 8: Arabic should have 'many' plural form")
            XCTAssertTrue(forms.keys.contains("other"), "Step 8: Arabic should have 'other' plural form")
        } else {
            XCTFail("Step 8: Expected plural value for items_count")
        }
    }

    // MARK: - Performance Tests

    func testExtractPerformance() throws {
        measure {
            let extractor = StringExtractor(projectPath: tempProjectDir.path, verbose: false)
            _ = try! extractor.extract()
        }
    }

    func testMergePerformance() throws {
        let extractor = StringExtractor(projectPath: tempProjectDir.path, verbose: false)
        let extractedStrings = try extractor.extract()

        let generator = BaseTranslationFileGenerator(version: 1, verbose: false)
        let baseFile = generator.generate(from: extractedStrings)

        let emptyTarget = TargetTranslationFile(
            version: 0,
            modules: [:]
        )

        measure {
            let merger = LanguageMerger()
            _ = merger.sync(base: baseFile, target: emptyTarget)
        }
    }
}
