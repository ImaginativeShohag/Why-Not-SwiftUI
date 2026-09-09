@testable import LocalizeKit
import XCTest

/// Unit tests for String+Localization extension methods.
@MainActor
final class StringLocalizationTests: XCTestCase {
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
        // Reset the active language to an English baseline. LocalizationManager is a
        // shared singleton, so a test that activates another language (e.g. Arabic) would
        // otherwise leak into later tests. Plural resolution follows currentLanguageCode,
        // so tests asserting English CLDR forms depend on this deterministic reset.
        LocalizationManager.shared.activateLanguage(
            languageCode: Constants.defaultLanguageCode,
            languageName: Constants.defaultLanguageName,
            country: Constants.defaultCountry,
            version: 0,
            translationFile: TranslationFile(modules: [:])
        )
    }

    override func tearDown() async throws {
        // Clean up after each test.
        await LocalizationManager.shared.clearCache()
        try await super.tearDown()
    }

    // MARK: - Module Name Extraction Tests

    func testExtractModuleName_withValidPath_shouldReturnModuleName() {
        let moduleName = String.extractModuleName(from: "Store/Sources/UI/CartScreen.swift")
        XCTAssertEqual(moduleName, "Store")
    }

    func testExtractModuleName_withAnotherValidPath_shouldReturnModuleName() {
        let moduleName = String.extractModuleName(from: "Home/Sources/HomeScreen.swift")
        XCTAssertEqual(moduleName, "Home")
    }

    func testExtractModuleName_withSingleComponentPath_shouldReturnComponent() {
        let moduleName = String.extractModuleName(from: "SomeModule")
        XCTAssertEqual(moduleName, "SomeModule")
    }

    func testExtractModuleName_withEmptyPath_shouldReturnUnknown() {
        let moduleName = String.extractModuleName(from: "")
        XCTAssertEqual(moduleName, "Unknown")
    }

    func testExtractModuleName_withMultipleSlashesInPath_shouldReturnFirstComponent() {
        let moduleName = String.extractModuleName(from: "LocalizeKit/Tests/StringLocalizationTests.swift")
        XCTAssertEqual(moduleName, "LocalizeKit")
    }

    func testExtractModuleName_withActualFileID_shouldReturnModuleName() {
        // This test verifies that #fileID in actual runtime works as expected.
        // The test file itself is in LocalizeKit module.
        let moduleName = String.extractModuleName(from: #fileID)
        XCTAssertEqual(moduleName, "LocalizeKitTests", "Module extraction should work with actual #fileID from LocalizeKit module")
    }

    func testExtractModuleName_withSlashOnlyPath_shouldReturnUnknown() {
        // Edge case: path is just "/".
        let moduleName = String.extractModuleName(from: "/")
        XCTAssertEqual(moduleName, "Unknown")
    }

    func testExtractModuleName_withLeadingSlashInPath_shouldReturnUnknown() {
        // Edge case: path starts with "/" (shouldn't happen with #fileID, but test defensively).
        let moduleName = String.extractModuleName(from: "/Store/Sources/UI/CartScreen.swift")
        XCTAssertEqual(moduleName, "Unknown", "Leading slash should result in empty first component")
    }

    // MARK: - Helper Methods

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

    /// Sets up mock Arabic translations to exercise non-English CLDR plural rules.
    ///
    /// Arabic distinguishes all six plural categories, so activating it verifies that
    /// `pluralString(for:in:count:)` resolves categories via `currentLanguageCode`
    /// rather than always assuming English. The `items_count` key mirrors the English
    /// mock's key so it can be reused across a language switch.
    private func setupArabicMockTranslations() {
        let mockTranslations = TranslationFile(modules: [
            "Store": ModuleTranslations(translations: [
                "items_count": TranslationEntry(
                    value: .plural([
                        .zero: "لا عناصر",
                        .one: "عنصر واحد",
                        .two: "عنصران",
                        .few: "عناصر قليلة",
                        .many: "عناصر كثيرة",
                        .other: "%d عنصر"
                    ])
                )
            ])
        ])

        LocalizationManager.shared.activateLanguage(
            languageCode: "ar_AE",
            languageName: "العربية",
            country: "United Arab Emirates",
            version: 1,
            translationFile: mockTranslations
        )
    }

    /// Activates French to exercise the default-plural fallback path under a non-English
    /// language whose CLDR rules differ from the device locale.
    ///
    /// French maps count 0 to `.one` (English maps it to `.other`), so activating French
    /// lets tests prove that the fallback category is resolved from `currentLanguageCode`
    /// rather than `Locale.current`. Only an unrelated key is seeded so fallback tests can
    /// use a deliberately absent key to reach the default-plural branch.
    private func setupFrenchMockTranslations() {
        let mockTranslations = TranslationFile(modules: [
            "Store": ModuleTranslations(translations: [
                "items_count": TranslationEntry(
                    value: .plural([
                        .one: "%d article",
                        .other: "%d articles"
                    ])
                )
            ])
        ])

        LocalizationManager.shared.activateLanguage(
            languageCode: "fr_FR",
            languageName: "Français",
            country: "France",
            version: 1,
            translationFile: mockTranslations
        )
    }

    // MARK: - Simple Localization Tests

    func testSimpleLocalize_withExistingTranslation_shouldReturnTranslation() {
        // Given.
        setupMockTranslations()
        let key = "welcome"
        let defaultValue = "Welcome to Store!"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "Welcome Translated")
    }

    func testSimpleLocalize_withMissingTranslation_shouldReturnDefault() {
        // Given - no translations set up.
        let key = "nonexistent"
        let defaultValue = "Default Text"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_withInvalidKeyFormat_shouldReturnDefault() {
        // Given.
        setupMockTranslations()
        let key = "invalidkey" // No underscore separator.
        let defaultValue = "Fallback Text"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_withComment_shouldReturnTranslation() {
        // Given.
        setupMockTranslations()
        let key = "welcome"
        let defaultValue = "Welcome!"

        // When.
        let result = key.localize(default: defaultValue, comment: "Greeting on home screen", file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "Welcome Translated")
    }

    // MARK: - Single Interpolation Tests

    func testLocalizeWithSingleArg_withStringPlaceholder_shouldReplacePlaceholder() {
        // Given.
        setupMockTranslations()
        let key = "greeting"
        let defaultValue = "Hello, %@!"
        let name = "John"

        // When.
        let result = key.localize(default: defaultValue, with: name, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "Hello, John! Welcome.")
    }

    func testLocalizeWithSingleArg_withIntPlaceholder_shouldReplacePlaceholder() {
        // Given - no translations, uses default.
        let key = "count"
        let defaultValue = "You have %d messages"
        let count = 42

        // When.
        let result = key.localize(default: defaultValue, with: count, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "You have 42 messages")
    }

    func testLocalizeWithSingleArg_withDoublePlaceholder_shouldReplacePlaceholder() {
        // Given - no translations, uses default.
        let key = "price"
        let defaultValue = "Total: $%.2f"
        let price = 19.99

        // When.
        let result = key.localize(default: defaultValue, with: price, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "Total: $19.99")
    }

    func testLocalizeWithSingleArg_withMissingTranslation_shouldUseDefault() {
        // Given - no translations set up.
        let key = "missing"
        let defaultValue = "Welcome, %@!"
        let name = "Alice"

        // When.
        let result = key.localize(default: defaultValue, with: name, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "Welcome, Alice!")
    }

    // MARK: - Multiple Interpolation Tests

    func testLocalizeWithMultipleArgs_withExistingTranslation_shouldReplaceAllPlaceholders() {
        // Given.
        setupMockTranslations()
        let key = "order_summary"
        let defaultValue = "Order #%@ contains %d items"
        let orderId = "ABC123"
        let itemCount = 5

        // When.
        let result = key.localize(default: defaultValue, with: orderId, itemCount, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "Order #ABC123 has 5 items")
    }

    func testLocalizeWithMultipleArgs_withMixedTypePlaceholders_shouldReplaceAllPlaceholders() {
        // Given - no translations, uses default.
        let key = "summary"
        let defaultValue = "%@ bought %d items for $%.2f"
        let name = "Bob"
        let count = 3
        let total = 45.50

        // When.
        let result = key.localize(default: defaultValue, with: name, count, total, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "Bob bought 3 items for $45.50")
    }

    func testLocalizeWithMultipleArgs_withMissingTranslation_shouldUseDefault() {
        // Given - no translations set up.
        let key = "nonexistent"
        let defaultValue = "Hello %@, you have %d new messages"
        let name = "Charlie"
        let count = 10

        // When.
        let result = key.localize(default: defaultValue, with: name, count, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "Hello Charlie, you have 10 new messages")
    }

    // MARK: - Plural Localization Tests

    func testPluralLocalize_withZeroCountInEnglish_shouldReturnOtherForm() {
        // Given - CLDR: English has no .zero category, count=0 uses .other.
        let key = "items"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Cart is empty",
            .one: "One item",
            .other: "Multiple items"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 0, file: storeModuleFile)

        // Then - .other is selected per CLDR rules for English.
        XCTAssertEqual(result, "Multiple items")
    }

    func testPluralLocalize_withCountOfOne_shouldReturnOneForm() {
        // Given - using default plurals (no server translation).
        let key = "items"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Cart is empty",
            .one: "One item",
            .other: "Multiple items"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 1, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "One item")
    }

    func testPluralLocalize_withCountAboveOne_shouldReturnOtherForm() {
        // Given - using default plurals (no server translation).
        let key = "items"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Cart is empty",
            .one: "One item",
            .other: "Multiple items"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 5, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "Multiple items")
    }

    func testPluralLocalize_withOnlyOtherFormForResolvedCategory_shouldReturnExactForm() {
        // Given - only "other" form provided.
        let key = "items"
        let defaultPlural: [PluralCategory: String] = [
            .other: "Items available"
        ]

        // When - CLDR: English count=0 selects .other directly.
        let result = key.localize(defaultPlural: defaultPlural, count: 0, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "Items available")
    }

    func testPluralLocalize_withEmptyDefaults_shouldReturnKey() {
        // Given - empty dictionary.
        let key = "items"
        let defaultPlural: [PluralCategory: String] = [:]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 5, file: storeModuleFile)

        // Then - should return key as last resort.
        XCTAssertEqual(result, "items")
    }

    func testPluralLocalize_withExistingTranslation_shouldReturnTranslatedForm() {
        // Given.
        setupMockTranslations()
        let key = "items_count"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default zero",
            .one: "Default one",
            .other: "Default other"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 5, file: storeModuleFile)

        // Then - should use translated value format string, not default.
        // Note: This returns the format string; use the `with:` variant for interpolation.
        XCTAssertEqual(result, "%d items in cart")
    }

    func testPluralLocalize_withExistingTranslationAndZeroCount_shouldReturnOtherForm() {
        // Given.
        setupMockTranslations()
        let key = "items_count"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default empty",
            .one: "Default one",
            .other: "Default other"
        ]

        // When - CLDR: English count=0 selects .other, not .zero.
        let result = key.localize(defaultPlural: defaultPlural, count: 0, file: storeModuleFile)

        // Then - server translation .other form is used.
        XCTAssertEqual(result, "%d items in cart")
    }

    func testPluralLocalize_withExistingTranslationAndCountOfOne_shouldReturnOneForm() {
        // Given.
        setupMockTranslations()
        let key = "items_count"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default empty",
            .one: "Default one",
            .other: "Default other"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 1, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "1 item in cart")
    }

    // MARK: - Plural with Single Interpolation Tests

    func testPluralLocalizeWithSingleArg_withZeroCount_shouldReturnOtherForm() {
        // Given - CLDR: English count=0 selects .other.
        let key = "apples"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No apples",
            .one: "%d apple",
            .other: "%d apples"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 0, with: 0, file: storeModuleFile)

        // Then - .other form used with format.
        XCTAssertEqual(result, "0 apples")
    }

    func testPluralLocalizeWithSingleArg_withCountOfOne_shouldReturnOneForm() {
        // Given - using default plurals.
        let key = "apples"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No apples",
            .one: "%d apple",
            .other: "%d apples"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 1, with: 1, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "1 apple")
    }

    func testPluralLocalizeWithSingleArg_withCountAboveOne_shouldReturnOtherForm() {
        // Given - using default plurals.
        let key = "apples"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No apples",
            .one: "%d apple",
            .other: "%d apples"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 10, with: 10, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "10 apples")
    }

    func testPluralLocalizeWithSingleArg_withExistingTranslation_shouldReturnTranslatedForm() {
        // Given.
        setupMockTranslations()
        let key = "apple_count"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default no apples",
            .one: "Default %d apple",
            .other: "Default %d apples"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 5, with: 5, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "5 apples")
    }

    // MARK: - Plural with Multiple Interpolation Tests

    func testPluralLocalizeWithMultipleArgs_withZeroCount_shouldReturnOtherForm() {
        // Given - CLDR: English count=0 selects .other.
        let key = "cart"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Your cart is empty",
            .one: "1 item costing %@",
            .other: "%d items costing %@"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 0, with: 0, "$0.00", file: storeModuleFile)

        // Then - .other form used with format.
        XCTAssertEqual(result, "0 items costing $0.00")
    }

    func testPluralLocalizeWithMultipleArgs_withCountOfOne_shouldReturnOneForm() {
        // Given - using default plurals.
        let key = "cart"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Your cart is empty",
            .one: "You have %d item worth %@",
            .other: "%d items costing %@"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 1, with: 1, "$25.00", file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "You have 1 item worth $25.00")
    }

    func testPluralLocalizeWithMultipleArgs_withCountAboveOne_shouldReturnOtherForm() {
        // Given - using default plurals.
        let key = "cart"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Your cart is empty",
            .one: "1 item costing %@",
            .other: "%d items costing %@"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 3, with: 3, "$99.99", file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "3 items costing $99.99")
    }

    func testPluralLocalizeWithMultipleArgs_withExistingTranslation_shouldReturnTranslatedForm() {
        // Given.
        setupMockTranslations()
        let key = "cart_summary"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default empty",
            .one: "Default 1 item worth %@",
            .other: "Default %d items worth %@"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: 5, with: 5, "$150.00", file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "You have 5 items worth $150.00")
    }

    // MARK: - Additional Plural Categories Tests

    func testPluralLocalize_withTwoCategoryInEnglish_shouldReturnOtherForm() {
        // Given - testing .two category (used in Arabic for dual forms).
        // Note: In English locale, count=2 falls back to .other.
        let key = "books"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No books",
            .one: "One book",
            .two: "Two books", // Only used in Arabic/Welsh, not English.
            .other: "%d books"
        ]

        // When - In English locale, count=2 selects .other, not .two.
        let result = key.localize(defaultPlural: defaultPlural, count: 2, with: 2, file: storeModuleFile)

        // Then - Falls back to .other for English.
        XCTAssertEqual(result, "2 books")
    }

    func testPluralLocalize_withFewCategoryInEnglish_shouldReturnOtherForm() {
        // Given - testing .few category (used in Slavic languages).
        let key = "items"
        let defaultPlural: [PluralCategory: String] = [
            .one: "One item",
            .few: "A few items",
            .other: "%d items"
        ]

        // When - English maps count=3 to .other directly (no .few category in English).
        let result = key.localize(defaultPlural: defaultPlural, count: 3, with: 3, file: storeModuleFile)

        // Then - .other is selected per CLDR rules for English.
        XCTAssertEqual(result, "3 items")
    }

    func testPluralLocalize_withManyCategoryInEnglish_shouldReturnOtherForm() {
        // Given - testing .many category.
        // Note: In English locale, large counts fall back to .other.
        let key = "products"
        let defaultPlural: [PluralCategory: String] = [
            .one: "One product",
            .many: "Many products", // Only used in Polish/Russian, not English.
            .other: "%d products"
        ]

        // When - In English locale, count=100 selects .other, not .many.
        let result = key.localize(defaultPlural: defaultPlural, count: 100, with: 100, file: storeModuleFile)

        // Then - Falls back to .other for English.
        XCTAssertEqual(result, "100 products")
    }

    // MARK: - Non-English Locale Plural Tests

    func testPluralLocalize_withArabicZeroCount_shouldReturnZeroForm() {
        // Given - Arabic activated; CLDR: Arabic has a distinct .zero category (English does not).
        setupArabicMockTranslations()
        let key = "items_count"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Default zero",
            .one: "Default one",
            .other: "Default other"
        ]

        // When - count 0 resolves against Arabic rules via currentLanguageCode.
        let result = key.localize(defaultPlural: defaultPlural, count: 0, file: storeModuleFile)

        // Then - Arabic .zero server form is selected, unlike English which would pick .other.
        XCTAssertEqual(result, "لا عناصر")
    }

    func testPluralLocalize_withSwitchFromEnglishToArabic_shouldApplyArabicPluralRules() {
        // Given - English is active; CLDR maps count 2 to .other for English.
        setupMockTranslations()
        let key = "items_count"
        let defaultPlural: [PluralCategory: String] = [
            .two: "Default two",
            .other: "Default other"
        ]
        let englishResult = key.localize(defaultPlural: defaultPlural, count: 2, file: storeModuleFile)
        XCTAssertEqual(englishResult, "%d items in cart")

        // When - switching to Arabic and resolving the same key and count.
        setupArabicMockTranslations()
        let arabicResult = key.localize(defaultPlural: defaultPlural, count: 2, file: storeModuleFile)

        // Then - the same count now resolves to Arabic's .two form, proving plural rules follow the active language.
        XCTAssertEqual(arabicResult, "عنصران")
    }

    func testPluralLocalize_withFrenchZeroCountAndMissingTranslation_shouldUseAppLanguageNotDeviceLocale() {
        // Given - French is active, but the key has no server translation, so resolution
        // falls through to the default-plural dictionary. French CLDR maps count 0 to .one,
        // whereas English (the usual device/test locale) maps it to .other.
        setupFrenchMockTranslations()
        let key = "missing_items_count" // Absent from the French mock → default-plural branch.
        let defaultPlural: [PluralCategory: String] = [
            .one: "%d élément ajouté",
            .other: "%d éléments ajoutés"
        ]

        // When - resolving the fallback category for count 0.
        let result = key.localize(defaultPlural: defaultPlural, count: 0, with: 0, file: storeModuleFile)

        // Then - the .one form is chosen from the app language (French), not .other from the
        // device locale. This guards the fix where the fallback category ignored the locale
        // (e.g. a French device on an English app would otherwise pick English's .other).
        XCTAssertEqual(result, "0 élément ajouté")
    }

    // MARK: - Edge Cases for Counts

    func testPluralLocalize_withNegativeCount_shouldReturnOtherForm() {
        // Given.
        let key = "balance"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "No balance",
            .one: "One unit",
            .other: "%d units"
        ]

        // When.
        let result = key.localize(defaultPlural: defaultPlural, count: -5, with: -5, file: storeModuleFile)

        // Then - negative treated as .other.
        XCTAssertEqual(result, "-5 units")
    }

    func testPluralLocalize_withVeryLargeCount_shouldReturnOtherForm() {
        // Given.
        let key = "items"
        let defaultPlural: [PluralCategory: String] = [
            .one: "One item",
            .other: "%d items"
        ]

        // When - Note: %d format specifier has limitations with Int.max (64-bit).
        // Using a large but safe value instead.
        let largeCount = 999_999_999
        let result = key.localize(defaultPlural: defaultPlural, count: largeCount, with: largeCount, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, "\(largeCount) items")
    }

    func testPluralLocalize_withZeroCountAndOnlyOtherForm_shouldReturnOtherForm() {
        // Given - only .other form provided.
        let key = "items"
        let defaultPlural: [PluralCategory: String] = [
            .other: "%d items available"
        ]

        // When - English maps count=0 to .other directly (no .zero category in English).
        let result = key.localize(defaultPlural: defaultPlural, count: 0, with: 0, file: storeModuleFile)

        // Then - .other is the exact match, not a fallback.
        XCTAssertEqual(result, "0 items available")
    }

    // MARK: - Key Format Edge Cases

    func testSimpleLocalize_withEmptyKey_shouldReturnDefault() {
        // Given.
        let key = ""
        let defaultValue = "Fallback"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - should return default.
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_withMultipleUnderscoresInKey_shouldReturnDefault() {
        // Given.
        setupMockTranslations()
        let key = "user_profile_name_label"
        let defaultValue = "Name Label"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - should handle multiple underscores (module is "store").
        XCTAssertEqual(result, defaultValue) // No translation exists.
    }

    func testSimpleLocalize_withUnicodeCharactersInKey_shouldReturnDefault() {
        // Given.
        let key = "emoji_🎉_test"
        let defaultValue = "Party Test"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - should return default (non-standard key).
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_withUppercaseModuleInKey_shouldReturnDefault() {
        // Given.
        setupMockTranslations()
        let key = "STORE_welcome"
        let defaultValue = "Welcome"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - case sensitive, should not find translation.
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_withVeryLongKey_shouldReturnDefault() {
        // Given.
        let key = "" + String(repeating: "a", count: 1000)
        let defaultValue = "Long Key Test"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - should handle gracefully.
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_withUnderscoreOnlyKey_shouldReturnDefault() {
        // Given.
        let key = "_"
        let defaultValue = "Underscore Only"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - invalid format.
        XCTAssertEqual(result, defaultValue)
    }

    func testSimpleLocalize_withLeadingUnderscoreInKey_shouldReturnDefault() {
        // Given.
        let key = "_store_welcome"
        let defaultValue = "Welcome"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - module would be empty.
        XCTAssertEqual(result, defaultValue)
    }

    // MARK: - Value Edge Cases

    func testSimpleLocalize_withEmptyDefaultValue_shouldReturnEmptyString() {
        // Given.
        let key = "empty"
        let defaultValue = ""

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - should return empty string.
        XCTAssertEqual(result, "")
    }

    func testSimpleLocalize_withUnicodeDefaultValue_shouldReturnDefault() {
        // Given.
        let key = "greeting"
        let defaultValue = "Hello 👋 مرحبا নমস্কার"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then.
        XCTAssertEqual(result, defaultValue)
    }

    // MARK: - Format String Mismatch Tests

    func testLocalizeWithArgs_withMorePlaceholdersThanArguments_shouldFallBackToVerbatimFormat() {
        // Given - format has three placeholders but only two arguments are supplied.
        let key = "format"
        let defaultValue = "Name: %@, City: %@, Age: %d"

        // When - providing 2 arguments for 3 placeholders.
        let result = key.localize(default: defaultValue, with: "John", "Bangladesh", file: storeModuleFile)

        // Then - SafeFormat refuses to read the missing third slot and returns the format string
        // verbatim rather than partially interpolating, so neither supplied argument appears.
        XCTAssertEqual(result, "Name: %@, City: %@, Age: %d")
        XCTAssertFalse(result.contains("John"))
        XCTAssertFalse(result.contains("Bangladesh"))
    }

    func testLocalizeWithArgs_withFewerPlaceholdersThanArguments_shouldIgnoreExtraArguments() {
        // Given.
        let key = "format"
        let defaultValue = "Name: %@"

        // When - providing 2 arguments for 1 placeholder.
        let result = key.localize(default: defaultValue, with: "John", 30, file: storeModuleFile)

        // Then - extra argument is ignored.
        XCTAssertEqual(result, "Name: John")
    }

    func testLocalizeWithArgs_withEscapedPercentSign_shouldRenderSinglePercent() {
        // Given.
        let key = "discount"
        let defaultValue = "Save %%d off!" // Escaped %.

        // When.
        let result = key.localize(default: defaultValue, with: 20, file: storeModuleFile)

        // Then - %% becomes single %.
        XCTAssertTrue(result.contains("%"))
    }

    func testLocalizeWithArgs_withArgumentsButNoPlaceholders_shouldReturnStaticText() {
        // Given.
        let key = "static"
        let defaultValue = "Static text without placeholders"

        // When - providing arguments that won't be used.
        let result = key.localize(default: defaultValue, with: "Ignored", 42, file: storeModuleFile)

        // Then - arguments ignored, returns static text.
        XCTAssertEqual(result, defaultValue)
    }

    func testPluralLocalizeWithArgs_withDifferentPlaceholderTypesPerForm_shouldFormatSelectedForm() {
        // Given - the .one and .other forms declare different placeholder types.
        let key = "items"
        let defaultPlural: [PluralCategory: String] = [
            .one: "One item: %@", // String placeholder.
            .other: "%d items" // Integer placeholder.
        ]

        // When - count selects .other (%d) and is formatted with a matching Int.
        let otherResult = key.localize(defaultPlural: defaultPlural, count: 5, with: 5, file: storeModuleFile)

        // Then - the .other form is used with its integer argument.
        XCTAssertEqual(otherResult, "5 items")

        // When - count selects .one (%@) and is formatted with a matching String.
        let oneResult = key.localize(defaultPlural: defaultPlural, count: 1, with: "Apple", file: storeModuleFile)

        // Then - the .one form is used with its string argument.
        XCTAssertEqual(oneResult, "One item: Apple")
    }

    // MARK: - Translation Type Mismatch Tests

    func testSimpleLocalize_withPluralTranslation_shouldReturnDefault() {
        // Given - setup translation marked as plural type.
        setupMockTranslations()
        let key = "items_count" // This is a plural type in mock.
        let defaultValue = "Default items"

        // When - calling simple localize on a plural translation.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - string(for:in:) returns nil for a plural entry, so the default is returned.
        XCTAssertEqual(result, defaultValue)
    }

    func testPluralLocalize_withSimpleTranslation_shouldFallBackToDefaultPlural() {
        // Given.
        setupMockTranslations()
        let key = "welcome" // This is a simple type in mock.
        let defaultPlural: [PluralCategory: String] = [
            .one: "One welcome",
            .other: "%d welcomes"
        ]

        // When - calling plural localize on a simple translation.
        let result = key.localize(defaultPlural: defaultPlural, count: 5, file: storeModuleFile)

        // Then - pluralString(...) returns nil for a simple entry, so the default plural is used (count 5 -> .other).
        XCTAssertEqual(result, "%d welcomes")
    }

    func testPluralLocalize_withInterpolationTranslation_shouldFallBackToDefaultPlural() {
        // Given.
        setupMockTranslations()
        let key = "greeting" // This is interpolation type in mock (a simple entry with a placeholder).
        let defaultPlural: [PluralCategory: String] = [
            .one: "One greeting",
            .other: "%d greetings"
        ]

        // When - calling plural localize on interpolation translation.
        let result = key.localize(defaultPlural: defaultPlural, count: 5, file: storeModuleFile)

        // Then - pluralString(...) returns nil for a non-plural entry, so the default plural is used (count 5 -> .other).
        XCTAssertEqual(result, "%d greetings")
    }

    // MARK: - LocalizationManager State Tests

    func testLocalize_withNoActiveLanguage_shouldReturnDefault() {
        // Given - fresh state, no language activated (already cleared in setUp).
        let key = "test"
        let defaultValue = "Test Value"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - should return default.
        XCTAssertEqual(result, defaultValue)
    }

    func testLocalize_withMultipleActivatedLanguages_shouldUseLatestLanguage() async {
        // Given - activate first language.
        setupMockTranslations() // English.

        // Verify first language works.
        let result1 = "welcome".localize(default: "Welcome", file: storeModuleFile)
        XCTAssertEqual(result1, "Welcome Translated")

        // When - activate another language.
        let spanishTranslations = TranslationFile(modules: [
            "Store": ModuleTranslations(translations: [
                "welcome": TranslationEntry(
                    value: .simple("Bienvenido")
                )
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
        let result2 = "welcome".localize(default: "Welcome", file: storeModuleFile)
        XCTAssertEqual(result2, "Bienvenido")
    }

    func testLocalize_withClearedCache_shouldReturnDefault() async {
        // Given - setup translations.
        setupMockTranslations()

        // Verify translation exists.
        let result1 = "welcome".localize(default: "Welcome", file: storeModuleFile)
        XCTAssertEqual(result1, "Welcome Translated")

        // When - clear cache.
        await LocalizationManager.shared.clearCache()

        // Then - should fallback to default.
        let result2 = "welcome".localize(default: "Welcome", file: storeModuleFile)
        XCTAssertEqual(result2, "Welcome")
    }

    func testLocalize_withConcurrentAccess_shouldCompleteAllRequests() async {
        // Given.
        setupMockTranslations()

        // When - multiple concurrent localization calls.
        await withTaskGroup(of: String.self) { group in
            for i in 0 ..< 100 {
                group.addTask { @MainActor in
                    if i % 2 == 0 {
                        return "welcome".localize(default: "Welcome", file: self.storeModuleFile)
                    } else {
                        return "greeting".localize(default: "Hello, %@!", with: "User\(i)")
                    }
                }
            }

            // Then - all should complete without crashes.
            var results: [String] = []
            for await result in group {
                results.append(result)
            }

            XCTAssertEqual(results.count, 100)
        }
    }

    // MARK: - Module Boundary Tests

    func testLocalize_withNonExistentModule_shouldReturnDefault() {
        // Given.
        setupMockTranslations()
        let key = "fake_module_test"
        let defaultValue = "Test"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - should return default.
        XCTAssertEqual(result, defaultValue)
    }

    func testLocalize_withKeyInDifferentModule_shouldReturnDefault() {
        // Given.
        setupMockTranslations() // Only Store module has translations.
        let key = "home_welcome" // Trying to access as Home module.
        let defaultValue = "Home Welcome"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - should return default (not found in Home module).
        XCTAssertEqual(result, defaultValue)
    }

    func testLocalize_withMatchingModuleNameCase_shouldReturnTranslation() {
        // Given.
        setupMockTranslations() // Module is "Store".
        let key = "welcome"
        let defaultValue = "Welcome"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - should find translation (depends on implementation case sensitivity).
        XCTAssertEqual(result, "Welcome Translated")
    }

    func testLocalize_withDifferentKeyNameCase_shouldReturnDefault() {
        // Given.
        setupMockTranslations() // Key is "welcome".
        let key = "Welcome" // Different case.
        let defaultValue = "Welcome"

        // When.
        let result = key.localize(default: defaultValue, file: storeModuleFile)

        // Then - should not find (case sensitive).
        XCTAssertEqual(result, defaultValue)
    }

    func testPluralLocalize_withMissingOtherCategory_shouldReturnFallbackForm() {
        // Given - unusual case where .other is not defined.
        let key = "items"
        let defaultPlural: [PluralCategory: String] = [
            .zero: "Zero",
            .one: "One"
        ]

        // When/Then - count that doesn't match defined categories.
        let result = key.localize(defaultPlural: defaultPlural, count: 5, file: storeModuleFile)

        // Then - should fallback to .one then return key as last resort.
        XCTAssertEqual(result, "One")
    }
}
