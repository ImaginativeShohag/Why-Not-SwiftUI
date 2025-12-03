import Foundation

// MARK: - Base Translation File Models (base.json)

/// Base translation file structure with full metadata and per-key versioning
struct BaseTranslationFile: Codable {
    let version: Int
    let language: String
    let generatedAt: String
    let modules: [String: [String: BaseTranslationEntry]]
}

/// Translation entry in base.json with per-key version tracking
struct BaseTranslationEntry: Codable {
    let value: TranslationValue
    let type: TranslationType
    let comment: String?
    let version: Int
    let metadata: BaseMetadata?
}

/// Metadata for base translation entries
struct BaseMetadata: Codable {
    let addedInVersion: Int
    let lastModifiedVersion: Int?
    let status: TranslationStatus?
}

// MARK: - Target Translation File Models (ar.json, bn.json, etc.)

/// Target language file structure (simplified, no metadata)
struct TargetTranslationFile: Codable {
    let version: Int
    let language: String
    let generatedAt: String
    let modules: [String: [String: TargetTranslationEntry]]
}

/// Translation entry in target language files (simplified)
struct TargetTranslationEntry: Codable {
    let value: TranslationValue
    let type: TranslationType
}

// MARK: - Shared Types

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

    /// Get string representation for comparison
    var stringValue: String {
        switch self {
        case .simple(let str):
            return str
        case .plural(let dict):
            return dict.sorted(by: { $0.key < $1.key })
                .map { "\($0.key):\($0.value)" }
                .joined(separator: "|")
        }
    }
}

enum TranslationType: String, Codable {
    case simple
    case plural
    case interpolation
}

enum TranslationStatus: String, Codable {
    case new
    case modified
    case unchanged
    case removed
}

// MARK: - Legacy Support (backward compatibility)

/// Legacy translation file structure (for migration)
struct TranslationFile: Codable {
    let version: String
    let language: String
    let generatedAt: String
    let modules: [String: [String: TranslationEntry]]
}

/// Legacy translation entry
struct TranslationEntry: Codable {
    let value: TranslationValue
    let type: TranslationType
    let comment: String?
    let metadata: TranslationMetadata?
}

/// Legacy metadata structure
struct TranslationMetadata: Codable {
    let addedInVersion: String?
    let lastModifiedVersion: String?
    let status: TranslationStatus?
    let translationStatus: TranslationValidationStatus?
    let changeReason: String?
}

enum TranslationValidationStatus: String, Codable {
    case untranslated
    case needsReview = "needs_review"
    case validated
}

// MARK: - File Type Detection

enum TranslationFileType {
    case base(BaseTranslationFile)
    case target(TargetTranslationFile)
    case legacy(TranslationFile)
}

/// Load and auto-detect translation file type
func loadTranslationFile(from path: String) throws -> TranslationFileType {
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)

    // Try base file first
    if let baseFile = try? JSONDecoder().decode(BaseTranslationFile.self, from: data) {
        return .base(baseFile)
    }

    // Try target file
    if let targetFile = try? JSONDecoder().decode(TargetTranslationFile.self, from: data) {
        return .target(targetFile)
    }

    // Fall back to legacy format
    let legacyFile = try JSONDecoder().decode(TranslationFile.self, from: data)
    return .legacy(legacyFile)
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

struct DiffSummary: Codable {
    var new: Int
    var modified: Int
    var removed: Int
    var unchanged: Int
}

struct DiffFile: Codable {
    let version: String
    let previousVersion: String
    let generatedAt: String
    let summary: DiffSummary
    let changesByModule: [String: LegacyModuleChanges]
}

struct ModuleChanges: Codable {
    let new: [String: BaseTranslationEntry]
    let modified: [String: ModifiedEntry]
    let removed: [String: BaseTranslationEntry]
}

// Legacy version for old diff command
struct LegacyModuleChanges: Codable {
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
