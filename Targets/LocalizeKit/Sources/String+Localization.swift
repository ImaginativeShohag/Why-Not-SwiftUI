import Foundation

// MARK: - String Localization Extension

extension String {
    /// Simple localization with default fallback
    /// - Parameters:
    ///   - defaultValue: English text to show if translation not found
    ///   - comment: Context for translators (optional)
    /// - Returns: Localized string or default value
    ///
    /// Example:
    /// ```swift
    /// Text("store_welcome".localize(
    ///     default: "Welcome to the Store!",
    ///     comment: "Greeting shown on store home screen"
    /// ))
    /// ```
    @MainActor
    public func localize(
        default defaultValue: String,
        comment: String? = nil
    ) -> String {
        LocalizationManager.shared.string(for: self) ?? defaultValue
    }

    /// Localization with string interpolation (single parameter)
    /// - Parameters:
    ///   - defaultValue: English format string with placeholder (e.g., "Hello, %@!")
    ///   - comment: Context for translators
    ///   - argument: Value to interpolate
    /// - Returns: Formatted localized string
    ///
    /// Example:
    /// ```swift
    /// Text("store_greeting".localize(
    ///     default: "Hello, %@!",
    ///     comment: "Personal greeting with user's name",
    ///     with: userName
    /// ))
    /// ```
    @MainActor
    public func localize(
        default defaultValue: String,
        comment: String? = nil,
        with argument: CVarArg
    ) -> String {
        let format = localize(default: defaultValue, comment: comment)
        return String(format: format, argument)
    }

    /// Localization with string interpolation (multiple parameters)
    /// - Parameters:
    ///   - defaultValue: English format string with placeholders (e.g., "Order #%@ contains %d items")
    ///   - comment: Context for translators
    ///   - arguments: Values to interpolate
    /// - Returns: Formatted localized string
    ///
    /// Example:
    /// ```swift
    /// Text("store_order_summary".localize(
    ///     default: "Order #%@ contains %d items",
    ///     comment: "Order summary with ID and item count",
    ///     with: orderID, itemCount
    /// ))
    /// ```
    @MainActor
    public func localize(
        default defaultValue: String,
        comment: String? = nil,
        with arguments: CVarArg...
    ) -> String {
        let format = localize(default: defaultValue, comment: comment)
        return String(format: format, arguments: arguments)
    }

    /// Localization with plural support
    /// - Parameters:
    ///   - defaultPlural: Dictionary of plural forms for English
    ///   - comment: Context for translators
    ///   - count: The count to determine plural form
    /// - Returns: Localized plural string
    ///
    /// Example:
    /// ```swift
    /// Text("store_apple_count".localize(
    ///     defaultPlural: [
    ///         .zero: "No apples",
    ///         .one: "1 apple",
    ///         .other: "%d apples"
    ///     ],
    ///     comment: "Apple count in shopping cart",
    ///     count: appleCount
    /// ))
    /// ```
    @MainActor
    public func localize(
        defaultPlural: [PluralCategory: String],
        comment: String? = nil,
        count: Int
    ) -> String {
        // Try to get from server/cache first
        if let translated = LocalizationManager.shared.pluralString(for: self, count: count) {
            return translated
        }

        // Fallback to default plurals
        let category = PluralCategory.category(
            for: count,
            customRules: LocalizationManager.shared.pluralRules
        )

        // Try exact category match first
        if let value = defaultPlural[category] {
            return value
        }

        // Fallback chain: other → many → few → two → one → zero → key
        return defaultPlural[.other]
            ?? defaultPlural[.many]
            ?? defaultPlural[.few]
            ?? defaultPlural[.two]
            ?? defaultPlural[.one]
            ?? defaultPlural[.zero]
            ?? self  // Last resort: return key
    }

    /// Localization with plural and interpolation (single parameter)
    /// - Parameters:
    ///   - defaultPlural: Dictionary of plural format strings for English
    ///   - comment: Context for translators
    ///   - count: The count for plural form
    ///   - argument: Value to interpolate
    /// - Returns: Formatted localized plural string
    ///
    /// Example:
    /// ```swift
    /// Text("store_apple_count".localize(
    ///     defaultPlural: [
    ///         .zero: "No apples",
    ///         .one: "1 apple",
    ///         .other: "%d apples"
    ///     ],
    ///     comment: "Apple count in shopping cart",
    ///     count: appleCount,
    ///     with: appleCount
    /// ))
    /// ```
    @MainActor
    public func localize(
        defaultPlural: [PluralCategory: String],
        comment: String? = nil,
        count: Int,
        with argument: CVarArg
    ) -> String {
        let format = localize(defaultPlural: defaultPlural, comment: comment, count: count)
        return String(format: format, argument)
    }

    /// Localization with plural and interpolation (multiple parameters)
    /// - Parameters:
    ///   - defaultPlural: Dictionary of plural format strings for English
    ///   - comment: Context for translators
    ///   - count: The count for plural form
    ///   - arguments: Values to interpolate
    /// - Returns: Formatted localized plural string
    ///
    /// Example:
    /// ```swift
    /// Text("store_item_summary".localize(
    ///     defaultPlural: [
    ///         .zero: "Your cart is empty",
    ///         .one: "You have 1 item worth %@",
    ///         .other: "You have %d items worth %@"
    ///     ],
    ///     comment: "Cart summary with count and total price",
    ///     count: itemCount,
    ///     with: itemCount, totalPrice
    /// ))
    /// ```
    @MainActor
    public func localize(
        defaultPlural: [PluralCategory: String],
        comment: String? = nil,
        count: Int,
        with arguments: CVarArg...
    ) -> String {
        let format = localize(defaultPlural: defaultPlural, comment: comment, count: count)
        return String(format: format, arguments: arguments)
    }
}
