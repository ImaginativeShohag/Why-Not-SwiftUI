import Foundation

// MARK: - Translation Models

/// Root translation file structure
public struct TranslationFile: Codable, Sendable {
    public let version: String
    public let language: String
    public let generatedAt: String
    public let modules: [String: ModuleTranslations]

    public init(version: String, language: String, generatedAt: String, modules: [String: ModuleTranslations]) {
        self.version = version
        self.language = language
        self.generatedAt = generatedAt
        self.modules = modules
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

/// Available languages response from server
public struct AvailableLanguages: Codable, Sendable {
    public let languages: [Language]

    public init(languages: [Language]) {
        self.languages = languages
    }
}

/// Language information
public struct Language: Codable, Sendable, Identifiable {
    public let code: String
    public let name: String
    public let nativeName: String

    public var id: String { code }

    public init(code: String, name: String, nativeName: String) {
        self.code = code
        self.name = name
        self.nativeName = nativeName
    }
}
