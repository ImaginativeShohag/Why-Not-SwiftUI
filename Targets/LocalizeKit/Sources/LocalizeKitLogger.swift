import Foundation
import OSLog

/// Internal DEBUG-only logger for LocalizeKit
/// - Note: All logging is completely removed in Release builds
/// - Note: Internal visibility - not part of LocalizeKit's public API
enum LocalizeKitLogger {

    // MARK: - Configuration

    /// Logger subsystem identifier
    private static let subsystem = "com.localizekit"

    /// Logger category (module name)
    private static let category = "LocalizeKit"

    /// OSLog instance
    private static let logger = Logger(subsystem: subsystem, category: category)

    // MARK: - Logging Methods

    /// Log debug message
    /// - Parameters:
    ///   - message: Message to log
    ///   - file: Source file (auto-populated)
    ///   - line: Line number (auto-populated)
    ///   - function: Function name (auto-populated)
    static func d(
        _ message: String,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
        #if DEBUG
        logger.debug("[\(extractFileName(file))]:\(line) \(function) -> \(message)")
        #endif
    }

    /// Log error message
    /// - Parameters:
    ///   - message: Message to log
    ///   - file: Source file (auto-populated)
    ///   - line: Line number (auto-populated)
    ///   - function: Function name (auto-populated)
    static func e(
        _ message: String,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
        #if DEBUG
        logger.error("[\(extractFileName(file))]:\(line) \(function) -> \(message)")
        #endif
    }

    /// Log warning message
    /// - Parameters:
    ///   - message: Message to log
    ///   - file: Source file (auto-populated)
    ///   - line: Line number (auto-populated)
    ///   - function: Function name (auto-populated)
    static func w(
        _ message: String,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
        #if DEBUG
        logger.warning("[\(extractFileName(file))]:\(line) \(function) -> \(message)")
        #endif
    }

    // MARK: - Utilities

    /// Extract filename from full file path
    /// - Parameter file: Full file path from #fileID
    /// - Returns: Just the filename
    private static func extractFileName(_ file: String) -> String {
        let components = file.split(separator: "/")
        return components.last.map(String.init) ?? file
    }
}
