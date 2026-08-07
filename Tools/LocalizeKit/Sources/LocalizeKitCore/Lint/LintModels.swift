//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

// MARK: - Lint Issue

public enum LintSeverity: String {
    case error
    case warning
}

public struct LintIssue {
    public let ruleID: String
    public let severity: LintSeverity
    public let message: String
    public let filePath: String
    public let line: Int
    public let column: Int

    public init(
        ruleID: String,
        severity: LintSeverity,
        message: String,
        filePath: String,
        line: Int,
        column: Int
    ) {
        self.ruleID = ruleID
        self.severity = severity
        self.message = message
        self.filePath = filePath
        self.line = line
        self.column = column
    }
}

// MARK: - Resolved Argument Types

/// The static type resolved for a `with:` / `count:` argument.
///
/// Literal arguments are classified directly from SwiftSyntax (`LiteralTypeResolver`);
/// every other argument is resolved authoritatively from Xcode's IndexStoreDB
/// (`SemanticTypeResolver`). `.unknown` means neither backend could classify it.
public enum ResolvedType: Equatable {
    case string
    case integer
    case unsignedInteger
    case floatingPoint
    case boolean
    case nilLiteral
    case character    // `%c` — an integer code point printed as its Unicode scalar. Only ever an
                      // *expected* (specifier) type; the literal/semantic resolvers never produce it.
    case object       // Heterogeneous reference type / explicit Any / NSObject
    case unknown      // Could not be classified by either backend
}

/// A `with:` argument captured from a `.localize` / `Text.localized` call site.
public struct LintArgument {
    public let label: String?
    public let text: String
    public let resolvedType: ResolvedType
    public let line: Int
    public let column: Int

    /// 1-based line of the rightmost member identifier to look up, or `nil`. May
    /// differ from `line` for multi-line arguments (a ternary whose branch is on a
    /// later line, or a member chain broken across lines).
    public let memberLookupLine: Int?

    /// 1-based UTF-8 column of the rightmost member identifier in this argument,
    /// or `nil` when there is no member to look up (literals, complex expressions).
    /// Used by the semantic resolver to query IndexStoreDB at the exact symbol
    /// position — for `item.getItemQty()` this points at `getItemQty`, not at
    /// the start of `item`.
    public let memberLookupColumn: Int?

    public init(
        label: String?,
        text: String,
        resolvedType: ResolvedType,
        line: Int,
        column: Int,
        memberLookupLine: Int? = nil,
        memberLookupColumn: Int? = nil
    ) {
        self.label = label
        self.text = text
        self.resolvedType = resolvedType
        self.line = line
        self.column = column
        self.memberLookupLine = memberLookupLine
        self.memberLookupColumn = memberLookupColumn
    }
}

/// The `count:` argument passed to plural overloads (when present).
public struct LintCountArgument {
    public let text: String
    public let resolvedType: ResolvedType
    public let line: Int
    public let column: Int
    public let memberLookupLine: Int?
    public let memberLookupColumn: Int?

    public init(
        text: String,
        resolvedType: ResolvedType,
        line: Int,
        column: Int,
        memberLookupLine: Int? = nil,
        memberLookupColumn: Int? = nil
    ) {
        self.text = text
        self.resolvedType = resolvedType
        self.line = line
        self.column = column
        self.memberLookupLine = memberLookupLine
        self.memberLookupColumn = memberLookupColumn
    }
}
