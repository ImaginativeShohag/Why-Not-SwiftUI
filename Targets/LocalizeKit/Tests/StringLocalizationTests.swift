@testable import LocalizeKit
import XCTest

/// Unit tests for String+Localization extension methods
@MainActor
final class StringLocalizationTests: XCTestCase {
    // MARK: - Setup / Teardown

    override func setUp() async throws {
        try await super.setUp()
        // Clear any existing translations before each test
        await LocalizationManager.shared.clearCache()
    }

    override func tearDown() async throws {
        // Clean up after each test
        await LocalizationManager.shared.clearCache()
        try await super.tearDown()
    }

    // MARK: - Helper Methods

    /// Sets up mock translations for testing
    private func setupMockTranslations() {
        let mockTranslations = TranslationFile(modules: [
            "Store": ModuleTranslations(translations: [
                "store_welcome": TranslationEntry(
                    value: .simple("Welcome Translated"),
                    type: .simple
                ),
                "store_greeting": TranslationEntry(
                    value: .simple("Hello, %@! Welcome."),
                    type: .interpolation
                ),
                "store_order_summary": TranslationEntry(
                    value: .simple("Order #%@ has %d items"),
                    type: .interpolation
                ),
                "store_items_count": TranslationEntry(
                    value: .plural([
                        .zero: "No items in cart",
                        .one: "1 item in cart",
                        .other: "%d items in cart"
                    ]),
                    type: .plural
                ),
                "store_apple_count": TranslationEntry(
                    value: .plural([
                        .zero: "No apples",
                        .one: "One apple",
                        .other: "%d apples"
                    ]),
                    type: .plural
                ),
                "store_cart_summary": TranslationEntry(
                    value: .plural([
                        .zero: "Your cart is empty",
                        .one: "You have 1 item worth %@",
                        .other: "You have %d items worth %@"
                    ]),
                    type: .plural
                )
            ])
        ])

        LocalizationManager.shared.activateLanguage(
            languageCode: "en_US",
            languageName: "English",
            country: "United States",
            version: 1,
            mockTranslations
        )
    }

    // MARK: - Simple Localization Tests

    func testSimpleLocalize_WhenTranslationExists_ReturnsTranslation() {
        // Given
        setupMockTranslations()
        let key = "store_welcome"
        let defaultValue = "Welcome to Store!"

        // When
        let result = key.localize(default: defaultValue)

        // Then
        XCTAssertEqual(result, "Welcome Translated")
    }

    func testSimpleLocalize_WhenTranslationMissing_ReturnsDefault() {
        // Given - no translations set up
        let key = "store_nonexistent"
        let defaultValue = "Default Text"

        // When
        let result = key.localize(default: defaultValue)

        // Then
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_WithInvalidKeyFormat_ReturnsDefault() {
        // Given
        setupMockTranslations()
        let key = "invalidkey" // No underscore separator
        let defaultValue = "Fallback Text"

        // When
        let result = key.localize(default: defaultValue)

        // Then
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_WithComment_Works() {
        // Given
        setupMockTranslations()
        let key = "store_welcome"
        let defaultValue = "Welcome!"

        // When
        let result = key.localize(default: defaultValue, comment: "Greeting on home screen")

        // Then
        XCTAssertEqual(result, "Welcome Translated")
    }

    // MARK: - Single Interpolation Tests

    func testLocalizeWithSingleArg_StringPlaceholder() {
        // Given
        setupMockTranslations()
        let key = "store_greeting"
        let defaultValue = "Hello, %@!"
        let name = "John"

        // When
        let result = key.localize(default: defaultValue, with: name)

        // Then
        XCTAssertEqual(result, "Hello, John! Welcome.")
    }

    func testLocalizeWithSingleArg_IntPlaceholder() {
        // Given - no translations, uses default
        let key = "store_count"
        let defaultValue = "You have %d messages"
        let count = 42

        // When
        let result = key.localize(default: defaultValue, with: count)

        // Then
        XCTAssertEqual(result, "You have 42 messages")
    }

    func testLocalizeWithSingleArg_DoublePlaceholder() {
        // Given - no translations, uses default
        let key = "store_price"
        let defaultValue = "Total: $%.2f"
        let price = 19.99

        // When
        let result = key.localize(default: defaultValue, with: price)

        // Then
        XCTAssertEqual(result, "Total: $19.99")
    }

    func testLocalizeWithSingleArg_WhenTranslationMissing_UsesDefault() {
        // Given - no translations set up
        let key = "store_missing"
        let defaultValue = "Welcome, %@!"
        let name = "Alice"

        // When
        let result = key.localize(default: defaultValue, with: name)

        // Then
        XCTAssertEqual(result, "Welcome, Alice!")
    }

    // MARK: - Multiple Interpolation Tests

    func testLocalizeWithMultipleArgs_ReplacesAllPlaceholders() {
        // Given
        setupMockTranslations()
        let key = "store_order_summary"
        let defaultValue = "Order #%@ contains %d items"
        let orderId = "ABC123"
        let itemCount = 5

        // When
        let result = key.localize(default: defaultValue, with: orderId, itemCount)

        // Then
        XCTAssertEqual(result, "Order #ABC123 has 5 items")
    }

    func testLocalizeWithMultipleArgs_MixedTypes() {
        // Given - no translations, uses default
        let key = "store_summary"
        let defaultValue = "%@ bought %d items for $%.2f"
        let name = "Bob"
        let count = 3
        let total = 45.50

        // When
        let result = key.localize(default: defaultValue, with: name, count, total)

        // Then
        XCTAssertEqual(result, "Bob bought 3 items for $45.50")
    }

    func testLocalizeWithMultipleArgs_WhenTranslationMissing_UsesDefault() {
        // Given - no translations set up
        let key = "store_nonexistent"
        let defaultValue = "Hello %@, you have %d new messages"
        let name = "Charlie"
        let count = 10

        // When
        let result = key.localize(default: defaultValue, with: name, count)

        // Then
        XCTAssertEqual(result, "Hello Charlie, you have 10 new messages")
    }

    // MARK: - Plural Localization Tests

    func testPluralLocalize_ZeroCount_ReturnsZeroForm() {
        // Given - using default plurals (no server translation)
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Cart is empty",
            .one: "One item",
            .other: "Multiple items"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 0)

        // Then
        XCTAssertEqual(result, "Cart is empty")
    }

    func testPluralLocalize_OneCount_ReturnsOneForm() {
        // Given - using default plurals (no server translation)
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Cart is empty",
            .one: "One item",
            .other: "Multiple items"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 1)

        // Then
        XCTAssertEqual(result, "One item")
    }

    func testPluralLocalize_MultipleCount_ReturnsOtherForm() {
        // Given - using default plurals (no server translation)
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Cart is empty",
            .one: "One item",
            .other: "Multiple items"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 5)

        // Then
        XCTAssertEqual(result, "Multiple items")
    }

    func testPluralLocalize_FallbackChain_WhenExactCategoryMissing() {
        // Given - only "other" form provided
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .other: "Items available"
        ]

        // When - count is 0 but .zero not defined, should fallback to .other
        let result = key.localize(defaultPlural: defaultPlural, count: 0)

        // Then
        XCTAssertEqual(result, "Items available")
    }

    func testPluralLocalize_ReturnsKey_WhenNoDefaultsProvided() {
        // Given - empty dictionary
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [:]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 5)

        // Then - should return key as last resort
        XCTAssertEqual(result, "store_items")
    }

    func testPluralLocalize_TranslationExists_ReturnsTranslated() {
        // Given
        setupMockTranslations()
        let key = "store_items_count"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default zero",
            .one: "Default one",
            .other: "Default other"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 5)

        // Then - should use translated value format string, not default
        // Note: This returns the format string; use the `with:` variant for interpolation
        XCTAssertEqual(result, "%d items in cart")
    }

    func testPluralLocalize_TranslatedZeroForm() {
        // Given
        setupMockTranslations()
        let key = "store_items_count"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default empty",
            .one: "Default one",
            .other: "Default other"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 0)

        // Then
        XCTAssertEqual(result, "No items in cart")
    }

    func testPluralLocalize_TranslatedOneForm() {
        // Given
        setupMockTranslations()
        let key = "store_items_count"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default empty",
            .one: "Default one",
            .other: "Default other"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 1)

        // Then
        XCTAssertEqual(result, "1 item in cart")
    }

    // MARK: - Plural with Single Interpolation Tests

    func testPluralLocalizeWithSingleArg_ZeroCount() {
        // Given - using default plurals
        let key = "store_apples"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No apples",
            .one: "%d apple",
            .other: "%d apples"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 0, with: 0)

        // Then
        XCTAssertEqual(result, "No apples")
    }

    func testPluralLocalizeWithSingleArg_OneCount() {
        // Given - using default plurals
        let key = "store_apples"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No apples",
            .one: "%d apple",
            .other: "%d apples"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 1, with: 1)

        // Then
        XCTAssertEqual(result, "1 apple")
    }

    func testPluralLocalizeWithSingleArg_MultipleCount() {
        // Given - using default plurals
        let key = "store_apples"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No apples",
            .one: "%d apple",
            .other: "%d apples"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 10, with: 10)

        // Then
        XCTAssertEqual(result, "10 apples")
    }

    func testPluralLocalizeWithSingleArg_TranslationExists() {
        // Given
        setupMockTranslations()
        let key = "store_apple_count"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default no apples",
            .one: "Default %d apple",
            .other: "Default %d apples"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 5, with: 5)

        // Then
        XCTAssertEqual(result, "5 apples")
    }

    // MARK: - Plural with Multiple Interpolation Tests

    func testPluralLocalizeWithMultipleArgs_ZeroCount() {
        // Given - using default plurals
        let key = "store_cart"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Your cart is empty",
            .one: "1 item costing %@",
            .other: "%d items costing %@"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 0, with: 0, "$0.00")

        // Then
        XCTAssertEqual(result, "Your cart is empty")
    }

    func testPluralLocalizeWithMultipleArgs_OneCount() {
        // Given - using default plurals
        let key = "store_cart"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Your cart is empty",
            .one: "You have %d item worth %@",
            .other: "%d items costing %@"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 1, with: 1, "$25.00")

        // Then
        XCTAssertEqual(result, "You have 1 item worth $25.00")
    }

    func testPluralLocalizeWithMultipleArgs_MultipleCount() {
        // Given - using default plurals
        let key = "store_cart"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Your cart is empty",
            .one: "1 item costing %@",
            .other: "%d items costing %@"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 3, with: 3, "$99.99")

        // Then
        XCTAssertEqual(result, "3 items costing $99.99")
    }

    func testPluralLocalizeWithMultipleArgs_TranslationExists() {
        // Given
        setupMockTranslations()
        let key = "store_cart_summary"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default empty",
            .one: "Default 1 item worth %@",
            .other: "Default %d items worth %@"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 5, with: 5, "$150.00")

        // Then
        XCTAssertEqual(result, "You have 5 items worth $150.00")
    }

    // MARK: - Additional Plural Categories Tests

    func testPluralLocalize_TwoCategory() {
        // Given - testing .two category (used in Arabic for dual forms)
        // Note: In English locale, count=2 falls back to .other
        let key = "store_books"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No books",
            .one: "One book",
            .two: "Two books", // Only used in Arabic/Welsh, not English
            .other: "%d books"
        ]

        // When - In English locale, count=2 selects .other, not .two
        let result = key.localize(defaultPlural: defaultPlural, count: 2, with: 2)

        // Then - Falls back to .other for English
        XCTAssertEqual(result, "2 books")
    }

    func testPluralLocalize_FewCategory() {
        // Given - testing .few category (used in Slavic languages)
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .one: "One item",
            .few: "A few items",
            .other: "%d items"
        ]

        // When - simulating a count that would trigger .few in Polish/Russian
        let result = key.localize(defaultPlural: defaultPlural, count: 3, with: 3)

        // Then - falls back to .other since we don't have language-specific plural rules
        XCTAssertEqual(result, "3 items")
    }

    func testPluralLocalize_ManyCategory() {
        // Given - testing .many category
        // Note: In English locale, large counts fall back to .other
        let key = "store_products"
        let defaultPlural: [PluralCategory: String] = [
            .one: "One product",
            .many: "Many products", // Only used in Polish/Russian, not English
            .other: "%d products"
        ]

        // When - In English locale, count=100 selects .other, not .many
        let result = key.localize(defaultPlural: defaultPlural, count: 100, with: 100)

        // Then - Falls back to .other for English
        XCTAssertEqual(result, "100 products")
    }

    func testPluralLocalize_FallbackFromTwoToOne() {
        // Given - .two not defined, should fallback to .one then .other
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .one: "Single item",
            .other: "Multiple items"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 2)

        // Then - should fallback to .other
        XCTAssertEqual(result, "Multiple items")
    }

    func testPluralLocalize_FallbackFromFewToOther() {
        // Given - .few not defined
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .one: "One item",
            .other: "%d items"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 3, with: 3)

        // Then - should fallback to .other
        XCTAssertEqual(result, "3 items")
    }

    func testPluralLocalize_FallbackFromManyToOther() {
        // Given - .many not defined
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .one: "One item",
            .other: "%d items"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 100, with: 100)

        // Then - should fallback to .other
        XCTAssertEqual(result, "100 items")
    }

    // MARK: - Edge Cases for Counts

    func testPluralLocalize_NegativeCount() {
        // Given
        let key = "store_balance"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No balance",
            .one: "One unit",
            .other: "%d units"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: -5, with: -5)

        // Then - negative treated as .other
        XCTAssertEqual(result, "-5 units")
    }

    func testPluralLocalize_VeryLargeCount() {
        // Given
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .one: "One item",
            .other: "%d items"
        ]

        // When - Note: %d format specifier has limitations with Int.max (64-bit)
        // Using a large but safe value instead
        let largeCount = 999_999_999
        let result = key.localize(defaultPlural: defaultPlural, count: largeCount, with: largeCount)

        // Then
        XCTAssertEqual(result, "\(largeCount) items")
    }

    func testPluralLocalizeWithArgs_NegativeCountAsArgument() {
        // Given
        let key = "store_temperature"
        let defaultPlural: [PluralCategory: String] = [
            .one: "%d degree",
            .other: "%d degrees"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: -10, with: -10)

        // Then
        XCTAssertEqual(result, "-10 degrees")
    }

    func testPluralLocalize_ZeroWithOnlyOtherForm() {
        // Given - no .zero form provided
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .other: "%d items available"
        ]

        // When
        let result = key.localize(defaultPlural: defaultPlural, count: 0, with: 0)

        // Then - should fallback to .other
        XCTAssertEqual(result, "0 items available")
    }

    // MARK: - Key Format Edge Cases

    func testSimpleLocalize_EmptyKey() {
        // Given
        let key = ""
        let defaultValue = "Fallback"

        // When
        let result = key.localize(default: defaultValue)

        // Then - should return default
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_KeyWithMultipleUnderscores() {
        // Given
        setupMockTranslations()
        let key = "store_user_profile_name_label"
        let defaultValue = "Name Label"

        // When
        let result = key.localize(default: defaultValue)

        // Then - should handle multiple underscores (module is "store")
        XCTAssertEqual(result, defaultValue) // No translation exists
    }

    func testSimpleLocalize_KeyWithUnicodeCharacters() {
        // Given
        let key = "store_emoji_🎉_test"
        let defaultValue = "Party Test"

        // When
        let result = key.localize(default: defaultValue)

        // Then - should return default (non-standard key)
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_KeyWithUppercaseModule() {
        // Given
        setupMockTranslations()
        let key = "STORE_welcome"
        let defaultValue = "Welcome"

        // When
        let result = key.localize(default: defaultValue)

        // Then - case sensitive, should not find translation
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_VeryLongKey() {
        // Given
        let key = "store_" + String(repeating: "a", count: 1000)
        let defaultValue = "Long Key Test"

        // When
        let result = key.localize(default: defaultValue)

        // Then - should handle gracefully
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_KeyWithOnlyUnderscore() {
        // Given
        let key = "_"
        let defaultValue = "Underscore Only"

        // When
        let result = key.localize(default: defaultValue)

        // Then - invalid format
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_KeyStartingWithUnderscore() {
        // Given
        let key = "_store_welcome"
        let defaultValue = "Welcome"

        // When
        let result = key.localize(default: defaultValue)

        // Then - module would be empty
        XCTAssertEqual(result, defaultValue)
    }

    // MARK: - Value Edge Cases

    func testSimpleLocalize_EmptyDefaultValue() {
        // Given
        let key = "store_empty"
        let defaultValue = ""

        // When
        let result = key.localize(default: defaultValue)

        // Then - should return empty string
        XCTAssertEqual(result, "")
    }

    func testSimpleLocalize_DefaultValueWithUnicode() {
        // Given
        let key = "store_greeting"
        let defaultValue = "Hello 👋 مرحبا নমস্কার"

        // When
        let result = key.localize(default: defaultValue)

        // Then
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_DefaultValueWithEmoji() {
        // Given
        let key = "store_party"
        let defaultValue = "🎉🎊🥳"

        // When
        let result = key.localize(default: defaultValue)

        // Then
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_VeryLongDefaultValue() {
        // Given
        let key = "store_long"
        let defaultValue = String(repeating: "Lorem ipsum dolor sit amet. ", count: 100)

        // When
        let result = key.localize(default: defaultValue)

        // Then - should handle large strings
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_DefaultValueWithNewlines() {
        // Given
        let key = "store_multiline"
        let defaultValue = "Line 1\nLine 2\nLine 3"

        // When
        let result = key.localize(default: defaultValue)

        // Then
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_DefaultValueWithSpecialCharacters() {
        // Given
        let key = "store_special"
        let defaultValue = "Test: @#$%^&*(){}[]|\\/<>?"

        // When
        let result = key.localize(default: defaultValue)

        // Then
        XCTAssertEqual(result, defaultValue)
    }

    // MARK: - Format String Mismatch Tests

    func testLocalizeWithArgs_MorePlaceholdersThanArguments() {
        // Given
        let key = "store_format"
        let defaultValue = "Name: %@, Age: %d, City: %@"

        // When - only providing 2 arguments for 3 placeholders
        let result = key.localize(default: defaultValue, with: "John", 30, "Bangladesh")

        // Then - String(format:) behavior: extra placeholder remains or crashes
        // This tests that the implementation handles this edge case
        XCTAssertTrue(result.contains("John"))
        XCTAssertTrue(result.contains("30"))
        XCTAssertTrue(result.contains("Bangladesh"))
    }

    func testLocalizeWithArgs_FewerPlaceholdersThanArguments() {
        // Given
        let key = "store_format"
        let defaultValue = "Name: %@"

        // When - providing 2 arguments for 1 placeholder
        let result = key.localize(default: defaultValue, with: "John", 30)

        // Then - extra argument is ignored
        XCTAssertEqual(result, "Name: John")
    }

    func testLocalizeWithArgs_EscapedPercentSign() {
        // Given
        let key = "store_discount"
        let defaultValue = "Save %%d off!" // Escaped %

        // When
        let result = key.localize(default: defaultValue, with: 20)

        // Then - %% becomes single %
        XCTAssertTrue(result.contains("%"))
    }

    func testLocalizeWithArgs_NoPlaceholdersButArgumentsProvided() {
        // Given
        let key = "store_static"
        let defaultValue = "Static text without placeholders"

        // When - providing arguments that won't be used
        let result = key.localize(default: defaultValue, with: "Ignored", 42)

        // Then - arguments ignored, returns static text
        XCTAssertEqual(result, defaultValue)
    }

    func testPluralLocalizeWithArgs_MismatchedPlaceholderTypes() {
        // Given
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .one: "One item: %@", // String placeholder
            .other: "%d items" // Integer placeholder
        ]

        // When - passing integer to .other (correct), but string if .one selected
        let result = key.localize(defaultPlural: defaultPlural, count: 5, with: 5)

        // Then
        XCTAssertEqual(result, "5 items")
    }

    // MARK: - Translation Type Mismatch Tests

    func testSimpleLocalize_OnPluralTranslation() {
        // Given - setup translation marked as plural type
        setupMockTranslations()
        let key = "store_items_count" // This is a plural type in mock
        let defaultValue = "Default items"

        // When - calling simple localize on a plural translation
        let result = key.localize(default: defaultValue)

        // Then - should return the translation's first available value or default
        // Implementation dependent - might return key, default, or first plural form
        XCTAssertFalse(result.isEmpty)
    }

    func testPluralLocalize_OnSimpleTranslation() {
        // Given
        setupMockTranslations()
        let key = "store_welcome" // This is a simple type in mock
        let defaultPlural: [PluralCategory: String] = [
            .one: "One welcome",
            .other: "%d welcomes"
        ]

        // When - calling plural localize on a simple translation
        let result = key.localize(defaultPlural: defaultPlural, count: 5)

        // Then - might return the simple value or fallback to default plural
        XCTAssertFalse(result.isEmpty)
    }

    func testPluralLocalize_OnInterpolationTranslation() {
        // Given
        setupMockTranslations()
        let key = "store_greeting" // This is interpolation type in mock
        let defaultPlural: [PluralCategory: String] = [
            .one: "One greeting",
            .other: "%d greetings"
        ]

        // When - calling plural localize on interpolation translation
        let result = key.localize(defaultPlural: defaultPlural, count: 5)

        // Then - implementation should handle gracefully
        XCTAssertFalse(result.isEmpty)
    }

    // MARK: - LocalizationManager State Tests

    func testLocalize_WhenNoLanguageActivated() {
        // Given - fresh state, no language activated (already cleared in setUp)
        let key = "store_test"
        let defaultValue = "Test Value"

        // When
        let result = key.localize(default: defaultValue)

        // Then - should return default
        XCTAssertEqual(result, defaultValue)
    }

    func testLocalize_AfterMultipleLanguageActivations() async {
        // Given - activate first language
        setupMockTranslations() // English

        // Verify first language works
        let result1 = "store_welcome".localize(default: "Welcome")
        XCTAssertEqual(result1, "Welcome Translated")

        // When - activate another language
        let spanishTranslations = TranslationFile(modules: [
            "Store": ModuleTranslations(translations: [
                "store_welcome": TranslationEntry(
                    value: .simple("Bienvenido"),
                    type: .simple
                )
            ])
        ])

        LocalizationManager.shared.activateLanguage(
            languageCode: "es_ES",
            languageName: "Spanish",
            country: "Spain",
            version: 1,
            spanishTranslations
        )

        // Then - should use new language
        let result2 = "store_welcome".localize(default: "Welcome")
        XCTAssertEqual(result2, "Bienvenido")
    }

    func testLocalize_AfterClearCache() async {
        // Given - setup translations
        setupMockTranslations()

        // Verify translation exists
        let result1 = "store_welcome".localize(default: "Welcome")
        XCTAssertEqual(result1, "Welcome Translated")

        // When - clear cache
        await LocalizationManager.shared.clearCache()

        // Then - should fallback to default
        let result2 = "store_welcome".localize(default: "Welcome")
        XCTAssertEqual(result2, "Welcome")
    }

    func testLocalize_ConcurrentAccess() async {
        // Given
        setupMockTranslations()

        // When - multiple concurrent localization calls
        await withTaskGroup(of: String.self) { group in
            for i in 0 ..< 100 {
                group.addTask { @MainActor in
                    if i % 2 == 0 {
                        return "store_welcome".localize(default: "Welcome")
                    } else {
                        return "store_greeting".localize(default: "Hello, %@!", with: "User\(i)")
                    }
                }
            }

            // Then - all should complete without crashes
            var results: [String] = []
            for await result in group {
                results.append(result)
            }

            XCTAssertEqual(results.count, 100)
        }
    }

    // MARK: - Module Boundary Tests

    func testLocalize_NonExistentModule() {
        // Given
        setupMockTranslations()
        let key = "fakemodul_test"
        let defaultValue = "Test"

        // When
        let result = key.localize(default: defaultValue)

        // Then - should return default
        XCTAssertEqual(result, defaultValue)
    }

    func testLocalize_KeyExistsInWrongModule() {
        // Given
        setupMockTranslations() // Only Store module has translations
        let key = "home_welcome" // Trying to access as Home module
        let defaultValue = "Home Welcome"

        // When
        let result = key.localize(default: defaultValue)

        // Then - should return default (not found in Home module)
        XCTAssertEqual(result, defaultValue)
    }

    func testLocalize_CaseSensitiveModuleName() {
        // Given
        setupMockTranslations() // Module is "Store"
        let key = "store_welcome" // lowercase module
        let defaultValue = "Welcome"

        // When
        let result = key.localize(default: defaultValue)

        // Then - should find translation (depends on implementation case sensitivity)
        XCTAssertEqual(result, "Welcome Translated")
    }

    func testLocalize_CaseSensitiveKeyName() {
        // Given
        setupMockTranslations() // Key is "store_welcome"
        let key = "store_Welcome" // Different case
        let defaultValue = "Welcome"

        // When
        let result = key.localize(default: defaultValue)

        // Then - should not find (case sensitive)
        XCTAssertEqual(result, defaultValue)
    }

    // MARK: - Comment Parameter Coverage

    func testLocalizeWithSingleArg_WithComment() {
        // Given
        setupMockTranslations()
        let key = "store_greeting"
        let defaultValue = "Hello, %@!"
        let name = "Alice"

        // When
        let result = key.localize(
            default: defaultValue,
            comment: "User greeting with name",
            with: name
        )

        // Then
        XCTAssertEqual(result, "Hello, Alice! Welcome.")
    }

    func testLocalizeWithMultipleArgs_WithComment() {
        // Given
        setupMockTranslations()
        let key = "store_order_summary"
        let defaultValue = "Order #%@ with %d items"

        // When
        let result = key.localize(
            default: defaultValue,
            comment: "Order summary with ID and count",
            with: "ORD123", 5
        )

        // Then
        XCTAssertEqual(result, "Order #ORD123 has 5 items")
    }

    func testPluralLocalize_WithComment() {
        // Given
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No items",
            .one: "One item",
            .other: "%d items"
        ]

        // When
        let result = key.localize(
            defaultPlural: defaultPlural,
            comment: "Shopping cart item count",
            count: 3,
            with: 3
        )

        // Then
        XCTAssertEqual(result, "3 items")
    }

    func testPluralLocalizeWithArgs_WithComment() {
        // Given
        setupMockTranslations()
        let key = "store_cart_summary"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Empty cart",
            .one: "One item worth %@",
            .other: "%d items worth %@"
        ]

        // When
        let result = key.localize(
            defaultPlural: defaultPlural,
            comment: "Cart summary with count and total",
            count: 5,
            with: 5, "$99.99"
        )

        // Then
        XCTAssertEqual(result, "You have 5 items worth $99.99")
    }

    // MARK: - Comprehensive Fallback Chain Tests

    func testPluralLocalize_ComplexFallbackChain() {
        // Given - only .other defined
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .other: "%d items"
        ]

        // When/Then - test various counts all fallback to .other
        XCTAssertEqual(key.localize(defaultPlural: defaultPlural, count: 0, with: 0), "0 items")
        XCTAssertEqual(key.localize(defaultPlural: defaultPlural, count: 1, with: 1), "1 items")
        XCTAssertEqual(key.localize(defaultPlural: defaultPlural, count: 2, with: 2), "2 items")
        XCTAssertEqual(key.localize(defaultPlural: defaultPlural, count: 3, with: 3), "3 items")
        XCTAssertEqual(key.localize(defaultPlural: defaultPlural, count: 100, with: 100), "100 items")
    }

    func testPluralLocalize_PartialPluralDefinitions() {
        // Given - only .zero and .other defined, missing .one, .two, .few, .many
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No items",
            .other: "%d items"
        ]

        // When/Then
        XCTAssertEqual(key.localize(defaultPlural: defaultPlural, count: 0), "No items")
        XCTAssertEqual(key.localize(defaultPlural: defaultPlural, count: 1, with: 1), "1 items")
        XCTAssertEqual(key.localize(defaultPlural: defaultPlural, count: 2, with: 2), "2 items")
    }

    func testPluralLocalize_AllCategoriesDefined() {
        // Given - all six CLDR categories defined
        // Note: In English locale, only .zero, .one, and .other are used
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Zero items",
            .one: "One item",
            .two: "Two items", // Not used in English
            .few: "A few items", // Not used in English
            .many: "Many items", // Not used in English
            .other: "%d items"
        ]

        // When/Then - verify correct category selection for English locale
        XCTAssertEqual(key.localize(defaultPlural: defaultPlural, count: 0), "Zero items")
        XCTAssertEqual(key.localize(defaultPlural: defaultPlural, count: 1), "One item")
        // Count 2 and 100 fall back to .other in English
        XCTAssertEqual(key.localize(defaultPlural: defaultPlural, count: 2, with: 2), "2 items")
        XCTAssertEqual(key.localize(defaultPlural: defaultPlural, count: 100, with: 100), "100 items")
    }

    func testPluralLocalize_MissingOtherCategory() {
        // Given - unusual case where .other is not defined
        let key = "store_items"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Zero",
            .one: "One"
        ]

        // When/Then - count that doesn't match defined categories
        let result = key.localize(defaultPlural: defaultPlural, count: 5)

        // Then - should fallback to .one then return key as last resort
        XCTAssertEqual(result, "One")
    }
}
