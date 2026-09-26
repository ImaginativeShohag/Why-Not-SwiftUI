//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// Validates that each `.localize(...)` / `Text.localized(...)` call site has format
/// specifiers in its default value (or each plural form) that match the number and
/// type of `with:` arguments supplied.
public final class FormatLinter {

    /// Optional semantic resolver. When set, the linter consults IndexStoreDB at
    /// the source position of each `with:` argument to refine the literal-only
    /// `ResolvedType` baked into the `LintArgument` during extraction. Semantic
    /// results always win when available — they come from Swift's actual type checker.
    private let semanticResolver: SemanticTypeResolver?

    /// When `true`, slots whose argument type could not be resolved (`.unknown`)
    /// emit a `format_arg_type_unverified` *warning* instead of being silently
    /// skipped. Lets callers surface call sites the linter could not prove safe so
    /// a human can check them. Off by default to preserve quiet, error-only output.
    private let warnUnverified: Bool

    public init(semanticResolver: SemanticTypeResolver? = nil, warnUnverified: Bool = false) {
        self.semanticResolver = semanticResolver
        self.warnUnverified = warnUnverified
    }

    /// Run lint checks over a list of extracted call sites and return the issues found.
    public func lint(_ extracted: [ExtractedString]) -> [LintIssue] {
        var issues: [LintIssue] = []

        for entry in extracted {
            issues.append(contentsOf: lintEntry(entry))
        }

        return issues
    }

    // MARK: - Per-entry lint

    private func lintEntry(_ entry: ExtractedString) -> [LintIssue] {
        var issues: [LintIssue] = []

        // Authoritative type resolution: when a semantic resolver is configured,
        // ask IndexStoreDB for the type of each argument at its source position.
        // Anything it can answer (.unknown is "I don't know") replaces the
        // literal-only baseline from `LintArgument.resolvedType`.
        let resolved = semanticallyResolved(entry: entry)

        // Empty key check
        if resolved.key.isEmpty {
            issues.append(
                LintIssue(
                    ruleID: "empty_key",
                    severity: .error,
                    message: "Localization key is empty.",
                    filePath: resolved.filePath,
                    line: resolved.lineNumber,
                    column: resolved.column
                )
            )
        }

        switch resolved.type {
        case .simple, .interpolation:
            issues.append(contentsOf: lintSimple(resolved))
        case .plural:
            issues.append(contentsOf: lintPlural(resolved))
        }

        return issues
    }

    /// Re-build `entry` with any argument types refined by the semantic resolver.
    /// When the semantic resolver returns `.unknown` for an arg, we keep the
    /// literal-only baseline so we don't downgrade information.
    private func semanticallyResolved(entry: ExtractedString) -> ExtractedString {
        guard let resolver = semanticResolver else { return entry }

        let arguments = entry.arguments.map { arg -> LintArgument in
            guard let semantic = semanticType(
                resolver: resolver,
                filePath: entry.filePath,
                line: arg.memberLookupLine ?? arg.line,
                memberLookupColumn: arg.memberLookupColumn
            ) else { return arg }
            return LintArgument(
                label: arg.label,
                text: arg.text,
                resolvedType: semantic,
                line: arg.line,
                column: arg.column,
                memberLookupLine: arg.memberLookupLine,
                memberLookupColumn: arg.memberLookupColumn
            )
        }

        var refinedCountArgument = entry.countArgument
        if let countArg = entry.countArgument,
           let semantic = semanticType(
               resolver: resolver,
               filePath: entry.filePath,
               line: countArg.memberLookupLine ?? countArg.line,
               memberLookupColumn: countArg.memberLookupColumn
           ) {
            refinedCountArgument = LintCountArgument(
                text: countArg.text,
                resolvedType: semantic,
                line: countArg.line,
                column: countArg.column,
                memberLookupLine: countArg.memberLookupLine,
                memberLookupColumn: countArg.memberLookupColumn
            )
        }

        return ExtractedString(
            key: entry.key,
            moduleName: entry.moduleName,
            defaultValue: entry.defaultValue,
            comment: entry.comment,
            type: entry.type,
            pluralForms: entry.pluralForms,
            filePath: entry.filePath,
            lineNumber: entry.lineNumber,
            column: entry.column,
            arguments: arguments,
            countArgument: refinedCountArgument
        )
    }

    /// Query the semantic resolver for the type at `memberLookupColumn` on `line`,
    /// widening the search by ±1 column to absorb the occasional SwiftSyntax /
    /// IndexStoreDB disagreement for back-quoted or attributed identifiers. We
    /// resist widening further so a stale-index hit on a neighbouring construct
    /// never overrides a clean literal baseline. Returns `nil` (keep the literal
    /// baseline) when there is no symbol to look up or the resolver answers `.unknown`.
    private func semanticType(
        resolver: SemanticTypeResolver,
        filePath: String,
        line: Int,
        memberLookupColumn: Int?
    ) -> ResolvedType? {
        guard let column = memberLookupColumn else { return nil }
        let widened = max(1, column - 1) ... (column + 1)
        let semantic = resolver.resolveType(at: filePath, line: line, utf8ColumnRange: widened)
        return semantic == .unknown ? nil : semantic
    }

    // MARK: - Simple / interpolation

    private func lintSimple(_ entry: ExtractedString) -> [LintIssue] {
        var issues: [LintIssue] = []
        let scan = FormatSpecifierParser.scan(entry.defaultValue)
        let specifiers = scan.specifiers

        // Context-aware unescaped-`%` check: only fires when the call passes arguments
        // through `String(format:)`. With no `with:` args, the default string is returned
        // verbatim and `%Compliance`-style decoration is harmless.
        issues.append(contentsOf: ambiguousPercentIssues(
            scan: scan,
            entry: entry,
            source: entry.defaultValue,
            pluralCategory: nil
        ))

        if specifiers.isEmpty && !entry.arguments.isEmpty {
            issues.append(
                LintIssue(
                    ruleID: "format_unused_args",
                    severity: .error,
                    message: "Default value '\(entry.defaultValue)' has no format specifiers but \(entry.arguments.count) `with:` argument(s) provided.",
                    filePath: entry.filePath,
                    line: entry.lineNumber,
                    column: entry.column
                )
            )
            return issues
        }

        if !specifiers.isEmpty && entry.arguments.isEmpty {
            issues.append(
                LintIssue(
                    ruleID: "format_missing_args",
                    severity: .error,
                    message: "Default value '\(entry.defaultValue)' contains \(specifiers.count) format specifier(s) but no `with:` argument was provided.",
                    filePath: entry.filePath,
                    line: entry.lineNumber,
                    column: entry.column
                )
            )
            return issues
        }

        // Dynamic width/precision (`%*d`, `%.*f`) consume extra leading `Int`
        // arguments at runtime that shift every subsequent slot. We cannot model
        // that here without a full positional walk, so we decline to count- or
        // type-check such formats rather than emit a false positive. (Dynamic
        // width is vanishingly rare in localized strings.)
        if specifiers.contains(where: { $0.dynamicWidth || $0.dynamicPrecision }) {
            return issues
        }

        // Count check (only for non-positional formats; positional may legally repeat).
        if specifiers.allSatisfy({ $0.position == nil }) {
            if specifiers.count != entry.arguments.count {
                issues.append(
                    LintIssue(
                        ruleID: "format_arg_count_mismatch",
                        severity: .error,
                        message: "Default value '\(entry.defaultValue)' has \(specifiers.count) format specifier(s) but \(entry.arguments.count) `with:` argument(s) supplied.",
                        filePath: entry.filePath,
                        line: entry.lineNumber,
                        column: entry.column
                    )
                )
            }
        }

        // Positional under-supply: a `%N$…` specifier referencing an argument slot
        // beyond the supplied count is a guaranteed runtime crash. The exact-count
        // check above is skipped for positional formats (they may legally repeat a
        // slot), so this is the only thing that catches a missing positional arg.
        if let issue = positionalUnderSupplyIssue(specifiers: specifiers, entry: entry) {
            issues.append(issue)
        }

        // Type check per slot.
        let pairs = pairArguments(specifiers: specifiers, arguments: entry.arguments)
        for pair in pairs {
            if let issue = checkTypeCompatibility(
                specifier: pair.specifier,
                argument: pair.argument,
                key: entry.key,
                callLine: entry.lineNumber,
                callColumn: entry.column,
                filePath: entry.filePath
            ) {
                issues.append(issue)
            }
        }

        return issues
    }

    // MARK: - Plural

    private func lintPlural(_ entry: ExtractedString) -> [LintIssue] {
        var issues: [LintIssue] = []

        guard let pluralForms = entry.pluralForms, !pluralForms.isEmpty else {
            issues.append(
                LintIssue(
                    ruleID: "plural_empty",
                    severity: .error,
                    message: "Plural localization '\(entry.key)' has no plural forms defined.",
                    filePath: entry.filePath,
                    line: entry.lineNumber,
                    column: entry.column
                )
            )
            return issues
        }

        // CLDR requires `.other` as the universal fallback.
        if pluralForms["other"] == nil {
            issues.append(
                LintIssue(
                    ruleID: "plural_missing_other",
                    severity: .error,
                    message: "Plural localization '\(entry.key)' is missing the required `.other` form.",
                    filePath: entry.filePath,
                    line: entry.lineNumber,
                    column: entry.column
                )
            )
        }

        // count: argument must resolve to an integer (or be unknown — we won't warn then).
        if let countArg = entry.countArgument {
            switch countArg.resolvedType {
            case .integer, .unsignedInteger, .unknown, .nilLiteral:
                break
            case .floatingPoint, .string, .boolean, .object, .character:
                // `.character` is only ever a specifier's *expected* type, never an argument's
                // resolved type, so this branch is unreachable for it — listed for exhaustiveness.
                issues.append(
                    LintIssue(
                        ruleID: "plural_count_type",
                        severity: .error,
                        message: "Plural `count:` must be an integer, got \(describe(type: countArg.resolvedType)) ('\(countArg.text)').",
                        filePath: entry.filePath,
                        line: countArg.line,
                        column: countArg.column
                    )
                )
            }
        }

        // All non-empty plural forms should agree on specifier shape.
        let formScans: [(category: String, scan: FormatScanResult)] = pluralForms
            .map { ($0.key, FormatSpecifierParser.scan($0.value)) }

        // Context-aware unescaped-`%` check across every plural form.
        for form in formScans {
            issues.append(contentsOf: ambiguousPercentIssues(
                scan: form.scan,
                entry: entry,
                source: pluralForms[form.category] ?? "",
                pluralCategory: form.category
            ))
        }

        let formSpecifiers: [(category: String, specifiers: [FormatSpecifier])] = formScans
            .map { ($0.category, $0.scan.specifiers) }

        let referenceSpecifiers = formSpecifiers.first(where: { $0.category == "other" })?.specifiers
            ?? formSpecifiers.max(by: { $0.specifiers.count < $1.specifiers.count })?.specifiers
            ?? []

        for form in formSpecifiers where form.specifiers.count != referenceSpecifiers.count {
            issues.append(
                LintIssue(
                    ruleID: "plural_form_inconsistent",
                    severity: .warning,
                    message: "Plural form '.\(form.category)' for '\(entry.key)' has \(form.specifiers.count) format specifier(s); '.other' has \(referenceSpecifiers.count). Plural forms should share the same `with:` shape.",
                    filePath: entry.filePath,
                    line: entry.lineNumber,
                    column: entry.column
                )
            )
        }

        // Dynamic width/precision shifts argument indices unpredictably — decline
        // to count/type-check rather than emit a false positive (see `lintSimple`).
        if referenceSpecifiers.contains(where: { $0.dynamicWidth || $0.dynamicPrecision }) {
            return issues
        }

        // Pair the canonical form's specifiers with provided `with:` arguments.
        if referenceSpecifiers.allSatisfy({ $0.position == nil }) {
            if referenceSpecifiers.count != entry.arguments.count {
                issues.append(
                    LintIssue(
                        ruleID: "format_arg_count_mismatch",
                        severity: .error,
                        message: "Plural '\(entry.key)' (.other) expects \(referenceSpecifiers.count) interpolation argument(s) but \(entry.arguments.count) `with:` argument(s) supplied.",
                        filePath: entry.filePath,
                        line: entry.lineNumber,
                        column: entry.column
                    )
                )
            }
        }

        if let issue = positionalUnderSupplyIssue(specifiers: referenceSpecifiers, entry: entry) {
            issues.append(issue)
        }

        let pairs = pairArguments(specifiers: referenceSpecifiers, arguments: entry.arguments)
        for pair in pairs {
            if let issue = checkTypeCompatibility(
                specifier: pair.specifier,
                argument: pair.argument,
                key: entry.key,
                callLine: entry.lineNumber,
                callColumn: entry.column,
                filePath: entry.filePath
            ) {
                issues.append(issue)
            }
        }

        return issues
    }

    // MARK: - Positional under-supply

    /// Returns an error when a positional specifier (`%N$…`) references an argument
    /// slot beyond the number of `with:` arguments supplied — a guaranteed runtime
    /// crash that the exact-count check cannot catch (it is skipped for positional
    /// formats because they may legally repeat a slot). Returns `nil` when every
    /// referenced position is covered or there are no positional specifiers.
    private func positionalUnderSupplyIssue(
        specifiers: [FormatSpecifier],
        entry: ExtractedString
    ) -> LintIssue? {
        guard let maxPosition = specifiers.compactMap(\.position).max(),
              maxPosition > entry.arguments.count else {
            return nil
        }
        return LintIssue(
            ruleID: "format_arg_count_mismatch",
            severity: .error,
            message: "Default value '\(entry.defaultValue)' references positional argument %\(maxPosition)$ but only \(entry.arguments.count) `with:` argument(s) supplied.",
            filePath: entry.filePath,
            line: entry.lineNumber,
            column: entry.column
        )
    }

    // MARK: - Pairing

    private struct ArgumentPair {
        let specifier: FormatSpecifier
        let argument: LintArgument
    }

    private func pairArguments(
        specifiers: [FormatSpecifier],
        arguments: [LintArgument]
    ) -> [ArgumentPair] {
        var pairs: [ArgumentPair] = []
        for (index, specifier) in specifiers.enumerated() {
            let argIndex: Int
            if let position = specifier.position {
                argIndex = position - 1 // 1-based
            } else {
                argIndex = index
            }
            guard argIndex >= 0, argIndex < arguments.count else { continue }
            pairs.append(ArgumentPair(specifier: specifier, argument: arguments[argIndex]))
        }
        return pairs
    }

    // MARK: - Unescaped percent

    /// Emit one error per ambiguous `%X` occurrence in `scan`, but ONLY when the
    /// call passes arguments through `String(format:)`. Without `with:` arguments,
    /// the default value is returned verbatim and decorative percents like
    /// `"%Compliance"` are safe. Shared by the simple and plural paths — pass the
    /// relevant `source` string and (for plurals) the `pluralCategory`.
    private func ambiguousPercentIssues(
        scan: FormatScanResult,
        entry: ExtractedString,
        source: String,
        pluralCategory: String?
    ) -> [LintIssue] {
        guard !entry.arguments.isEmpty, !scan.ambiguousPercents.isEmpty else {
            return []
        }
        return scan.ambiguousPercents.map { ambiguous in
            LintIssue(
                ruleID: "unescaped_percent",
                severity: .error,
                message: ambiguousPercentMessage(
                    key: entry.key,
                    source: source,
                    raw: ambiguous.raw,
                    pluralCategory: pluralCategory
                ),
                filePath: entry.filePath,
                line: entry.lineNumber,
                column: entry.column
            )
        }
    }

    private func ambiguousPercentMessage(
        key: String,
        source: String,
        raw: String,
        pluralCategory: String?
    ) -> String {
        let suggestion = "%%" + raw.dropFirst()
        let location = pluralCategory.map { " (.\($0))" } ?? ""
        return "Default value for '\(key)'\(location) — '\(source)' — contains '\(raw)' which is not a recognised format specifier; "
            + "since `with:` arguments are passed through `String(format:)`, a literal `%` must be escaped as `%%`. "
            + "Replace '\(raw)' with '\(suggestion)'."
    }

    // MARK: - Type compatibility

    private func checkTypeCompatibility(
        specifier: FormatSpecifier,
        argument: LintArgument,
        key: String,
        callLine: Int,
        callColumn: Int,
        filePath: String
    ) -> LintIssue? {
        let expected = specifier.expectedType
        let actual = argument.resolvedType

        // Unresolved type: we can neither prove nor disprove a mismatch (custom
        // type, typealias, complex expression, or a missing/stale Xcode index).
        // Surface it as a warning when asked; otherwise stay silent (pessimistic).
        if actual == .unknown {
            guard warnUnverified else { return nil }
            return LintIssue(
                ruleID: "format_arg_type_unverified",
                severity: .warning,
                message: "Argument '\(argument.text)' for format specifier '\(specifier.raw)' (key '\(key)') could not be type-checked — its static type was not resolved (custom type/typealias, complex expression, or a missing/stale Xcode index). Verify it matches '\(specifier.raw)' manually.",
                filePath: filePath,
                line: argument.line,
                column: argument.column
            )
        }

        if isCompatible(expected: expected, actual: actual, conversion: specifier.conversion) {
            return nil
        }

        let severity: LintSeverity = strictMismatch(specifier: specifier, actual: actual) ? .error : .warning

        let message = """
        Argument '\(argument.text)' is \(describe(type: actual)), but format specifier '\(specifier.raw)' for key '\(key)' expects \(describe(type: expected)).
        """

        return LintIssue(
            ruleID: "format_arg_type_mismatch",
            severity: severity,
            message: message,
            filePath: filePath,
            line: argument.line,
            column: argument.column
        )
    }

    private func isCompatible(
        expected: ResolvedType,
        actual: ResolvedType,
        conversion: Character
    ) -> Bool {
        if expected == actual { return true }
        if actual == .unknown || actual == .nilLiteral { return true }

        switch expected {
        case .object:
            // `%@` calls `description` through an Objective-C object pointer.
            // Swift `String` auto-bridges to `NSString`, and existing `NSObject`
            // subclasses pass through cleanly. Numerics and `Bool` do NOT
            // auto-bridge through CVarArg — they pass as raw bits and the
            // format string interprets them as object pointers, producing
            // garbage or a crash. Use `%d` / `%lld` / `%f` / `%@` with an
            // explicit `String(value)` instead.
            return actual == .string || actual == .object
        case .integer, .unsignedInteger:
            // %d / %u / %x — integer-shaped only.
            return actual == .integer || actual == .unsignedInteger
        case .character:
            // `%c` reads an int code point and prints its Unicode scalar. Accept only
            // integer-shaped arguments; `Bool` renders a control glyph and `String`/`Character`
            // are passed as pointers, so both are rejected (mirrors `SafeFormat.matches`).
            return actual == .integer || actual == .unsignedInteger
        case .floatingPoint:
            // %f / %g / %e — accept integer literals (auto-promote) and floating point.
            return actual == .floatingPoint || actual == .integer || actual == .unsignedInteger
        case .string:
            // %s expects a C string — Swift String passed via UnsafePointer; almost always wrong.
            return actual == .string
        case .boolean:
            return actual == .boolean
        case .nilLiteral, .unknown:
            return true
        }
    }

    /// Whether a mismatch is severe enough to be classed as an error rather than a warning.
    private func strictMismatch(specifier: FormatSpecifier, actual: ResolvedType) -> Bool {
        let expected = specifier.expectedType
        // Passing a string to a numeric specifier or a numeric to %s is almost always a runtime crash.
        if (expected == .integer || expected == .unsignedInteger || expected == .floatingPoint || expected == .character) && actual == .string {
            return true
        }
        if expected == .string && (actual == .integer || actual == .unsignedInteger || actual == .floatingPoint || actual == .boolean) {
            return true
        }
        if (expected == .integer || expected == .character) && actual == .floatingPoint {
            // %d / %c given a Double / CGFloat → drops to garbage on 64-bit systems.
            return true
        }
        // `%@` with a non-bridging Swift type (Int, Double, Bool) crashes or prints
        // garbage at runtime. Treat as a hard error so it surfaces as a build break.
        if expected == .object &&
            (actual == .integer || actual == .unsignedInteger || actual == .floatingPoint || actual == .boolean) {
            return true
        }
        return false
    }

    private func describe(type: ResolvedType) -> String {
        switch type {
        case .string: return "String"
        case .integer: return "Int"
        case .unsignedInteger: return "UInt"
        case .floatingPoint: return "Double/Float"
        case .boolean: return "Bool"
        case .nilLiteral: return "nil"
        case .character: return "Character code point (Int)"
        case .object: return "object (Any/NSObject)"
        case .unknown: return "unknown"
        }
    }
}
