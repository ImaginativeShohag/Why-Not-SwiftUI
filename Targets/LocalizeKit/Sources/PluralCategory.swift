import Foundation

/// Plural rule function signature (Vue-i18n style)
/// - Parameters:
///   - choice: The numeric value to determine plural form
///   - choicesLength: Number of available plural categories (always 6 for CLDR)
/// - Returns: Index of the plural category to use (0-5)
public typealias PluralRule = (Int, Int) -> Int

/// CLDR-compliant plural categories for localization
/// Covers all world languages with 6 distinct plural forms
public enum PluralCategory: String, Codable, CaseIterable, Sendable {
    case zero
    case one
    case two
    case few
    case many
    case other

    /// Determine plural category for a count based on custom rules or built-in locale rules
    /// - Parameters:
    ///   - count: The numeric value
    ///   - locale: The locale (defaults to current)
    ///   - customRules: Optional dictionary of custom plural rules per language
    /// - Returns: The appropriate plural category
    public static func category(
        for count: Int,
        locale: Locale = .current,
        customRules: [String: PluralRule] = [:]
    ) -> PluralCategory {
        let allCategories: [PluralCategory] = [.zero, .one, .two, .few, .many, .other]
        let languageCode = locale.language.languageCode?.identifier ?? Constants.fallbackLanguageCode

        // 1. Check if custom rule exists for current language
        if let customRule = customRules[languageCode] {
            let index = customRule(count, allCategories.count)
            // Clamp index to valid range (0-5)
            let safeIndex = max(0, min(index, allCategories.count - 1))
            return allCategories[safeIndex]
        }

        // 2. Fallback to built-in ICU/CLDR rules
        return builtInCategory(for: count, languageCode: languageCode)
    }

    /// Built-in plural rules following CLDR standards
    /// Supports common languages: English, Arabic, Russian, Polish, Bengali, etc.
    private static func builtInCategory(for count: Int, languageCode: String) -> PluralCategory {
        switch languageCode {
        case "en", "de", "nl", "sv", "da", "no", "nn", "nb", "fo", "is", "it", "pt", "es", "ca", "et", "fi", "gl", "hu", "lb", "ml", "sw", "ta", "te", "ur", "zu":
            // English-like: zero, one, other
            if count == 0 { return .zero }
            if count == 1 { return .one }
            return .other

        case "ar":
            // Arabic: Uses all 6 categories
            if count == 0 { return .zero }
            if count == 1 { return .one }
            if count == 2 { return .two }
            if count % 100 >= 3 && count % 100 <= 10 { return .few }
            if count % 100 >= 11 { return .many }
            return .other

        case "ru", "uk", "be":
            // Russian/Ukrainian/Belarusian: one, few, many, other
            if count == 0 { return .many }

            let mod10 = count % 10
            let mod100 = count % 100

            if mod10 == 1 && mod100 != 11 { return .one }
            if mod10 >= 2 && mod10 <= 4 && !(mod100 >= 12 && mod100 <= 14) { return .few }
            if mod10 == 0 || (mod10 >= 5 && mod10 <= 9) || (mod100 >= 11 && mod100 <= 14) { return .many }
            return .other

        case "pl":
            // Polish: one, few, many, other
            if count == 0 { return .many }
            if count == 1 { return .one }
            let mod10 = count % 10
            let mod100 = count % 100
            if mod10 >= 2 && mod10 <= 4 && !(mod100 >= 12 && mod100 <= 14) { return .few }
            return .many

        case "cs", "sk":
            // Czech/Slovak: one, few, many, other
            if count == 0 { return .other }
            if count == 1 { return .one }
            if count >= 2 && count <= 4 { return .few }
            return .other

        case "ro", "mo":
            // Romanian: one, few, other
            if count == 0 { return .few }
            if count == 1 { return .one }
            let mod100 = count % 100
            if count != 0 && mod100 >= 1 && mod100 <= 19 { return .few }
            return .other

        case "bn", "hi", "mr", "gu", "pa":
            // Bengali and similar: zero, one, other
            if count == 0 { return .zero }
            if count == 1 { return .one }
            return .other

        case "fr":
            // French: zero, one, many, other
            if count == 0 { return .zero }
            if count == 1 { return .one }
            if count >= 1000000 { return .many }
            return .other

        case "cy":
            // Welsh: Uses special forms
            if count == 0 { return .zero }
            if count == 1 { return .one }
            if count == 2 { return .two }
            if count == 3 { return .few }
            if count == 6 { return .many }
            return .other

        case "ga":
            // Irish: Uses special forms
            if count == 0 { return .zero }
            if count == 1 { return .one }
            if count == 2 { return .two }
            if count >= 3 && count <= 6 { return .few }
            if count >= 7 && count <= 10 { return .many }
            return .other

        case "ja", "ko", "zh", "vi", "th", "id", "ms", "tr", "fa":
            // Asian languages: other only (no plural distinction)
            return .other

        default:
            // Default simple rule for unknown languages
            if count == 0 { return .zero }
            if count == 1 { return .one }
            return .other
        }
    }
}
