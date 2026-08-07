@testable import LocalizeKit
import XCTest

/// Comprehensive unit tests for `PluralCategory.category(for:locale:customRules:)`.
///
/// All expected values are derived from Unicode CLDR v48.1 cardinal plural rules for integers.
/// CLDR Version: 48.1 | Unicode Version: 16.0.0
/// Reference: https://www.unicode.org/cldr/charts/48/supplemental/language_plural_rules.html
/// Source data: https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-core/supplemental/plurals.json
///
/// Tests are organized **per-language** so adding a new language only requires adding
/// a new section — no modification of existing tests needed.
@MainActor
final class PluralCategoryTests: XCTestCase {
    // MARK: - Setup

    override func setUp() async throws {
        try await super.setUp()
        LocalizationManager.shared.configure(pluralRules: [:])
    }

    // MARK: - Helpers

    private func locale(_ languageCode: String) -> Locale {
        Locale(identifier: languageCode)
    }

    private func assertCategory(
        _ expected: PluralCategory,
        for count: Int,
        language: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let result = PluralCategory.category(for: count, locale: locale(language))
        XCTAssertEqual(
            result, expected,
            "Expected .\(expected) for count \(count) in '\(language)', got .\(result)",
            file: file, line: line
        )
    }

    private func assertCategories(
        _ expectations: [(count: Int, expected: PluralCategory)],
        language: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        for (count, expected) in expectations {
            assertCategory(expected, for: count, language: language, file: file, line: line)
        }
    }

    // ==========================================
    // MARK: - Arabic (ar)
    // ==========================================
    // CLDR: zero → n = 0; one → n = 1; two → n = 2;
    //        few → n % 100 = 3..10; many → n % 100 = 11..99; other
    // Integer samples:
    //   zero: 0 | one: 1 | two: 2
    //   few: 3~10, 103~110, 1003, …
    //   many: 11~26, 111, 1011, …
    //   other: 100~102, 200~202, 300~302, …

    func testArabic_categories() {
        assertCategories([
            (0, .zero),
            (1, .one),
            (2, .two),
            // few: n%100 = 3..10
            (3, .few), (4, .few), (5, .few), (6, .few),
            (7, .few), (8, .few), (9, .few), (10, .few),
            (103, .few), (110, .few), (205, .few), (1003, .few),
            // many: n%100 = 11..99
            (11, .many), (12, .many), (19, .many), (20, .many),
            (50, .many), (99, .many),
            (111, .many), (199, .many), (250, .many),
            // other: n%100 = 0, 1, 2 (but exact 0,1,2 caught above)
            (100, .other), (200, .other), (300, .other), (1000, .other),
            (101, .other), (102, .other), (201, .other), (202, .other),
        ], language: "ar")
    }

    func testArabic_boundaries() {
        // few ↔ many boundary
        assertCategory(.other, for: 102, language: "ar")   // n%100=2, not in 3..10
        assertCategory(.few, for: 103, language: "ar")     // n%100=3, start of few
        assertCategory(.few, for: 110, language: "ar")     // n%100=10, end of few
        assertCategory(.many, for: 111, language: "ar")    // n%100=11, start of many

        // many ↔ other boundary
        assertCategory(.few, for: 10, language: "ar")      // n%100=10 → few
        assertCategory(.many, for: 11, language: "ar")     // n%100=11, start of many
        assertCategory(.many, for: 99, language: "ar")     // n%100=99, end of many
        assertCategory(.other, for: 100, language: "ar")   // n%100=0 → other
    }

    func testArabic_largeNumbers() {
        assertCategory(.other, for: 1_000_000, language: "ar")  // n%100=0 → other
        assertCategory(.many, for: 1_000_011, language: "ar")   // n%100=11 → many
        assertCategory(.few, for: 1_000_003, language: "ar")    // n%100=3 → few
    }

    func testArabic_negativeNumbers() {
        assertCategory(.one, for: -1, language: "ar")
        assertCategory(.two, for: -2, language: "ar")
        assertCategory(.few, for: -3, language: "ar")
        assertCategory(.few, for: -10, language: "ar")
        assertCategory(.many, for: -11, language: "ar")
        assertCategory(.many, for: -99, language: "ar")
        assertCategory(.other, for: -100, language: "ar")
        assertCategory(.few, for: -103, language: "ar")
        assertCategory(.many, for: -111, language: "ar")
    }

    // ==========================================
    // MARK: - Belarusian (be)
    // ==========================================
    // CLDR: one → n % 10 = 1 and n % 100 ≠ 11
    //        few → n % 10 = 2..4 and n % 100 ≠ 12..14
    //        many → n % 10 = 0 or n % 10 = 5..9 or n % 100 = 11..14
    // Integer samples:
    //   one: 1, 21, 31, 41, 51, 61, 71, 81, 101, 1001, …
    //   few: 2~4, 22~24, 32~34, 42~44, 52~54, 62, 102, 1002, …
    //   many: 0, 5~19, 100, 1000, …

    func testBelarusian_categories() {
        assertCategories([
            (1, .one), (21, .one), (31, .one), (101, .one), (1001, .one),
            (2, .few), (3, .few), (4, .few), (22, .few), (23, .few),
            (0, .many), (5, .many), (10, .many), (11, .many), (12, .many), (100, .many),
        ], language: "be")
    }

    func testBelarusian_negativeNumbers() {
        assertCategory(.one, for: -1, language: "be")
        assertCategory(.few, for: -2, language: "be")
        assertCategory(.many, for: -5, language: "be")
        assertCategory(.one, for: -21, language: "be")
        assertCategory(.many, for: -11, language: "be")
    }

    // ==========================================
    // MARK: - Bengali (bn)
    // ==========================================
    // CLDR: one → i = 0 or n = 1
    // Integer samples: one: 0, 1 | other: 2~17, 100, 1000, …

    func testBengali_categories() {
        assertCategories([
            (0, .one), (1, .one), (2, .other), (5, .other), (100, .other),
        ], language: "bn")
    }

    func testBengali_negativeNumbers() {
        assertCategory(.one, for: -1, language: "bn")
        assertCategory(.other, for: -2, language: "bn")
        assertCategory(.other, for: -100, language: "bn")
    }

    // ==========================================
    // MARK: - Catalan (ca)
    // ==========================================
    // CLDR: one → i = 1 and v = 0
    //        many → e = 0 and i ≠ 0 and i % 1000000 = 0 and v = 0
    // Integer samples: one: 1 | many: 1000000, … | other: 0, 2~16, 100, …

    func testCatalan_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other),
            (1_000_000, .many), (5_000_000, .many),
            (1_500_000, .other),
        ], language: "ca")
    }

    func testCatalan_negativeNumbers() {
        assertCategory(.one, for: -1, language: "ca")
        assertCategory(.other, for: -2, language: "ca")
        assertCategory(.many, for: -1_000_000, language: "ca")
    }

    // ==========================================
    // MARK: - Chinese (zh)
    // ==========================================
    // CLDR: other (always — no plural distinction)
    // Integer samples: other: 0~15, 100, 1000, …

    func testChinese_categories() {
        for count in [0, 1, 2, 5, 10, 100, 1000] {
            assertCategory(.other, for: count, language: "zh")
        }
    }

    func testChinese_negativeNumbers() {
        for count in [-1, -5, -100] {
            assertCategory(.other, for: count, language: "zh")
        }
    }

    // ==========================================
    // MARK: - Czech (cs)
    // ==========================================
    // CLDR: one → i = 1 and v = 0; few → i = 2..4 and v = 0; other
    // Integer samples: one: 1 | few: 2~4 | other: 0, 5~19, 100, 1000, …

    func testCzech_categories() {
        assertCategories([
            (0, .other), (1, .one),
            (2, .few), (3, .few), (4, .few),
            (5, .other), (10, .other), (20, .other), (100, .other), (1000, .other),
        ], language: "cs")
    }

    func testCzech_boundaries() {
        assertCategory(.one, for: 1, language: "cs")
        assertCategory(.few, for: 2, language: "cs")     // start of few
        assertCategory(.few, for: 4, language: "cs")     // end of few
        assertCategory(.other, for: 5, language: "cs")   // outside few
    }

    func testCzech_negativeNumbers() {
        assertCategory(.one, for: -1, language: "cs")
        assertCategory(.few, for: -2, language: "cs")
        assertCategory(.few, for: -4, language: "cs")
        assertCategory(.other, for: -5, language: "cs")
        assertCategory(.other, for: -100, language: "cs")
    }

    // ==========================================
    // MARK: - Danish (da)
    // ==========================================
    // CLDR: one → n = 1 or t != 0 and i = 0,1
    // For integers (t=0): effectively one → n = 1
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testDanish_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (10, .other), (100, .other),
        ], language: "da")
    }

    func testDanish_negativeNumbers() {
        assertCategory(.one, for: -1, language: "da")
        assertCategory(.other, for: -2, language: "da")
    }

    // ==========================================
    // MARK: - Dutch (nl)
    // ==========================================
    // CLDR: one → i = 1 and v = 0
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testDutch_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (50, .other),
        ], language: "nl")
    }

    func testDutch_negativeNumbers() {
        assertCategory(.one, for: -1, language: "nl")
        assertCategory(.other, for: -2, language: "nl")
    }

    // ==========================================
    // MARK: - English (en)
    // ==========================================
    // CLDR: one → i = 1 and v = 0
    // Integer samples: one: 1 | other: 0, 2~16, 100, 1000, …

    func testEnglish_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (5, .other),
            (10, .other), (16, .other), (21, .other),
            (100, .other), (1000, .other), (10_000, .other),
        ], language: "en")
    }

    func testEnglish_negativeNumbers() {
        assertCategory(.one, for: -1, language: "en")
        assertCategory(.other, for: -2, language: "en")
        assertCategory(.other, for: -5, language: "en")
        assertCategory(.other, for: -100, language: "en")
    }

    // ==========================================
    // MARK: - Estonian (et)
    // ==========================================
    // CLDR: one → i = 1 and v = 0
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testEstonian_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (10, .other),
        ], language: "et")
    }

    func testEstonian_negativeNumbers() {
        assertCategory(.one, for: -1, language: "et")
        assertCategory(.other, for: -2, language: "et")
    }

    // ==========================================
    // MARK: - Faroese (fo)
    // ==========================================
    // CLDR: one → n = 1
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testFaroese_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (100, .other),
        ], language: "fo")
    }

    func testFaroese_negativeNumbers() {
        assertCategory(.one, for: -1, language: "fo")
        assertCategory(.other, for: -2, language: "fo")
    }

    // ==========================================
    // MARK: - Finnish (fi)
    // ==========================================
    // CLDR: one → i = 1 and v = 0
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testFinnish_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (15, .other),
        ], language: "fi")
    }

    func testFinnish_negativeNumbers() {
        assertCategory(.one, for: -1, language: "fi")
        assertCategory(.other, for: -2, language: "fi")
    }

    // ==========================================
    // MARK: - French (fr)
    // ==========================================
    // CLDR: one → i = 0, 1
    //        many → e = 0 and i ≠ 0 and i % 1000000 = 0 and v = 0
    // Integer samples: one: 0, 1 | many: 1000000, … | other: 2~17, 100, …

    func testFrench_categories() {
        assertCategories([
            (0, .one),
            (1, .one),
            (2, .other),
            (5, .other),
            (100, .other),
            (1_000_000, .many),
            (2_000_000, .many),
            (1_000_001, .other),
            (999_999, .other),
        ], language: "fr")
    }

    func testFrench_negativeNumbers() {
        assertCategory(.one, for: -1, language: "fr")
        assertCategory(.other, for: -2, language: "fr")
        assertCategory(.other, for: -5, language: "fr")
        assertCategory(.many, for: -1_000_000, language: "fr")
    }

    // ==========================================
    // MARK: - Galician (gl)
    // ==========================================
    // CLDR: one → i = 1 and v = 0
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testGalician_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (7, .other),
        ], language: "gl")
    }

    func testGalician_negativeNumbers() {
        assertCategory(.one, for: -1, language: "gl")
        assertCategory(.other, for: -2, language: "gl")
    }

    // ==========================================
    // MARK: - German (de)
    // ==========================================
    // CLDR: one → i = 1 and v = 0
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testGerman_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (11, .other), (100, .other),
        ], language: "de")
    }

    func testGerman_negativeNumbers() {
        assertCategory(.one, for: -1, language: "de")
        assertCategory(.other, for: -2, language: "de")
    }

    // ==========================================
    // MARK: - Gujarati (gu)
    // ==========================================
    // CLDR: one → i = 0 or n = 1
    // Integer samples: one: 0, 1 | other: 2~17, 100, …

    func testGujarati_categories() {
        assertCategories([
            (0, .one), (1, .one), (2, .other), (50, .other),
        ], language: "gu")
    }

    func testGujarati_negativeNumbers() {
        assertCategory(.one, for: -1, language: "gu")
        assertCategory(.other, for: -2, language: "gu")
    }

    // ==========================================
    // MARK: - Hindi (hi)
    // ==========================================
    // CLDR: one → i = 0 or n = 1
    // Integer samples: one: 0, 1 | other: 2~17, 100, 1000, …

    func testHindi_categories() {
        assertCategories([
            (0, .one), (1, .one), (2, .other), (10, .other), (1000, .other),
        ], language: "hi")
    }

    func testHindi_negativeNumbers() {
        assertCategory(.one, for: -1, language: "hi")
        assertCategory(.other, for: -2, language: "hi")
    }

    // ==========================================
    // MARK: - Hungarian (hu)
    // ==========================================
    // CLDR: one → n = 1
    // Integer samples: one: 1 | other: 0, 2~16, 100, 1000, …

    func testHungarian_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (1000, .other),
        ], language: "hu")
    }

    func testHungarian_negativeNumbers() {
        assertCategory(.one, for: -1, language: "hu")
        assertCategory(.other, for: -2, language: "hu")
    }

    // ==========================================
    // MARK: - Icelandic (is)
    // ==========================================
    // CLDR: one → t = 0 and i % 10 = 1 and i % 100 ≠ 11
    // For integers (t=0): one when i%10=1 and i%100≠11
    // Integer samples: one: 1, 21, 31, 41, 51, 61, 71, 81, 101, 1001, …
    //                  other: 0, 2~16, 100, 1000, …

    func testIcelandic_categories() {
        assertCategories([
            (0, .other),
            (1, .one),       // i%10=1, i%100=1 ≠ 11
            (2, .other),
            (10, .other),
            (11, .other),    // i%10=1, but i%100=11
            (21, .one),      // i%10=1, i%100=21 ≠ 11
            (31, .one),
            (41, .one),
            (51, .one),
            (61, .one),
            (71, .one),
            (81, .one),
            (91, .one),
            (101, .one),     // i%10=1, i%100=1 ≠ 11
            (111, .other),   // i%10=1, i%100=11
            (211, .other),
            (311, .other),
            (100, .other),
            (200, .other),
            (22, .other),
            (33, .other),
        ], language: "is")
    }

    func testIcelandic_negativeNumbers() {
        assertCategory(.one, for: -1, language: "is")
        assertCategory(.other, for: -2, language: "is")
        assertCategory(.other, for: -11, language: "is")
        assertCategory(.one, for: -21, language: "is")
        assertCategory(.one, for: -101, language: "is")
        assertCategory(.other, for: -111, language: "is")
    }

    // ==========================================
    // MARK: - Indonesian (id)
    // ==========================================
    // CLDR: other (always — no plural distinction)
    // Integer samples: other: 0~15, 100, 1000, …

    func testIndonesian_categories() {
        for count in [0, 1, 2, 10, 100] {
            assertCategory(.other, for: count, language: "id")
        }
    }

    func testIndonesian_negativeNumbers() {
        for count in [-1, -5, -100] {
            assertCategory(.other, for: count, language: "id")
        }
    }

    // ==========================================
    // MARK: - Irish (ga)
    // ==========================================
    // CLDR: one → n = 1; two → n = 2;
    //        few → n = 3..6; many → n = 7..10; other
    // Integer samples:
    //   one: 1 | two: 2 | few: 3~6 | many: 7~10
    //   other: 0, 11~25, 100, 1000, …

    func testIrish_categories() {
        assertCategories([
            (0, .other),
            (1, .one), (2, .two),
            (3, .few), (4, .few), (5, .few), (6, .few),
            (7, .many), (8, .many), (9, .many), (10, .many),
            (11, .other), (12, .other), (20, .other), (100, .other),
        ], language: "ga")
    }

    func testIrish_boundaries() {
        assertCategory(.two, for: 2, language: "ga")
        assertCategory(.few, for: 3, language: "ga")       // start of few
        assertCategory(.few, for: 6, language: "ga")       // end of few
        assertCategory(.many, for: 7, language: "ga")      // start of many
        assertCategory(.many, for: 10, language: "ga")     // end of many
        assertCategory(.other, for: 11, language: "ga")    // outside many
    }

    func testIrish_negativeNumbers() {
        assertCategory(.one, for: -1, language: "ga")
        assertCategory(.two, for: -2, language: "ga")
        assertCategory(.few, for: -3, language: "ga")
        assertCategory(.few, for: -6, language: "ga")
        assertCategory(.many, for: -7, language: "ga")
        assertCategory(.many, for: -10, language: "ga")
        assertCategory(.other, for: -11, language: "ga")
    }

    // ==========================================
    // MARK: - Italian (it)
    // ==========================================
    // CLDR: one → i = 1 and v = 0
    //        many → e = 0 and i ≠ 0 and i % 1000000 = 0 and v = 0
    // Integer samples: one: 1 | many: 1000000, … | other: 0, 2~16, 100, …

    func testItalian_categories() {
        assertCategories([
            (0, .other),
            (1, .one),
            (2, .other),
            (5, .other),
            (100, .other),
            (1000, .other),
            (999_999, .other),
            (1_000_000, .many),
            (2_000_000, .many),
            (3_000_000, .many),
            (1_000_001, .other),
            (10_000_000, .many),
        ], language: "it")
    }

    func testItalian_negativeNumbers() {
        assertCategory(.one, for: -1, language: "it")
        assertCategory(.other, for: -2, language: "it")
        assertCategory(.many, for: -1_000_000, language: "it")
        assertCategory(.other, for: -1_000_001, language: "it")
    }

    // ==========================================
    // MARK: - Japanese (ja)
    // ==========================================
    // CLDR: other (always — no plural distinction)
    // Integer samples: other: 0~15, 100, 1000, …

    func testJapanese_categories() {
        for count in [0, 1, 2, 5, 10, 100, 1000] {
            assertCategory(.other, for: count, language: "ja")
        }
    }

    func testJapanese_negativeNumbers() {
        for count in [-1, -5, -100] {
            assertCategory(.other, for: count, language: "ja")
        }
    }

    // ==========================================
    // MARK: - Korean (ko)
    // ==========================================
    // CLDR: other (always — no plural distinction)
    // Integer samples: other: 0~15, 100, 1000, …

    func testKorean_categories() {
        for count in [0, 1, 2, 5, 10, 100, 1000] {
            assertCategory(.other, for: count, language: "ko")
        }
    }

    func testKorean_negativeNumbers() {
        for count in [-1, -5, -100] {
            assertCategory(.other, for: count, language: "ko")
        }
    }

    // ==========================================
    // MARK: - Luxembourgish (lb)
    // ==========================================
    // CLDR: one → n = 1
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testLuxembourgish_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (50, .other),
        ], language: "lb")
    }

    func testLuxembourgish_negativeNumbers() {
        assertCategory(.one, for: -1, language: "lb")
        assertCategory(.other, for: -2, language: "lb")
    }

    // ==========================================
    // MARK: - Malay (ms)
    // ==========================================
    // CLDR: other (always — no plural distinction)
    // Integer samples: other: 0~15, 100, 1000, …

    func testMalay_categories() {
        for count in [0, 1, 2, 10, 100] {
            assertCategory(.other, for: count, language: "ms")
        }
    }

    func testMalay_negativeNumbers() {
        for count in [-1, -5, -100] {
            assertCategory(.other, for: count, language: "ms")
        }
    }

    // ==========================================
    // MARK: - Malayalam (ml)
    // ==========================================
    // CLDR: one → n = 1
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testMalayalam_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (25, .other),
        ], language: "ml")
    }

    func testMalayalam_negativeNumbers() {
        assertCategory(.one, for: -1, language: "ml")
        assertCategory(.other, for: -2, language: "ml")
    }

    // ==========================================
    // MARK: - Marathi (mr)
    // ==========================================
    // CLDR: one → n = 1
    // Same CLDR group as fo, hu, lb, ml, ta, te, tr
    // Integer samples: one: 1 | other: 0, 2~16, 100, 1000, …

    func testMarathi_categories() {
        assertCategories([
            (0, .other),
            (1, .one),
            (2, .other),
            (12, .other),
            (100, .other),
            (1000, .other),
        ], language: "mr")
    }

    func testMarathi_negativeNumbers() {
        assertCategory(.one, for: -1, language: "mr")
        assertCategory(.other, for: -2, language: "mr")
        assertCategory(.other, for: -100, language: "mr")
    }

    // ==========================================
    // MARK: - Moldovan (mo)
    // ==========================================
    // CLDR: Same as Romanian (ro)
    // one → i = 1 and v = 0
    // few → v != 0 or n = 0 or n != 1 and n % 100 = 1..19
    // For integers: few → n = 0 or (n ≠ 1 and n % 100 = 1..19)
    // Integer samples: one: 1 | few: 0, 2~16, 101, 1001, … | other: 20~35, 100, …

    func testMoldovan_categories() {
        assertCategories([
            (0, .few), (1, .one),
            (2, .few), (19, .few),
            (20, .other),
            (100, .other),
            (101, .few),            // n%100=1, in 1..19, n≠1 → few
            (102, .few), (119, .few),
        ], language: "mo")
    }

    func testMoldovan_negativeNumbers() {
        assertCategory(.one, for: -1, language: "mo")
        assertCategory(.few, for: -2, language: "mo")
        assertCategory(.other, for: -20, language: "mo")
        assertCategory(.few, for: -101, language: "mo")
    }

    // ==========================================
    // MARK: - Norwegian (no)
    // ==========================================
    // CLDR: one → n = 1
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testNorwegian_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (100, .other),
        ], language: "no")
    }

    func testNorwegian_negativeNumbers() {
        assertCategory(.one, for: -1, language: "no")
        assertCategory(.other, for: -2, language: "no")
    }

    // ==========================================
    // MARK: - Norwegian Bokmål (nb)
    // ==========================================
    // CLDR: one → n = 1
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testNorwegianBokmal_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (100, .other),
        ], language: "nb")
    }

    func testNorwegianBokmal_negativeNumbers() {
        assertCategory(.one, for: -1, language: "nb")
        assertCategory(.other, for: -2, language: "nb")
    }

    // ==========================================
    // MARK: - Norwegian Nynorsk (nn)
    // ==========================================
    // CLDR: one → n = 1
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testNorwegianNynorsk_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (100, .other),
        ], language: "nn")
    }

    func testNorwegianNynorsk_negativeNumbers() {
        assertCategory(.one, for: -1, language: "nn")
        assertCategory(.other, for: -2, language: "nn")
    }

    // ==========================================
    // MARK: - Persian (fa)
    // ==========================================
    // CLDR: one → i = 0 or n = 1
    // Integer samples: one: 0, 1 | other: 2~17, 100, …

    func testPersian_categories() {
        assertCategories([
            (0, .one), (1, .one), (2, .other), (10, .other), (100, .other),
        ], language: "fa")
    }

    func testPersian_negativeNumbers() {
        assertCategory(.one, for: -1, language: "fa")
        assertCategory(.other, for: -2, language: "fa")
        assertCategory(.other, for: -100, language: "fa")
    }

    // ==========================================
    // MARK: - Polish (pl)
    // ==========================================
    // CLDR (integers, v=0):
    //   one  → i = 1 and v = 0
    //   few  → i % 10 = 2..4 and i % 100 ≠ 12..14
    //   many → everything else (i ≠ 1 and (i%10=0..1 or i%10=5..9 or i%100=12..14))
    // Integer samples:
    //   one: 1 | few: 2~4, 22~24, 32~34, … | many: 0, 5~19, 100, 1000, …

    func testPolish_categories() {
        assertCategories([
            (1, .one),
            // few: i%10=2..4, i%100≠12..14
            (2, .few), (3, .few), (4, .few),
            (22, .few), (23, .few), (24, .few),
            (32, .few), (33, .few), (34, .few),
            (102, .few), (1002, .few),
            // many: everything else
            (0, .many), (5, .many), (6, .many), (9, .many),
            (10, .many), (11, .many),
            (12, .many), (13, .many), (14, .many),   // mod100=12..14 exception
            (15, .many), (19, .many), (20, .many), (21, .many), (25, .many),
            (100, .many), (111, .many),
            (112, .many), (113, .many), (114, .many), // mod100=12..14 exception
        ], language: "pl")
    }

    func testPolish_boundaries() {
        // 12-14 override mod10 rules
        assertCategory(.many, for: 12, language: "pl")
        assertCategory(.many, for: 13, language: "pl")
        assertCategory(.many, for: 14, language: "pl")
        assertCategory(.many, for: 112, language: "pl")
        assertCategory(.many, for: 113, language: "pl")
        assertCategory(.many, for: 114, language: "pl")
        // But 22-24 are few (mod100≠12..14)
        assertCategory(.few, for: 22, language: "pl")
        assertCategory(.few, for: 23, language: "pl")
        assertCategory(.few, for: 24, language: "pl")
    }

    func testPolish_largeNumbers() {
        assertCategory(.many, for: 1_000_001, language: "pl")   // i≠1, i%10=1 → many
        assertCategory(.few, for: 1_000_002, language: "pl")    // i%10=2, i%100=2 → few
        assertCategory(.many, for: 1_000_000, language: "pl")   // i%10=0 → many
        assertCategory(.many, for: 1_000_012, language: "pl")   // i%100=12 → many
    }

    func testPolish_negativeNumbers() {
        assertCategory(.one, for: -1, language: "pl")
        assertCategory(.few, for: -2, language: "pl")
        assertCategory(.few, for: -3, language: "pl")
        assertCategory(.many, for: -5, language: "pl")
        assertCategory(.many, for: -12, language: "pl")
        assertCategory(.few, for: -22, language: "pl")
    }

    // ==========================================
    // MARK: - Portuguese (pt)
    // ==========================================
    // CLDR: one → i = 0..1
    //        many → e = 0 and i ≠ 0 and i % 1000000 = 0 and v = 0
    // Integer samples: one: 0, 1 | many: 1000000, … | other: 2~17, 100, …

    func testPortuguese_categories() {
        assertCategories([
            (0, .one),
            (1, .one),
            (2, .other),
            (5, .other),
            (100, .other),
            (1000, .other),
            (1_000_000, .many),
            (2_000_000, .many),
            (1_000_001, .other),
        ], language: "pt")
    }

    func testPortuguese_negativeNumbers() {
        assertCategory(.one, for: -1, language: "pt")
        assertCategory(.other, for: -2, language: "pt")
        assertCategory(.many, for: -1_000_000, language: "pt")
    }

    // ==========================================
    // MARK: - Punjabi (pa)
    // ==========================================
    // CLDR: one → n = 0..1
    // Integer samples: one: 0, 1 | other: 2~17, 100, …

    func testPunjabi_categories() {
        assertCategories([
            (0, .one), (1, .one), (2, .other), (99, .other),
        ], language: "pa")
    }

    func testPunjabi_negativeNumbers() {
        assertCategory(.one, for: -1, language: "pa")
        assertCategory(.other, for: -2, language: "pa")
    }

    // ==========================================
    // MARK: - Romanian (ro)
    // ==========================================
    // CLDR (integers, v=0):
    //   one  → i = 1 and v = 0
    //   few  → v != 0 or n = 0 or n != 1 and n % 100 = 1..19
    //   other → everything else
    // For integers: few → n = 0 or (n ≠ 1 and n % 100 = 1..19)
    // Integer samples (from CLDR):
    //   one: 1
    //   few: 0, 2~16, 101, 1001, …
    //   other: 20~35, 100, 1000, 10000, …
    //
    // NOTE: The CLDR range for few is n%100=1..19 (includes 1).
    //       So 101 (n%100=1) is "few", NOT "other".
    //       Only n%100=0 and n%100=20..99 map to "other".

    func testRomanian_categories() {
        assertCategories([
            (0, .few),              // n=0 → few
            (1, .one),              // i=1 → one
            (2, .few),              // n%100=2, in 1..19 → few
            (10, .few),             // n%100=10, in 1..19 → few
            (15, .few),             // n%100=15, in 1..19 → few
            (19, .few),             // n%100=19, in 1..19 → few
            (20, .other),           // n%100=20, NOT in 1..19 → other
            (50, .other),           // n%100=50 → other
            (100, .other),          // n%100=0, n≠0 → other
            (101, .few),            // n%100=1, in 1..19, n≠1 → few
            (102, .few),            // n%100=2, in 1..19 → few
            (119, .few),            // n%100=19, in 1..19 → few
            (120, .other),          // n%100=20 → other
            (200, .other),          // n%100=0 → other
            (201, .few),            // n%100=1, in 1..19, n≠1 → few
            (219, .few),            // n%100=19 → few
            (1001, .few),           // CLDR sample: n%100=1, n≠1 → few
        ], language: "ro")
    }

    func testRomanian_boundaries() {
        assertCategory(.few, for: 0, language: "ro")      // n=0 → few
        assertCategory(.one, for: 1, language: "ro")      // i=1 → one
        assertCategory(.few, for: 2, language: "ro")      // n%100=2, in 1..19
        assertCategory(.few, for: 19, language: "ro")     // n%100=19, boundary end
        assertCategory(.other, for: 20, language: "ro")   // n%100=20, outside 1..19
        assertCategory(.other, for: 100, language: "ro")  // n%100=0 → other
        assertCategory(.few, for: 101, language: "ro")    // n%100=1, in 1..19 → few
        assertCategory(.few, for: 102, language: "ro")    // n%100=2 → few
    }

    func testRomanian_negativeNumbers() {
        assertCategory(.one, for: -1, language: "ro")
        assertCategory(.few, for: -2, language: "ro")
        assertCategory(.few, for: -19, language: "ro")
        assertCategory(.other, for: -20, language: "ro")
        assertCategory(.other, for: -100, language: "ro")
        assertCategory(.few, for: -101, language: "ro")
    }

    // ==========================================
    // MARK: - Russian (ru)
    // ==========================================
    // CLDR (integers, v=0):
    //   one  → i % 10 = 1 and i % 100 ≠ 11
    //   few  → i % 10 = 2..4 and i % 100 ≠ 12..14
    //   many → i % 10 = 0 or i % 10 = 5..9 or i % 100 = 11..14
    // Integer samples:
    //   one: 1, 21, 31, 41, 51, 61, 71, 81, 101, 1001, …
    //   few: 2~4, 22~24, 32~34, 42~44, 52~54, 62, 102, 1002, …
    //   many: 0, 5~19, 100, 1000, 10000, …

    func testRussian_categories() {
        assertCategories([
            // one: i%10=1, i%100≠11
            (1, .one), (21, .one), (31, .one), (41, .one), (51, .one),
            (101, .one), (1001, .one),
            // few: i%10=2..4, i%100≠12..14
            (2, .few), (3, .few), (4, .few),
            (22, .few), (23, .few), (24, .few),
            (32, .few), (102, .few), (1002, .few),
            // many: i%10=0 or i%10=5..9 or i%100=11..14
            (0, .many), (5, .many), (6, .many), (7, .many), (8, .many), (9, .many),
            (10, .many), (11, .many), (12, .many), (13, .many), (14, .many),
            (15, .many), (19, .many), (20, .many), (25, .many),
            (100, .many), (111, .many), (112, .many), (114, .many), (211, .many),
        ], language: "ru")
    }

    func testRussian_boundaries() {
        // 11-14 override the mod10 rules
        // i%10=1 but i%100=11 → many (not one)
        assertCategory(.many, for: 11, language: "ru")
        assertCategory(.many, for: 111, language: "ru")
        // i%10=2 but i%100=12 → many (not few)
        assertCategory(.many, for: 12, language: "ru")
        assertCategory(.many, for: 112, language: "ru")
        // i%10=3 but i%100=13 → many (not few)
        assertCategory(.many, for: 13, language: "ru")
        assertCategory(.many, for: 113, language: "ru")
        // i%10=4 but i%100=14 → many (not few)
        assertCategory(.many, for: 14, language: "ru")
        assertCategory(.many, for: 114, language: "ru")
        // 121-124 follow normal mod10 rules
        assertCategory(.one, for: 121, language: "ru")
        assertCategory(.few, for: 122, language: "ru")
        assertCategory(.few, for: 123, language: "ru")
        assertCategory(.few, for: 124, language: "ru")
    }

    func testRussian_largeNumbers() {
        assertCategory(.one, for: 1_000_001, language: "ru")    // i%10=1, i%100=1 → one
        assertCategory(.few, for: 1_000_002, language: "ru")    // i%10=2, i%100=2 → few
        assertCategory(.many, for: 1_000_000, language: "ru")   // i%10=0 → many
        assertCategory(.many, for: 1_000_011, language: "ru")   // i%100=11 → many
    }

    func testRussian_negativeNumbers() {
        assertCategory(.one, for: -1, language: "ru")
        assertCategory(.few, for: -2, language: "ru")
        assertCategory(.few, for: -3, language: "ru")
        assertCategory(.few, for: -4, language: "ru")
        assertCategory(.many, for: -5, language: "ru")
        assertCategory(.many, for: -11, language: "ru")
        assertCategory(.many, for: -12, language: "ru")
        assertCategory(.one, for: -21, language: "ru")
        assertCategory(.few, for: -22, language: "ru")
    }

    // ==========================================
    // MARK: - Slovak (sk)
    // ==========================================
    // CLDR: one → i = 1 and v = 0; few → i = 2..4 and v = 0; other
    // Integer samples: one: 1 | few: 2~4 | other: 0, 5~19, 100, …

    func testSlovak_categories() {
        assertCategories([
            (0, .other), (1, .one),
            (2, .few), (3, .few), (4, .few),
            (5, .other), (10, .other), (100, .other),
        ], language: "sk")
    }

    func testSlovak_negativeNumbers() {
        assertCategory(.one, for: -1, language: "sk")
        assertCategory(.few, for: -2, language: "sk")
        assertCategory(.few, for: -4, language: "sk")
        assertCategory(.other, for: -5, language: "sk")
    }

    // ==========================================
    // MARK: - Spanish (es)
    // ==========================================
    // CLDR: one → n = 1
    //        many → e = 0 and i ≠ 0 and i % 1000000 = 0 and v = 0
    // Integer samples: one: 1 | many: 1000000, … | other: 0, 2~16, 100, …

    func testSpanish_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other),
            (1_000_000, .many), (2_000_000, .many),
            (1_000_001, .other), (500_000, .other),
        ], language: "es")
    }

    func testSpanish_negativeNumbers() {
        assertCategory(.one, for: -1, language: "es")
        assertCategory(.other, for: -2, language: "es")
        assertCategory(.many, for: -1_000_000, language: "es")
    }

    // ==========================================
    // MARK: - Swahili (sw)
    // ==========================================
    // CLDR: one → i = 1 and v = 0
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testSwahili_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (99, .other),
        ], language: "sw")
    }

    func testSwahili_negativeNumbers() {
        assertCategory(.one, for: -1, language: "sw")
        assertCategory(.other, for: -2, language: "sw")
    }

    // ==========================================
    // MARK: - Swedish (sv)
    // ==========================================
    // CLDR: one → i = 1 and v = 0
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testSwedish_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (99, .other),
        ], language: "sv")
    }

    func testSwedish_negativeNumbers() {
        assertCategory(.one, for: -1, language: "sv")
        assertCategory(.other, for: -2, language: "sv")
    }

    // ==========================================
    // MARK: - Tamil (ta)
    // ==========================================
    // CLDR: one → n = 1
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testTamil_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (33, .other),
        ], language: "ta")
    }

    func testTamil_negativeNumbers() {
        assertCategory(.one, for: -1, language: "ta")
        assertCategory(.other, for: -2, language: "ta")
    }

    // ==========================================
    // MARK: - Telugu (te)
    // ==========================================
    // CLDR: one → n = 1
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testTelugu_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (44, .other),
        ], language: "te")
    }

    func testTelugu_negativeNumbers() {
        assertCategory(.one, for: -1, language: "te")
        assertCategory(.other, for: -2, language: "te")
    }

    // ==========================================
    // MARK: - Thai (th)
    // ==========================================
    // CLDR: other (always — no plural distinction)
    // Integer samples: other: 0~15, 100, 1000, …

    func testThai_categories() {
        for count in [0, 1, 2, 10, 100] {
            assertCategory(.other, for: count, language: "th")
        }
    }

    func testThai_negativeNumbers() {
        for count in [-1, -5, -100] {
            assertCategory(.other, for: count, language: "th")
        }
    }

    // ==========================================
    // MARK: - Turkish (tr)
    // ==========================================
    // CLDR: one → n = 1
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testTurkish_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (5, .other), (100, .other),
        ], language: "tr")
    }

    func testTurkish_negativeNumbers() {
        assertCategory(.one, for: -1, language: "tr")
        assertCategory(.other, for: -2, language: "tr")
    }

    // ==========================================
    // MARK: - Ukrainian (uk)
    // ==========================================
    // CLDR: Same rules as Russian (ru)
    //   one  → i % 10 = 1 and i % 100 ≠ 11
    //   few  → i % 10 = 2..4 and i % 100 ≠ 12..14
    //   many → i % 10 = 0 or i % 10 = 5..9 or i % 100 = 11..14
    // Integer samples:
    //   one: 1, 21, 31, … | few: 2~4, 22~24, … | many: 0, 5~19, 100, …

    func testUkrainian_categories() {
        assertCategories([
            (1, .one), (21, .one), (101, .one),
            (2, .few), (3, .few), (4, .few), (22, .few),
            (0, .many), (5, .many), (11, .many), (12, .many), (14, .many), (100, .many),
        ], language: "uk")
    }

    func testUkrainian_negativeNumbers() {
        assertCategory(.one, for: -1, language: "uk")
        assertCategory(.few, for: -2, language: "uk")
        assertCategory(.many, for: -5, language: "uk")
        assertCategory(.one, for: -21, language: "uk")
        assertCategory(.many, for: -11, language: "uk")
    }

    // ==========================================
    // MARK: - Urdu (ur)
    // ==========================================
    // CLDR: one → i = 1 and v = 0
    // Integer samples: one: 1 | other: 0, 2~16, 100, …

    func testUrdu_categories() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (50, .other),
        ], language: "ur")
    }

    func testUrdu_negativeNumbers() {
        assertCategory(.one, for: -1, language: "ur")
        assertCategory(.other, for: -2, language: "ur")
    }

    // ==========================================
    // MARK: - Vietnamese (vi)
    // ==========================================
    // CLDR: other (always — no plural distinction)
    // Integer samples: other: 0~15, 100, 1000, …

    func testVietnamese_categories() {
        for count in [0, 1, 2, 10, 100] {
            assertCategory(.other, for: count, language: "vi")
        }
    }

    func testVietnamese_negativeNumbers() {
        for count in [-1, -5, -100] {
            assertCategory(.other, for: count, language: "vi")
        }
    }

    // ==========================================
    // MARK: - Welsh (cy)
    // ==========================================
    // CLDR: zero → n = 0; one → n = 1; two → n = 2;
    //        few → n = 3; many → n = 6; other
    // Integer samples:
    //   zero: 0 | one: 1 | two: 2 | few: 3 | many: 6
    //   other: 4, 5, 7~20, 100, 1000, …

    func testWelsh_categories() {
        assertCategories([
            (0, .zero), (1, .one), (2, .two), (3, .few),
            (4, .other), (5, .other), (6, .many),
            (7, .other), (8, .other), (9, .other), (10, .other),
            (100, .other), (1000, .other),
        ], language: "cy")
    }

    func testWelsh_negativeNumbers() {
        assertCategory(.one, for: -1, language: "cy")
        assertCategory(.two, for: -2, language: "cy")
        assertCategory(.few, for: -3, language: "cy")
        assertCategory(.other, for: -4, language: "cy")
        assertCategory(.many, for: -6, language: "cy")
        assertCategory(.other, for: -7, language: "cy")
    }

    // ==========================================
    // MARK: - Zulu (zu)
    // ==========================================
    // CLDR: one → i = 0 or n = 1
    // Integer samples: one: 0, 1 | other: 2~17, 100, …

    func testZulu_categories() {
        assertCategories([
            (0, .one), (1, .one), (2, .other), (20, .other),
        ], language: "zu")
    }

    func testZulu_negativeNumbers() {
        assertCategory(.one, for: -1, language: "zu")
        assertCategory(.other, for: -2, language: "zu")
    }

    // ==========================================
    // MARK: - Default Fallback (unknown languages)
    // ==========================================
    // Unknown languages should fall back to CLDR default: one (n=1), other.

    func testDefaultFallback_unknownLanguage() {
        assertCategories([
            (0, .other), (1, .one), (2, .other), (10, .other), (100, .other),
        ], language: "xx")
    }

    func testDefaultFallback_anotherUnknownLanguage() {
        assertCategories([
            (0, .other), (1, .one), (2, .other),
        ], language: "zzz")
    }

    func testDefaultFallback_negativeNumbers() {
        assertCategory(.one, for: -1, language: "xx")
        assertCategory(.other, for: -2, language: "xx")
    }

    // ==========================================
    // MARK: - Custom Plural Rules
    // ==========================================

    func testCustomRule_overridesBuiltIn() {
        let customRule: PluralRule = { _, _ in 0 }
        let result = PluralCategory.category(for: 5, locale: locale("en"), customRules: ["en": customRule])
        XCTAssertEqual(result, .zero)
    }

    func testCustomRule_indexClamping_tooHigh() {
        let customRule: PluralRule = { _, _ in 999 }
        let result = PluralCategory.category(for: 1, locale: locale("en"), customRules: ["en": customRule])
        XCTAssertEqual(result, .other) // clamped to index 5
    }

    func testCustomRule_indexClamping_negative() {
        let customRule: PluralRule = { _, _ in -5 }
        let result = PluralCategory.category(for: 1, locale: locale("en"), customRules: ["en": customRule])
        XCTAssertEqual(result, .zero) // clamped to index 0
    }

    func testCustomRule_onlyAffectsTargetLanguage() {
        let customRule: PluralRule = { _, _ in 0 }
        let rules = ["fr": customRule]

        let enResult = PluralCategory.category(for: 5, locale: locale("en"), customRules: rules)
        XCTAssertEqual(enResult, .other, "English should use built-in rules")

        let frResult = PluralCategory.category(for: 5, locale: locale("fr"), customRules: rules)
        XCTAssertEqual(frResult, .zero, "French should use custom rule")
    }

    func testCustomRule_receivesCorrectParameters() {
        var capturedChoice: Int?
        var capturedLength: Int?
        let customRule: PluralRule = { choice, length in
            capturedChoice = choice
            capturedLength = length
            return 5
        }

        _ = PluralCategory.category(for: 42, locale: locale("en"), customRules: ["en": customRule])
        XCTAssertEqual(capturedChoice, 42)
        XCTAssertEqual(capturedLength, 6) // 6 CLDR categories
    }

    // ==========================================
    // MARK: - PluralCategory Type Tests
    // ==========================================

    func testCaseIterable_allCases() {
        let allCases = PluralCategory.allCases
        XCTAssertEqual(allCases.count, 6)
        XCTAssertEqual(allCases, [.zero, .one, .two, .few, .many, .other])
    }

    func testCodable_roundTrip() throws {
        for category in PluralCategory.allCases {
            let data = try JSONEncoder().encode(category)
            let decoded = try JSONDecoder().decode(PluralCategory.self, from: data)
            XCTAssertEqual(category, decoded)
        }
    }

    func testRawValue_strings() {
        XCTAssertEqual(PluralCategory.zero.rawValue, "zero")
        XCTAssertEqual(PluralCategory.one.rawValue, "one")
        XCTAssertEqual(PluralCategory.two.rawValue, "two")
        XCTAssertEqual(PluralCategory.few.rawValue, "few")
        XCTAssertEqual(PluralCategory.many.rawValue, "many")
        XCTAssertEqual(PluralCategory.other.rawValue, "other")
    }
}
