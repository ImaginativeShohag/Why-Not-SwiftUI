import Foundation

// MARK: - Base Translation File Models (base.json)

/// Base translation file structure with full metadata and per-key versioning
public struct BaseTranslationFile: Codable {
    public let version: Int
    public let language: String
    public let generatedAt: String
    public let modules: [String: [String: BaseTranslationEntry]]
}

/// Translation entry in base.json with per-key version tracking
public struct BaseTranslationEntry: Codable {
    public let value: TranslationValue
    public let type: TranslationType
    public let comment: String?
    public let version: Int
    public let metadata: BaseMetadata?
}

/// Metadata for base translation entries
public struct BaseMetadata: Codable {
    public let addedInVersion: Int
    public let lastModifiedVersion: Int?
    public let status: TranslationStatus?
}

// MARK: - Target Translation File Models (ar.json, bn.json, etc.)

/// Target language file structure (simplified, no metadata)
public struct TargetTranslationFile: Codable {
    public let version: Int
    public let modules: [String: [String: TargetTranslationEntry]]
}

/// Translation entry in target language files (simplified)
public struct TargetTranslationEntry: Codable {
    public let value: TranslationValue
    public let comment: String?
}

// MARK: - Shared Types

public enum TranslationValue: Codable {
    case simple(String)
    case plural([String: String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .simple(string)
        } else {
            let dict = try container.decode([String: String].self)
            self = .plural(dict)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let string):
            try container.encode(string)
        case .plural(let dict):
            try container.encode(dict)
        }
    }

    /// Get string representation for comparison
    public var stringValue: String {
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

public enum TranslationType: String, Codable {
    case simple
    case plural
    case interpolation
}

public enum TranslationStatus: String, Codable {
    case new
    case modified
    case unchanged
    case removed
}

// MARK: - Legacy Support (backward compatibility)

/// Legacy translation file structure (for migration)
public struct TranslationFile: Codable {
    public let version: String
    public let language: String
    public let generatedAt: String
    public let modules: [String: [String: TranslationEntry]]
}

/// Legacy translation entry
public struct TranslationEntry: Codable {
    public let value: TranslationValue
    public let type: TranslationType
    public let comment: String?
    public let metadata: TranslationMetadata?
}

/// Legacy metadata structure
public struct TranslationMetadata: Codable {
    public let addedInVersion: String?
    public let lastModifiedVersion: String?
    public let status: TranslationStatus?
    public let translationStatus: TranslationValidationStatus?
    public let changeReason: String?
}

public enum TranslationValidationStatus: String, Codable {
    case untranslated
    case needsReview = "needs_review"
    case validated
}

// MARK: - File Type Detection

public enum TranslationFileType {
    case base(BaseTranslationFile)
    case target(TargetTranslationFile)
    case legacy(TranslationFile)
}

/// Load and auto-detect translation file type
public func loadTranslationFile(from path: String) throws -> TranslationFileType {
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

public struct ExtractedString {
    public let key: String
    public let moduleName: String
    public let defaultValue: String
    public let comment: String
    public let type: TranslationType
    public let pluralForms: [String: String]?
    public let filePath: String
    public let lineNumber: Int

    // MARK: Lint metadata (optional — populated by `StringExtractor` for lint use-cases)

    /// 1-based column of the call expression in the source file.
    public let column: Int

    /// `with:` arguments captured from the call site (variadic flattened).
    public let arguments: [LintArgument]

    /// `count:` argument captured from plural overloads.
    public let countArgument: LintCountArgument?

    public init(
        key: String,
        moduleName: String,
        defaultValue: String,
        comment: String,
        type: TranslationType,
        pluralForms: [String: String]?,
        filePath: String,
        lineNumber: Int,
        column: Int = 1,
        arguments: [LintArgument] = [],
        countArgument: LintCountArgument? = nil
    ) {
        self.key = key
        self.moduleName = moduleName
        self.defaultValue = defaultValue
        self.comment = comment
        self.type = type
        self.pluralForms = pluralForms
        self.filePath = filePath
        self.lineNumber = lineNumber
        self.column = column
        self.arguments = arguments
        self.countArgument = countArgument
    }
}

// MARK: - Diff Models

public struct DiffSummary: Codable {
    public var new: Int
    public var modified: Int
    public var removed: Int
    public var unchanged: Int
}

public struct DiffFile: Codable {
    public let version: String
    public let previousVersion: String
    public let generatedAt: String
    public let summary: DiffSummary
    public let changesByModule: [String: LegacyModuleChanges]
}

public struct ModuleChanges: Codable {
    public let new: [String: BaseTranslationEntry]
    public let modified: [String: ModifiedEntry]
    public let removed: [String: BaseTranslationEntry]
}

// Legacy version for old diff command
public struct LegacyModuleChanges: Codable {
    public let new: [String: TranslationEntry]
    public let modified: [String: ModifiedEntry]
    public let removed: [String: TranslationEntry]
}

public struct ModifiedEntry: Codable {
    public let oldValue: TranslationValue
    public let newValue: TranslationValue
    public let type: TranslationType
    public let comment: String?
}
