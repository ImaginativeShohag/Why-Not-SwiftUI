@testable import LocalizeKit
import CoreGraphics
import XCTest

/// Performance benchmarks for the crash-safe `SafeFormat` interpolation layer.
///
/// `SafeFormat` adds work to every interpolated `.localize(with:)` call: it scans the format
/// string with `FormatSpecifierParser` and type-checks each `CVarArg` before delegating to
/// `String(format:)`. These benchmarks quantify that overhead so regressions are visible, and
/// pair each `SafeFormat` measurement with the equivalent bare `String(format:)` baseline so the
/// added cost can be read directly from the two numbers.
///
/// Run with:
/// ```
/// tuist test 'WhyNotSwiftUI Development' --test-targets LocalizeKitTests/SafeFormatPerformanceTests
/// ```
final class SafeFormatPerformanceTests: XCTestCase {
    // MARK: - Constants

    private let key = "perf_key"
    private let module = "Store"

    /// Number of iterations per `measure` block so the per-call cost is large enough to be
    /// resolved above timer noise.
    private let iterations = 10_000

    // MARK: - Fast Path (No Arguments, No Specifiers)

    func testPerformance_whenNoArgumentsAndNoSpecifiers_shouldMeasureFastPath() {
        // The early-return branch (arguments.isEmpty && !format.contains("%")) — the most common
        // real call shape (plain translated copy with no interpolation), skipping scan and validation.
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string("Welcome to the store!", arguments: [], key: key, module: module)
            }
        }
    }

    // MARK: - Single Argument

    func testPerformance_whenSafeFormatSingleObjectArgument_shouldMeasureOverhead() {
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string("Hello, %@!", arguments: ["World"], key: key, module: module)
            }
        }
    }

    func testPerformance_whenBaselineSingleObjectArgument_shouldMeasureBaseline() {
        // Bare String(format:) with no validation — the lower bound SafeFormat is compared against.
        measure {
            for _ in 0..<iterations {
                _ = String(format: "Hello, %@!", arguments: ["World"])
            }
        }
    }

    // MARK: - Five Mixed Arguments

    /// Format string and matching arguments exercising all three common specifier kinds
    /// (`%@`, `%d`, `%.2f`) across five argument slots.
    private let fiveArgFormat = "Order #%@ has %d items totaling %.2f, ref %@, qty %d"
    private let fiveArgValues: [CVarArg] = ["A1", 3, 9.5, "REF", 7]

    func testPerformance_whenSafeFormatFiveMixedArguments_shouldMeasureOverhead() {
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string(
                    fiveArgFormat,
                    arguments: fiveArgValues,
                    key: key,
                    module: module
                )
            }
        }
    }

    func testPerformance_whenBaselineFiveMixedArguments_shouldMeasureBaseline() {
        measure {
            for _ in 0..<iterations {
                _ = String(format: fiveArgFormat, arguments: fiveArgValues)
            }
        }
    }

    // MARK: - Ten Mixed Arguments

    /// Format string and matching arguments doubling the five-argument case to ten slots, so the
    /// per-argument validation cost can be read against the five-argument numbers.
    private let tenArgFormat = "%@ %d %.2f %@ %d, then %@ %d %.2f %@ %d"
    private let tenArgValues: [CVarArg] = ["A1", 3, 9.5, "REF", 7, "B2", 1, 2.5, "C3", 4]

    func testPerformance_whenSafeFormatTenMixedArguments_shouldMeasureOverhead() {
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string(
                    tenArgFormat,
                    arguments: tenArgValues,
                    key: key,
                    module: module
                )
            }
        }
    }

    func testPerformance_whenBaselineTenMixedArguments_shouldMeasureBaseline() {
        measure {
            for _ in 0..<iterations {
                _ = String(format: tenArgFormat, arguments: tenArgValues)
            }
        }
    }

    // MARK: - Mismatch / Fallback Path

    func testPerformance_whenSafeFormatMismatchFallback_shouldMeasureFallbackPath() {
        // The crash-avoidance path: validation fails and the verbatim format string is returned
        // without ever calling String(format:). Should be cheaper than the happy path.
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string("%d items", arguments: [3.7], key: key, module: module)
            }
        }
    }

    func testPerformance_whenFiveArgumentsAllWrong_shouldMeasureFallbackPath() {
        // Every one of the five arguments mismatches its specifier (object↔scalar swaps,
        // int↔double swaps). SafeFormat must bail to the verbatim format string.
        let wrongValues: [CVarArg] = [1, 2.0, "str", 4, 5.0]
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string(fiveArgFormat, arguments: wrongValues, key: key, module: module)
            }
        }
    }

    func testPerformance_whenTenArgumentsAllWrong_shouldMeasureFallbackPath() {
        // All ten arguments mismatch their specifiers — the worst case for a fully-validated
        // fallback before bailing to the verbatim string.
        let wrongValues: [CVarArg] = [1, 2.0, "str", 4, 5.0, 6, 7.0, "str", 9, 10.0]
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string(tenArgFormat, arguments: wrongValues, key: key, module: module)
            }
        }
    }

    func testPerformance_whenTenArgumentsLastWrong_shouldMeasureFallbackPath() {
        // Nine arguments match their specifiers and only the final `%d` slot is wrong (a Double in
        // an integer slot). Contrasted with the all-wrong case, this exercises the path where most
        // arguments pass validation before the single mismatch trips the verbatim fallback.
        let lastWrongValues: [CVarArg] = ["A1", 3, 9.5, "REF", 7, "B2", 1, 2.5, "C3", 4.0]
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string(tenArgFormat, arguments: lastWrongValues, key: key, module: module)
            }
        }
    }

    // MARK: - Ambiguous / Dynamic-Width Fallback

    func testPerformance_whenAmbiguousPercent_shouldMeasureEarlyBailoutPath() {
        // An unrecognised %X sequence (%C) forces the ambiguous-percent guard to bail out
        // before any per-argument validation runs.
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string("Reading %C sensor", arguments: [3], key: key, module: module)
            }
        }
    }

    func testPerformance_whenTrailingBarePercentNoArguments_shouldMeasureEarlyBailoutPath() {
        // A translated string ending in an unescaped '%' (e.g. "Save 50%"). The scan records the
        // trailing bare '%' as an ambiguous percent, so SafeFormat bails to the verbatim string
        // without ever calling String(format:) — the scan + ambiguous-percent guard path for a
        // common decorative-percent shape.
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string("Save 50%", arguments: [], key: key, module: module)
            }
        }
    }

    func testPerformance_whenDynamicWidth_shouldMeasureEarlyBailoutPath() {
        // A `*` (dynamic width/precision) specifier forces bailout before positional/sequential
        // validation runs.
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string("%*d", arguments: [5, 3], key: key, module: module)
            }
        }
    }

    // MARK: - Positional Specifiers

    func testPerformance_whenPositionalSpecifiers_shouldMeasureOverhead() {
        // Positional specifiers (%1$@ etc.) build an [Int: FormatArgumentType] dictionary in
        // expectedTypesByArgumentIndex instead of a simple sequential increment — measured
        // separately from the sequential-only cases above.
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string(
                    "%2$@ has %1$d items, ref %3$@",
                    arguments: [3, "A1", "REF"],
                    key: key,
                    module: module
                )
            }
        }
    }

    // MARK: - Parser In Isolation

    func testPerformance_whenParserScansFormat_shouldMeasureScanCost() {
        // Isolates the scan cost — the dominant part of SafeFormat's added work.
        measure {
            for _ in 0..<iterations {
                _ = FormatSpecifierParser.scan("Order #%@ has %d items totaling %.2f")
            }
        }
    }

    func testPerformance_whenParserScansLongFormat_shouldMeasureScanCostAtScale() {
        // A longer format string with many specifiers and several decorative (non-specifier)
        // percents mixed in, to catch scan-time blowup that a 3-specifier string wouldn't surface.
        let longFormat = "Order #%@ (%d%% complete) has %d items totaling %.2f, ref %@, "
            + "qty %d, discount %d%%, tax %.2f, code %@, status %d%%, note %@"
        measure {
            for _ in 0..<iterations {
                _ = FormatSpecifierParser.scan(longFormat)
            }
        }
    }

    // MARK: - End-to-End via String.localize

    @MainActor
    func testPerformance_whenLocalizeWithArgumentEndToEnd_shouldMeasureFullPath() {
        // Realistic call path including module extraction and LocalizationManager lookup
        // (no translation loaded, so it falls back to the default format string before formatting).
        let file = "Store/Sources/UI/TestScreen.swift"
        measure {
            for _ in 0..<iterations {
                _ = "greeting".localize(
                    default: "Hello, %@!",
                    comment: nil,
                    with: "World",
                    file: file
                )
            }
        }
    }

    @MainActor
    func testPerformance_whenLocalizePluralWithArgumentEndToEnd_shouldMeasureFullPath() {
        // Same realistic call path as above but through the plural overload: it resolves the
        // plural category, falls back to the default format string (no translation loaded), then
        // routes through SafeFormat for the interpolated count.
        let file = "Store/Sources/UI/TestScreen.swift"
        let plurals: [PluralCategory: String] = [
            .zero: "No items",
            .one: "1 item",
            .other: "%d items",
        ]
        measure {
            for _ in 0..<iterations {
                _ = "items_count".localize(
                    defaultPlural: plurals,
                    comment: nil,
                    count: 5,
                    with: 5,
                    file: file
                )
            }
        }
    }
}
