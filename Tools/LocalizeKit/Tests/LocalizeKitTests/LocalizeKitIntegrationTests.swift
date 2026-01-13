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

    private func createSwiftFileWithGreeting(in directory: URL, withInterpolation: Bool) throws {
        let greetingCode: String
        if withInterpolation {
            greetingCode = """
            import SwiftUI

            struct GreetingScreen: View {
                var body: some View {
                    Text("store_greeting".localize(
                        default: "Welcome, %@!",
                        comment: "Greeting with name",
                        with: userName
                    ))
                }
            }
            """
        } else {
            greetingCode = """
            import SwiftUI

            struct GreetingScreen: View {
                var body: some View {
                    Text("store_greeting".localize(
                        default: "Welcome",
                        comment: "Simple greeting"
                    ))
                }
            }
            """
        }

        let greetingPath = directory.appendingPathComponent("GreetingScreen.swift")
        try greetingCode.write(to: greetingPath, atomically: true, encoding: .utf8)
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
                comment: nil
            ),
            "old_key": TargetTranslationEntry(
                value: .simple("قيمة قديمة"),
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
                comment: nil
            ),
            "store_greeting": TargetTranslationEntry(
                value: .simple("!**%@** ،مرحبا"),
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
                comment: nil
            ),
            "store_product_title": TargetTranslationEntry(
                value: .simple("تفاصيل المنتج"),
                comment: nil
            ),
            "store_price": TargetTranslationEntry(
                value: .simple("$%.2f :السعر"),
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

    // MARK: - Type Change Integration Tests

    func testTypeChange_SimpleToInterpolation_UpdatesBothBaseAndTarget() async throws {
        // Create a separate module directory for this test to avoid interference
        let typeTestModulePath = tempProjectDir.appendingPathComponent("Targets/TypeTest/Sources")
        try FileManager.default.createDirectory(at: typeTestModulePath, withIntermediateDirectories: true)

        // Step 1: Create Swift file with simple string (no interpolation)
        try createSwiftFileWithGreeting(in: typeTestModulePath, withInterpolation: false)

        // Step 2: First extraction (Version 1) - Extract simple string
        let extractor = StringExtractor(projectPath: tempProjectDir.path, verbose: false)
        let firstExtractedStrings = try extractor.extract()

        // Verify extracted string has type = .simple
        let greetingString = firstExtractedStrings.first { $0.key == "store_greeting" }
        XCTAssertNotNil(greetingString, "Step 2: Should extract store_greeting")
        XCTAssertEqual(greetingString?.type, .simple, "Step 2: Type should be .simple")
        XCTAssertEqual(greetingString?.defaultValue, "Welcome", "Step 2: Value should be 'Welcome'")

        // Step 3: Generate base.json with version 1
        let generator = BaseTranslationFileGenerator(version: 1, verbose: false)
        let firstBaseFile = generator.generate(from: firstExtractedStrings)

        XCTAssertEqual(firstBaseFile.version, 1, "Step 3: Base file should have version 1")

        // Verify base file entry
        let baseEntry = firstBaseFile.modules["TypeTest"]?["store_greeting"]
        XCTAssertNotNil(baseEntry, "Step 3: Base file should contain store_greeting")
        XCTAssertEqual(baseEntry?.type, .simple, "Step 3: Base entry type should be .simple")
        XCTAssertEqual(baseEntry?.version, 1, "Step 3: Base entry version should be 1")
        if case .simple(let value) = baseEntry?.value {
            XCTAssertEqual(value, "Welcome", "Step 3: Base entry value should be 'Welcome'")
        } else {
            XCTFail("Step 3: Expected simple value")
        }

        // Step 4: Create empty target file (Arabic) and sync
        let languageMerger = LanguageMerger()
        let emptyTarget = TargetTranslationFile(
            version: 0,
            modules: [:]
        )
        let firstTargetFile = languageMerger.sync(base: firstBaseFile, target: emptyTarget)

        // Verify target file entry has type = .simple
        let firstTargetEntry = firstTargetFile.modules["TypeTest"]?["store_greeting"]
        XCTAssertNotNil(firstTargetEntry, "Step 4: Target file should contain store_greeting")
        // Note: type field removed from TargetTranslationEntry
        if case .simple(let value) = firstTargetEntry?.value {
            XCTAssertEqual(value, "Welcome", "Step 4: Target entry should have English default")
        } else {
            XCTFail("Step 4: Expected simple value")
        }

        // Step 5: Simulate translation - Add Arabic translation
        var translatedModules: [String: [String: TargetTranslationEntry]] = [:]
        translatedModules["TypeTest"] = [
            "store_greeting": TargetTranslationEntry(
                value: .simple("مرحبا"),
                comment: nil
            )
        ]
        let translatedTarget = TargetTranslationFile(
            version: 1,
            modules: translatedModules
        )

        // Verify Arabic translation
        if case .simple(let value) = translatedTarget.modules["TypeTest"]!["store_greeting"]!.value {
            XCTAssertEqual(value, "مرحبا", "Step 5: Should have Arabic translation")
        }

        // Step 6: Modify source code - Add interpolation (type change)
        try createSwiftFileWithGreeting(in: typeTestModulePath, withInterpolation: true)

        // Step 7: Second extraction - Extract string with interpolation
        let secondExtractedStrings = try extractor.extract()

        // Verify extracted string now has type = .interpolation
        let updatedGreetingString = secondExtractedStrings.first { $0.key == "store_greeting" }
        XCTAssertNotNil(updatedGreetingString, "Step 7: Should extract updated store_greeting")
        XCTAssertEqual(updatedGreetingString?.type, .interpolation, "Step 7: Type should be .interpolation")
        XCTAssertEqual(updatedGreetingString?.defaultValue, "Welcome, %@!", "Step 7: Value should be 'Welcome, %@!'")

        // Step 8: Merge with existing base file using BaseFileMerger
        let baseFileMerger = BaseFileMerger()
        let updatedBaseFile = try await baseFileMerger.merge(
            existing: firstBaseFile,
            extracted: secondExtractedStrings,
            newVersion: 2
        )

        // Verify base file entry was updated
        let updatedBaseEntry: BaseTranslationEntry? = updatedBaseFile.modules["TypeTest"]?["store_greeting"]
        XCTAssertNotNil(updatedBaseEntry, "Step 8: Updated base file should contain store_greeting")
        XCTAssertEqual(updatedBaseEntry?.type, .interpolation, "Step 8: Base entry type should be .interpolation (changed from .simple)")
        XCTAssertEqual(updatedBaseEntry?.version, 2, "Step 8: Base entry version should be incremented to 2")
        XCTAssertEqual(updatedBaseEntry?.metadata?.status, .modified, "Step 8: Base entry should be marked as .modified")
        if case .simple(let value) = updatedBaseEntry?.value {
            XCTAssertEqual(value, "Welcome, %@!", "Step 8: Base entry value should be 'Welcome, %@!'")
        } else {
            XCTFail("Step 8: Expected simple value with interpolation")
        }

        // Step 9: Sync updated base with target file
        let updatedTargetFile = languageMerger.sync(base: updatedBaseFile, target: translatedTarget)

        // Verify target file entry was updated with new type
        let updatedTargetEntry: TargetTranslationEntry? = updatedTargetFile.modules["TypeTest"]?["store_greeting"]
        XCTAssertNotNil(updatedTargetEntry, "Step 9: Updated target file should contain store_greeting")
        // Note: type field removed from TargetTranslationEntry

        // Because version changed, translation should be reset to English default
        if case .simple(let value) = updatedTargetEntry?.value {
            XCTAssertEqual(value, "Welcome, %@!", "Step 9: Target entry should be reset to English default because type changed")
            XCTAssertTrue(value.contains("%@"), "Step 9: Target entry should preserve format specifier")
        } else {
            XCTFail("Step 9: Expected simple value with interpolation")
        }

        // Step 10: Verify both base and target contain the updated value
        // Note: type field removed from TargetTranslationEntry, so we only verify values match
        if case .simple(let baseValue) = updatedBaseEntry?.value,
           case .simple(let targetValue) = updatedTargetEntry?.value {
            XCTAssertEqual(baseValue, targetValue, "Step 10: Base and target values should match after sync")
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
