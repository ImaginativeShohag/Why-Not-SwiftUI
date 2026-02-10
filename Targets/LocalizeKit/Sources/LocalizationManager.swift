import Foundation
import SwiftUI
import UIKit

// MARK: - Localization Manager

/// Main localization manager handling translation loading/retrieval
/// Singleton pattern with observable language changes
@MainActor
@Observable
public final class LocalizationManager {
    // MARK: - Singleton

    public static let shared = LocalizationManager()

    // MARK: - Observable Properties
    
    /// Current selected country name
    public private(set) var currentCountry: String = Constants.defaultCountry

    /// Current selected language code
    public private(set) var currentLanguage: String = Constants.defaultLanguageCode

    /// Current language name in its native locale (from nameLocale field in API)
    public private(set) var currentLanguageName: String = Constants.defaultLanguageName

    /// Current language version from available languages API
    public private(set) var currentLanguageVersion: Int?

    /// Available languages fetched from server
    public private(set) var availableLanguages: [Language] = []

    /// Loading state
    public private(set) var isLoading: Bool = false

    /// Whether the current language uses right-to-left layout direction.
    ///
    /// This computed property checks if the `currentLanguage` starts with any
    /// of the prefixes in the `rtlLanguages` array. Matching is case-insensitive.
    ///
    /// **Prefix Matching Examples:**
    /// - `"ar"` matches `"ar"`, `"ar_AE"`, `"ar_SA"`, `"AR"`, `"AR_EG"`
    /// - `"he"` matches `"he"`, `"he_IL"`, `"HE"`
    /// - `"en"` does NOT match any default RTL prefix → returns `false`
    ///
    /// **Usage:**
    /// ```swift
    /// if LocalizationManager.shared.isRightToLeft {
    ///     // Apply RTL-specific UI adjustments
    /// }
    /// ```
    ///
    /// **Performance:** O(n) where n is the size of `rtlLanguages` array.
    ///
    /// - SeeAlso: `rtlLanguages`, `layoutDirection`, `configure(rtlLanguages:)`
    public var isRightToLeft: Bool {
        let lowercased = currentLanguage.lowercased()
        return rtlLanguages.contains { lowercased.hasPrefix($0) }
    }

    /// Current layout direction based on the active language.
    ///
    /// Returns `.rightToLeft` if `isRightToLeft` is `true`, otherwise `.leftToRight`.
    /// This value is automatically applied to SwiftUI's environment when using
    /// the `.onLanguageChange()` view modifier.
    ///
    /// **SwiftUI Integration:**
    /// ```swift
    /// ContentView()
    ///     .onLanguageChange()  // Automatically applies layoutDirection
    /// ```
    ///
    /// **Manual Usage:**
    /// ```swift
    /// let direction = LocalizationManager.shared.layoutDirection
    /// if direction == .rightToLeft {
    ///     // Apply custom RTL logic
    /// }
    /// ```
    ///
    /// - SeeAlso: `isRightToLeft`, `rtlLanguages`, `onLanguageChange()`
    public var layoutDirection: LayoutDirection {
        isRightToLeft ? .rightToLeft : .leftToRight
    }

    // MARK: - Private Properties

    private var translationStorage: TranslationStorage?

    /// Current translations - triggers UI updates when changed
    private var currentTranslations: TranslationFile?

    /// Custom plural rules per language (Vue-i18n style)
    public var pluralRules: [String: PluralRule] = [:]

    /// Language prefixes that use right-to-left (RTL) layout direction.
    ///
    /// This array contains lowercase two-letter ISO 639-1 language code prefixes
    /// used to determine if a language uses RTL layout. Prefix matching is used
    /// to support language variants (e.g., "ar" matches "ar_AE", "ar_SA").
    ///
    /// **Default RTL Languages:**
    /// - `"ar"` - Arabic (العربية) - Used in 22+ countries
    /// - `"he"` - Hebrew (עברית) - Used in Israel
    /// - `"ur"` - Urdu (اردو) - Used in Pakistan, India
    /// - `"fa"` - Persian/Farsi (فارسی) - Used in Iran, Afghanistan (as Dari)
    ///
    /// **Other RTL Languages** (not included by default):
    /// - `"yi"` - Yiddish (ייִדיש)
    /// - `"ps"` - Pashto
    /// - `"sd"` - Sindhi (Arabic script variant)
    /// - `"ug"` - Uyghur
    ///
    /// **Format Requirements:**
    /// - Use lowercase two-letter codes only (e.g., `"ar"`, not `"AR"` or `"ara"`)
    /// - Matching is case-insensitive at runtime (e.g., "AR_AE" will match "ar")
    /// - Codes are prefix-matched, so "ar" matches "ar", "ar_AE", "ar_SA", etc.
    ///
    /// **Usage Example:**
    /// ```swift
    /// // Add support for additional RTL languages
    /// LocalizationManager.shared.configure(rtlLanguages: [
    ///     "ar", "he", "ur", "fa", "yi", "ps"
    /// ])
    ///
    /// // Check if current language is RTL
    /// if LocalizationManager.shared.isRightToLeft {
    ///     print("Current language uses RTL layout")
    /// }
    /// ```
    ///
    /// **Performance:** RTL detection is O(n) where n is the size of this array.
    /// Keep the array small for optimal performance.
    ///
    /// - SeeAlso: `configure(rtlLanguages:)`, `isRightToLeft`, `layoutDirection`
    public var rtlLanguages: [String] = Constants.defaultRTLLanguages

    // MARK: - Initialization

    private init() {
        // Initialize storage
        do {
            self.translationStorage = try TranslationStorage()
        } catch {
            LocalizeKitLogger.e("Failed to initialize TranslationStorage: \(error)")
        }

        // Load saved language preference
        if let savedLanguage = LocalizeKitStorage.shared.selectedLanguage {
            self.currentLanguage = savedLanguage
            Task {
                await loadCachedTranslations(for: savedLanguage)
            }
        }

        // Load saved country preference (default to "United States")
        if let savedCountry = LocalizeKitStorage.shared.selectedCountry {
            self.currentCountry = savedCountry
        }

        // Load saved language version
        self.currentLanguageVersion = LocalizeKitStorage.shared.selectedLanguageVersion

        // Load saved language name (default to "English")
        if let savedLanguageName = LocalizeKitStorage.shared.selectedLanguageName {
            self.currentLanguageName = savedLanguageName
        }

        // Validate stored layout direction matches current language
        let expectedDirection = isLanguageRTL(currentLanguage) ? "rtl" : "ltr"
        if LocalizeKitStorage.shared.layoutDirection != expectedDirection {
            LocalizeKitStorage.shared.layoutDirection = expectedDirection
            LocalizeKitLogger.d("LocalizationManager: Corrected layout direction to \(expectedDirection)")
        }

        // Apply RTL/LTR to app at launch
        applySemanticContentAttributeToApp()
    }

    // MARK: - Configuration

    /// Configure LocalizationManager with custom plural rules
    /// - Parameter pluralRules: Dictionary of language code to plural rule function
    public func configure(pluralRules: [String: PluralRule]) {
        self.pluralRules = pluralRules
        LocalizeKitLogger.d("LocalizationManager configured with \(pluralRules.count) custom plural rules")
    }

    /// Configure which languages should use right-to-left (RTL) layout direction.
    ///
    /// This method allows customization of the RTL language list at runtime.
    /// Call this method early in your app lifecycle (e.g., in `AppDelegate` or
    /// `App.init()`) before activating any languages.
    ///
    /// **When to Use:**
    /// - Add support for RTL languages not included by default (e.g., Yiddish, Pashto)
    /// - Remove RTL languages if your app doesn't support them
    /// - Override default behavior for testing purposes
    ///
    /// - Parameter rtlLanguages: Array of lowercase two-letter ISO 639-1 language
    ///   code prefixes (e.g., `["ar", "he", "yi"]`). Use empty array `[]` to treat
    ///   all languages as left-to-right (useful for testing).
    ///
    /// **Example: Add Yiddish Support**
    /// ```swift
    /// LocalizationManager.shared.configure(rtlLanguages: [
    ///     "ar", "he", "ur", "fa", "yi"  // Add Yiddish
    /// ])
    /// ```
    ///
    /// **Example: Minimal RTL Support**
    /// ```swift
    /// // Only support Arabic and Hebrew
    /// LocalizationManager.shared.configure(rtlLanguages: ["ar", "he"])
    /// ```
    ///
    /// **Example: App Initialization**
    /// ```swift
    /// @main
    /// struct MyApp: App {
    ///     init() {
    ///         LocalizationManager.shared.configure(rtlLanguages: [
    ///             "ar", "he", "ur", "fa", "yi", "ps"
    ///         ])
    ///     }
    ///
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///                 .onLanguageChange()
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// **Behavior:**
    /// - Changes take effect immediately for the current language
    /// - Affects `isRightToLeft`, `layoutDirection`, and storage persistence
    /// - Applies to all subsequent language activations
    ///
    /// - SeeAlso: `rtlLanguages`, `isRightToLeft`, `layoutDirection`
    /// - Important: Call before activating any languages for consistent behavior.
    public func configure(rtlLanguages: [String]) {
        self.rtlLanguages = rtlLanguages
        LocalizeKitLogger.d("LocalizationManager configured with RTL languages: \(rtlLanguages.joined(separator: ", "))")
    }

    // MARK: - Language Management

    /// Change the current language
    /// - Parameter languageCode: Language code (e.g., "en", "bn")
    /// - Note: This method only loads from cache. Use repository layer to fetch new translations first.
    public func changeLanguage(to languageCode: String) async {
        guard languageCode != currentLanguage else { return }

        LocalizeKitLogger.d("LocalizationManager: Changing language to: \(languageCode)")
        isLoading = true

        // Load from cache only
        if await loadCachedTranslations(for: languageCode) {
            currentLanguage = languageCode
            LocalizeKitStorage.shared.selectedLanguage = languageCode
            isLoading = false
            LocalizeKitLogger.d("LocalizationManager: Language changed to \(languageCode) from cache")
        } else {
            isLoading = false
            LocalizeKitLogger.w("LocalizationManager: No cached translations for \(languageCode). Repository must fetch first.")
        }
    }

    // MARK: - Data Setters (Called by Repository Layer)

    /// Set available languages from external source
    /// - Parameter languages: Array of available languages
    public func setAvailableLanguages(_ languages: [Language]) {
        availableLanguages = languages
        LocalizeKitLogger.d("LocalizationManager: Set \(languages.count) available languages")
    }

    /// Set translations from external source and cache them
    /// - Parameters:
    ///   - translationFile: Translation file from server (no version)
    ///   - languageCode: Language code for the translations
    ///   - version: Version from Language.version in available languages API
    public func setTranslations(_ translationFile: TranslationFile, for languageCode: String, version: Int) async {
        // Cache the translations with version from Language API
        await cacheTranslations(translationFile, for: languageCode, version: version)

        // If this is the current language, set it as active
        if languageCode == currentLanguage {
            currentTranslations = translationFile
            LocalizeKitLogger.d("LocalizationManager: Set and activated translations for \(languageCode)")
        } else {
            LocalizeKitLogger.d("LocalizationManager: Cached translations for \(languageCode)")
        }
    }

    /// Check cache state for a language (version comparison)
    /// - Parameter language: Language object with code and server version
    /// - Returns: Cache state (valid, stale, missing, or corrupted)
    public func getCacheState(for language: Language) async -> CacheState {
        guard let storage = translationStorage else {
            LocalizeKitLogger.e("TranslationStorage not initialized")
            return .missing
        }

        return await storage.checkCacheState(for: language)
    }

    /// Activate language from provided TranslationFile
    /// - Parameters:
    ///   - languageCode: Language code
    ///   - languageName: Language name in native locale (from nameLocale field)
    ///   - country: Country name
    ///   - version: Language version from available languages API
    ///   - translationFile: Translation file to activate
    public func activateLanguage(languageCode: String, languageName: String, country: String, version: Int, _ translationFile: TranslationFile) {
        currentTranslations = translationFile
        currentLanguage = languageCode
        currentCountry = country
        currentLanguageVersion = version
        currentLanguageName = languageName
        LocalizeKitStorage.shared.selectedLanguage = languageCode
        LocalizeKitStorage.shared.selectedCountry = country
        LocalizeKitStorage.shared.selectedLanguageVersion = version
        LocalizeKitStorage.shared.selectedLanguageName = languageName
        LocalizeKitStorage.shared.layoutDirection = isLanguageRTL(languageCode) ? "rtl" : "ltr"

        // Automatically apply RTL/LTR to UIKit windows
        applySemanticContentAttributeToApp()

        LocalizeKitLogger.d("LocalizationManager: Activated language \(languageCode) (\(languageName)) for country \(country), version: \(version)")
    }

    /// Determine if a language code is RTL based on configured RTL languages
    /// - Parameter languageCode: Language code to check
    /// - Returns: True if language is RTL
    private func isLanguageRTL(_ languageCode: String) -> Bool {
        let lowercased = languageCode.lowercased()
        return rtlLanguages.contains { lowercased.hasPrefix($0) }
    }

    /// Delete corrupted cache file
    /// - Parameter languageCode: Language code
    public func deleteCacheFile(for languageCode: String) async throws {
        guard let storage = translationStorage else {
            throw StorageError.cacheDirectoryNotFound
        }

        try await storage.deleteCacheFile(for: languageCode)
        LocalizeKitLogger.d("LocalizationManager: Deleted cache file for \(languageCode)")
    }

    // MARK: - Translation Retrieval

    /// Get simple translated string
    /// - Parameters:
    ///   - key: Translation key (e.g., "cart_title")
    ///   - moduleName: Module name (e.g., "Store")
    /// - Returns: Translated string or nil if not found
    public func string(for key: String, in moduleName: String) -> String? {
        guard let translations = currentTranslations else {
            return nil
        }

        // Direct lookup using module name and key
        guard let moduleTranslations = translations.modules[moduleName]?.translations[key] else {
            LocalizeKitLogger.w("Translation not found for key: \(key) in module: \(moduleName)")
            return nil
        }

        // Extract value based on type
        switch moduleTranslations.value {
        case .simple(let value):
            return value
        case .plural:
            LocalizeKitLogger.w("Key \(key) in module \(moduleName) is plural, use pluralString() instead")
            return nil
        }
    }

    /// Get plural translated string
    /// - Parameters:
    ///   - key: Translation key (e.g., "items_count")
    ///   - moduleName: Module name (e.g., "Store")
    ///   - count: Count to determine plural form
    /// - Returns: Translated plural string or nil if not found
    public func pluralString(for key: String, in moduleName: String, count: Int) -> String? {
        guard let translations = currentTranslations else {
            return nil
        }

        // Direct lookup using module name and key
        guard let moduleTranslations = translations.modules[moduleName]?.translations[key] else {
            LocalizeKitLogger.w("Translation not found for key: \(key) in module: \(moduleName)")
            return nil
        }

        // Extract plural dictionary
        guard case .plural(let pluralDict) = moduleTranslations.value else {
            LocalizeKitLogger.w("Key \(key) in module \(moduleName) is not plural, use string() instead")
            return nil
        }

        // Determine plural category
        let locale = Locale(identifier: currentLanguage)
        let category = PluralCategory.category(
            for: count,
            locale: locale,
            customRules: pluralRules
        )

        // Try exact category match first
        if let value = pluralDict[category] {
            return value
        }

        // Fallback chain: other → many → few → two → one → zero
        return pluralDict[.other]
            ?? pluralDict[.many]
            ?? pluralDict[.few]
            ?? pluralDict[.two]
            ?? pluralDict[.one]
            ?? pluralDict[.zero]
    }

    // MARK: - Cache Management

    /// Load translations from cache
    /// - Parameter languageCode: Language code
    /// - Returns: True if loaded successfully
    private func loadCachedTranslations(for languageCode: String) async -> Bool {
        guard let storage = translationStorage else {
            LocalizeKitLogger.e("TranslationStorage not initialized")
            return false
        }

        do {
            if let cached = try await storage.load(for: languageCode) {
                currentTranslations = cached.translationFile
                LocalizeKitLogger.d("Loaded cached translations for \(languageCode), version: \(cached.version)")
                return true
            }
        } catch {
            LocalizeKitLogger.e("Failed to load cached translations: \(error)")
        }

        return false
    }

    /// Save translations to cache
    /// - Parameters:
    ///   - translations: Translation file from server (no version)
    ///   - languageCode: Language code
    ///   - version: Version from Language.version in available languages API
    public func cacheTranslations(_ translations: TranslationFile, for languageCode: String, version: Int) async {
        guard let storage = translationStorage else {
            LocalizeKitLogger.e("TranslationStorage not initialized")
            return
        }

        do {
            try await storage.save(translations, for: languageCode, version: version)
            LocalizeKitLogger.d("Cached translations for \(languageCode), version: \(version)")
        } catch {
            LocalizeKitLogger.e("Failed to cache translations: \(error)")
        }
    }

    /// Clear all cached translations
    public func clearCache() async {
        guard let storage = translationStorage else {
            LocalizeKitLogger.e("TranslationStorage not initialized")
            return
        }

        do {
            try await storage.clearAll()
            currentTranslations = nil
            LocalizeKitLogger.d("Cleared all cached translations")
        } catch {
            LocalizeKitLogger.e("Failed to clear cache: \(error)")
        }
    }

    /// Get cache info
    /// - Returns: Array of cached language codes
    public func getCachedLanguages() async -> [String] {
        guard let storage = translationStorage else {
            LocalizeKitLogger.e("TranslationStorage not initialized")
            return []
        }

        do {
            return try await storage.listCachedLanguages()
        } catch {
            LocalizeKitLogger.e("Failed to list cached languages: \(error)")
            return []
        }
    }

    // MARK: - Debug

    /// Get cache directory path for debugging
    public func getCacheDirectory() async -> String {
        guard let storage = translationStorage else {
            return "Storage not initialized"
        }

        return await storage.getCacheDirectoryPath()
    }

    // MARK: - UIKit Integration

    /// Apply semantic content attribute to app windows based on current language direction
    /// This ensures navigation transitions and all UIKit animations respect RTL
    @MainActor
    private func applySemanticContentAttributeToApp() {
        let attribute: UISemanticContentAttribute = isRightToLeft ? .forceRightToLeft : .forceLeftToRight

        // Update appearance for all UIKit components

        // Base view
        UIView.appearance().semanticContentAttribute = attribute

        // Navigation & Bars
        UINavigationBar.appearance().semanticContentAttribute = attribute
        UITabBar.appearance().semanticContentAttribute = attribute
        UIToolbar.appearance().semanticContentAttribute = attribute
        UISearchBar.appearance().semanticContentAttribute = attribute

        // Controls
        UIButton.appearance().semanticContentAttribute = attribute
        UITextField.appearance().semanticContentAttribute = attribute
        UITextView.appearance().semanticContentAttribute = attribute
        UISegmentedControl.appearance().semanticContentAttribute = attribute
        UISlider.appearance().semanticContentAttribute = attribute
        UIStepper.appearance().semanticContentAttribute = attribute
        UISwitch.appearance().semanticContentAttribute = attribute
        UIProgressView.appearance().semanticContentAttribute = attribute
        UIPageControl.appearance().semanticContentAttribute = attribute
        UIDatePicker.appearance().semanticContentAttribute = attribute
        UIRefreshControl.appearance().semanticContentAttribute = attribute

        // Containers
        UIScrollView.appearance().semanticContentAttribute = attribute
        UIStackView.appearance().semanticContentAttribute = attribute
        UITableView.appearance().semanticContentAttribute = attribute
        UICollectionView.appearance().semanticContentAttribute = attribute

        // Cells
        UITableViewCell.appearance().semanticContentAttribute = attribute
        UICollectionViewCell.appearance().semanticContentAttribute = attribute
        UITableViewHeaderFooterView.appearance().semanticContentAttribute = attribute
        UICollectionReusableView.appearance().semanticContentAttribute = attribute

        // Other Views
        UILabel.appearance().semanticContentAttribute = attribute
        UIImageView.appearance().semanticContentAttribute = attribute
        UIPickerView.appearance().semanticContentAttribute = attribute
        UIActivityIndicatorView.appearance().semanticContentAttribute = attribute
        UIVisualEffectView.appearance().semanticContentAttribute = attribute
        UIInputView.appearance().semanticContentAttribute = attribute

        // Apply to all existing windows
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows {
                    window.semanticContentAttribute = attribute
                    window.rootViewController?.view.semanticContentAttribute = attribute
                    window.setNeedsLayout()
                }
            }
        }
    }
}

// MARK: - Cache State

/// Represents the state of a cached translation file
public enum CacheState: Sendable {
    /// Cache exists and version matches server version (includes cached file)
    case valid(cachedFile: CachedTranslationFile)
    /// Cache exists but version is outdated (includes old version number)
    case stale(cachedVersion: Int)
    /// No cache exists for this language
    case missing
    /// Cache file exists but is corrupted/invalid JSON
    case corrupted
}
