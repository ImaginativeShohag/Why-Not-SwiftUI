import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(CustomMacros)
import URLMacroMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
]
#endif

final class URLMacroTests: XCTestCase {
    func testMacro() throws {
        #if canImport(CustomMacros)
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(CustomMacros)
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testValidURL() {
        assertMacroExpansion(
            #"""
            #URL("https://www.avanderlee.com")
            """#,
            expandedSource: #"""
            URL(string: "https://www.avanderlee.com")!
            """#,
            macros: testMacros
        )
    }
    
    func testURLStringLiteralError() {
        assertMacroExpansion(
            #"""
            #URL("https://www.avanderlee.com/\(Int.random(in: 1...5))")
            """#,
            expandedSource: #"""
            #URL("https://www.avanderlee.com/\(Int.random(in: 1...5))")
            """#,
            diagnostics: [
                DiagnosticSpec(message: "#URL requires a static string literal", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
}
