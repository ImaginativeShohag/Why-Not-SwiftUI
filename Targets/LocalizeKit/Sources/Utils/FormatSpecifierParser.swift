import Foundation

// MARK: - Format Argument Type

/// The argument type a `printf`-style conversion expects.
///
/// Runtime counterpart of the CLI linter's `ResolvedType`, trimmed to the cases the
/// runtime can actually distinguish from a `CVarArg`'s dynamic type.
enum FormatArgumentType: Equatable {
    /// Signed integer (`%d`, `%i`).
    case integer
    /// Unsigned integer (`%u`, `%x`, `%o`).
    case unsignedInteger
    /// Floating point (`%f`, `%e`, `%g`, `%a`).
    case floatingPoint
    /// Objective-C object (`%@`).
    case object
    /// C string pointer (`%s`) — almost never satisfiable by a Swift value.
    case string
    /// Character code point (`%c`) — reads an `int`, printed as its Unicode scalar.
    case character
    /// Pointer or unclassifiable (`%p`).
    case unknown
}

// MARK: - Format Specifier

/// One parsed format specifier from a localized format string.
struct FormatSpecifier: Equatable {
    /// 1-based positional index from `%1$@` etc., or `nil` when not positional.
    let position: Int?

    /// Conversion character (e.g. `@`, `d`, `f`, `s`, `x`, `c`).
    let conversion: Character

    /// Length modifier (e.g. `l`, `ll`, `h`, `z`) — preserved for diagnostics.
    let lengthModifier: String

    /// Raw substring from the format string, for use in messages.
    let raw: String

    /// Single source of truth mapping each recognised conversion character to the
    /// argument type it expects. `recognizedConversions` and `expectedType` are both
    /// derived from this so the two can never drift apart.
    ///
    /// Uppercase `C` and `S` (Cocoa wide-char / wide-string) are intentionally
    /// excluded: they are essentially never used in Swift code, and treating
    /// them as specifiers would misclassify decorative percents like
    /// `"%Compliance"` or `"%Service"` as broken format strings.
    static let conversionTypes: [Character: FormatArgumentType] = [
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

    /// The expected `FormatArgumentType` for the argument at this position.
    var expectedType: FormatArgumentType {
        FormatSpecifier.conversionTypes[conversion] ?? .unknown
    }
}

// MARK: - Scan Result

/// A `%X` sequence that the parser saw inside a format string but could not classify
/// as a known conversion specifier (e.g. `%C`, `%S`).
///
/// When the call site has no `with:` arguments these are harmless (the default string
/// is returned verbatim), but they become a runtime crash risk the moment any argument
/// is interpolated through `String(format:)`.
struct AmbiguousPercent: Equatable {
    /// Raw substring captured from the format string, e.g. `"%C"`.
    let raw: String
}

/// Result of scanning a format string. Contains both recognised specifiers and
/// the positions where the parser dropped an unknown `%X` sequence.
struct FormatScanResult: Equatable {
    let specifiers: [FormatSpecifier]
    let ambiguousPercents: [AmbiguousPercent]
}

// MARK: - Parser

/// Parser for `printf`-style format strings used by `String(format:)`.
///
/// Ported from the LocalizeKit CLI linter so the runtime can pre-validate a resolved
/// format string against its `CVarArg` arguments before calling `String(format:)`,
/// which traps (`EXC_BAD_ACCESS`) on a specifier/argument type mismatch.
///
/// Recognizes:
///  - `%%` (literal percent — ignored)
///  - Positional specifiers like `%1$@`
///  - Flags `-+ #0`, width, precision (`.NN` or `.*`)
///  - Length modifiers `h`, `hh`, `l`, `ll`, `z`, `j`, `t`, `q`, `L`
///  - All standard conversion characters
enum FormatSpecifierParser {

    /// Scan a format string and return both recognised specifiers and the
    /// positions where an unknown `%X` sequence was dropped.
    ///
    /// The scan walks the string once, left-to-right, over its Unicode scalars (so a
    /// multi-byte character counts as a single unit). On each `%` it consumes an optional
    /// specifier in the exact order `printf` itself parses one, then classifies the result.
    /// The per-step breakdown lives in the `Step N` comments inside the loop.
    ///
    /// A truncated specifier (string ends mid-parse) breaks out of the loop and contributes
    /// nothing to the result.
    static func scan(_ format: String) -> FormatScanResult {
        var specifiers: [FormatSpecifier] = []
        var ambiguous: [AmbiguousPercent] = []
        let scalars = Array(format.unicodeScalars)
        var i = 0

        while i < scalars.count {
            // Step 1: Skip any scalar that does not open a specifier; on `%`, anchor `start`.
            guard scalars[i] == "%" else {
                i += 1
                continue
            }

            // Start of a possible specifier.
            let start = i
            i += 1
            guard i < scalars.count else { break }

            // Step 2: `%%` literal — an escaped percent contributes no specifier.
            if scalars[i] == "%" {
                i += 1
                continue
            }

            // Step 3: Positional prefix — digits immediately followed by '$' (e.g. `%1$@`) set
            // the 1-based `position`; otherwise the cursor rewinds so those digits become width.
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

            // Step 4: Flags. We deliberately drop the space flag because `% d` / `% o` are
            // vanishingly rare in Swift and supporting them misclassifies decorative
            // strings like `"5% off"` as malformed format specifiers.
            while i < scalars.count, "-+#0".unicodeScalars.contains(scalars[i]) {
                i += 1
            }

            // Step 5: Width — a `*` (dynamic) or a digit run.
            if i < scalars.count, scalars[i] == "*" {
                i += 1
            } else {
                while i < scalars.count, scalars[i].isASCIIDigit {
                    i += 1
                }
            }

            // Step 6: Precision — a `.` followed by a `*` (dynamic) or a digit run.
            if i < scalars.count, scalars[i] == "." {
                i += 1
                if i < scalars.count, scalars[i] == "*" {
                    i += 1
                } else {
                    while i < scalars.count, scalars[i].isASCIIDigit {
                        i += 1
                    }
                }
            }

            // Step 7: Length modifier — `h`/`hh`, `l`/`ll`, or a single `j t z q L` (kept for diagnostics).
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

            // Step 8: Conversion character — the terminating letter; `raw` is sliced as `start..<i`.
            guard i < scalars.count else { break }
            let conversionScalar = scalars[i]
            let conversion = Character(conversionScalar)
            i += 1

            let raw = String(String.UnicodeScalarView(scalars[start..<i]))

            // Step 9: Classify. Drop speculatively-parsed specifiers whose conversion character
            // is not a recognised format conversion. This makes `"%Compliance"` resolve to zero
            // specifiers (decorative `%`) instead of being misread as `%C` + literal text.
            guard FormatSpecifier.recognizedConversions.contains(conversion) else {
                ambiguous.append(AmbiguousPercent(raw: raw))
                continue
            }

            specifiers.append(
                FormatSpecifier(
                    position: position,
                    conversion: conversion,
                    lengthModifier: lengthModifier,
                    raw: raw
                )
            )
        }

        return FormatScanResult(specifiers: specifiers, ambiguousPercents: ambiguous)
    }
}

private extension Unicode.Scalar {
    var isASCIIDigit: Bool {
        self >= "0" && self <= "9"
    }
}
