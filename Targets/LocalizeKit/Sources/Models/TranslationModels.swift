import Foundation

// MARK: - Translation Models

/// Server translation file structure.
public struct TranslationFile: Codable, Sendable {
    public let modules: [String: ModuleTranslations]

    public init(modules: [String: ModuleTranslations]) {
        self.modules = modules
    }
}

/// Local storage model with version from Language API.
public struct CachedTranslationFile: Codable, Sendable {
    public let version: Int  // From Language.version in available languages API
    public let translationFile: TranslationFile

    public init(version: Int, translationFile: TranslationFile) {
        self.version = version
        self.translationFile = translationFile
    }
}

/// Translation strings for a specific module.
public struct ModuleTranslations: Codable, Sendable {
    public let translations: [String: TranslationEntry]

    public init(translations: [String: TranslationEntry]) {
        self.translations = translations
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.translations = try container.decode([String: TranslationEntry].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(translations)
    }
}

/// Individual translation entry.
public struct TranslationEntry: Codable, Sendable {
    public let value: TranslationValue

    public init(value: TranslationValue) {
        self.value = value
    }
}

/// Translation value (either simple string or plural dictionary).
public enum TranslationValue: Codable, Sendable {
    case simple(String)
    case plural([PluralCategory: String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Try to decode as dictionary first (plural).
        if let pluralDict = try? container.decode([String: String].self) {
            var categoryDict: [PluralCategory: String] = [:]
            for (key, value) in pluralDict {
                if let category = PluralCategory(rawValue: key) {
                    categoryDict[category] = value
                }
            }
            self = .plural(categoryDict)
        } else {
            // Otherwise decode as simple string.
            let simpleValue = try container.decode(String.self)
            self = .simple(simpleValue)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let string):
            try container.encode(string)
        case .plural(let dict):
            let stringDict = dict.reduce(into: [String: String]()) { result, pair in
                result[pair.key.rawValue] = pair.value
            }
            try container.encode(stringDict)
        }
    }
}

// MARK: - Available Languages

/// Available languages response from server (grouped by country).
public struct AvailableLanguages: Codable, Sendable {
    /// Dictionary mapping country names to their available languages.
    public let data: [String: [Language]]

    public init(data: [String: [Language]]) {
        self.data = data
    }

    /// Get all countries sorted alphabetically.
    public var countries: [String] {
        data.keys.sorted()
    }

    /// Get languages for a specific country.
    public func languages(for country: String) -> [Language] {
        data[country] ?? []
    }

    /// Find a language by code within a specific country's list.
    ///
    /// Country-scoped on purpose: the same code can appear under multiple countries with
    /// different `version` values, so resolving against the flattened `allLanguages` would pick an
    /// arbitrary entry (Swift `Dictionary` iteration order is not stable across launches) and yield
    /// a nondeterministic version. Always resolve within the country the user actually selected.
    public func language(code: String, in country: String) -> Language? {
        languages(for: country).first { $0.code == code }
    }

    /// Get all languages (flattened from all countries).
    public var allLanguages: [Language] {
        data.values.flatMap { $0 }
    }
}

/// Language information.
public struct Language: Codable, Sendable, Identifiable {
    public let code: String
    public let nameEn: String
    public let nameLocale: String
    public let version: Int

    public var id: String { code }

    enum CodingKeys: String, CodingKey {
        case code
        case nameEn = "name_en"
        case nameLocale = "name_locale"
        case version
    }

    public init(code: String, nameEn: String, nameLocale: String, version: Int) {
        self.code = code
        self.nameEn = nameEn
        self.nameLocale = nameLocale
        self.version = version
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(String.self, forKey: .code)
        nameEn = try container.decode(String.self, forKey: .nameEn)
        nameLocale = try container.decode(String.self, forKey: .nameLocale)

        // Try to decode version as Int first, then as String, converting to Int.
        // Default to 0 if version is missing or invalid.
        if let versionInt = try? container.decode(Int.self, forKey: .version) {
            version = versionInt
        } else if let versionString = try? container.decode(String.self, forKey: .version),
                  let versionInt = Int(versionString) {
            version = versionInt
        } else {
            version = 0
        }
    }
}
