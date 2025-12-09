import Foundation
import Core
import SuperLog

/// Main localization manager handling translation loading/retrieval
/// Singleton pattern with observable language changes
@MainActor
@Observable
public final class LocalizationManager {
    // MARK: - Singleton

    public static let shared = LocalizationManager()

    // MARK: - Observable Properties

    /// Current selected language code
    public private(set) var currentLanguage: String = "en"

    /// Available languages fetched from server
    public private(set) var availableLanguages: [Language] = []

    /// Loading state
    public private(set) var isLoading: Bool = false

    // MARK: - Private Properties

    private var translationStorage: TranslationStorage?

    /// Current translations - triggers UI updates when changed
    private var currentTranslations: TranslationFile?

    /// Custom plural rules per language (Vue-i18n style)
    public var pluralRules: [String: PluralRule] = [:]

    // MARK: - Initialization

    private init() {
        // Initialize storage
        do {
            self.translationStorage = try TranslationStorage()
        } catch {
            SuperLog.e("Failed to initialize TranslationStorage: \(error)")
        }

        // Load saved language preference
        if let savedLanguage = Preferences.selectedLanguage {
            self.currentLanguage = savedLanguage
            Task {
                await loadCachedTranslations(for: savedLanguage)
            }
        }
    }

    // MARK: - Configuration

    /// Configure LocalizationManager with custom plural rules
    /// - Parameter pluralRules: Dictionary of language code to plural rule function
    public func configure(pluralRules: [String: PluralRule]) {
        self.pluralRules = pluralRules
        SuperLog.d("LocalizationManager configured with \(pluralRules.count) custom plural rules")
    }

    // MARK: - Language Management

    /// Change the current language
    /// - Parameter languageCode: Language code (e.g., "en", "bn")
    /// - Note: This method only loads from cache. Use repository layer to fetch new translations first.
    public func changeLanguage(to languageCode: String) async {
        guard languageCode != currentLanguage else { return }

        SuperLog.d("LocalizationManager: Changing language to: \(languageCode)")
        isLoading = true

        // Load from cache only
        if await loadCachedTranslations(for: languageCode) {
            currentLanguage = languageCode
            Preferences.selectedLanguage = languageCode
            isLoading = false
            SuperLog.d("LocalizationManager: Language changed to \(languageCode) from cache")
        } else {
            isLoading = false
            SuperLog.w("LocalizationManager: No cached translations for \(languageCode). Repository must fetch first.")
        }
    }

    // MARK: - Data Setters (Called by Repository Layer)

    /// Set available languages from external source
    /// - Parameter languages: Array of available languages
    public func setAvailableLanguages(_ languages: [Language]) {
        self.availableLanguages = languages
        SuperLog.d("LocalizationManager: Set \(languages.count) available languages")
    }

    /// Set translations from external source and cache them
    /// - Parameters:
    ///   - translationFile: Translation file to set and cache
    ///   - languageCode: Language code for the translations
    public func setTranslations(_ translationFile: TranslationFile, for languageCode: String) async {
        // Cache the translations
        await cacheTranslations(translationFile, for: languageCode)

        // If this is the current language, set it as active
        if languageCode == currentLanguage {
            currentTranslations = translationFile
            SuperLog.d("LocalizationManager: Set and activated translations for \(languageCode)")
        } else {
            SuperLog.d("LocalizationManager: Cached translations for \(languageCode)")
        }

        // Save version to preferences
        Preferences.translationVersion = translationFile.version
    }

    // MARK: - Translation Retrieval

    /// Get simple translated string
    /// - Parameter key: Translation key (e.g., "store_welcome")
    /// - Returns: Translated string or nil if not found
    public func string(for key: String) -> String? {
        guard let translations = currentTranslations else {
            return nil
        }

        // Extract module and key from format "module_key"
        let components = key.split(separator: "_", maxSplits: 1)
        guard components.count >= 2 else {
            SuperLog.w("Invalid key format: \(key). Expected 'module_key'")
            return nil
        }

        let moduleName = String(components[0]).capitalized
        let translationKey = String(components[1])

        // Look up in module translations
        guard let moduleTranslations = translations.modules[moduleName]?.translations[key] else {
            SuperLog.w("Translation not found for key: \(key)")
            return nil
        }

        // Extract value based on type
        switch moduleTranslations.value {
        case .simple(let value):
            return value
        case .plural:
            SuperLog.w("Key \(key) is plural, use pluralString() instead")
            return nil
        }
    }

    /// Get plural translated string
    /// - Parameters:
    ///   - key: Translation key (e.g., "store_items_count")
    ///   - count: Count to determine plural form
    /// - Returns: Translated plural string or nil if not found
    public func pluralString(for key: String, count: Int) -> String? {
        guard let translations = currentTranslations else {
            return nil
        }

        // Extract module and key from format "module_key"
        let components = key.split(separator: "_", maxSplits: 1)
        guard components.count >= 2 else {
            SuperLog.w("Invalid key format: \(key). Expected 'module_key'")
            return nil
        }

        let moduleName = String(components[0]).capitalized
        let translationKey = String(components[1])

        // Look up in module translations
        guard let moduleTranslations = translations.modules[moduleName]?.translations[key] else {
            SuperLog.w("Translation not found for key: \(key)")
            return nil
        }

        // Extract plural dictionary
        guard case .plural(let pluralDict) = moduleTranslations.value else {
            SuperLog.w("Key \(key) is not plural, use string() instead")
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
            SuperLog.e("TranslationStorage not initialized")
            return false
        }

        do {
            if let cached = try await storage.load(for: languageCode) {
                currentTranslations = cached
                SuperLog.d("Loaded cached translations for \(languageCode), version: \(cached.version)")
                return true
            }
        } catch {
            SuperLog.e("Failed to load cached translations: \(error)")
        }

        return false
    }

    /// Save translations to cache
    /// - Parameters:
    ///   - translations: Translation file to cache
    ///   - languageCode: Language code
    public func cacheTranslations(_ translations: TranslationFile, for languageCode: String) async {
        guard let storage = translationStorage else {
            SuperLog.e("TranslationStorage not initialized")
            return
        }

        do {
            try await storage.save(translations, for: languageCode)
            SuperLog.d("Cached translations for \(languageCode), version: \(translations.version)")
        } catch {
            SuperLog.e("Failed to cache translations: \(error)")
        }
    }

    /// Clear all cached translations
    public func clearCache() async {
        guard let storage = translationStorage else {
            SuperLog.e("TranslationStorage not initialized")
            return
        }

        do {
            try await storage.clearAll()
            currentTranslations = nil
            SuperLog.d("Cleared all cached translations")
        } catch {
            SuperLog.e("Failed to clear cache: \(error)")
        }
    }

    /// Get cache info
    /// - Returns: Array of cached language codes
    public func getCachedLanguages() async -> [String] {
        guard let storage = translationStorage else {
            SuperLog.e("TranslationStorage not initialized")
            return []
        }

        do {
            return try await storage.listCachedLanguages()
        } catch {
            SuperLog.e("Failed to list cached languages: \(error)")
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
}

// MARK: - Preferences Extension

extension Key {
    static let selectedLanguage: Key = "selectedLanguage"
    static let translationVersion: Key = "translationVersion"
}

extension Preferences {
    @UserDefault(key: .selectedLanguage)
    public static var selectedLanguage: String?

    @UserDefault(key: .translationVersion)
    public static var translationVersion: Int?
}
