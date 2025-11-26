import Foundation

// MARK: - Translation File Models

struct TranslationFile: Codable {
    let version: String
    let language: String
    let generatedAt: String
    let modules: [String: [String: TranslationEntry]]
}

struct TranslationEntry: Codable {
    let value: TranslationValue
    let type: TranslationType
    let comment: String?
    let metadata: TranslationMetadata?
}

enum TranslationValue: Codable {
    case simple(String)
    case plural([String: String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .simple(string)
        } else {
            let dict = try container.decode([String: String].self)
            self = .plural(dict)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let string):
            try container.encode(string)
        case .plural(let dict):
            try container.encode(dict)
        }
    }
}

enum TranslationType: String, Codable {
    case simple
    case plural
    case interpolation
}

struct TranslationMetadata: Codable {
    let addedInVersion: String?
    let lastModifiedVersion: String?
    let status: TranslationStatus?
    let translationStatus: TranslationValidationStatus?
    let changeReason: String?
}

enum TranslationStatus: String, Codable {
    case new
    case modified
    case unchanged
    case removed
}

enum TranslationValidationStatus: String, Codable {
    case untranslated
    case needsReview = "needs_review"
    case validated
}

// MARK: - Extracted String

struct ExtractedString {
    let key: String
    let moduleName: String
    let defaultValue: String
    let comment: String
    let type: TranslationType
    let pluralForms: [String: String]?
    let filePath: String
    let lineNumber: Int
}

// MARK: - Diff Models

struct DiffFile: Codable {
    let version: String
    let previousVersion: String
    let generatedAt: String
    let summary: DiffSummary
    let changesByModule: [String: ModuleChanges]
}

struct DiffSummary: Codable {
    let new: Int
    let modified: Int
    let removed: Int
    let unchanged: Int
}

struct ModuleChanges: Codable {
    let new: [String: TranslationEntry]
    let modified: [String: ModifiedEntry]
    let removed: [String: TranslationEntry]
}

struct ModifiedEntry: Codable {
    let oldValue: TranslationValue
    let newValue: TranslationValue
    let type: TranslationType
    let comment: String?
}
