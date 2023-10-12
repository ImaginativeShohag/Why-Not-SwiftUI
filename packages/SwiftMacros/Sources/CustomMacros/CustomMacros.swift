import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

// MARK: -

/// Source: https://www.avanderlee.com/swift/macros/

public struct URLMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        print(node.argumentList.map { $0.expression })

        /// ```
        /// [
        ///     StringLiteralExprSyntax
        ///     ├─openQuote: stringQuote
        ///     ├─segments: StringLiteralSegmentsSyntax
        ///     │ ╰─[0]: StringSegmentSyntax
        ///     │   ╰─content: stringSegment("https://www.avanderlee.com")
        ///     ╰─closeQuote: stringQuote
        /// ]
        /// ```

        guard
            /// 1. Grab the first (and only) Macro argument.
            let argument = node.argumentList.first?.expression,
            /// 2. Ensure the argument contains of a single String literal segment.
            let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
            segments.count == 1,
            /// 3. Grab the actual String literal segment.
            case .stringSegment(let literalSegment)? = segments.first
        else {
            throw URLMacroError.requiresStaticStringLiteral
        }

        /// 4. Validate whether the String literal matches a valid URL structure.
        guard let _ = URL(string: literalSegment.content.text) else {
            throw URLMacroError.malformedURL(urlString: "\(argument)")
        }

        return "URL(string: \(argument))!"
    }
}

enum URLMacroError: Error, CustomStringConvertible {
    case requiresStaticStringLiteral
    case malformedURL(urlString: String)

    var description: String {
        switch self {
        case .requiresStaticStringLiteral:
            return "#URL requires a static string literal"
        case .malformedURL(let urlString):
            return "The input URL is malformed: \(urlString)"
        }
    }
}

// MARK: -

/// Source: https://betterprogramming.pub/use-swift-macros-to-initialize-a-structure-516728c5fb49

public struct StructInitMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw StructInitError.onlyApplicableToStruct
        }

        let members = structDecl.memberBlock.members
        let variableDecl = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let variablesName = variableDecl.compactMap { $0.bindings.first?.pattern }
        let variablesType = variableDecl.compactMap { $0.bindings.first?.typeAnnotation?.type }

        let initializer = try InitializerDeclSyntax(StructInitMacro.generateInitialCode(variablesName: variablesName, variablesType: variablesType)) {
            for name in variablesName {
                ExprSyntax("self.\(name) = \(name)")
            }
        }

        return [DeclSyntax(initializer)]
    }

    public static func generateInitialCode(variablesName: [PatternSyntax],
                                           variablesType: [TypeSyntax]) -> SyntaxNodeString
    {
        var initialCode = "init("
        for (name, type) in zip(variablesName, variablesType) {
            initialCode += "\(name): \(type), "
        }
        initialCode = String(initialCode.dropLast(2))
        initialCode += ")"
        return SyntaxNodeString(stringLiteral: initialCode)
    }
}

enum StructInitError: CustomStringConvertible, Error {
    case onlyApplicableToStruct

    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "@StructInit can only be applied to a structure"
        }
    }
}

// MARK: -

@main
struct URLMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        URLMacro.self,
        StructInitMacro.self,
    ]
}
