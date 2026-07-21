@testable import LocalizeKit
import CoreGraphics
import XCTest

/// Unit tests for the crash-safe `SafeFormat` interpolation layer and its backing
/// `FormatSpecifierParser`.
///
/// `String(format:)` traps with `EXC_BAD_ACCESS` when a conversion specifier and its `CVarArg`
/// disagree (e.g. `%d` with a `Double`, or `%@` with an `Int`). `SafeFormat` validates the
/// arguments against the parsed specifiers first and falls back to the verbatim format string on
/// any mismatch. The mere fact that these tests run to completion (instead of crashing the test
/// process) is itself part of what they verify.
final class SafeFormatTests: XCTestCase {
    // MARK: - Constants

    private let key = "test_key"
    private let module = "Store"

    private func format(_ format: String, _ arguments: [CVarArg]) -> String {
        SafeFormat.string(format, arguments: arguments, key: key, module: module)
    }

    /// Assert `SafeFormat` produced exactly what native `String(format:)` produces — i.e. the
    /// argument was accepted and forwarded, not rejected into the verbatim fallback. Use only for
    /// combinations known to be non-crashing (calling native `String(format:)` on a genuine
    /// mismatch would itself trap), or where the output is non-deterministic (e.g. `%p` addresses).
    private func assertMatchesNative(
        _ format: String,
        _ arguments: [CVarArg],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            self.format(format, arguments),
            String(format: format, arguments: arguments),
            file: file,
            line: line
        )
    }

    // MARK: - Happy Path (output must equal native String(format:))

    func testNoArguments_ReturnsFormatVerbatim() {
        XCTAssertEqual(format("Plain text", []), "Plain text")
    }

    func testObjectSpecifier_WithString() {
        XCTAssertEqual(format("Hello, %@!", ["World"]), "Hello, World!")
    }

    func testIntegerSpecifier_WithInt() {
        XCTAssertEqual(format("%d items", [5]), "5 items")
    }

    func testFloatSpecifier_WithDouble() {
        XCTAssertEqual(format("Total: %.2f", [9.5]), "Total: 9.50")
    }

    func testFloatSpecifier_WithFloatAndCGFloat() {
        XCTAssertEqual(format("%.1f", [Float(2.5)]), "2.5")
        XCTAssertEqual(format("%.1f", [CGFloat(3.5)]), "3.5")
    }

    func testCharacterSpecifier_WithIntCodePoint() {
        // %c reads an int code point and prints its Unicode scalar (65 -> "A").
        XCTAssertEqual(format("Grade %c", [65]), "Grade A")
    }

    func testMultipleArguments_MatchingTypes() {
        XCTAssertEqual(format("Order #%@ has %d items", ["A1", 3]), "Order #A1 has 3 items")
    }

    func testPositionalSpecifiers_Reordered() {
        XCTAssertEqual(format("%2$@ before %1$@", ["second", "first"]), "first before second")
    }

    func testExtraArguments_AreIgnoredNotCrashed() {
        // More args than specifiers is safe for String(format:) — extras are ignored.
        XCTAssertEqual(format("%d", [7, 8, 9]), "7")
    }

    func testLiteralPercent_IsNotASpecifier() {
        XCTAssertEqual(format("50%% off %@", ["today"]), "50% off today")
    }

    func testLiteralPercent_WithNoArguments_IsCollapsed() {
        // Escaped `%%` must collapse to `%` even when no interpolation args are supplied.
        // Regression: the empty-args fast path used to return the format verbatim, leaving
        // the literal `%%` in the output.
        XCTAssertEqual(format("100%% off", []), "100% off")
        XCTAssertEqual(format("%%", []), "%")
    }

    // MARK: - Type Coverage: Integer / Unsigned Accept Paths

    func testIntegerSpecifier_AcceptsBool() {
        // `matches` treats `Bool` as an integer (it bridges to an int). This is the accept-side
        // counterpart to `testCharacterSpecifier_WithBool_FallsBack`, where `%c` rejects `Bool`.
        XCTAssertEqual(format("%d", [true]), "1")
        XCTAssertEqual(format("%d", [false]), "0")
    }

    func testIntegerSpecifier_AcceptsAllSignedFixedWidthTypes() {
        XCTAssertEqual(format("%d", [Int(1)]), "1")
        XCTAssertEqual(format("%d", [Int8(2)]), "2")
        XCTAssertEqual(format("%d", [Int16(3)]), "3")
        XCTAssertEqual(format("%d", [Int32(4)]), "4")
        XCTAssertEqual(format("%d", [Int64(5)]), "5")
    }

    func testIntegerSpecifier_AcceptsAllUnsignedFixedWidthTypes() {
        XCTAssertEqual(format("%d", [UInt(6)]), "6")
        XCTAssertEqual(format("%d", [UInt8(7)]), "7")
        XCTAssertEqual(format("%d", [UInt16(8)]), "8")
        XCTAssertEqual(format("%d", [UInt32(9)]), "9")
        XCTAssertEqual(format("%d", [UInt64(10)]), "10")
    }

    func testUnsignedIntegerSpecifier_AcceptsInteger() {
        XCTAssertEqual(format("%u apples", [5]), "5 apples")
    }

    func testUnsignedHexAndOctalSpecifiers_AcceptInteger() {
        // `%x`/`%X`/`%o` all resolve to `.unsignedInteger` and accept fixed-width integers.
        XCTAssertEqual(format("%x", [255]), "ff")
        XCTAssertEqual(format("%X", [255]), "FF")
        XCTAssertEqual(format("%o", [8]), "10")
    }

    // MARK: - Type Coverage: Character Accept Paths

    func testCharacterSpecifier_AcceptsFixedWidthIntegers() {
        // `%c` reads any fixed-width integer as an `int` code point and prints its Unicode scalar.
        XCTAssertEqual(format("%c", [65]), "A")
        XCTAssertEqual(format("%c", [Int8(66)]), "B")
        XCTAssertEqual(format("%c", [UInt8(67)]), "C")
        XCTAssertEqual(format("%c", [UInt(68)]), "D")
    }

    // MARK: - Type Coverage: Object Accept Paths

    func testObjectSpecifier_AcceptsNSString() {
        XCTAssertEqual(format("Hello, %@!", [NSString(string: "hi")]), "Hello, hi!")
    }

    func testObjectSpecifier_AcceptsReferenceType() {
        // A genuine class instance is accepted via the `type(of:) is AnyClass` branch, distinct
        // from value types (Int/Double) which bridge to NSNumber and must be rejected — see the
        // matching mismatch tests below.
        XCTAssertEqual(format("Value: %@", [DescribedObject()]), "Value: custom-object")
    }

    // MARK: - Type Coverage: Pointer (unknown) Accept Path

    func testPointerSpecifier_IsAccepted() {
        // `%p` maps to `.unknown`, which is always accepted and forwarded to `String(format:)`
        // (it cannot mismatch in a crashing way). Output is an address, so compare to native.
        assertMatchesNative("%p", [255])
    }

    // MARK: - Mismatch (must fall back to verbatim format, never crash)

    func testIntegerSpecifier_WithDouble_FallsBack() {
        // The original crash: %d paired with a floating-point value.
        XCTAssertEqual(format("%d items", [3.7]), "%d items")
    }

    func testIntegerSpecifier_WithString_FallsBack() {
        XCTAssertEqual(format("%d items", ["oops"]), "%d items")
    }

    func testObjectSpecifier_WithInt_FallsBack() {
        // %@ with a raw Int would dereference it as a pointer.
        XCTAssertEqual(format("Hello, %@!", [5]), "Hello, %@!")
    }

    func testFloatSpecifier_WithInt_FallsBack() {
        XCTAssertEqual(format("Total: %.2f", [9]), "Total: %.2f")
    }

    func testTooFewArguments_FallsBack() {
        XCTAssertEqual(format("%@ and %@", ["only one"]), "%@ and %@")
    }

    func testSpecifierWithNoArguments_FallsBack() {
        // A format that references an argument slot but supplies none must degrade to verbatim,
        // not read past the empty argument list. Guards the narrowed empty-args fast path.
        XCTAssertEqual(format("%d items", []), "%d items")
        XCTAssertEqual(format("Hello, %@!", []), "Hello, %@!")
    }

    func testMismatchedTypeAmongMany_FallsBack() {
        // Second argument is wrong (Double for %d) — whole call degrades safely.
        XCTAssertEqual(format("Order #%@ has %d items", ["A1", 3.0]), "Order #%@ has %d items")
    }

    func testCStringSpecifier_AlwaysFallsBack() {
        // %s expects a C string pointer; a Swift String is not safe to pass.
        XCTAssertEqual(format("Name: %s", ["Shohag"]), "Name: %s")
    }

    func testCharacterSpecifier_WithBool_FallsBack() {
        // %c + Bool would render an unprintable control glyph — degrade to verbatim instead.
        XCTAssertEqual(format("%c", [true]), "%c")
    }

    func testCharacterSpecifier_WithString_FallsBack() {
        // A Character/String is encoded as an object pointer; %c would misread it as an int.
        XCTAssertEqual(format("Grade %c", ["A"]), "Grade %c")
    }

    func testAmbiguousPercent_WithArguments_FallsBack() {
        // %C is not a recognised conversion; interpolating with args would be a hazard.
        XCTAssertEqual(format("%C grade %@", ["A"]), "%C grade %@")
    }

    func testDynamicWidth_FallsBack() {
        // %*d consumes an extra integer argument the parser cannot account for.
        XCTAssertEqual(format("%*d", [5, 42]), "%*d")
    }

    func testMixedPositionalAndSequential_FallsBack() {
        // Undefined behaviour in printf — degrade safely.
        XCTAssertEqual(format("%1$@ and %@", ["a", "b"]), "%1$@ and %@")
    }

    func testUnsignedIntegerSpecifier_WithDouble_FallsBack() {
        // `.unsignedInteger` shares the integer accept rules — a floating-point value is rejected.
        XCTAssertEqual(format("%u apples", [3.7]), "%u apples")
    }

    func testFloatSpecifier_WithString_FallsBack() {
        XCTAssertEqual(format("Total: %.2f", ["oops"]), "Total: %.2f")
    }

    func testObjectSpecifier_WithDouble_FallsBack() {
        // Value types bridge to NSNumber (so `is NSObject` is true) but are encoded as scalars;
        // `%@` would dereference the raw value as a pointer, so they must fall back.
        XCTAssertEqual(format("Value: %@", [3.14]), "Value: %@")
    }

    func testObjectSpecifier_WithBool_FallsBack() {
        // `Bool` is a value type, not a class — `%@` must reject it even though it bridges.
        XCTAssertEqual(format("Value: %@", [true]), "Value: %@")
    }

    func testCStringSpecifier_WithInt_FallsBack() {
        // `%s` (`.string`) is never satisfiable by any Swift value — always falls back.
        XCTAssertEqual(format("Name: %s", [5]), "Name: %s")
    }

    // MARK: - Parser Unit Tests

    func testParser_RecognisesStandardSpecifiers() {
        let result = FormatSpecifierParser.scan("Order #%@ has %d items at %.2f")
        XCTAssertEqual(result.specifiers.map(\.conversion), ["@", "d", "f"])
        XCTAssertTrue(result.ambiguousPercents.isEmpty)
    }

    func testParser_PositionalSpecifiers() {
        let result = FormatSpecifierParser.scan("%2$@ %1$d")
        XCTAssertEqual(result.specifiers.map(\.position), [2, 1])
    }

    func testParser_LiteralPercentIgnored() {
        let result = FormatSpecifierParser.scan("100%% sure")
        XCTAssertTrue(result.specifiers.isEmpty)
        XCTAssertTrue(result.ambiguousPercents.isEmpty)
    }

    func testParser_AmbiguousPercentCaptured() {
        let result = FormatSpecifierParser.scan("%Compliance report")
        XCTAssertTrue(result.specifiers.isEmpty)
        XCTAssertEqual(result.ambiguousPercents.first?.raw, "%C")
    }

    func testParser_ExpectedTypes() {
        let result = FormatSpecifierParser.scan("%@ %d %u %f %s %c %p")
        XCTAssertEqual(
            result.specifiers.map(\.expectedType),
            [.object, .integer, .unsignedInteger, .floatingPoint, .string, .character, .unknown]
        )
    }

    func testParser_ConversionTypes_EveryEntryParsesToItsMappedType() {
        // Guards the single source of truth `FormatSpecifier.conversionTypes`: every recognised
        // conversion character (including aliases like `i`/`D`, hex `x`/`X`, octal `o`/`O`, and
        // the uppercase floating-point variants) must scan to exactly one specifier whose
        // `expectedType` equals its mapped type, with no ambiguous percents. Mistyping or dropping
        // a map entry breaks this test.
        XCTAssertFalse(FormatSpecifier.conversionTypes.isEmpty)
        for (conversion, expectedType) in FormatSpecifier.conversionTypes {
            let result = FormatSpecifierParser.scan("%\(conversion)")
            XCTAssertEqual(
                result.specifiers.count, 1,
                "Expected exactly one specifier for '%\(conversion)'"
            )
            XCTAssertEqual(
                result.specifiers.first?.conversion, conversion,
                "Conversion character mismatch for '%\(conversion)'"
            )
            XCTAssertEqual(
                result.specifiers.first?.expectedType, expectedType,
                "Expected type mismatch for '%\(conversion)'"
            )
            XCTAssertTrue(
                result.ambiguousPercents.isEmpty,
                "'%\(conversion)' should not be captured as an ambiguous percent"
            )
        }
    }

    func testParser_RecognizedConversions_MatchConversionTypesKeys() {
        // `recognizedConversions` is derived from `conversionTypes`; assert they stay in lockstep.
        XCTAssertEqual(
            FormatSpecifier.recognizedConversions,
            Set(FormatSpecifier.conversionTypes.keys)
        )
    }

    // MARK: - Parser Flags (step 5: `-+#0` consumed, space flag excluded)

    func testParser_MinusFlag_ConsumedAndSpecifierRecognised() {
        // Left-justify flag before a width — the `d` must still be picked up as the conversion.
        let result = FormatSpecifierParser.scan("%-10d")
        XCTAssertEqual(result.specifiers.map(\.conversion), ["d"])
        XCTAssertEqual(result.specifiers.first?.expectedType, .integer)
        XCTAssertTrue(result.ambiguousPercents.isEmpty)
    }

    func testParser_PlusFlag_Consumed() {
        let result = FormatSpecifierParser.scan("%+d")
        XCTAssertEqual(result.specifiers.map(\.conversion), ["d"])
        XCTAssertTrue(result.ambiguousPercents.isEmpty)
    }

    func testParser_HashFlag_Consumed() {
        let result = FormatSpecifierParser.scan("%#x")
        XCTAssertEqual(result.specifiers.map(\.conversion), ["x"])
        XCTAssertEqual(result.specifiers.first?.expectedType, .unsignedInteger)
        XCTAssertTrue(result.ambiguousPercents.isEmpty)
    }

    func testParser_ZeroFlag_Consumed() {
        // Zero-pad flag combined with width and precision.
        let result = FormatSpecifierParser.scan("%08.2f")
        XCTAssertEqual(result.specifiers.map(\.conversion), ["f"])
        XCTAssertEqual(result.specifiers.first?.expectedType, .floatingPoint)
        XCTAssertTrue(result.ambiguousPercents.isEmpty)
    }

    func testParser_AllRecognisedFlagsStacked() {
        // Every recognised flag (`-`, `+`, `#`, `0`) stacked before width/precision on one
        // specifier — the flags loop must consume them all and still land on `f`.
        let result = FormatSpecifierParser.scan("%-+#08.2f")
        XCTAssertEqual(result.specifiers.map(\.conversion), ["f"])
        XCTAssertTrue(result.ambiguousPercents.isEmpty)
    }

    func testParser_FlagsFollowPositionalPrefix() {
        // Flags come after the positional `N$` prefix; both must be captured.
        let result = FormatSpecifierParser.scan("%1$+d")
        XCTAssertEqual(result.specifiers.first?.position, 1)
        XCTAssertEqual(result.specifiers.first?.conversion, "d")
        XCTAssertTrue(result.ambiguousPercents.isEmpty)
    }

    func testParser_SpaceFlag_NotConsumed_BecomesAmbiguous() {
        // The space flag is deliberately unsupported: `% d` must NOT parse as a specifier,
        // otherwise decorative strings like "5% off" get misread as malformed formats. The
        // bare `% ` is captured as an ambiguous percent and `d` stays literal text.
        let result = FormatSpecifierParser.scan("% d")
        XCTAssertTrue(result.specifiers.isEmpty)
        XCTAssertEqual(result.ambiguousPercents.map(\.raw), ["% "])
    }

    // MARK: - Flags Round-Trip Through SafeFormat (output must equal native String(format:))

    func testFlaggedSpecifiers_RoundTripThroughSafeFormat() {
        // Recognised flags must not break specifier recognition or argument validation; each
        // output must match what native `String(format:)` produces.
        XCTAssertEqual(format("%+d", [5]), "+5")
        XCTAssertEqual(format("%#x", [255]), "0xff")
        XCTAssertEqual(format("%08.2f", [3.5]), "00003.50")
        XCTAssertEqual(format("[%-5d]", [42]), "[42   ]")
    }

    func testSpaceFlag_FallsBack_EvenWithArguments() {
        // Because `% ` is unclassifiable, interpolating with an argument degrades to the
        // verbatim format rather than crashing.
        XCTAssertEqual(format("% d", [5]), "% d")
    }
}

// MARK: - Test Support

/// A reference type used to exercise the `%@` object accept branch that admits genuine class
/// instances (`type(of:) is AnyClass`), as opposed to value types that merely bridge to `NSNumber`.
/// Overriding `description` makes the `%@` output deterministic.
private final class DescribedObject: NSObject {
    override var description: String { "custom-object" }
}
