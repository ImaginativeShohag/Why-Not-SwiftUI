//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftSyntax

/// Minimal type classifier for *literal* `with:` / `count:` arguments.
///
/// The authoritative type backend is `SemanticTypeResolver`, which reads Xcode's
/// IndexStoreDB. IndexStoreDB only records *symbol references* (variables, method
/// calls, properties), so it cannot classify literal arguments like `with: 42` or
/// `with: "x"`. This helper fills that single gap: it classifies literals and
/// returns `.unknown` for everything else, leaving all non-literal resolution to
/// the semantic backend.
enum LiteralTypeResolver {

    /// Classify `expression` when it is a literal (after peeling parentheses and a
    /// leading sign), otherwise return `.unknown`.
    static func resolve(_ expression: ExprSyntax) -> ResolvedType {
        let unwrapped = unwrap(expression)

        if unwrapped.is(StringLiteralExprSyntax.self) { return .string }
        if unwrapped.is(IntegerLiteralExprSyntax.self) { return .integer }
        if unwrapped.is(FloatLiteralExprSyntax.self) { return .floatingPoint }
        if unwrapped.is(BooleanLiteralExprSyntax.self) { return .boolean }
        if unwrapped.is(NilLiteralExprSyntax.self) { return .nilLiteral }
        if unwrapped.is(ArrayExprSyntax.self) || unwrapped.is(DictionaryExprSyntax.self) {
            return .object
        }

        return .unknown
    }

    /// Peel `(literal)` parentheses and a leading unary sign so `(42)` and `-5`
    /// still resolve to their literal kind.
    private static func unwrap(_ expression: ExprSyntax) -> ExprSyntax {
        if let tuple = expression.as(TupleExprSyntax.self),
           tuple.elements.count == 1,
           let inner = tuple.elements.first {
            return unwrap(inner.expression)
        }
        if let prefix = expression.as(PrefixOperatorExprSyntax.self) {
            return unwrap(prefix.expression)
        }
        return expression
    }
}
