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

    // MARK: - Single Argument

    func testPerformance_SafeFormat_SingleObjectArgument() {
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string("Hello, %@!", arguments: ["World"], key: key, module: module)
            }
        }
    }

    func testPerformance_Baseline_SingleObjectArgument() {
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

    func testPerformance_SafeFormat_FiveMixedArguments() {
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

    func testPerformance_Baseline_FiveMixedArguments() {
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

    func testPerformance_SafeFormat_TenMixedArguments() {
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

    func testPerformance_Baseline_TenMixedArguments() {
        measure {
            for _ in 0..<iterations {
                _ = String(format: tenArgFormat, arguments: tenArgValues)
            }
        }
    }

    // MARK: - Mismatch / Fallback Path

    func testPerformance_SafeFormat_MismatchFallback() {
        // The crash-avoidance path: validation fails and the verbatim format string is returned
        // without ever calling String(format:). Should be cheaper than the happy path.
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string("%d items", arguments: [3.7], key: key, module: module)
            }
        }
    }

    func testPerformance_SafeFormat_FiveArgumentsAllWrong() {
        // Every one of the five arguments mismatches its specifier (object↔scalar swaps,
        // int↔double swaps). SafeFormat must bail to the verbatim format string.
        let wrongValues: [CVarArg] = [1, 2.0, "str", 4, 5.0]
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string(fiveArgFormat, arguments: wrongValues, key: key, module: module)
            }
        }
    }

    func testPerformance_SafeFormat_TenArgumentsAllWrong() {
        // All ten arguments mismatch their specifiers — the worst case for a fully-validated
        // fallback before bailing to the verbatim string.
        let wrongValues: [CVarArg] = [1, 2.0, "str", 4, 5.0, 6, 7.0, "str", 9, 10.0]
        measure {
            for _ in 0..<iterations {
                _ = SafeFormat.string(tenArgFormat, arguments: wrongValues, key: key, module: module)
            }
        }
    }

    func testPerformance_SafeFormat_TenArgumentsLastWrong() {
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

    // MARK: - Parser In Isolation

    func testPerformance_ParserScan() {
        // Isolates the scan cost — the dominant part of SafeFormat's added work.
        measure {
            for _ in 0..<iterations {
                _ = FormatSpecifierParser.scan("Order #%@ has %d items totaling %.2f")
            }
        }
    }

    // MARK: - End-to-End via String.localize

    @MainActor
    func testPerformance_EndToEnd_LocalizeWithArgument() {
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
    func testPerformance_EndToEnd_LocalizePluralWithArgument() {
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
