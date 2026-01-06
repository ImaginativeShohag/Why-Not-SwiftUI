import Foundation

/// Internal UserDefaults storage for LocalizeKit
/// Handles persistent storage of language preferences
/// - Note: Internal visibility - not part of LocalizeKit's public API
final class LocalizeKitStorage: @unchecked Sendable {
    // MARK: - Singleton

    static let shared = LocalizeKitStorage()

    // MARK: - Keys

    /// Keys are kept identical to Preferences for backward compatibility
    /// This ensures existing users don't lose their language selection
    private enum StorageKey: String {
        case selectedLanguage
        case selectedCountry
        case selectedLanguageVersion
        case selectedLanguageName
    }

    // MARK: - Properties

    private let userDefaults: UserDefaults

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Selected Language

    /// Get the currently selected language code
    /// - Returns: Language code (e.g., "en", "bn") or nil if not set
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

    /// Get the currently selected country name
    /// - Returns: Country name (e.g., "United States", "Bangladesh") or nil if not set
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

    /// Get the currently selected language version from API
    /// - Returns: Version number from available languages API or nil if not set
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

    /// Get the currently selected language name in its native locale (from nameLocale field)
    /// - Returns: Language name (e.g., "English", "বাংলা", "العربية") or nil if not set
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

    // MARK: - Utilities

    /// Clear all LocalizeKit storage
    func clearAll() {
        selectedLanguage = nil
        selectedCountry = nil
        selectedLanguageVersion = nil
        selectedLanguageName = nil
    }
}
