//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

@testable import LocalizeKitCore
import XCTest

/// Unit tests for the `printf`-style format specifier parser.
final class FormatSpecifierParserTests: XCTestCase {

    // MARK: - Dynamic width / precision

    func testParse_dynamicWidth_setsDynamicWidthFlag() {
        let result = FormatSpecifierParser.parse("%*d")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "d")
        XCTAssertTrue(result[0].dynamicWidth)
        XCTAssertFalse(result[0].dynamicPrecision)
    }

    func testParse_dynamicPrecision_setsDynamicPrecisionFlag() {
        let result = FormatSpecifierParser.parse("%.*f")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "f")
        XCTAssertTrue(result[0].dynamicPrecision)
        XCTAssertFalse(result[0].dynamicWidth)
    }

    func testParse_dynamicWidthAndPrecision_setsBothFlags() {
        let result = FormatSpecifierParser.parse("%*.*f")
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(result[0].dynamicWidth)
        XCTAssertTrue(result[0].dynamicPrecision)
    }

    func testParse_staticWidthAndPrecision_leavesDynamicFlagsFalse() {
        let result = FormatSpecifierParser.parse("%8.2f")
        XCTAssertEqual(result.count, 1)
        XCTAssertFalse(result[0].dynamicWidth)
        XCTAssertFalse(result[0].dynamicPrecision)
    }

    // MARK: - Empty / no specifiers

    func testParse_emptyString_returnsNoSpecifiers() {
        XCTAssertTrue(FormatSpecifierParser.parse("").isEmpty)
    }

    func testParse_plainTextWithoutSpecifiers_returnsNoSpecifiers() {
        XCTAssertTrue(FormatSpecifierParser.parse("Hello world!").isEmpty)
    }

    func testParse_doublePercent_isLiteralAndIgnored() {
        XCTAssertTrue(FormatSpecifierParser.parse("100%% complete").isEmpty)
    }

    func testParse_trailingPercent_doesNotCrash() {
        // Bare `%` at end of string is malformed but must not crash the parser.
        let result = FormatSpecifierParser.parse("Discount %")
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Single specifiers

    func testParse_objectSpecifier_returnsExpectedTypeObject() {
        let result = FormatSpecifierParser.parse("Hello, %@!")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "@")
        XCTAssertEqual(result[0].expectedType, .object)
        XCTAssertNil(result[0].position)
        XCTAssertEqual(result[0].raw, "%@")
    }

    func testParse_intSpecifier_returnsExpectedTypeInteger() {
        let result = FormatSpecifierParser.parse("Score: %d")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "d")
        XCTAssertEqual(result[0].expectedType, .integer)
    }

    func testParse_floatSpecifier_returnsExpectedTypeFloatingPoint() {
        let result = FormatSpecifierParser.parse("Price: %f")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].expectedType, .floatingPoint)
    }

    func testParse_stringSpecifier_returnsExpectedTypeString() {
        let result = FormatSpecifierParser.parse("Path: %s")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].expectedType, .string)
    }

    func testParse_unsignedHexSpecifiers_returnUnsignedInteger() {
        let result = FormatSpecifierParser.parse("%u %x %X %o")
        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result.allSatisfy { $0.expectedType == .unsignedInteger })
    }

    // MARK: - Width / precision / flags

    func testParse_precisionFloat_isParsedAsFloat() {
        let result = FormatSpecifierParser.parse("%.2f")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "f")
        XCTAssertEqual(result[0].expectedType, .floatingPoint)
        XCTAssertEqual(result[0].raw, "%.2f")
    }

    func testParse_widthAndFlags_retainsConversion() {
        let result = FormatSpecifierParser.parse("%-10d")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "d")
        XCTAssertEqual(result[0].expectedType, .integer)
    }

    func testParse_dynamicWidth_doesNotConfuseParser() {
        let result = FormatSpecifierParser.parse("%*.*f")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "f")
    }

    // MARK: - Length modifiers

    func testParse_lengthModifier_lld_recognisedAsInteger() {
        let result = FormatSpecifierParser.parse("Long: %lld")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "d")
        XCTAssertEqual(result[0].lengthModifier, "ll")
        XCTAssertEqual(result[0].expectedType, .integer)
    }

    func testParse_lengthModifier_hu_recognisedAsUnsignedInteger() {
        let result = FormatSpecifierParser.parse("Short: %hu")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "u")
        XCTAssertEqual(result[0].lengthModifier, "h")
        XCTAssertEqual(result[0].expectedType, .unsignedInteger)
    }

    func testParse_lengthModifier_z_recognised() {
        let result = FormatSpecifierParser.parse("%zd")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "d")
        XCTAssertEqual(result[0].lengthModifier, "z")
    }

    // MARK: - Multiple specifiers

    func testParse_multipleSpecifiers_areReturnedInOrder() {
        let result = FormatSpecifierParser.parse("%@ scored %d in %.1f seconds")
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].conversion, "@")
        XCTAssertEqual(result[1].conversion, "d")
        XCTAssertEqual(result[2].conversion, "f")
    }

    func testParse_specifiersAroundDoublePercent_areCountedOnce() {
        let result = FormatSpecifierParser.parse("%@ saved 50%% on %d items")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].expectedType, .object)
        XCTAssertEqual(result[1].expectedType, .integer)
    }

    // MARK: - Positional

    func testParse_positionalSpecifier_setsPosition() {
        let result = FormatSpecifierParser.parse("%1$@ then %2$d")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].position, 1)
        XCTAssertEqual(result[0].expectedType, .object)
        XCTAssertEqual(result[1].position, 2)
        XCTAssertEqual(result[1].expectedType, .integer)
    }

    func testParse_repeatedPositional_keepsBothEntries() {
        let result = FormatSpecifierParser.parse("%1$@ likes %1$@ very much")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].position, 1)
        XCTAssertEqual(result[1].position, 1)
    }

    // MARK: - Decorative percents (corner cases)

    func testParse_percentFollowedByCapitalLetterWord_isDecorative() {
        // "%Compliance" — the `%` is decoration, not a `%C` wide-char specifier.
        // The parser must treat unknown conversion chars as literal so users can
        // write product names like "%Compliance", "%Service", "%Network".
        let result = FormatSpecifierParser.parse("%Compliance")
        XCTAssertTrue(result.isEmpty, "Decorative `%` before a word should produce no specifiers")
    }

    func testParse_percentFollowedByCapitalSWord_isDecorative() {
        // "%Service" — same as above; capital `S` is wide-char, excluded from whitelist.
        let result = FormatSpecifierParser.parse("%Service is down")
        XCTAssertTrue(result.isEmpty)
    }

    func testParse_decorativePercentMixedWithRealSpecifier_recognisesOnlyTheReal() {
        // "%Compliance: %@" — the `%C` is decoration, but the trailing `%@` is a real
        // specifier. We must NOT swallow the `%@` while skipping `%C…`.
        let result = FormatSpecifierParser.parse("%Compliance: %@")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "@")
    }

    func testParse_capitalSAndCWideCharSpecifiers_areDropped() {
        // Standalone `%S` and `%C` are technically valid Cocoa wide-char specifiers,
        // but they are vanishingly rare in Swift and conflict with decorative usage.
        XCTAssertTrue(FormatSpecifierParser.parse("%S").isEmpty)
        XCTAssertTrue(FormatSpecifierParser.parse("%C").isEmpty)
    }

    func testParse_lowercaseStringAndCharSpecifiers_areStillRecognised() {
        // `%s` (C string) and `%c` (char) remain valid — only their uppercase
        // wide-char cousins are dropped.
        let s = FormatSpecifierParser.parse("Path: %s")
        XCTAssertEqual(s.count, 1)
        XCTAssertEqual(s[0].conversion, "s")
        XCTAssertEqual(s[0].expectedType, .string)

        let c = FormatSpecifierParser.parse("Char: %c")
        XCTAssertEqual(c.count, 1)
        XCTAssertEqual(c[0].conversion, "c")
        XCTAssertEqual(c[0].expectedType, .character)
    }

    // MARK: - Escape sequences inside the format string

    func testParse_escapedNewlineBeforeSpecifier_doesNotConfuseParser() {
        // The extractor reads the raw string segment, so `\n` arrives as the two
        // characters `\` and `n` rather than the newline itself.
        let result = FormatSpecifierParser.parse("Do you want to open this link:\\n%@")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "@")
        XCTAssertEqual(result[0].expectedType, .object)
    }

    func testParse_escapedBackslashAndQuotes_areTransparent() {
        let result = FormatSpecifierParser.parse(#"\"quoted\" path \\drive — %@"#)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "@")
    }

    func testParse_escapedTab_doesNotProduceSpecifier() {
        let result = FormatSpecifierParser.parse("Item:\\t%d")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "d")
    }

    // MARK: - Boundary positions

    func testParse_specifierAtStartOfString_isParsed() {
        let result = FormatSpecifierParser.parse("%@: hello")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "@")
    }

    func testParse_specifierAtEndOfString_isParsed() {
        let result = FormatSpecifierParser.parse("Hello %@")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "@")
    }

    func testParse_adjacentSpecifiers_areAllRecognised() {
        let result = FormatSpecifierParser.parse("%@%@")
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.conversion == "@" })
    }

    func testParse_specifierFollowedByDoublePercent_keepsOneAndIgnoresLiteral() {
        // "%@%%" — one real %@, then literal %.
        let result = FormatSpecifierParser.parse("%@%%")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "@")
    }

    func testParse_emailAtSignAfterSpecifier_isNotASecondSpecifier() {
        // "Contact %@ at user@example.com" — the second `@` belongs to the email
        // and is NOT a format specifier (it has no preceding `%`).
        let result = FormatSpecifierParser.parse("Contact %@ at user@example.com")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "@")
    }

    func testParse_dollarSignBeforeFloat_isNotConfusedWithPositional() {
        // "$%.2f" — the `$` here is a currency sign, NOT a positional separator
        // (positional needs digits before `$`). Must parse as one float specifier.
        let result = FormatSpecifierParser.parse("Total: $%.2f")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].conversion, "f")
        XCTAssertNil(result[0].position)
    }

    func testParse_orphanDollarSign_isLiteral() {
        let result = FormatSpecifierParser.parse("Cost: $42")
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Pathological inputs

    func testParse_lotsOfDoublePercent_returnsNoSpecifiers() {
        let result = FormatSpecifierParser.parse("100%% off, 50%% off, 25%% off")
        XCTAssertTrue(result.isEmpty)
    }

    func testParse_percentBetweenTwoLiterals_isLiteralAlone() {
        // "5% off" — bare `%` followed by space (non-specifier char). Currently parses
        // ` ` as conversion and discards under the whitelist → 0 specifiers.
        let result = FormatSpecifierParser.parse("5% off")
        XCTAssertTrue(result.isEmpty)
    }

    func testParse_unknownLowercaseLetterAfterPercent_isDecoration() {
        // `%z` alone (no length modifier follow-up like `%zd`) is unknown; drop it.
        let result = FormatSpecifierParser.parse("%z")
        XCTAssertTrue(result.isEmpty)
    }

    func testParse_emptyDefaultStringWithDecorativePercent() {
        let result = FormatSpecifierParser.parse("%")
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - scan() — both recognised and ambiguous percents

    func testScan_recognisedSpecifierOnly_hasNoAmbiguous() {
        let scan = FormatSpecifierParser.scan("Hello, %@!")
        XCTAssertEqual(scan.specifiers.count, 1)
        XCTAssertTrue(scan.ambiguousPercents.isEmpty)
    }

    func testScan_decorativePercent_isReportedAsAmbiguous() {
        let scan = FormatSpecifierParser.scan("%Compliance")
        XCTAssertTrue(scan.specifiers.isEmpty)
        XCTAssertEqual(scan.ambiguousPercents.map(\.raw), ["%C"])
    }

    func testScan_decorativePercentMixedWithSpecifier_separatesBoth() {
        let scan = FormatSpecifierParser.scan("%Compliance: %@")
        XCTAssertEqual(scan.specifiers.count, 1)
        XCTAssertEqual(scan.specifiers[0].conversion, "@")
        XCTAssertEqual(scan.ambiguousPercents.map(\.raw), ["%C"])
    }

    func testScan_capitalSAndC_areReportedAsAmbiguous() {
        let scanS = FormatSpecifierParser.scan("%S")
        XCTAssertTrue(scanS.specifiers.isEmpty)
        XCTAssertEqual(scanS.ambiguousPercents.map(\.raw), ["%S"])

        let scanC = FormatSpecifierParser.scan("%C")
        XCTAssertTrue(scanC.specifiers.isEmpty)
        XCTAssertEqual(scanC.ambiguousPercents.map(\.raw), ["%C"])
    }

    func testScan_doublePercent_isNotAmbiguous() {
        let scan = FormatSpecifierParser.scan("100%% complete")
        XCTAssertTrue(scan.specifiers.isEmpty)
        XCTAssertTrue(scan.ambiguousPercents.isEmpty,
                      "%% is the standard escape and must not be reported as ambiguous")
    }
}
