//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

@testable import LocalizeKitCore
import XCTest

/// Unit tests for `FormatLinter`, the rule engine that flags arg-count and arg-type
/// mismatches between `.localize` default values and the supplied `with:` arguments.
final class FormatLinterTests: XCTestCase {

    private let linter = FormatLinter()

    // MARK: - Helpers

    /// Build an `ExtractedString` with sensible defaults for lint tests.
    private func makeExtracted(
        key: String = "test_key",
        defaultValue: String = "",
        type: TranslationType = .simple,
        pluralForms: [String: String]? = nil,
        arguments: [LintArgument] = [],
        countArgument: LintCountArgument? = nil,
        line: Int = 1,
        column: Int = 1
    ) -> ExtractedString {
        ExtractedString(
            key: key,
            moduleName: "TestModule",
            defaultValue: defaultValue,
            comment: "",
            type: type,
            pluralForms: pluralForms,
            filePath: "/tmp/Test.swift",
            lineNumber: line,
            column: column,
            arguments: arguments,
            countArgument: countArgument
        )
    }

    private func makeArg(_ text: String, type: ResolvedType) -> LintArgument {
        LintArgument(label: nil, text: text, resolvedType: type, line: 1, column: 1)
    }

    // MARK: - Empty key

    func testLint_emptyKey_emitsEmptyKeyError() {
        let entry = makeExtracted(key: "", defaultValue: "Hello")
        let issues = linter.lint([entry])
        XCTAssertTrue(issues.contains { $0.ruleID == "empty_key" && $0.severity == .error })
    }

    // MARK: - Simple / interpolation

    func testLint_simpleStringWithNoArgs_passes() {
        let entry = makeExtracted(defaultValue: "Hello world")
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }

    func testLint_objectSpecifierMatchesString_passes() {
        let entry = makeExtracted(
            defaultValue: "Hello, %@!",
            type: .interpolation,
            arguments: [makeArg("name", type: .string)]
        )
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }

    func testLint_intSpecifierMatchesInt_passes() {
        let entry = makeExtracted(
            defaultValue: "Score: %d",
            type: .interpolation,
            arguments: [makeArg("score", type: .integer)]
        )
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }

    func testLint_floatSpecifierAcceptsInteger_passes() {
        let entry = makeExtracted(
            defaultValue: "Total: %.2f",
            type: .interpolation,
            arguments: [makeArg("count", type: .integer)]
        )
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }

    func testLint_characterSpecifierMatchesInt_passes() {
        // `%c` expects an integer code point (mirrors `SafeFormat`: accept integers only).
        let entry = makeExtracted(
            defaultValue: "Grade: %c",
            type: .interpolation,
            arguments: [makeArg("codePoint", type: .integer)]
        )
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }

    func testLint_characterSpecifierRejectsString_reportsError() {
        // A `Character`/`String` is passed as a pointer; `%c` would misread it. Strict error.
        let entry = makeExtracted(
            defaultValue: "Grade: %c",
            type: .interpolation,
            arguments: [makeArg("grade", type: .string)]
        )
        let issues = linter.lint([entry])
        XCTAssertTrue(issues.contains {
            $0.ruleID == "format_arg_type_mismatch" && $0.severity == .error
        })
    }

    func testLint_characterSpecifierRejectsBool_reportsWarning() {
        // `Bool` for `%c` renders a control glyph — flagged, but not a crash, so a warning.
        let entry = makeExtracted(
            defaultValue: "%c",
            type: .interpolation,
            arguments: [makeArg("flag", type: .boolean)]
        )
        let issues = linter.lint([entry])
        let mismatch = issues.first { $0.ruleID == "format_arg_type_mismatch" }
        XCTAssertNotNil(mismatch)
        XCTAssertEqual(mismatch?.severity, .warning)
    }

    func testLint_objectSpecifierAcceptsBridgingTypes_passes() {
        // %@ legitimately bridges only String (auto-NSString) and NSObject types.
        // Numerics and Bool do NOT auto-bridge through CVarArg.
        let cases: [ResolvedType] = [.string, .object]
        for type in cases {
            let entry = makeExtracted(
                defaultValue: "Value: %@",
                type: .interpolation,
                arguments: [makeArg("v", type: type)]
            )
            XCTAssertTrue(linter.lint([entry]).isEmpty, "%@ should accept \(type)")
        }
    }

    func testLint_objectSpecifierRejectsIntArgument_reportsError() {
        // Passing Int to %@ produces garbage or crashes at runtime — this is the
        // exact pattern the user reported with `Qty: %@` + `getItemQty()` (Int).
        let entry = makeExtracted(
            defaultValue: "Qty: %@",
            type: .interpolation,
            arguments: [makeArg("count", type: .integer)]
        )
        let issues = linter.lint([entry])
        let mismatch = issues.first { $0.ruleID == "format_arg_type_mismatch" }
        XCTAssertNotNil(mismatch)
        XCTAssertEqual(mismatch?.severity, .error,
                       "Int passed to %@ is a runtime crash, must be an error")
    }

    func testLint_objectSpecifierRejectsDoubleArgument_reportsError() {
        let entry = makeExtracted(
            defaultValue: "Total: %@",
            type: .interpolation,
            arguments: [makeArg("price", type: .floatingPoint)]
        )
        let issues = linter.lint([entry])
        XCTAssertTrue(issues.contains {
            $0.ruleID == "format_arg_type_mismatch" && $0.severity == .error
        })
    }

    func testLint_objectSpecifierRejectsBoolArgument_reportsError() {
        let entry = makeExtracted(
            defaultValue: "Status: %@",
            type: .interpolation,
            arguments: [makeArg("isAdmin", type: .boolean)]
        )
        let issues = linter.lint([entry])
        XCTAssertTrue(issues.contains {
            $0.ruleID == "format_arg_type_mismatch" && $0.severity == .error
        })
    }

    func testLint_mixedSpecifiersWithIntForPercentAt_reportsOnlyTheMismatch() {
        // User scenario 2: "Quantity %@ total price $%.2f" with Int + Double.
        // The %.2f part with Double is fine; the %@ with Int is the bug.
        let entry = makeExtracted(
            defaultValue: "Quantity %@ total price $%.2f",
            type: .interpolation,
            arguments: [
                makeArg("qty", type: .integer),
                makeArg("price", type: .floatingPoint)
            ]
        )
        let mismatches = linter.lint([entry]).filter { $0.ruleID == "format_arg_type_mismatch" }
        XCTAssertEqual(mismatches.count, 1, "Only the %@/Int slot should be flagged")
        XCTAssertEqual(mismatches.first?.severity, .error)
        XCTAssertTrue(mismatches.first?.message.contains("qty") == true)
    }

    // MARK: - Count mismatches

    func testLint_specifierWithoutArgs_reportsMissingArgs() {
        let entry = makeExtracted(defaultValue: "Hello, %@!", type: .interpolation)
        let ids = linter.lint([entry]).map(\.ruleID)
        XCTAssertEqual(ids, ["format_missing_args"])
    }

    func testLint_argsWithoutSpecifiers_reportsUnusedArgs() {
        let entry = makeExtracted(
            defaultValue: "Hello world",
            arguments: [makeArg("name", type: .string)]
        )
        let ids = linter.lint([entry]).map(\.ruleID)
        XCTAssertEqual(ids, ["format_unused_args"])
    }

    func testLint_threeSpecifiersTwoArgs_reportsCountMismatch() {
        let entry = makeExtracted(
            defaultValue: "%@ %d %f",
            type: .interpolation,
            arguments: [
                makeArg("name", type: .string),
                makeArg("score", type: .integer)
            ]
        )
        let issues = linter.lint([entry])
        XCTAssertTrue(issues.contains { $0.ruleID == "format_arg_count_mismatch" && $0.severity == .error })
    }

    // MARK: - Type mismatches

    func testLint_stringPassedToIntSpecifier_reportsErrorMismatch() {
        let entry = makeExtracted(
            defaultValue: "Score: %d",
            type: .interpolation,
            arguments: [makeArg("name", type: .string)]
        )
        let issues = linter.lint([entry])
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues.first?.ruleID, "format_arg_type_mismatch")
        XCTAssertEqual(issues.first?.severity, .error)
    }

    func testLint_intPassedToStringSpecifier_reportsErrorMismatch() {
        let entry = makeExtracted(
            defaultValue: "Path: %s",
            type: .interpolation,
            arguments: [makeArg("count", type: .integer)]
        )
        let issues = linter.lint([entry])
        XCTAssertEqual(issues.first?.ruleID, "format_arg_type_mismatch")
        XCTAssertEqual(issues.first?.severity, .error)
    }

    func testLint_doublePassedToIntSpecifier_reportsErrorMismatch() {
        let entry = makeExtracted(
            defaultValue: "Score: %d",
            type: .interpolation,
            arguments: [makeArg("price", type: .floatingPoint)]
        )
        let issues = linter.lint([entry])
        XCTAssertEqual(issues.first?.severity, .error)
    }

    func testLint_boolPassedToIntSpecifier_reportsWarning() {
        let entry = makeExtracted(
            defaultValue: "Score: %d",
            type: .interpolation,
            arguments: [makeArg("flag", type: .boolean)]
        )
        let issues = linter.lint([entry])
        XCTAssertEqual(issues.first?.ruleID, "format_arg_type_mismatch")
        XCTAssertEqual(issues.first?.severity, .warning)
    }

    func testLint_unknownTypeArgument_isPessimistic_skipsTypeRule() {
        // Linter must NOT emit a mismatch when it cannot prove one — this protects callers
        // who pass expressions whose types we cannot infer (e.g., generic returns).
        let entry = makeExtracted(
            defaultValue: "Score: %d",
            type: .interpolation,
            arguments: [makeArg("mystery", type: .unknown)]
        )
        let issues = linter.lint([entry])
        XCTAssertFalse(issues.contains { $0.ruleID == "format_arg_type_mismatch" })
    }

    // MARK: - Unverified (unresolved-type) arguments

    func testLint_unknownArg_withWarnUnverified_emitsWarning() {
        // When the resolver can't determine an argument's type, the slot goes
        // unchecked. With `warnUnverified` on, surface it as a warning so the user
        // can verify the call site manually.
        let entry = makeExtracted(
            defaultValue: "Score: %d",
            type: .interpolation,
            arguments: [makeArg("mystery", type: .unknown)]
        )
        let issues = FormatLinter(warnUnverified: true).lint([entry])
        let warn = issues.first { $0.ruleID == "format_arg_type_unverified" }
        XCTAssertNotNil(warn, "Got: \(issues.map(\.ruleID))")
        XCTAssertEqual(warn?.severity, .warning)
        XCTAssertTrue(warn?.message.contains("mystery") == true)
        XCTAssertFalse(issues.contains { $0.ruleID == "format_arg_type_mismatch" },
                       "Unverified is not a proven mismatch")
    }

    func testLint_unknownArg_withoutWarnUnverified_staysSilent() {
        // Default behaviour is unchanged: no unverified noise.
        let entry = makeExtracted(
            defaultValue: "Score: %d",
            type: .interpolation,
            arguments: [makeArg("mystery", type: .unknown)]
        )
        let issues = FormatLinter().lint([entry])
        XCTAssertFalse(issues.contains { $0.ruleID == "format_arg_type_unverified" })
    }

    func testLint_nilLiteralArg_withWarnUnverified_doesNotWarn() {
        // `nil` is a known literal, not "unknown" — must not be flagged as unverified.
        let entry = makeExtracted(
            defaultValue: "Path: %s",
            type: .interpolation,
            arguments: [makeArg("nil", type: .nilLiteral)]
        )
        let issues = FormatLinter(warnUnverified: true).lint([entry])
        XCTAssertFalse(issues.contains { $0.ruleID == "format_arg_type_unverified" })
    }

    func testLint_knownTypeArg_withWarnUnverified_doesNotWarn() {
        // A resolvable, compatible argument must never produce an unverified warning.
        let entry = makeExtracted(
            defaultValue: "Score: %d",
            type: .interpolation,
            arguments: [makeArg("score", type: .integer)]
        )
        let issues = FormatLinter(warnUnverified: true).lint([entry])
        XCTAssertTrue(issues.isEmpty, "Got: \(issues.map(\.ruleID))")
    }

    func testLint_pluralUnknownArg_withWarnUnverified_emitsWarning() {
        let entry = makeExtracted(
            type: .plural,
            pluralForms: ["one": "1 item", "other": "%d items"],
            arguments: [makeArg("mystery", type: .unknown)],
            countArgument: LintCountArgument(text: "count", resolvedType: .integer, line: 1, column: 1)
        )
        let issues = FormatLinter(warnUnverified: true).lint([entry])
        XCTAssertTrue(issues.contains { $0.ruleID == "format_arg_type_unverified" && $0.severity == .warning },
                      "Got: \(issues.map(\.ruleID))")
    }

    func testLint_nilLiteralArgument_isAlwaysCompatible() {
        let entry = makeExtracted(
            defaultValue: "Path: %s",
            type: .interpolation,
            arguments: [makeArg("nil", type: .nilLiteral)]
        )
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }

    // MARK: - Plural

    func testLint_pluralEmpty_reportsPluralEmptyError() {
        let entry = makeExtracted(
            type: .plural,
            pluralForms: [:]
        )
        XCTAssertTrue(linter.lint([entry]).contains { $0.ruleID == "plural_empty" && $0.severity == .error })
    }

    func testLint_pluralMissingOther_reportsPluralMissingOtherError() {
        let entry = makeExtracted(
            type: .plural,
            pluralForms: ["one": "1 item"]
        )
        XCTAssertTrue(linter.lint([entry]).contains { $0.ruleID == "plural_missing_other" && $0.severity == .error })
    }

    func testLint_pluralFormsWithMatchingArguments_passes() {
        let entry = makeExtracted(
            type: .plural,
            pluralForms: ["one": "1 item", "other": "%d items"],
            arguments: [makeArg("count", type: .integer)],
            countArgument: LintCountArgument(text: "count", resolvedType: .integer, line: 1, column: 1)
        )
        // `.one` has 0 specifiers and `.other` has 1 — that's a real warning we keep,
        // but no errors should be present.
        let issues = linter.lint([entry])
        XCTAssertFalse(issues.contains { $0.severity == .error })
        XCTAssertTrue(issues.contains { $0.ruleID == "plural_form_inconsistent" && $0.severity == .warning })
    }

    func testLint_pluralCountArgumentIsDouble_reportsCountTypeError() {
        let entry = makeExtracted(
            type: .plural,
            pluralForms: ["one": "1 item", "other": "%d items"],
            arguments: [makeArg("count", type: .integer)],
            countArgument: LintCountArgument(text: "price", resolvedType: .floatingPoint, line: 1, column: 1)
        )
        XCTAssertTrue(linter.lint([entry]).contains { $0.ruleID == "plural_count_type" && $0.severity == .error })
    }

    func testLint_pluralCountArgumentIsString_reportsCountTypeError() {
        let entry = makeExtracted(
            type: .plural,
            pluralForms: ["one": "1 item", "other": "%d items"],
            arguments: [makeArg("count", type: .integer)],
            countArgument: LintCountArgument(text: "label", resolvedType: .string, line: 1, column: 1)
        )
        XCTAssertTrue(linter.lint([entry]).contains { $0.ruleID == "plural_count_type" && $0.severity == .error })
    }

    func testLint_pluralWithIntPassedToOtherFormat_reportsTypeMismatch() {
        let entry = makeExtracted(
            type: .plural,
            pluralForms: ["one": "1 item", "other": "%d items"],
            arguments: [makeArg("name", type: .string)],
            countArgument: LintCountArgument(text: "count", resolvedType: .integer, line: 1, column: 1)
        )
        XCTAssertTrue(linter.lint([entry]).contains { $0.ruleID == "format_arg_type_mismatch" && $0.severity == .error })
    }

    // MARK: - Positional specifiers

    func testLint_positionalSpecifiers_acceptRepeatedReferences() {
        // %1$@ is referenced twice; only one with: argument is needed.
        let entry = makeExtracted(
            defaultValue: "%1$@ likes %1$@",
            type: .interpolation,
            arguments: [makeArg("name", type: .string)]
        )
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }

    func testLint_positionalReferenceBeyondArgCount_reportsError() {
        // `%2$@` references the second argument but only one is supplied — a
        // guaranteed runtime crash. The exact-count check is skipped for positional
        // formats (they may legally repeat), so this must be caught separately.
        let entry = makeExtracted(
            defaultValue: "%2$@",
            type: .interpolation,
            arguments: [makeArg("only", type: .string)]
        )
        let issues = linter.lint([entry])
        XCTAssertTrue(
            issues.contains { $0.ruleID == "format_arg_count_mismatch" && $0.severity == .error },
            "Positional reference beyond arg count must error. Got: \(issues.map(\.ruleID))"
        )
    }

    func testLint_mixedPositionalReferenceBeyondArgCount_reportsError() {
        // "%1$@ %2$@" needs 2 args; only 1 supplied → second slot crashes at runtime.
        let entry = makeExtracted(
            defaultValue: "%1$@ %2$@",
            type: .interpolation,
            arguments: [makeArg("first", type: .string)]
        )
        let issues = linter.lint([entry])
        XCTAssertTrue(
            issues.contains { $0.ruleID == "format_arg_count_mismatch" && $0.severity == .error },
            "Missing positional argument must error. Got: \(issues.map(\.ruleID))"
        )
    }

    func testLint_positionalReferencesAllSupplied_passes() {
        let entry = makeExtracted(
            defaultValue: "%2$@ then %1$@",
            type: .interpolation,
            arguments: [makeArg("a", type: .string), makeArg("b", type: .string)]
        )
        XCTAssertFalse(linter.lint([entry]).contains { $0.severity == .error })
    }

    // MARK: - Dynamic width / precision

    func testLint_dynamicWidthWithWidthAndValueArgs_doesNotFalselyReportCountMismatch() {
        // `%*d` consumes TWO arguments at runtime: the width (Int) and the value
        // (Int). Supplying both is correct and must NOT be reported as a count
        // mismatch. The linter cannot model the shifted indices reliably, so it
        // declines to count/type-check dynamic-width formats rather than emit a
        // false positive.
        let entry = makeExtracted(
            defaultValue: "%*d",
            type: .interpolation,
            arguments: [makeArg("width", type: .integer), makeArg("value", type: .integer)]
        )
        let issues = linter.lint([entry])
        XCTAssertFalse(
            issues.contains { $0.ruleID == "format_arg_count_mismatch" },
            "Dynamic-width format with correct args must not be flagged. Got: \(issues.map(\.ruleID))"
        )
    }

    func testLint_dynamicPrecisionWithPrecisionAndValueArgs_doesNotFalselyReportCountMismatch() {
        let entry = makeExtracted(
            defaultValue: "%.*f",
            type: .interpolation,
            arguments: [makeArg("precision", type: .integer), makeArg("value", type: .floatingPoint)]
        )
        let issues = linter.lint([entry])
        XCTAssertFalse(
            issues.contains { $0.ruleID == "format_arg_count_mismatch" },
            "Dynamic-precision format with correct args must not be flagged. Got: \(issues.map(\.ruleID))"
        )
    }

    // MARK: - Source positions

    func testLint_argumentMismatchUsesArgumentLineAndColumn() {
        let arg = LintArgument(
            label: nil,
            text: "name",
            resolvedType: .string,
            line: 42,
            column: 18
        )
        let entry = makeExtracted(
            defaultValue: "Score: %d",
            type: .interpolation,
            arguments: [arg],
            line: 40,
            column: 9
        )
        let issues = linter.lint([entry])
        let issue = try? XCTUnwrap(issues.first)
        XCTAssertEqual(issue?.line, 42)
        XCTAssertEqual(issue?.column, 18)
    }

    func testLint_callLevelIssueUsesEntryLineAndColumn() {
        // A count mismatch is reported at the call site, not at any specific argument.
        let entry = makeExtracted(
            defaultValue: "Hello, %@!",
            type: .interpolation,
            line: 100,
            column: 5
        )
        let issues = linter.lint([entry])
        XCTAssertEqual(issues.first?.line, 100)
        XCTAssertEqual(issues.first?.column, 5)
    }

    // MARK: - Decorative percent (context-aware)

    func testLint_decorativePercentWithoutArguments_passes() {
        // User scenario 1: "%Compliance" with no `with:` — the default value is returned
        // verbatim by `.localize`, never reaching `String(format:)`. Linter must stay silent.
        let entry = makeExtracted(
            key: "compliance_label",
            defaultValue: "%Compliance",
            type: .simple
        )
        XCTAssertTrue(
            linter.lint([entry]).isEmpty,
            "Decorative '%' with no `with:` args must not produce any issue"
        )
    }

    func testLint_escapedPercentWithoutArguments_passes() {
        // The CORRECT, portable form. Never produces issues regardless of args.
        let entry = makeExtracted(
            key: "compliance_label",
            defaultValue: "%%Compliance",
            type: .simple
        )
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }

    func testLint_decorativePercentWithArguments_reportsUnescapedPercentError() {
        // The dangerous case: `%C` would be interpreted as Cocoa wide-char by
        // `String(format:)`, producing garbage or a crash.
        let entry = makeExtracted(
            key: "compliance_link",
            defaultValue: "%Compliance: %@",
            type: .interpolation,
            arguments: [makeArg("name", type: .string)]
        )
        let issues = linter.lint([entry])
        let unescaped = issues.first { $0.ruleID == "unescaped_percent" }
        let issue = try? XCTUnwrap(unescaped)
        XCTAssertEqual(issue?.severity, .error)
        XCTAssertTrue(issue?.message.contains("%C") == true,
                      "Message must mention the offending '%C'")
        XCTAssertTrue(issue?.message.contains("%%C") == true,
                      "Message must suggest '%%C' as the fix")
    }

    func testLint_escapedPercentWithArguments_passes() {
        let entry = makeExtracted(
            key: "compliance_link",
            defaultValue: "%%Compliance: %@",
            type: .interpolation,
            arguments: [makeArg("name", type: .string)]
        )
        XCTAssertTrue(
            linter.lint([entry]).contains { $0.ruleID == "unescaped_percent" } == false,
            "Escaped '%%' must not be flagged"
        )
    }

    // MARK: - User scenario 2: link prompt with newline

    func testLint_linkPromptWithNewlineAndStringArg_passes() {
        // User scenario 2: "Do you want to open this link:\n%@" with one String `with:` arg.
        // The escape sequence appears in the source as the two literal chars `\` + `n`,
        // never as an actual newline character. Linter must accept it cleanly.
        let entry = makeExtracted(
            key: "open_link_prompt",
            defaultValue: #"Do you want to open this link:\n%@"#,
            type: .interpolation,
            arguments: [makeArg("url", type: .string)]
        )
        XCTAssertTrue(
            linter.lint([entry]).isEmpty,
            "Newline + %@ + String arg is a clean call site"
        )
    }

    func testLint_linkPromptWithNewlineAndIntArg_reportsTypeMismatch() {
        // %@ no longer accepts Int — Swift Int does not auto-bridge to NSObject
        // through CVarArg, so the runtime would print garbage or crash.
        let entry = makeExtracted(
            key: "open_link_prompt",
            defaultValue: #"Open link:\n%@"#,
            type: .interpolation,
            arguments: [makeArg("number", type: .integer)]
        )
        XCTAssertTrue(
            linter.lint([entry]).contains {
                $0.ruleID == "format_arg_type_mismatch" && $0.severity == .error
            },
            "Int passed to %@ must be flagged as an error"
        )
    }

    func testLint_linkPromptWithoutArgs_reportsMissingArgs() {
        let entry = makeExtracted(
            key: "open_link_prompt",
            defaultValue: #"Open link:\n%@"#,
            type: .interpolation
        )
        let issues = linter.lint([entry])
        XCTAssertTrue(issues.contains {
            $0.ruleID == "format_missing_args" && $0.severity == .error
        })
    }

    // MARK: - Additional corner cases

    func testLint_dollarSignBeforeFloatSpecifier_isNotConfusedWithPositional() {
        // "$%.2f" — the `$` is currency, NOT a positional marker (positional needs digits).
        // One float specifier expected; one Double arg supplied → clean.
        let entry = makeExtracted(
            key: "price_label",
            defaultValue: "Total: $%.2f",
            type: .interpolation,
            arguments: [makeArg("price", type: .floatingPoint)]
        )
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }

    func testLint_emailContainingAtSign_doesNotInflateSpecifierCount() {
        // The `@` in `user@example.com` is plain text — no preceding `%`.
        let entry = makeExtracted(
            key: "contact",
            defaultValue: "Contact %@ at user@example.com",
            type: .interpolation,
            arguments: [makeArg("name", type: .string)]
        )
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }

    func testLint_escapedPercentInteraction_works() {
        // "Save %@ now! 50%% off" — one specifier, one literal percent, one String arg.
        let entry = makeExtracted(
            key: "promo",
            defaultValue: "Save %@ now! 50%% off",
            type: .interpolation,
            arguments: [makeArg("name", type: .string)]
        )
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }

    func testLint_pluralWithDecorativePercentAndArguments_reportsUnescapedPercent() {
        // Decorative `%C` inside a plural form, with a `with:` arg → unsafe.
        let entry = makeExtracted(
            key: "compliance_count",
            type: .plural,
            pluralForms: [
                "one": "1 %Compliance issue",
                "other": "%d %Compliance issues"
            ],
            arguments: [makeArg("count", type: .integer)],
            countArgument: LintCountArgument(text: "count", resolvedType: .integer, line: 1, column: 1)
        )
        let issues = linter.lint([entry])
        XCTAssertTrue(issues.contains {
            $0.ruleID == "unescaped_percent" && $0.severity == .error
        }, "Got: \(issues.map(\.ruleID))")
    }

    func testLint_pluralWithDecorativePercentNoArgs_reportsOnlyMissingArgsRelatedIssues() {
        // No `with:` args → `String(format:)` not invoked → unescaped percent is safe.
        let entry = makeExtracted(
            key: "compliance_count",
            type: .plural,
            pluralForms: [
                "one": "1 %Compliance",
                "other": "Many %Compliance"
            ],
            countArgument: LintCountArgument(text: "count", resolvedType: .integer, line: 1, column: 1)
        )
        let issues = linter.lint([entry])
        XCTAssertFalse(
            issues.contains { $0.ruleID == "unescaped_percent" },
            "Without `with:` args, decorative percent must not be flagged. Got: \(issues.map(\.ruleID))"
        )
    }

    func testLint_capitalSWideCharSpecifier_treatedAsDecorationWithoutArgs() {
        // `%S` alone — wide-string specifier, dropped from whitelist. Without args, silent.
        let entry = makeExtracted(
            key: "wide_label",
            defaultValue: "%Service health",
            type: .simple
        )
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }

    func testLint_adjacentSpecifiersWithMatchingArgs_passes() {
        // "%@%@" — two object specifiers, two args.
        let entry = makeExtracted(
            key: "concat",
            defaultValue: "%@%@",
            type: .interpolation,
            arguments: [
                makeArg("a", type: .string),
                makeArg("b", type: .string)
            ]
        )
        XCTAssertTrue(linter.lint([entry]).isEmpty)
    }
}
