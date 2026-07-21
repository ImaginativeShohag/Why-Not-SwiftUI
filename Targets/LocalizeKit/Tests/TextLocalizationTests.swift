@testable import LocalizeKit
import SwiftUI
import XCTest

/// Unit tests for the `Text+Localization` extension (markdown-aware localized `Text`).
///
/// `Text.localized(...)` delegates string resolution to `String.localize(...)` (covered by
/// `StringLocalizationTests`) and then wraps the result in a markdown-rendered `Text`. These tests
/// focus on that `Text`-specific layer: correct integration with `localize`, the multi-argument
/// `String(format:arguments:)` path, and the markdown rendering branch.
@MainActor
final class TextLocalizationTests: XCTestCase {
    // MARK: - Constants

    /// Mock file path for Store module to simulate calling from Store module.
    private let storeModuleFile = "Store/Sources/UI/TestScreen.swift"

    // MARK: - Setup / Teardown

    override func setUp() async throws {
        try await super.setUp()
        // Clear any existing translations before each test.
        await LocalizationManager.shared.clearCache()
        // Reset custom plural rules so built-in CLDR rules are used.
        LocalizationManager.shared.configure(pluralRules: [:])
    }

    override func tearDown() async throws {
        // Clean up after each test.
        await LocalizationManager.shared.clearCache()
        try await super.tearDown()
    }

    // MARK: - Helper Methods

    /// Builds the `Text` that `Text.localized(...)` is expected to produce for a fully resolved
    /// string, using the same markdown-parse-then-wrap path as the production code.
    private func expectedText(_ string: String) -> Text {
        if let attributedString = try? AttributedString(markdown: string) {
            return Text(attributedString)
        } else {
            return Text(string)
        }
    }

    /// Sets up mock translations for testing.
    private func setupMockTranslations() {
        let mockTranslations = TranslationFile(modules: [
            "Store": ModuleTranslations(translations: [
                "welcome": TranslationEntry(
                    value: .simple("Welcome Translated")
                ),
                "greeting": TranslationEntry(
                    value: .simple("Hello, %@! Welcome.")
                ),
                "order_summary": TranslationEntry(
                    value: .simple("Order #%@ has %d items")
                ),
                "items_count": TranslationEntry(
                    value: .plural([
                        .zero: "No items in cart",
                        .one: "1 item in cart",
                        .other: "%d items in cart"
                    ])
                ),
                "apple_count": TranslationEntry(
                    value: .plural([
                        .zero: "No apples",
                        .one: "One apple",
                        .other: "%d apples"
                    ])
                ),
                "cart_summary": TranslationEntry(
                    value: .plural([
                        .zero: "Your cart is empty",
                        .one: "You have 1 item worth %@",
                        .other: "You have %d items worth %@"
                    ])
                ),
                "welcome_bold": TranslationEntry(
                    value: .simple("Welcome, **%@**!")
                )
            ])
        ])

        LocalizationManager.shared.activateLanguage(
            languageCode: "en_US",
            languageName: "English",
            country: "United States",
            version: 1,
            translationFile: mockTranslations
        )
    }

    // MARK: - Simple Localization Tests

    func testSimpleLocalized_WhenTranslationExists_ReturnsTranslation() {
        // Given.
        setupMockTranslations()

        // When.
        let result = Text.localized("welcome", default: "Welcome to Store!", file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, expectedText("Welcome Translated"))
    }

    func testSimpleLocalized_WhenTranslationMissing_ReturnsDefault() {
        // Given - no translations set up.
        let defaultValue = "Default Text"

        // When.
        let result = Text.localized("nonexistent", default: defaultValue, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, expectedText(defaultValue))
    }

    func testSimpleLocalized_WithComment_Works() {
        // Given.
        setupMockTranslations()

        // When.
        let result = Text.localized(
            "welcome",
            default: "Welcome!",
            comment: "Greeting on home screen",
            file: storeModuleFile
        )

        // Then.
        XCTAssertEqual(result, expectedText("Welcome Translated"))
    }

    // MARK: - Single Interpolation Tests

    func testLocalizedWithSingleArg_StringPlaceholder() {
        // Given.
        setupMockTranslations()

        // When.
        let result = Text.localized("greeting", default: "Hello, %@!", with: "John", file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, expectedText("Hello, John! Welcome."))
    }

    func testLocalizedWithSingleArg_IntPlaceholder() {
        // Given - no translations, uses default.
        // When.
        let result = Text.localized("count", default: "You have %d messages", with: 42, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, expectedText("You have 42 messages"))
    }

    func testLocalizedWithSingleArg_WhenTranslationMissing_UsesDefault() {
        // Given - no translations set up.
        // When.
        let result = Text.localized("missing", default: "Welcome, %@!", with: "Alice", file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, expectedText("Welcome, Alice!"))
    }

    // MARK: - Multiple Interpolation Tests

    func testLocalizedWithMultipleArgs_ReplacesAllPlaceholders() {
        // Given.
        setupMockTranslations()

        // When.
        let result = Text.localized(
            "order_summary",
            default: "Order #%@ contains %d items",
            with: "ABC123", 5,
            file: storeModuleFile
        )

        // Then.
        XCTAssertEqual(result, expectedText("Order #ABC123 has 5 items"))
    }

    func testLocalizedWithMultipleArgs_MixedTypes() {
        // Given - no translations, uses default.
        // When.
        let result = Text.localized(
            "summary",
            default: "%@ bought %d items for $%.2f",
            with: "Bob", 3, 45.50,
            file: storeModuleFile
        )

        // Then.
        XCTAssertEqual(result, expectedText("Bob bought 3 items for $45.50"))
    }

    func testLocalizedWithMultipleArgs_WhenTranslationMissing_UsesDefault() {
        // Given - no translations set up.
        // When.
        let result = Text.localized(
            "nonexistent",
            default: "Hello %@, you have %d new messages",
            with: "Charlie", 10,
            file: storeModuleFile
        )

        // Then.
        XCTAssertEqual(result, expectedText("Hello Charlie, you have 10 new messages"))
    }

    // MARK: - Plural Localization Tests

    func testPluralLocalized_OneCount_ReturnsOneForm() {
        // Given - using default plurals (no server translation).
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Cart is empty",
            .one: "One item",
            .other: "Multiple items"
        ]

        // When.
        let result = Text.localized("items", defaultPlural: defaultPlural, count: 1, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, expectedText("One item"))
    }

    func testPluralLocalized_MultipleCount_ReturnsOtherForm() {
        // Given - using default plurals (no server translation).
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Cart is empty",
            .one: "One item",
            .other: "Multiple items"
        ]

        // When.
        let result = Text.localized("items", defaultPlural: defaultPlural, count: 5, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, expectedText("Multiple items"))
    }

    func testPluralLocalized_TranslationExists_OneForm() {
        // Given.
        setupMockTranslations()
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default empty",
            .one: "Default one",
            .other: "Default other"
        ]

        // When.
        let result = Text.localized("items_count", defaultPlural: defaultPlural, count: 1, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, expectedText("1 item in cart"))
    }

    // MARK: - Plural with Single Interpolation Tests

    func testPluralLocalizedWithSingleArg_OneCount() {
        // Given - using default plurals.
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No apples",
            .one: "%d apple",
            .other: "%d apples"
        ]

        // When.
        let result = Text.localized(
            "apples",
            defaultPlural: defaultPlural,
            count: 1,
            with: 1,
            file: storeModuleFile
        )

        // Then.
        XCTAssertEqual(result, expectedText("1 apple"))
    }

    func testPluralLocalizedWithSingleArg_MultipleCount() {
        // Given - using default plurals.
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No apples",
            .one: "%d apple",
            .other: "%d apples"
        ]

        // When.
        let result = Text.localized(
            "apples",
            defaultPlural: defaultPlural,
            count: 10,
            with: 10,
            file: storeModuleFile
        )

        // Then.
        XCTAssertEqual(result, expectedText("10 apples"))
    }

    func testPluralLocalizedWithSingleArg_TranslationExists() {
        // Given.
        setupMockTranslations()
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default no apples",
            .one: "Default %d apple",
            .other: "Default %d apples"
        ]

        // When.
        let result = Text.localized(
            "apple_count",
            defaultPlural: defaultPlural,
            count: 5,
            with: 5,
            file: storeModuleFile
        )

        // Then.
        XCTAssertEqual(result, expectedText("5 apples"))
    }

    // MARK: - Plural with Multiple Interpolation Tests

    func testPluralLocalizedWithMultipleArgs_OneCount() {
        // Given - using default plurals.
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Your cart is empty",
            .one: "You have %d item worth %@",
            .other: "%d items costing %@"
        ]

        // When.
        let result = Text.localized(
            "cart",
            defaultPlural: defaultPlural,
            count: 1,
            with: 1, "$25.00",
            file: storeModuleFile
        )

        // Then.
        XCTAssertEqual(result, expectedText("You have 1 item worth $25.00"))
    }

    func testPluralLocalizedWithMultipleArgs_MultipleCount() {
        // Given - using default plurals.
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Your cart is empty",
            .one: "1 item costing %@",
            .other: "%d items costing %@"
        ]

        // When.
        let result = Text.localized(
            "cart",
            defaultPlural: defaultPlural,
            count: 3,
            with: 3, "$99.99",
            file: storeModuleFile
        )

        // Then.
        XCTAssertEqual(result, expectedText("3 items costing $99.99"))
    }

    func testPluralLocalizedWithMultipleArgs_TranslationExists() {
        // Given.
        setupMockTranslations()
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default empty",
            .one: "Default 1 item worth %@",
            .other: "Default %d items worth %@"
        ]

        // When.
        let result = Text.localized(
            "cart_summary",
            defaultPlural: defaultPlural,
            count: 5,
            with: 5, "$150.00",
            file: storeModuleFile
        )

        // Then.
        XCTAssertEqual(result, expectedText("You have 5 items worth $150.00"))
    }

    // MARK: - Markdown Rendering Tests

    func testLocalized_RendersMarkdownBold_FromDefault() {
        // Given - no translation, default contains markdown.
        let markdownDefault = "Welcome, **John**!"

        // When.
        let result = Text.localized("welcome_bold", default: markdownDefault, file: storeModuleFile)

        // Then - markdown branch is taken (asterisks parsed away into styling), so the result is
        // NOT equal to a verbatim Text of the raw markdown source string.
        XCTAssertEqual(result, expectedText(markdownDefault))
        XCTAssertNotEqual(result, Text(verbatim: markdownDefault))
    }

    func testLocalizedWithSingleArg_RendersMarkdownBold_FromTranslation() {
        // Given - translation value carries markdown emphasis around the interpolated value.
        setupMockTranslations()

        // When.
        let result = Text.localized("welcome_bold", default: "Welcome, %@!", with: "John", file: storeModuleFile)

        // Then - the resolved string "Welcome, **John**!" is rendered as markdown.
        XCTAssertEqual(result, expectedText("Welcome, **John**!"))
        XCTAssertNotEqual(result, Text(verbatim: "Welcome, **John**!"))
    }

    // MARK: - LocalizationManager State Tests

    func testLocalized_AfterClearCache_FallsBackToDefault() async {
        // Given - setup translations.
        setupMockTranslations()
        XCTAssertEqual(
            Text.localized("welcome", default: "Welcome", file: storeModuleFile),
            expectedText("Welcome Translated")
        )

        // When - clear cache.
        await LocalizationManager.shared.clearCache()

        // Then - should fallback to default.
        XCTAssertEqual(
            Text.localized("welcome", default: "Welcome", file: storeModuleFile),
            expectedText("Welcome")
        )
    }

    func testLocalized_AfterLanguageChange_UsesNewTranslation() {
        // Given - activate first language.
        setupMockTranslations() // English.
        XCTAssertEqual(
            Text.localized("welcome", default: "Welcome", file: storeModuleFile),
            expectedText("Welcome Translated")
        )

        // When - activate another language.
        let spanishTranslations = TranslationFile(modules: [
            "Store": ModuleTranslations(translations: [
                "welcome": TranslationEntry(value: .simple("Bienvenido"))
            ])
        ])
        LocalizationManager.shared.activateLanguage(
            languageCode: "es_ES",
            languageName: "Spanish",
            country: "Spain",
            version: 1,
            translationFile: spanishTranslations
        )

        // Then - should use new language.
        XCTAssertEqual(
            Text.localized("welcome", default: "Welcome", file: storeModuleFile),
            expectedText("Bienvenido")
        )
    }
}
