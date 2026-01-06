import Foundation

// MARK: - Translation Models

/// Server translation file structure (no version)
public struct TranslationFile: Codable, Sendable {
    public let modules: [String: ModuleTranslations]

    public init(modules: [String: ModuleTranslations]) {
        self.modules = modules
    }
}

/// Local storage model with version from Language API
public struct CachedTranslationFile: Codable, Sendable {
    public let version: Int  // From Language.version in available languages API
    public let translationFile: TranslationFile

    public init(version: Int, translationFile: TranslationFile) {
        self.version = version
        self.translationFile = translationFile
    }
}

/// Translation strings for a specific module
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

/// Individual translation entry
public struct TranslationEntry: Codable, Sendable {
    public let value: TranslationValue
    public let type: TranslationType
    public let comment: String?
    public let metadata: TranslationMetadata?

    public init(value: TranslationValue, type: TranslationType, comment: String? = nil, metadata: TranslationMetadata? = nil) {
        self.value = value
        self.type = type
        self.comment = comment
        self.metadata = metadata
    }
}

/// Translation value (either simple string or plural dictionary)
public enum TranslationValue: Codable, Sendable {
    case simple(String)
    case plural([PluralCategory: String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Try to decode as dictionary first (plural)
        if let pluralDict = try? container.decode([String: String].self) {
            var categoryDict: [PluralCategory: String] = [:]
            for (key, value) in pluralDict {
                if let category = PluralCategory(rawValue: key) {
                    categoryDict[category] = value
                }
            }
            self = .plural(categoryDict)
        } else {
            // Otherwise decode as simple string
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

/// Translation type
public enum TranslationType: String, Codable, Sendable {
    case simple
    case plural
    case interpolation
}

/// Translation metadata for tracking
public struct TranslationMetadata: Codable, Sendable {
    public let addedInVersion: String?
    public let lastModifiedVersion: String?
    public let status: TranslationStatus?
    public let translationStatus: TranslationValidationStatus?
    public let changeReason: String?

    public init(
        addedInVersion: String? = nil,
        lastModifiedVersion: String? = nil,
        status: TranslationStatus? = nil,
        translationStatus: TranslationValidationStatus? = nil,
        changeReason: String? = nil
    ) {
        self.addedInVersion = addedInVersion
        self.lastModifiedVersion = lastModifiedVersion
        self.status = status
        self.translationStatus = translationStatus
        self.changeReason = changeReason
    }
}

/// Translation status for version tracking
public enum TranslationStatus: String, Codable, Sendable {
    case new
    case modified
    case unchanged
    case removed
}

/// Translation validation status for translator workflow
public enum TranslationValidationStatus: String, Codable, Sendable {
    case untranslated
    case needsReview = "needs_review"
    case validated
}

// MARK: - Available Languages

/// Available languages response from server (grouped by country)
public struct AvailableLanguages: Codable, Sendable {
    /// Dictionary mapping country names to their available languages
    public let data: [String: [Language]]

    public init(data: [String: [Language]]) {
        self.data = data
    }

    /// Get all countries sorted alphabetically
    public var countries: [String] {
        data.keys.sorted()
    }

    /// Get languages for a specific country
    public func languages(for country: String) -> [Language] {
        data[country] ?? []
    }

    /// Get all languages (flattened from all countries)
    public var allLanguages: [Language] {
        data.values.flatMap { $0 }
    }
}

/// Language information
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

        // Try to decode version as Int first, then as String, converting to Int
        // Default to 0 if version is missing or invalid
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
