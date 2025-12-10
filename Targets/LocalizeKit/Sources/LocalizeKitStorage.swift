import Foundation

/// Internal UserDefaults storage for LocalizeKit
/// Handles persistent storage of language preferences and translation versions
/// - Note: Internal visibility - not part of LocalizeKit's public API
final class LocalizeKitStorage: @unchecked Sendable {
    // MARK: - Singleton

    static let shared = LocalizeKitStorage()

    // MARK: - Keys

    /// Keys are kept identical to Preferences for backward compatibility
    /// This ensures existing users don't lose their language selection
    private enum StorageKey: String {
        case selectedLanguage
        case translationVersion
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

    // MARK: - Translation Version

    /// Get the current translation version
    /// - Returns: Version number or nil if not set
    var translationVersion: Int? {
        get {
            guard userDefaults.object(forKey: StorageKey.translationVersion.rawValue) != nil else {
                return nil
            }
            return userDefaults.integer(forKey: StorageKey.translationVersion.rawValue)
        }
        set {
            if let newValue {
                userDefaults.set(newValue, forKey: StorageKey.translationVersion.rawValue)
            } else {
                userDefaults.removeObject(forKey: StorageKey.translationVersion.rawValue)
            }
        }
    }

    // MARK: - Utilities

    /// Clear all LocalizeKit storage
    func clearAll() {
        selectedLanguage = nil
        translationVersion = nil
    }
}
