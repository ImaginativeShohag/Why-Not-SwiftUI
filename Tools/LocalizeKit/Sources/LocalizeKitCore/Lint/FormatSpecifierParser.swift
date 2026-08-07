//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// One parsed format specifier from a localized format string.
public struct FormatSpecifier: Equatable {
    /// 1-based positional index from `%1$@` etc., or `nil` when not positional.
    public let position: Int?

    /// Conversion character (e.g. `@`, `d`, `f`, `s`, `x`, `c`).
    public let conversion: Character

    /// Length modifier (e.g. `l`, `ll`, `h`, `z`) — preserved for diagnostics.
    public let lengthModifier: String

    /// `true` when the width is given dynamically as `*` (e.g. `%*d`). At runtime
    /// this consumes an extra leading `Int` argument before the value, so the
    /// linter cannot reliably count or position-match arguments for such formats.
    public let dynamicWidth: Bool

    /// `true` when the precision is given dynamically as `.*` (e.g. `%.*f`). Like
    /// `dynamicWidth`, this consumes an extra leading `Int` argument at runtime.
    public let dynamicPrecision: Bool

    /// Raw substring from the format string, for use in messages.
    public let raw: String

    /// Single source of truth mapping each recognised conversion character to the
    /// argument type it expects. `recognizedConversions` and `expectedType` are both
    /// derived from this so the two can never drift apart.
    ///
    /// Uppercase `C` and `S` (Cocoa wide-char / wide-string) are intentionally
    /// excluded: they are essentially never used in Swift code, and treating
    /// them as specifiers would misclassify decorative percents like
    /// `"%Compliance"` or `"%Service"` as broken format strings.
    static let conversionTypes: [Character: ResolvedType] = [
        "@": .object,                                                    // Object (Cocoa)
        "d": .integer, "i": .integer, "D": .integer,                     // Signed integer
        "u": .unsignedInteger, "U": .unsignedInteger,                    // Unsigned
        "x": .unsignedInteger, "X": .unsignedInteger,                    // Hex
        "o": .unsignedInteger, "O": .unsignedInteger,                    // Octal
        "f": .floatingPoint, "F": .floatingPoint,
        "e": .floatingPoint, "E": .floatingPoint,
        "g": .floatingPoint, "G": .floatingPoint,
        "a": .floatingPoint, "A": .floatingPoint,                        // Floating point
        "s": .string,                                                    // C string (lowercase only)
        "c": .character,                                                 // Char (lowercase only)
        "p": .unknown                                                    // Pointer
    ]

    /// Conversion characters this parser recognises as real format specifiers.
    static var recognizedConversions: Set<Character> { Set(conversionTypes.keys) }

    /// The expected `ResolvedType` for the argument at this position.
    public var expectedType: ResolvedType {
        FormatSpecifier.conversionTypes[conversion] ?? .unknown
    }
}

/// A `%X` sequence that the parser saw inside a format string but could not classify
/// as a known conversion specifier. Examples: `%C`, `%S`, `%Compliance`'s leading
/// `%C`, or any other letter not on the recognised whitelist.
///
/// When the call site has no `with:` arguments these are harmless (the default
/// string is returned verbatim), but they become a runtime crash risk the moment
/// any argument is interpolated through `String(format:)`.
public struct AmbiguousPercent: Equatable {
    /// Raw substring captured from the format string, e.g. `"%C"`.
    public let raw: String
}

/// Result of scanning a format string. Contains both recognised specifiers and
/// the positions where the parser dropped an unknown `%X` sequence.
public struct FormatScanResult: Equatable {
    public let specifiers: [FormatSpecifier]
    public let ambiguousPercents: [AmbiguousPercent]
}

/// Parser for `printf`-style format strings used by `String(format:)`.
///
/// Recognizes:
///  - `%%` (literal percent — ignored)
///  - Positional specifiers like `%1$@`
///  - Flags `-+ #0`, width, precision (`.NN` or `.*`)
///  - Length modifiers `h`, `hh`, `l`, `ll`, `z`, `j`, `t`, `q`, `L`
///  - All standard conversion characters
public enum FormatSpecifierParser {

    /// Backward-compatible API: returns just the recognised specifiers.
    public static func parse(_ format: String) -> [FormatSpecifier] {
        scan(format).specifiers
    }

    /// Scan a format string and return both recognised specifiers and the
    /// positions where an unknown `%X` sequence was dropped.
    public static func scan(_ format: String) -> FormatScanResult {
        var specifiers: [FormatSpecifier] = []
        var ambiguous: [AmbiguousPercent] = []
        let scalars = Array(format.unicodeScalars)
        var i = 0

        while i < scalars.count {
            guard scalars[i] == "%" else {
                i += 1
                continue
            }

            // Start of a possible specifier.
            let start = i
            i += 1
            guard i < scalars.count else { break }

            // %% literal
            if scalars[i] == "%" {
                i += 1
                continue
            }

            // Positional: digits followed by '$'
            var position: Int? = nil
            let positionStart = i
            while i < scalars.count, scalars[i].isASCIIDigit {
                i += 1
            }
            if i < scalars.count, scalars[i] == "$", i > positionStart {
                let digits = String(String.UnicodeScalarView(scalars[positionStart..<i]))
                position = Int(digits)
                i += 1 // consume '$'
            } else {
                // Not positional — rewind so digits are treated as width.
                i = positionStart
            }

            // Flags. Note: the standard printf flag set is `-+ #0` (space included
            // for sign-padding). We deliberately drop the space flag because
            // `% d` / `% o` are vanishingly rare in Swift and supporting them
            // misclassifies decorative strings like `"5% off"` as malformed
            // format specifiers.
            while i < scalars.count, "-+#0".unicodeScalars.contains(scalars[i]) {
                i += 1
            }

            // Width
            var dynamicWidth = false
            if i < scalars.count, scalars[i] == "*" {
                dynamicWidth = true
                i += 1
            } else {
                while i < scalars.count, scalars[i].isASCIIDigit {
                    i += 1
                }
            }

            // Precision
            var dynamicPrecision = false
            if i < scalars.count, scalars[i] == "." {
                i += 1
                if i < scalars.count, scalars[i] == "*" {
                    dynamicPrecision = true
                    i += 1
                } else {
                    while i < scalars.count, scalars[i].isASCIIDigit {
                        i += 1
                    }
                }
            }

            // Length modifier
            var lengthModifier = ""
            if i < scalars.count {
                let c = scalars[i]
                switch c {
                case "h":
                    lengthModifier.append(Character(c))
                    i += 1
                    if i < scalars.count, scalars[i] == "h" {
                        lengthModifier.append("h")
                        i += 1
                    }
                case "l":
                    lengthModifier.append(Character(c))
                    i += 1
                    if i < scalars.count, scalars[i] == "l" {
                        lengthModifier.append("l")
                        i += 1
                    }
                case "j", "t", "z", "q", "L":
                    lengthModifier.append(Character(c))
                    i += 1
                default:
                    break
                }
            }

            // Conversion character
            guard i < scalars.count else { break }
            let conversionScalar = scalars[i]
            let conversion = Character(conversionScalar)
            i += 1

            let raw = String(String.UnicodeScalarView(scalars[start..<i]))

            // Drop speculatively-parsed specifiers whose conversion character is not a
            // recognised format conversion. This makes `"%Compliance"` resolve to zero
            // specifiers (decorative `%`) instead of being misread as `%C` + literal text.
            // We still record the position so the linter can warn when the call site
            // also passes `with:` arguments — in that case the format will be passed
            // through `String(format:)` and the unescaped `%` becomes a runtime hazard.
            guard FormatSpecifier.recognizedConversions.contains(conversion) else {
                ambiguous.append(AmbiguousPercent(raw: raw))
                continue
            }

            specifiers.append(
                FormatSpecifier(
                    position: position,
                    conversion: conversion,
                    lengthModifier: lengthModifier,
                    dynamicWidth: dynamicWidth,
                    dynamicPrecision: dynamicPrecision,
                    raw: raw
                )
            )
        }

        return FormatScanResult(specifiers: specifiers, ambiguousPercents: ambiguous)
    }
}

private extension Unicode.Scalar {
    var isASCIIDigit: Bool {
        return self >= "0" && self <= "9"
    }
}
