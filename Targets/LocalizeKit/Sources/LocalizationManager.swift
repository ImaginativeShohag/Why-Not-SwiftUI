import Foundation

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

// MARK: - Localization Manager

/// Main localization manager handling translation loading/retrieval
/// Singleton pattern with observable language changes
@MainActor
@Observable
public final class LocalizationManager {
    // MARK: - Singleton

    public static let shared = LocalizationManager()

    // MARK: - Observable Properties

    /// Current selected language code
    public private(set) var currentLanguage: String = "en_US"

    /// Current selected country name
    public private(set) var currentCountry: String = "United States"

    /// Current language version from available languages API
    public private(set) var currentLanguageVersion: Int?

    /// Current language name in its native locale (from nameLocale field in API)
    public private(set) var currentLanguageName: String = "English"

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
    }

    // MARK: - Configuration

    /// Configure LocalizationManager with custom plural rules
    /// - Parameter pluralRules: Dictionary of language code to plural rule function
    public func configure(pluralRules: [String: PluralRule]) {
        self.pluralRules = pluralRules
        LocalizeKitLogger.d("LocalizationManager configured with \(pluralRules.count) custom plural rules")
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
        self.availableLanguages = languages
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
        LocalizeKitLogger.d("LocalizationManager: Activated language \(languageCode) (\(languageName)) for country \(country), version: \(version)")
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
    /// - Parameter key: Translation key (e.g., "store_welcome")
    /// - Returns: Translated string or nil if not found
    public func string(for key: String) -> String? {
        guard let translations = currentTranslations else {
            return nil
        }

        // Extract module and key from format "module_key"
        let components = key.split(separator: "_", maxSplits: 1)
        guard components.count >= 2 else {
            LocalizeKitLogger.w("Invalid key format: \(key). Expected 'module_key'")
            return nil
        }

        let moduleName = String(components[0]).capitalized
        let translationKey = String(components[1])

        // Look up in module translations
        guard let moduleTranslations = translations.modules[moduleName]?.translations[key] else {
            LocalizeKitLogger.w("Translation not found for key: \(key)")
            return nil
        }

        // Extract value based on type
        switch moduleTranslations.value {
        case .simple(let value):
            return value
        case .plural:
            LocalizeKitLogger.w("Key \(key) is plural, use pluralString() instead")
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
            LocalizeKitLogger.w("Invalid key format: \(key). Expected 'module_key'")
            return nil
        }

        let moduleName = String(components[0]).capitalized
        let translationKey = String(components[1])

        // Look up in module translations
        guard let moduleTranslations = translations.modules[moduleName]?.translations[key] else {
            LocalizeKitLogger.w("Translation not found for key: \(key)")
            return nil
        }

        // Extract plural dictionary
        guard case .plural(let pluralDict) = moduleTranslations.value else {
            LocalizeKitLogger.w("Key \(key) is not plural, use string() instead")
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
}
