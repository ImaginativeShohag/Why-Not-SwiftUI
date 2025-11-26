import SwiftUI

// MARK: - Text Localization Extension with Markdown Support

extension Text {
    /// Creates a Text view with localized markdown content
    /// - Parameters:
    ///   - key: Translation key
    ///   - defaultValue: Default markdown string
    ///   - comment: Comment for translators
    /// - Returns: Text view with rendered markdown
    ///
    /// Example:
    /// ```swift
    /// Text.localized(
    ///     "store_welcome",
    ///     default: "Welcome, **%@**!",
    ///     comment: "Welcome message",
    ///     with: userName
    /// )
    /// ```
    @MainActor
    public static func localized(
        _ key: String,
        default defaultValue: String,
        comment: String = ""
    ) -> Text {
        let localizedString = key.localize(default: defaultValue, comment: comment)

        // Try to parse as markdown, fallback to plain text if fails
        if let attributedString = try? AttributedString(markdown: localizedString) {
            return Text(attributedString)
        } else {
            return Text(localizedString)
        }
    }

    /// Creates a Text view with localized markdown content and single interpolation
    /// - Parameters:
    ///   - key: Translation key
    ///   - defaultValue: Default markdown format string
    ///   - comment: Comment for translators
    ///   - argument: Value to interpolate
    /// - Returns: Text view with rendered markdown
    @MainActor
    public static func localized(
        _ key: String,
        default defaultValue: String,
        comment: String = "",
        with argument: CVarArg
    ) -> Text {
        let localizedString = key.localize(default: defaultValue, comment: comment, with: argument)

        // Try to parse as markdown, fallback to plain text if fails
        if let attributedString = try? AttributedString(markdown: localizedString) {
            return Text(attributedString)
        } else {
            return Text(localizedString)
        }
    }

    /// Creates a Text view with localized markdown content and multiple interpolations
    /// - Parameters:
    ///   - key: Translation key
    ///   - defaultValue: Default markdown format string
    ///   - comment: Comment for translators
    ///   - arguments: Values to interpolate
    /// - Returns: Text view with rendered markdown
    @MainActor
    public static func localized(
        _ key: String,
        default defaultValue: String,
        comment: String = "",
        with arguments: CVarArg...
    ) -> Text {
        let format = key.localize(default: defaultValue, comment: comment)
        let localizedString = String(format: format, arguments: arguments)

        // Try to parse as markdown, fallback to plain text if fails
        if let attributedString = try? AttributedString(markdown: localizedString) {
            return Text(attributedString)
        } else {
            return Text(localizedString)
        }
    }
}
