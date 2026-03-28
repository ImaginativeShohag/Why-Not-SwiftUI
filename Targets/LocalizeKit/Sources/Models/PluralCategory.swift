import Foundation

/// Plural rule function signature.
/// - Parameters:
///   - choice: The numeric value to determine plural form.
///   - choicesLength: Number of available plural categories (always 6 for CLDR).
/// - Returns: Index of the plural category to use (0-5)
public typealias PluralRule = (_ choice: Int, _ choicesLength: Int) -> Int

/// CLDR-compliant plural categories for localization.
/// Covers all world languages with 6 distinct plural forms.
public enum PluralCategory: String, Codable, CaseIterable, Sendable {
    case zero
    case one
    case two
    case few
    case many
    case other

    /// Determine plural category for a count based on custom rules or built-in locale rules.
    /// - Parameters:
    ///   - count: The numeric value.
    ///   - locale: The locale (defaults to current).
    ///   - customRules: Optional dictionary of custom plural rules per language.
    /// - Returns: The appropriate plural category.
    public static func category(
        for count: Int,
        locale: Locale = .current,
        customRules: [String: PluralRule] = [:]
    ) -> PluralCategory {
        let allCategories: [PluralCategory] = [.zero, .one, .two, .few, .many, .other]
        let languageCode = locale.language.languageCode?.identifier ?? Constants.fallbackLanguageCode

        // 1. Check if custom rule exists for current language.
        if let customRule = customRules[languageCode] {
            let index = customRule(count, allCategories.count)
            // Clamp index to valid range (0-5).
            let safeIndex = max(0, min(index, allCategories.count - 1))
            return allCategories[safeIndex]
        }

        // 2. Fallback to built-in ICU/CLDR rules.
        return builtInCategory(for: count, languageCode: languageCode)
    }

    /// Built-in plural rules following CLDR standards for integer values.
    /// These rules only apply when no custom rule is set for the language.
    /// For custom zero-form handling (e.g., "No items" for count 0),
    /// use the `customRules` parameter in `category(for:locale:customRules:)`.
    ///
    /// CLDR defines `n` as "absolute value of the source number",
    /// so negative counts are normalized via `abs()` before applying rules.
    ///
    /// Reference: https://www.unicode.org/cldr/charts/48/supplemental/language_plural_rules.html
    private static func builtInCategory(for count: Int, languageCode: String) -> PluralCategory {
        // CLDR operand `n` is the absolute value of the source number.
        let count = abs(count)
        switch languageCode {
        case "en", "de", "nl", "sv", "da", "no", "nn", "nb", "et", "fi", "gl", "hu", "lb", "ml", "mr", "sw", "ta", "te", "ur", "fo":
            // one (n=1), other
            if count == 1 { return .one }
            return .other

        case "is":
            // Icelandic: one (mod10=1, except mod100=11), other
            if count % 10 == 1 && count % 100 != 11 { return .one }
            return .other

        case "it", "es", "ca":
            // Romance: one (n=1), many (exact millions), other
            if count == 1 { return .one }
            if count != 0 && count % 1_000_000 == 0 { return .many }
            return .other

        case "pt":
            // Portuguese: one (n=0..1), many (exact millions), other
            if count == 0 || count == 1 { return .one }
            if count != 0 && count % 1_000_000 == 0 { return .many }
            return .other

        case "fr":
            // French: one (n=0..1), many (exact millions), other
            if count == 0 || count == 1 { return .one }
            if count != 0 && count % 1_000_000 == 0 { return .many }
            return .other

        case "bn", "hi", "gu", "pa", "zu":
            // South Asian: one (n=0..1), other
            if count == 0 || count == 1 { return .one }
            return .other

        case "fa":
            // Persian: one (n=0..1), other
            if count == 0 || count == 1 { return .one }
            return .other

        case "tr":
            // Turkish: one (n=1), other
            if count == 1 { return .one }
            return .other

        case "ar":
            // Arabic: zero, one, two, few, many, other
            if count == 0 { return .zero }
            if count == 1 { return .one }
            if count == 2 { return .two }
            let mod100 = count % 100
            if mod100 >= 3 && mod100 <= 10 { return .few }
            if mod100 >= 11 && mod100 <= 99 { return .many }
            return .other

        case "ru", "uk", "be":
            // Russian/Ukrainian/Belarusian: one, few, many, other
            let mod10 = count % 10
            let mod100 = count % 100
            if mod10 == 1 && mod100 != 11 { return .one }
            if mod10 >= 2 && mod10 <= 4 && !(mod100 >= 12 && mod100 <= 14) { return .few }
            if mod10 == 0 || (mod10 >= 5 && mod10 <= 9) || (mod100 >= 11 && mod100 <= 14) { return .many }
            return .other

        case "pl":
            // Polish: one, few, many (covers all integers)
            if count == 1 { return .one }
            let mod10 = count % 10
            let mod100 = count % 100
            if mod10 >= 2 && mod10 <= 4 && !(mod100 >= 12 && mod100 <= 14) { return .few }
            return .many

        case "cs", "sk":
            // Czech/Slovak: one, few, other (many only for decimals)
            if count == 1 { return .one }
            if count >= 2 && count <= 4 { return .few }
            return .other

        case "ro", "mo":
            // Romanian: one, few, other
            if count == 1 { return .one }
            let mod100 = count % 100
            if count == 0 || (mod100 >= 1 && mod100 <= 19) { return .few }
            return .other

        case "cy":
            // Welsh: zero, one, two, few, many, other
            if count == 0 { return .zero }
            if count == 1 { return .one }
            if count == 2 { return .two }
            if count == 3 { return .few }
            if count == 6 { return .many }
            return .other

        case "ga":
            // Irish: one, two, few, many, other
            if count == 1 { return .one }
            if count == 2 { return .two }
            if count >= 3 && count <= 6 { return .few }
            if count >= 7 && count <= 10 { return .many }
            return .other

        case "ja", "ko", "zh", "vi", "th", "id", "ms":
            // No plural distinction: other only
            return .other

        default:
            // Default CLDR-like rule: one (n=1), other
            if count == 1 { return .one }
            return .other
        }
    }
}
