import Foundation

// MARK: - String Localization Extension

extension String {
    /// Extract module name from `#fileID`.
    /// - Parameter fileID: Compile-time file identifier (e.g., `"Store/Sources/UI/CartScreen.swift"`).
    /// - Returns: Module name (e.g., `"Store"`).
    internal static func extractModuleName(from fileID: String) -> String {
        // Early validation: paths starting with "/" are invalid #fileID format.
        guard !fileID.hasPrefix("/") else {
            LocalizeKitLogger.e("Module extraction failed for fileID: '\(fileID)'. Path starts with leading slash.")
            return "Unknown"
        }

        // #fileID format: "ModuleName/Sources/..."
        // Extract first component before "/".
        let components = fileID.split(separator: "/", maxSplits: 1)

        guard let moduleName = components.first.map(String.init), !moduleName.isEmpty else {
            LocalizeKitLogger.e("Module extraction failed for fileID: '\(fileID)'. Returning 'Unknown'.")
            return "Unknown"
        }

        return moduleName
    }

    /// Simple localization with default fallback.
    /// - Parameters:
    ///   - defaultValue: English text to show if translation not found.
    ///   - comment: Context for translators (optional).
    ///   - file: Source file identifier (automatic via `#fileID`).
    /// - Returns: Localized string or default value.
    ///
    /// Example:
    /// ```swift
    /// Text("cart_title".localize(
    ///     default: "Cart",
    ///     comment: "Cart screen title"
    /// ))
    /// ```
    @MainActor
    public func localize(
        default defaultValue: String,
        comment: String? = nil,
        file: String = #fileID
    ) -> String {
        let moduleName = Self.extractModuleName(from: file)
        return LocalizationManager.shared.string(for: self, in: moduleName) ?? defaultValue
    }

    /// Localization with string interpolation (single parameter).
    /// - Parameters:
    ///   - defaultValue: English format string with placeholder (e.g., `"Hello, %@!"`).
    ///   - comment: Context for translators.
    ///   - argument: Value to interpolate.
    ///   - file: Source file identifier (automatic via `#fileID`).
    /// - Returns: Formatted localized string.
    ///
    /// Example:
    /// ```swift
    /// Text("greeting".localize(
    ///     default: "Hello, %@!",
    ///     comment: "Personal greeting with user's name",
    ///     with: userName
    /// ))
    /// ```
    @MainActor
    public func localize(
        default defaultValue: String,
        comment: String? = nil,
        with argument: CVarArg,
        file: String = #fileID
    ) -> String {
        let format = localize(default: defaultValue, comment: comment, file: file)
        return SafeFormat.string(
            format,
            arguments: [argument],
            key: self,
            module: Self.extractModuleName(from: file)
        )
    }

    /// Localization with string interpolation (multiple parameters).
    /// - Parameters:
    ///   - defaultValue: English format string with placeholders (e.g., `"Order #%@ contains %d items"`).
    ///   - comment: Context for translators.
    ///   - arguments: Values to interpolate.
    ///   - file: Source file identifier (automatic via `#fileID`).
    /// - Returns: Formatted localized string.
    ///
    /// Example:
    /// ```swift
    /// Text("order_summary".localize(
    ///     default: "Order #%@ contains %d items",
    ///     comment: "Order summary with ID and item count",
    ///     with: orderID, itemCount
    /// ))
    /// ```
    @MainActor
    public func localize(
        default defaultValue: String,
        comment: String? = nil,
        with arguments: CVarArg...,
        file: String = #fileID
    ) -> String {
        let format = localize(default: defaultValue, comment: comment, file: file)
        return SafeFormat.string(
            format,
            arguments: arguments,
            key: self,
            module: Self.extractModuleName(from: file)
        )
    }

    /// Localization with plural support.
    /// - Parameters:
    ///   - defaultPlural: Dictionary of plural forms for English.
    ///   - comment: Context for translators.
    ///   - count: The count to determine plural form.
    ///   - file: Source file identifier (automatic via `#fileID`).
    /// - Returns: Localized plural string.
    ///
    /// Example:
    /// ```swift
    /// Text("cart_status".localize(
    ///     defaultPlural: [
    ///         .zero: "Cart is empty",
    ///         .one: "One item in cart",
    ///         .other: "Multiple items in cart"
    ///     ],
    ///     comment: "Cart status message",
    ///     count: itemCount
    /// ))
    /// ```
    @MainActor
    public func localize(
        defaultPlural: [PluralCategory: String],
        comment: String? = nil,
        count: Int,
        file: String = #fileID
    ) -> String {
        // Try to get from server/cache first.
        let moduleName = Self.extractModuleName(from: file)
        if let translated = LocalizationManager.shared.pluralString(for: self, in: moduleName, count: count) {
            return translated
        }

        // Fallback to default plurals.
        // Use the app's selected language for plural rules, not the device locale,
        // otherwise a French device running the app in English would pick French
        // plural forms (e.g. count 0 → "one") for the English default strings.
        let locale = Locale(identifier: LocalizationManager.shared.currentLanguageCode)
        let category = PluralCategory.category(
            for: count,
            locale: locale,
            customRules: LocalizationManager.shared.pluralRules
        )

        // Try exact category match first.
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

    /// Localization with plural and interpolation (single parameter).
    /// - Parameters:
    ///   - defaultPlural: Dictionary of plural format strings for English.
    ///   - comment: Context for translators.
    ///   - count: The count for plural form.
    ///   - argument: Value to interpolate.
    ///   - file: Source file identifier (automatic via `#fileID`).
    /// - Returns: Formatted localized plural string.
    ///
    /// Example:
    /// ```swift
    /// Text("apple_count".localize(
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
        with argument: CVarArg,
        file: String = #fileID
    ) -> String {
        let format = localize(defaultPlural: defaultPlural, comment: comment, count: count, file: file)
        return SafeFormat.string(
            format,
            arguments: [argument],
            key: self,
            module: Self.extractModuleName(from: file)
        )
    }

    /// Localization with plural and interpolation (multiple parameters).
    /// - Parameters:
    ///   - defaultPlural: Dictionary of plural format strings for English.
    ///   - comment: Context for translators.
    ///   - count: The count for plural form.
    ///   - arguments: Values to interpolate.
    ///   - file: Source file identifier (automatic via `#fileID`).
    /// - Returns: Formatted localized plural string.
    ///
    /// Example:
    /// ```swift
    /// Text("item_summary".localize(
    ///     defaultPlural: [
    ///         .zero: "Your cart is empty",
    ///         .one: "You have %d item worth %@",
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
        with arguments: CVarArg...,
        file: String = #fileID
    ) -> String {
        let format = localize(defaultPlural: defaultPlural, comment: comment, count: count, file: file)
        return SafeFormat.string(
            format,
            arguments: arguments,
            key: self,
            module: Self.extractModuleName(from: file)
        )
    }
}
