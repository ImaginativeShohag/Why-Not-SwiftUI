import Foundation

// MARK: - LocalizeKit Constants

/// Centralized constants for LocalizeKit configuration
/// All default values and fallback configurations are defined here
public enum Constants {
    // MARK: - Default Locale Settings

    /// Default language code used when no language preference is saved
    /// - Example: "en_US" (US English)
    public static let defaultLanguageCode: String = "en_US"

    /// Default language name displayed in UI when no preference is saved
    /// - Example: "English"
    public static let defaultLanguageName: String = "English"

    /// Default country name used when no country preference is saved
    /// - Example: "United States"
    public static let defaultCountry: String = "United States"

    /// Fallback language code for plural rules when locale cannot determine language
    /// - Note: Two-letter ISO 639-1 code used in `PluralCategory` for rule matching
    public static let fallbackLanguageCode: String = "en"

    // MARK: - RTL (Right-to-Left) Languages

    /// Default list of language prefixes that use right-to-left (RTL) layout direction.
    ///
    /// This array contains lowercase two-letter ISO 639-1 language code prefixes.
    /// Prefix matching is used to support language variants:
    /// - "ar" matches "ar", "ar_AE", "ar_SA", "AR", "AR_EG"
    /// - "he" matches "he", "he_IL", "HE"
    ///
    /// **Included Languages:**
    /// - `"ar"` - Arabic (العربية) - Used in 22+ countries
    /// - `"he"` - Hebrew (עברית) - Used in Israel
    /// - `"ur"` - Urdu (اردو) - Used in Pakistan, India
    /// - `"fa"` - Persian/Farsi (فارسی) - Used in Iran, Afghanistan (as Dari)
    ///
    /// **Other RTL Languages** (not included by default, can be added via `configure(rtlLanguages:)`):
    /// - `"yi"` - Yiddish (ייִדיש)
    /// - `"ps"` - Pashto
    /// - `"sd"` - Sindhi (Arabic script variant)
    /// - `"ug"` - Uyghur
    public static let defaultRTLLanguages: [String] = ["ar", "he", "ur", "fa"]
}
