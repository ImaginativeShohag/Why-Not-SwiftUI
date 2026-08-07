import Foundation

/// Internal `UserDefaults` storage for LocalizeKit.
/// Handles persistent storage of language preferences.
/// - Note: Internal visibility - not part of LocalizeKit's public API.
final class LocalizeKitStorage: @unchecked Sendable {
    // MARK: - Singleton

    static let shared = LocalizeKitStorage()

    // MARK: - Keys

    private enum StorageKey: String {
        case selectedLanguage
        case selectedCountry
        case selectedLanguageVersion
        case selectedLanguageName
        case layoutDirection
    }

    // MARK: - Properties

    private let userDefaults: UserDefaults

    // MARK: - Initialization

    /// Use ``shared`` instead of creating a new instance.
    /// This initializer is exposed only for testing with a custom `UserDefaults`.
    init(userDefaults: UserDefaults? = nil) {
        self.userDefaults = userDefaults
            ?? UserDefaults(suiteName: Constants.userDefaultsSuiteName)
            ?? .standard
    }

    // MARK: - Selected Language

    /// Get the currently selected language code.
    /// - Returns: Language code (e.g., "en", "bn") or nil if not set.
    var selectedLanguage: String? {
        get {
            userDefaults.string(forKey: StorageKey.selectedLanguage.rawValue)
        }
        set {
            if let newValue {
                userDefaults.set(newValue, forKey: StorageKey.selectedLanguage.rawValue)
            } else {
                userDefaults.removeObject(forKey: StorageKey.selectedLanguage.rawValue)
            }
        }
    }

    // MARK: - Selected Country

    /// Get the currently selected country name.
    /// - Returns: Country name (e.g., "United States", "Bangladesh") or nil if not set.
    var selectedCountry: String? {
        get {
            userDefaults.string(forKey: StorageKey.selectedCountry.rawValue)
        }
        set {
            if let newValue {
                userDefaults.set(newValue, forKey: StorageKey.selectedCountry.rawValue)
            } else {
                userDefaults.removeObject(forKey: StorageKey.selectedCountry.rawValue)
            }
        }
    }

    // MARK: - Selected Language Version

    /// Get the currently selected language version.
    /// - Returns: Version number or nil if not set.
    var selectedLanguageVersion: Int? {
        get {
            let value = userDefaults.integer(forKey: StorageKey.selectedLanguageVersion.rawValue)
            return value == 0 ? nil : value
        }
        set {
            if let newValue {
                userDefaults.set(newValue, forKey: StorageKey.selectedLanguageVersion.rawValue)
            } else {
                userDefaults.removeObject(forKey: StorageKey.selectedLanguageVersion.rawValue)
            }
        }
    }

    // MARK: - Selected Language Name

    /// Get the currently selected language name in its native locale.
    /// - Returns: Language name (e.g., "English", "বাংলা", "العربية") or nil if not set.
    var selectedLanguageName: String? {
        get {
            userDefaults.string(forKey: StorageKey.selectedLanguageName.rawValue)
        }
        set {
            if let newValue {
                userDefaults.set(newValue, forKey: StorageKey.selectedLanguageName.rawValue)
            } else {
                userDefaults.removeObject(forKey: StorageKey.selectedLanguageName.rawValue)
            }
        }
    }

    // MARK: - Layout Direction

    /// Get the stored layout direction preference.
    /// - Returns: Layout direction string ("rtl" or "ltr") or nil if not set.
    var layoutDirection: String? {
        get {
            userDefaults.string(forKey: StorageKey.layoutDirection.rawValue)
        }
        set {
            if let newValue {
                userDefaults.set(newValue, forKey: StorageKey.layoutDirection.rawValue)
            } else {
                userDefaults.removeObject(forKey: StorageKey.layoutDirection.rawValue)
            }
        }
    }

    // MARK: - Utilities

    /// Clear all LocalizeKit storage
    func clearAll() {
        selectedLanguage = nil
        selectedCountry = nil
        selectedLanguageVersion = nil
        selectedLanguageName = nil
        layoutDirection = nil
    }
}
