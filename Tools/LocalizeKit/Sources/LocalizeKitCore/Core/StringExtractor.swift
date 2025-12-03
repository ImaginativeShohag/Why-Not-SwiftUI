//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftParser
import SwiftSyntax

/// Extracts localization strings from Swift source files using SwiftSyntax
public final class StringExtractor {
    private let projectPath: String
    private let verbose: Bool

    public init(projectPath: String, verbose: Bool = false) {
        self.projectPath = projectPath
        self.verbose = verbose
    }

    /// Extract all localization strings from the project
    public func extract() throws -> [ExtractedString] {
        var extractedStrings: [ExtractedString] = []
        let fileManager = FileManager.default

        // Find all Targets directories
        let targetsPath = (projectPath as NSString).appendingPathComponent("Targets")

        guard fileManager.fileExists(atPath: targetsPath) else {
            throw ExtractionError.targetsDirectoryNotFound(path: targetsPath)
        }

        // Get all module directories
        let moduleDirectories = try fileManager.contentsOfDirectory(atPath: targetsPath)
            .filter { moduleName in
                var isDirectory: ObjCBool = false
                let modulePath = (targetsPath as NSString).appendingPathComponent(moduleName)
                return fileManager.fileExists(atPath: modulePath, isDirectory: &isDirectory) && isDirectory.boolValue
            }

        if verbose {
            print("📦 Found \(moduleDirectories.count) modules")
        }

        // Process each module
        for moduleName in moduleDirectories {
            let modulePath = (targetsPath as NSString).appendingPathComponent(moduleName)
            let sourcesPath = (modulePath as NSString).appendingPathComponent("Sources")

            guard fileManager.fileExists(atPath: sourcesPath) else {
                if verbose {
                    print("⚠️  No Sources directory in module: \(moduleName)")
                }
                continue
            }

            if verbose {
                print("🔍 Processing module: \(moduleName)")
            }

            let moduleStrings = try extractFromDirectory(
                sourcesPath,
                moduleName: moduleName,
                fileManager: fileManager
            )

            extractedStrings.append(contentsOf: moduleStrings)

            if verbose {
                print("   Found \(moduleStrings.count) strings")
            }
        }

        return extractedStrings
    }

    /// Recursively extract strings from a directory
    private func extractFromDirectory(
        _ directoryPath: String,
        moduleName: String,
        fileManager: FileManager
    ) throws -> [ExtractedString] {
        var extractedStrings: [ExtractedString] = []

        let enumerator = fileManager.enumerator(atPath: directoryPath)

        while let relativePath = enumerator?.nextObject() as? String {
            let fullPath = (directoryPath as NSString).appendingPathComponent(relativePath)

            // Only process Swift files
            guard relativePath.hasSuffix(".swift") else { continue }

            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory),
                  !isDirectory.boolValue else {
                continue
            }

            if verbose {
                print("   📄 \(relativePath)")
            }

            let fileStrings = try extractFromFile(fullPath, moduleName: moduleName)
            extractedStrings.append(contentsOf: fileStrings)
        }

        return extractedStrings
    }

    /// Extract strings from a single Swift file
    private func extractFromFile(_ filePath: String, moduleName: String) throws -> [ExtractedString] {
        let sourceCode = try String(contentsOfFile: filePath, encoding: .utf8)
        let sourceFile = Parser.parse(source: sourceCode)

        let visitor = LocalizationVisitor(
            filePath: filePath,
            moduleName: moduleName,
            sourceCode: sourceCode
        )

        visitor.walk(sourceFile)

        return visitor.extractedStrings
    }
}

// MARK: - Visitor

/// SwiftSyntax visitor that finds `.localize()` and `Text.localized()` calls
private final class LocalizationVisitor: SyntaxVisitor {
    public let filePath: String
    public let moduleName: String
    public let sourceCode: String
    private(set) var extractedStrings: [ExtractedString] = []

    public init(filePath: String, moduleName: String, sourceCode: String) {
        self.filePath = filePath
        self.moduleName = moduleName
        self.sourceCode = sourceCode
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        // Try to extract from either pattern:
        // 1. "key".localize(default: "value", comment: "...")
        // 2. Text.localized("key", default: "value", comment: "...")

        if let extracted = extractFromStringLocalize(node) {
            extractedStrings.append(extracted)
        } else if let extracted = extractFromTextLocalized(node) {
            extractedStrings.append(extracted)
        }

        return .visitChildren
    }

    /// Extract from pattern: "key".localize(default: "value", comment: "...")
    private func extractFromStringLocalize(_ node: FunctionCallExprSyntax) -> ExtractedString? {
        // Check if this is a .localize() call
        guard let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self),
              memberAccess.declName.baseName.text == "localize" else {
            return nil
        }

        // Extract the key (base of the member access)
        guard let keyExpr = memberAccess.base?.as(StringLiteralExprSyntax.self),
              let keySegment = keyExpr.segments.first?.as(StringSegmentSyntax.self) else {
            return nil
        }

        let key = keySegment.content.text
        return extractStringData(from: node, key: key)
    }

    /// Extract from pattern: Text.localized("key", default: "value", comment: "...")
    private func extractFromTextLocalized(_ node: FunctionCallExprSyntax) -> ExtractedString? {
        // Check if this is Text.localized() call
        guard let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self),
              memberAccess.declName.baseName.text == "localized" else {
            return nil
        }

        // Check if base is "Text"
        guard let baseIdentifier = memberAccess.base?.as(DeclReferenceExprSyntax.self),
              baseIdentifier.baseName.text == "Text" else {
            return nil
        }

        // First argument should be the key
        guard let firstArg = node.arguments.first,
              firstArg.label == nil, // unlabeled first argument
              let keyExpr = firstArg.expression.as(StringLiteralExprSyntax.self),
              let keySegment = keyExpr.segments.first?.as(StringSegmentSyntax.self) else {
            return nil
        }

        let key = keySegment.content.text
        return extractStringData(from: node, key: key)
    }

    /// Common extraction logic for both patterns
    private func extractStringData(from node: FunctionCallExprSyntax, key: String) -> ExtractedString? {
        // Parse arguments
        var defaultValue: String = ""
        var comment: String = ""
        var count: String? = nil
        var defaultPlural: [String: String]? = nil
        var withParameters: [String] = []

        for argument in node.arguments {
            let label = argument.label?.text ?? ""

            switch label {
            case "default":
                if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self),
                   let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                    defaultValue = segment.content.text
                } else if let dictExpr = argument.expression.as(DictionaryExprSyntax.self) {
                    // Handle plural dictionary
                    defaultPlural = parsePluralDictionary(dictExpr)
                }

            case "comment":
                if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self),
                   let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                    comment = segment.content.text
                }

            case "count":
                count = argument.expression.description.trimmingCharacters(in: .whitespacesAndNewlines)

            case "defaultPlural":
                if let dictExpr = argument.expression.as(DictionaryExprSyntax.self) {
                    defaultPlural = parsePluralDictionary(dictExpr)
                }

            case "with":
                // Capture interpolation parameters
                let paramDesc = argument.expression.description.trimmingCharacters(in: .whitespacesAndNewlines)
                withParameters.append(paramDesc)

            default:
                break
            }
        }

        // Determine type
        let type: TranslationType
        if defaultPlural != nil {
            type = .plural
        } else if defaultValue.contains("%") {
            type = .interpolation
        } else {
            type = .simple
        }

        // Get line number
        let lineNumber = sourceCode.lineNumber(at: node.position)

        return ExtractedString(
            key: key,
            moduleName: moduleName,
            defaultValue: defaultValue,
            comment: comment,
            type: type,
            pluralForms: defaultPlural,
            filePath: filePath,
            lineNumber: lineNumber
        )
    }

    private func parsePluralDictionary(_ dictExpr: DictionaryExprSyntax) -> [String: String] {
        var result: [String: String] = [:]

        guard case .elements(let elements) = dictExpr.content else {
            return result
        }

        for element in elements {
            // Key should be like .one, .other, etc.
            if let keyExpr = element.key.as(MemberAccessExprSyntax.self),
               let valueExpr = element.value.as(StringLiteralExprSyntax.self),
               let valueSegment = valueExpr.segments.first?.as(StringSegmentSyntax.self) {

                let category = keyExpr.declName.baseName.text
                let value = valueSegment.content.text

                result[category] = value
            }
        }

        return result
    }
}

// MARK: - Helper Extensions

extension String {
    /// Calculate line number for a given position in the source code
    public func lineNumber(at position: AbsolutePosition) -> Int {
        let offset = position.utf8Offset
        let substring = self.prefix(offset)
        return substring.reduce(1) { count, char in
            count + (char == "\n" ? 1 : 0)
        }
    }
}

// MARK: - Errors

public enum ExtractionError: LocalizedError {
    case targetsDirectoryNotFound(path: String)
    case invalidSwiftFile(path: String)

    public var errorDescription: String? {
        switch self {
        case .targetsDirectoryNotFound(let path):
            return "Targets directory not found at: \(path)"
        case .invalidSwiftFile(let path):
            return "Invalid Swift file: \(path)"
        }
    }
}
