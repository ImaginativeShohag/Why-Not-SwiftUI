import CoreGraphics
import Foundation

// MARK: - Safe Format

/// Crash-safe wrapper around `String(format:arguments:)`.
///
/// `String(format:)` reads its arguments from a `va_list` based purely on the conversion
/// characters in the format string. When a specifier and the supplied `CVarArg` disagree —
/// e.g. `"%d"` paired with a `Double`, or `"%@"` paired with an `Int` — the reader pulls the
/// wrong number of bytes off the stack and the process traps with `EXC_BAD_ACCESS`. This is a
/// memory-level fault that `try`/`catch` cannot rescue, so the only safe option is to validate
/// *before* calling `String(format:)`.
///
/// `SafeFormat.string(_:arguments:key:module:)` parses the (already-resolved/translated) `format` string with
/// `FormatSpecifierParser`, checks every referenced argument's runtime type against the
/// specifier that consumes it, and only forwards to `String(format:)` when the call is provably
/// safe. On any mismatch it logs (DEBUG only) and returns the unformatted `format` string
/// verbatim — the user sees imperfect copy (literal `%d`/`%@` tokens) instead of a crash.
enum SafeFormat {

    /// Format `arguments` into `format`, falling back to the raw `format` string on any
    /// specifier/argument mismatch rather than crashing.
    ///
    /// - Parameters:
    ///   - format: The resolved format string (may come from a server-pushed translation).
    ///   - arguments: The `CVarArg` values supplied at the call site.
    ///   - key: Translation key, for diagnostics.
    ///   - module: Module name, for diagnostics. Autoclosed so it is only resolved on the
    ///     DEBUG-only fallback path — never computed on the common success path.
    /// - Returns: The formatted string, or `format` verbatim when interpolation would be unsafe.
    static func string(
        _ format: String,
        arguments: [CVarArg],
        key: String,
        module: @autoclosure () -> String
    ) -> String {
        // With no arguments there is nothing to interpolate, but the format may still contain
        // an escaped `%%` that must collapse to `%`. Only a format with no `%` at all is
        // guaranteed to need no processing — return it verbatim as a fast path. Otherwise fall
        // through: a `%%`-only format is collapsed by `String(format:)` below, and a format that
        // references an argument slot bails safely on the argument-count check.
        if arguments.isEmpty && !format.contains("%") { return format }

        let scan = FormatSpecifierParser.scan(format)

        // An unescaped `%X` the parser could not classify (e.g. `%C`, a bare `%`) becomes a
        // hazard the moment any argument is interpolated — bail to the verbatim string.
        guard scan.ambiguousPercents.isEmpty else {
            log(
                "Unclassifiable percent sequence(s) \(scan.ambiguousPercents.map(\.raw)) in format "
                    + "for key '\(key)' in module '\(module())'. Returning unformatted string.",
                format: format
            )
            return format
        }

        // Dynamic width/precision (`%*d`, `%.*f`) consumes an extra integer argument that the
        // parser does not surface as its own specifier, so argument counting would be wrong.
        // These never appear in localization strings — treat as unsafe and bail.
        if scan.specifiers.contains(where: { $0.raw.contains("*") }) {
            log(
                "Dynamic width/precision is unsupported in format for key '\(key)' in module "
                    + "'\(module())'. Returning unformatted string.",
                format: format
            )
            return format
        }

        // Map each argument slot to the type its specifier expects.
        guard let expectedByIndex = expectedTypesByArgumentIndex(scan.specifiers) else {
            log(
                "Conflicting or mixed positional specifiers in format for key '\(key)' in module "
                    + "'\(module())'. Returning unformatted string.",
                format: format
            )
            return format
        }

        // The format must not reference an argument slot the caller did not supply, otherwise
        // `String(format:)` reads past the end of the argument list and crashes.
        let requiredArgumentCount = (expectedByIndex.keys.max().map { $0 + 1 }) ?? 0
        guard arguments.count >= requiredArgumentCount else {
            log(
                "Format for key '\(key)' in module '\(module())' needs \(requiredArgumentCount) "
                    + "argument(s) but \(arguments.count) supplied. Returning unformatted string.",
                format: format
            )
            return format
        }

        // Verify every referenced argument's runtime type matches its specifier.
        for (index, expected) in expectedByIndex {
            let argument = arguments[index]
            guard matches(argument: argument, expected: expected) else {
                log(
                    "Argument #\(index + 1) (\(type(of: argument))) does not match specifier "
                        + "'\(expected)' in format for key '\(key)' in module '\(module())'. "
                        + "Returning unformatted string.",
                    format: format
                )
                return format
            }
        }

        return String(format: format, arguments: arguments)
    }

    // MARK: - Private Helpers

    /// Build a map of `argument index → expected type` from the parsed specifiers.
    ///
    /// Returns `nil` when the format mixes positional and non-positional specifiers (undefined
    /// in `printf`) or when the same slot is referenced with conflicting types — both unsafe.
    private static func expectedTypesByArgumentIndex(
        _ specifiers: [FormatSpecifier]
    ) -> [Int: FormatArgumentType]? {
        var result: [Int: FormatArgumentType] = [:]
        var sequentialIndex = 0
        var sawPositional = false
        var sawSequential = false

        for specifier in specifiers {
            let index: Int
            if let position = specifier.position {
                sawPositional = true
                guard position >= 1 else { return nil }
                index = position - 1
            } else {
                sawSequential = true
                index = sequentialIndex
                sequentialIndex += 1
            }

            // A positional format may reference the same slot more than once (e.g.
            // `%1$d and %1$d`), which is legal — but only when every reference agrees on the
            // type. The single argument at that slot has one runtime type; if two specifiers
            // disagree (`%1$d` vs `%1$@`), one is guaranteed to misread it and trap. Bail here
            // rather than let the last write win and silently hide the conflict from the
            // per-index type check below.
            if let existing = result[index], existing != specifier.expectedType {
                return nil
            }
            result[index] = specifier.expectedType
        }

        // Mixed positional + sequential specifiers are undefined behaviour.
        if sawPositional && sawSequential { return nil }

        return result
    }

    /// Whether `argument`'s runtime type is safe to feed to a specifier expecting `expected`.
    ///
    /// Conservative by design: when in doubt it returns `false` so the caller falls back to the
    /// verbatim string rather than risk a crash.
    private static func matches(argument: CVarArg, expected: FormatArgumentType) -> Bool {
        switch expected {
        case .integer, .unsignedInteger:
            // `%d`/`%u`/`%x` read an integer. Any fixed-width integer is safe; `Bool` bridges to
            // an int. Floating-point and object arguments are not.
            switch argument {
            case is Int, is Int8, is Int16, is Int32, is Int64,
                 is UInt, is UInt8, is UInt16, is UInt32, is UInt64,
                 is Bool:
                return true
            default:
                return false
            }

        case .floatingPoint:
            // `%f`/`%g` read a double. Swift promotes `Float`/`CGFloat` to `Double` in varargs.
            return argument is Double || argument is Float || argument is CGFloat

        case .character:
            // `%c` reads an `int` code point and prints its Unicode scalar. Accept only
            // fixed-width integers. `Bool` is rejected (it would render an unprintable control
            // glyph), and `Character`/`String` are rejected because they are encoded into the
            // `va_list` as object pointers — `%c` would misread the pointer as an int. Both cases
            // fall back to the verbatim `%c` rather than emitting garbage.
            switch argument {
            case is Int, is Int8, is Int16, is Int32, is Int64,
                 is UInt, is UInt8, is UInt16, is UInt32, is UInt64:
                return true
            default:
                return false
            }

        case .object:
            // `%@` reads an object pointer. Swift `String` bridges to `NSString`, and genuine
            // reference types (Cocoa objects) are safe. Value types such as `Int`/`Double` must
            // be rejected here: although they bridge to `NSNumber` (so `is NSObject` is `true`),
            // they are encoded into the `va_list` as scalars, so `%@` would dereference the raw
            // value as a pointer.
            if argument is String || argument is NSString { return true }
            return type(of: argument) is AnyClass

        case .string:
            // `%s` reads a C string pointer. No ordinary Swift value satisfies this safely, so
            // always fall back rather than risk reading a bad pointer.
            return false

        case .unknown:
            // `%p` (pointer) and anything we could not classify — accept and let `String(format:)`
            // print it; these do not type-mismatch in a crashing way.
            return true
        }
    }

    /// DEBUG-only diagnostic. Release builds degrade silently to the verbatim string.
    ///
    /// Wrapped in `#if DEBUG` so the (relatively expensive) diagnostic string — including
    /// `type(of:)` reflection at the call site — is never constructed in release builds. The
    /// fallback path is an error path, so this keeps it cheap where it matters.
    private static func log(_ message: @autoclosure () -> String, format: String) {
        #if DEBUG
        LocalizeKitLogger.e("\(message()) Format: \"\(format)\"")
        #endif
    }
}
