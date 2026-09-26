//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// Validates translation files for completeness and correctness
public final class TranslationValidator {
    private let verbose: Bool

    public init(verbose: Bool = false) {
        self.verbose = verbose
    }

    /// Validate a translation file
    public func validate(
        file: TranslationFile,
        basePath: String? = nil,
        checkMissing: Bool = true,
        checkFormat: Bool = true,
        checkPlurals: Bool = true
    ) throws -> ValidationResult {
        var issues: [ValidationIssue] = []
        var stats = ValidationStats()

        // Load base file if provided
        var baseFile: TranslationFile?
        if let basePath = basePath {
            let url = URL(fileURLWithPath: basePath)
            let data = try Data(contentsOf: url)
            baseFile = try JSONDecoder().decode(TranslationFile.self, from: data)
        }

        // Validate each module
        for (moduleName, strings) in file.modules {
            let baseStrings = baseFile?.modules[moduleName] ?? [:]

            for (key, entry) in strings {
                stats.totalStrings += 1

                // Check for missing translations
                if checkMissing {
                    if case .simple(let value) = entry.value, value.isEmpty {
                        issues.append(ValidationIssue(
                            module: moduleName,
                            key: key,
                            severity: .error,
                            message: "Missing translation (empty value)"
                        ))
                        stats.missingTranslations += 1
                        continue
                    }
                }

                // Check format strings
                if checkFormat && entry.type == .interpolation {
                    let formatIssues = validateFormatString(
                        value: entry.value,
                        module: moduleName,
                        key: key,
                        baseEntry: baseStrings[key]
                    )
                    issues.append(contentsOf: formatIssues)
                    stats.formatIssues += formatIssues.count
                }

                // Check plural forms
                if checkPlurals && entry.type == .plural {
                    let pluralIssues = validatePluralForms(
                        value: entry.value,
                        module: moduleName,
                        key: key,
                        languageCode: file.language
                    )
                    issues.append(contentsOf: pluralIssues)
                    stats.pluralIssues += pluralIssues.count
                }

                // Check translation status
                if let translationStatus = entry.metadata?.translationStatus {
                    switch translationStatus {
                    case .untranslated:
                        stats.untranslated += 1
                    case .needsReview:
                        stats.needsReview += 1
                    case .validated:
                        stats.validated += 1
                    }
                }
            }
        }

        // Check for missing keys compared to base file
        if let baseFile = baseFile, checkMissing {
            for (moduleName, baseStrings) in baseFile.modules {
                let translatedStrings = file.modules[moduleName] ?? [:]

                for key in baseStrings.keys {
                    if translatedStrings[key] == nil {
                        issues.append(ValidationIssue(
                            module: moduleName,
                            key: key,
                            severity: .error,
                            message: "Missing key (exists in base language but not in \(file.language))"
                        ))
                        stats.missingKeys += 1
                    }
                }
            }
        }

        return ValidationResult(
            isValid: issues.filter { $0.severity == .error }.isEmpty,
            issues: issues,
            stats: stats
        )
    }

    // MARK: - Private Validation Methods

    private func validateFormatString(
        value: TranslationValue,
        module: String,
        key: String,
        baseEntry: TranslationEntry?
    ) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []

        switch value {
        case .simple(let text):
            let formatSpecifiers = extractFormatSpecifiers(from: text)

            if formatSpecifiers.isEmpty {
                issues.append(ValidationIssue(
                    module: module,
                    key: key,
                    severity: .warning,
                    message: "Marked as interpolation but no format specifiers found"
                ))
            }

            // Compare with base if available
            if let baseEntry = baseEntry, case .simple(let baseText) = baseEntry.value {
                let baseSpecifiers = extractFormatSpecifiers(from: baseText)

                if formatSpecifiers.count != baseSpecifiers.count {
                    issues.append(ValidationIssue(
                        module: module,
                        key: key,
                        severity: .error,
                        message: "Format specifier count mismatch (expected \(baseSpecifiers.count), got \(formatSpecifiers.count))"
                    ))
                }

                if formatSpecifiers != baseSpecifiers {
                    issues.append(ValidationIssue(
                        module: module,
                        key: key,
                        severity: .warning,
                        message: "Format specifier types differ from base language"
                    ))
                }
            }

        case .plural(let dict):
            for (category, text) in dict {
                let formatSpecifiers = extractFormatSpecifiers(from: text)

                if formatSpecifiers.isEmpty {
                    issues.append(ValidationIssue(
                        module: module,
                        key: key,
                        severity: .warning,
                        message: "No format specifiers in plural form '\(category)'"
                    ))
                }
            }
        }

        return issues
    }

    private func validatePluralForms(
        value: TranslationValue,
        module: String,
        key: String,
        languageCode: String
    ) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []

        guard case .plural(let dict) = value else {
            issues.append(ValidationIssue(
                module: module,
                key: key,
                severity: .error,
                message: "Marked as plural but value is not a dictionary"
            ))
            return issues
        }

        // Check for required plural forms based on language
        let requiredForms = getRequiredPluralForms(for: languageCode)

        for requiredForm in requiredForms {
            if dict[requiredForm] == nil {
                issues.append(ValidationIssue(
                    module: module,
                    key: key,
                    severity: .error,
                    message: "Missing required plural form '\(requiredForm)' for language '\(languageCode)'"
                ))
            }
        }

        // Check for empty values
        for (category, text) in dict {
            if text.isEmpty {
                issues.append(ValidationIssue(
                    module: module,
                    key: key,
                    severity: .error,
                    message: "Empty value in plural form '\(category)'"
                ))
            }
        }

        return issues
    }

    // MARK: - Helper Methods

    private func extractFormatSpecifiers(from text: String) -> [String] {
        let pattern = "%[@dfilucsSp]"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }

        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, options: [], range: range)

        return matches.map { match in
            let range = Range(match.range, in: text)!
            return String(text[range])
        }
    }

    private func getRequiredPluralForms(for languageCode: String) -> [String] {
        // Based on CLDR plural rules
        switch languageCode {
        case "en":
            return ["one", "other"]
        case "ar":
            return ["zero", "one", "two", "few", "many", "other"]
        case "bn", "hi":
            return ["one", "other"]
        case "ru", "uk":
            return ["one", "few", "many"]
        case "zh", "ja", "ko":
            return ["other"]
        default:
            return ["other"] // Default: at least "other" is required
        }
    }

    /// Print validation report
    public func printReport(_ result: ValidationResult, fileName: String) {
        print("""

        📋 Validation Report: \(fileName)
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        Overall Status: \(result.isValid ? "✅ PASS" : "❌ FAIL")

        Statistics:
        • Total Strings:     \(result.stats.totalStrings)
        • Validated:         \(result.stats.validated)
        • Needs Review:      \(result.stats.needsReview)
        • Untranslated:      \(result.stats.untranslated)
        • Missing Keys:      \(result.stats.missingKeys)
        • Format Issues:     \(result.stats.formatIssues)
        • Plural Issues:     \(result.stats.pluralIssues)

        """)

        if !result.issues.isEmpty {
            print("Issues Found:\n")

            let errors = result.issues.filter { $0.severity == .error }
            let warnings = result.issues.filter { $0.severity == .warning }

            if !errors.isEmpty {
                print("❌ Errors (\(errors.count)):")
                for issue in errors.prefix(10) {
                    print("   • [\(issue.module)] \(issue.key)")
                    print("     \(issue.message)")
                }
                if errors.count > 10 {
                    print("   ... and \(errors.count - 10) more errors")
                }
                print("")
            }

            if !warnings.isEmpty {
                print("⚠️  Warnings (\(warnings.count)):")
                for issue in warnings.prefix(5) {
                    print("   • [\(issue.module)] \(issue.key)")
                    print("     \(issue.message)")
                }
                if warnings.count > 5 {
                    print("   ... and \(warnings.count - 5) more warnings")
                }
                print("")
            }
        } else {
            print("✨ No issues found!\n")
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
}

// MARK: - Supporting Types

public struct ValidationResult {
    public let isValid: Bool
    public let issues: [ValidationIssue]
    public let stats: ValidationStats
}

public struct ValidationIssue {
    public let module: String
    public let key: String
    public let severity: Severity
    public let message: String

    public enum Severity {
        case error
        case warning
    }
}

public struct ValidationStats {
    public var totalStrings: Int = 0
    public var validated: Int = 0
    public var needsReview: Int = 0
    public var untranslated: Int = 0
    public var missingTranslations: Int = 0
    public var missingKeys: Int = 0
    public var formatIssues: Int = 0
    public var pluralIssues: Int = 0
}
