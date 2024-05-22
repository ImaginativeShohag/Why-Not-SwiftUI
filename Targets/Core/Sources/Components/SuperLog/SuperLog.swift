//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import OSLog

/// Enum which maps an appropriate symbol which added as prefix for each log message
///
/// - e: Log type error
/// - i: Log type info
/// - d: Log type debug
/// - v: Log type verbose
/// - w: Log type warning
/// - c: Log type critical
private enum LogEvent: String {
    case v = "[💬]" // verbose
    case d = "[🐞]" // debug
    case i = "[ℹ️]" // info
    case e = "[‼️]" // error
    case w = "[⚠️]" // warning
    case c = "[🔥]" // critical
}

/// Wrapping Swift.print() within DEBUG flag.
///
/// - Note: `print()` might cause [security vulnerabilities](https://codifiedsecurity.com/mobile-app-security-testing-checklist-ios/).
///
/// - Parameter object: The object which is to be logged.
///
public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    // Only allowing in DEBUG mode
    #if DEBUG
        if SuperLog.isEnabled {
            Swift.print(items, separator: separator, terminator: terminator)
        }
    #endif
}

/// **SuperLog** is a `Logger` wrapper for logging.
///
/// - Note: **SuperLog** only executes `Logger` when `DEBUG` flag is `true`.
/// - Note: For SwiftUI previews, it use `Swift.print()` instead of `Logger`.
public class SuperLog {
    // Restrict object creation.
    private init() {}

    /// Enable or disable the library.
    public static var isEnabled: Bool = true

    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }

    private static var isLoggingEnabled: Bool {
        #if DEBUG
            if isEnabled {
                return true
            }
            return false
        #else
            return false
        #endif
    }

    // MARK: - Logging methods

    /// Logs messages verbosely on console with prefix [💬].
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where logging to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func v(_ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        printLog(type: LogEvent.v, object, filename: filename, line: line, column: column, funcName: funcName)
    }

    /// Logs debug messages on console with prefix [🐞].
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where logging to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func d(_ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        printLog(type: LogEvent.d, object, filename: filename, line: line, column: column, funcName: funcName)
    }

    /// Logs info messages on console with prefix [ℹ️].
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where logging to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func i(_ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        printLog(type: LogEvent.i, object, filename: filename, line: line, column: column, funcName: funcName)
    }

    /// Logs error messages on console with prefix [‼️].
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where logging to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func e(_ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        printLog(type: LogEvent.e, object, filename: filename, line: line, column: column, funcName: funcName)
    }

    /// Logs warnings verbosely on console with prefix [⚠️].
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where logging to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func w(_ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        printLog(type: LogEvent.w, object, filename: filename, line: line, column: column, funcName: funcName)
    }

    /// Logs critical events on console with prefix [🔥].
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where logging to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func c(_ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        printLog(type: LogEvent.c, object, filename: filename, line: line, column: column, funcName: funcName)
    }

    /// Format parameters and print out the log.
    private class func printLog(type: LogEvent, _ object: Any, filename: String, line: Int, column: Int, funcName: String) {
        if isLoggingEnabled {
            let objectAsString = "\(object)"
            let mainFileName = sourceFileName(filePath: filename)
            let message = "\(Date().toString()) \(type.rawValue)[\(mainFileName)]:\(line):\(column) \(funcName) -> \(objectAsString)"
            let logger = Logger(subsystem: Logger.subsystem, category: mainFileName)

            switch type {
            case .v:
                logger.log("\(message)")

            case .d:
                logger.debug("\(message)")

            case .i:
                logger.info("\(message)")

            case .e:
                logger.error("\(message)")

            case .w:
                logger.warning("\(message)")

            case .c:
                logger.critical("\(message)")
            }

            if ProcessInfo.processInfo.isSwiftUIPreview {
                print(message)
            }
        }
    }

    /// Extract the file name from the file path.
    ///
    /// - Parameter filePath: Full file path in bundle
    /// - Returns: File Name with extension
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

// MARK: - Extensions

private extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    static var subsystem = Bundle.main.bundleIdentifier!
}

private extension Date {
    func toString() -> String {
        return SuperLog.dateFormatter.string(from: self as Date)
    }
}
