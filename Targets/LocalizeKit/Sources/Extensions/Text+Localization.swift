import SwiftUI

// MARK: - Text Localization Extension with Markdown Support

extension Text {
    /// Creates a Text view with localized markdown content.
    /// - Parameters:
    ///   - key: Translation key.
    ///   - defaultValue: Default markdown string.
    ///   - comment: Comment for translators.
    ///   - file: Source file identifier (automatic via #fileID).
    /// - Returns: Text view with rendered markdown.
    ///
    /// Example:
    /// ```swift
    /// Text.localized(
    ///     "welcome",
    ///     default: "Welcome, **%@**!",
    ///     comment: "Welcome message",
    ///     with: userName
    /// )
    /// ```
    @MainActor
    public static func localized(
        _ key: String,
        default defaultValue: String,
        comment: String = "",
        file: String = #fileID
    ) -> Text {
        let localizedString = key.localize(default: defaultValue, comment: comment, file: file)

        // Try to parse as markdown, fallback to plain text if fails.
        if let attributedString = try? AttributedString(markdown: localizedString) {
            return Text(attributedString)
        } else {
            return Text(localizedString)
        }
    }

    /// Creates a Text view with localized markdown content and single interpolation.
    /// - Parameters:
    ///   - key: Translation key.
    ///   - defaultValue: Default markdown format string.
    ///   - comment: Comment for translators.
    ///   - argument: Value to interpolate.
    ///   - file: Source file identifier (automatic via #fileID).
    /// - Returns: Text view with rendered markdown.
    @MainActor
    public static func localized(
        _ key: String,
        default defaultValue: String,
        comment: String = "",
        with argument: CVarArg,
        file: String = #fileID
    ) -> Text {
        let localizedString = key.localize(default: defaultValue, comment: comment, with: argument, file: file)

        // Try to parse as markdown, fallback to plain text if fails.
        if let attributedString = try? AttributedString(markdown: localizedString) {
            return Text(attributedString)
        } else {
            return Text(localizedString)
        }
    }

    /// Creates a Text view with localized markdown content and multiple interpolations.
    /// - Parameters:
    ///   - key: Translation key.
    ///   - defaultValue: Default markdown format string.
    ///   - comment: Comment for translators.
    ///   - arguments: Values to interpolate.
    ///   - file: Source file identifier (automatic via #fileID).
    /// - Returns: Text view with rendered markdown.
    @MainActor
    public static func localized(
        _ key: String,
        default defaultValue: String,
        comment: String = "",
        with arguments: CVarArg...,
        file: String = #fileID
    ) -> Text {
        let format = key.localize(default: defaultValue, comment: comment, file: file)
        let localizedString = SafeFormat.string(
            format,
            arguments: arguments,
            key: key,
            module: String.extractModuleName(from: file)
        )

        // Try to parse as markdown, fallback to plain text if fails.
        if let attributedString = try? AttributedString(markdown: localizedString) {
            return Text(attributedString)
        } else {
            return Text(localizedString)
        }
    }

    // MARK: - Plural Localization Methods

    /// Creates a Text view with localized markdown content and plural forms (no interpolation).
    /// - Parameters:
    ///   - key: Translation key.
    ///   - defaultPlural: Dictionary of plural forms with English defaults.
    ///   - comment: Comment for translators.
    ///   - count: Count value for plural category selection.
    ///   - file: Source file identifier (automatic via #fileID).
    /// - Returns: Text view with rendered markdown.
    ///
    /// Example:
    /// ```swift
    /// Text.localized(
    ///     "cart_status",
    ///     defaultPlural: [
    ///         .zero: "Cart is empty",
    ///         .one: "One item in cart",
    ///         .other: "Multiple items in cart"
    ///     ],
    ///     comment: "Cart status message",
    ///     count: itemCount
    /// )
    /// ```
    @MainActor
    public static func localized(
        _ key: String,
        defaultPlural: [PluralCategory: String],
        comment: String = "",
        count: Int,
        file: String = #fileID
    ) -> Text {
        let localizedString = key.localize(
            defaultPlural: defaultPlural,
            comment: comment,
            count: count,
            file: file
        )

        // Try to parse as markdown, fallback to plain text if fails.
        if let attributedString = try? AttributedString(markdown: localizedString) {
            return Text(attributedString)
        } else {
            return Text(localizedString)
        }
    }

    /// Creates a Text view with localized markdown content and plural forms with single interpolation.
    /// - Parameters:
    ///   - key: Translation key.
    ///   - defaultPlural: Dictionary of plural forms with format strings.
    ///   - comment: Comment for translators.
    ///   - count: Count value for plural category selection.
    ///   - argument: Value to interpolate.
    ///   - file: Source file identifier (automatic via #fileID).
    /// - Returns: Text view with rendered markdown.
    ///
    /// Example:
    /// ```swift
    /// Text.localized(
    ///     "cart_items",
    ///     defaultPlural: [
    ///         .one: "1 item in cart",
    ///         .other: "%d items in cart"
    ///     ],
    ///     comment: "Shopping cart item count",
    ///     count: count,
    ///     with: count
    /// )
    /// ```
    @MainActor
    public static func localized(
        _ key: String,
        defaultPlural: [PluralCategory: String],
        comment: String = "",
        count: Int,
        with argument: CVarArg,
        file: String = #fileID
    ) -> Text {
        let localizedString = key.localize(
            defaultPlural: defaultPlural,
            comment: comment,
            count: count,
            with: argument,
            file: file
        )

        // Try to parse as markdown, fallback to plain text if fails.
        if let attributedString = try? AttributedString(markdown: localizedString) {
            return Text(attributedString)
        } else {
            return Text(localizedString)
        }
    }

    /// Creates a Text view with localized markdown content and plural forms with multiple interpolations.
    /// - Parameters:
    ///   - key: Translation key.
    ///   - defaultPlural: Dictionary of plural forms with format strings.
    ///   - comment: Comment for translators.
    ///   - count: Count value for plural category selection.
    ///   - arguments: Values to interpolate.
    ///   - file: Source file identifier (automatic via #fileID).
    /// - Returns: Text view with rendered markdown.
    ///
    /// Example:
    /// ```swift
    /// Text.localized(
    ///     "item_summary",
    ///     defaultPlural: [
    ///         .zero: "Your cart is empty",
    ///         .one: "You have 1 item worth %@",
    ///         .other: "You have %d items worth %@"
    ///     ],
    ///     comment: "Cart summary with count and total price",
    ///     count: itemCount,
    ///     with: itemCount, totalPrice
    /// )
    /// ```
    @MainActor
    public static func localized(
        _ key: String,
        defaultPlural: [PluralCategory: String],
        comment: String = "",
        count: Int,
        with arguments: CVarArg...,
        file: String = #fileID
    ) -> Text {
        // Resolve the plural format string first, then interpolate so the collected `arguments`
        // array is applied via `String(format:arguments:)` rather than forwarded into a variadic.
        let format = key.localize(
            defaultPlural: defaultPlural,
            comment: comment,
            count: count,
            file: file
        )
        let localizedString = SafeFormat.string(
            format,
            arguments: arguments,
            key: key,
            module: String.extractModuleName(from: file)
        )

        // Try to parse as markdown, fallback to plain text if fails.
        if let attributedString = try? AttributedString(markdown: localizedString) {
            return Text(attributedString)
        } else {
            return Text(localizedString)
        }
    }
}
