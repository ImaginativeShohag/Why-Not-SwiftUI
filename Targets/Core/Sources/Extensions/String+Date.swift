//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

public extension String {
    /// Converts string to a `Date` object using the specified format.
    /// - Parameters:
    ///   - dateFormat: Sets the input `dateFormat`.
    ///   - timeZone: Sets the input `timeZone`.
    /// - Returns: An optional `Date` object. Returns `nil` if fails.
    func toDate(
        dateFormat: String = "yyyy-MM-dd HH:mm:ss",
        timeZone: TimeZone = .autoupdatingCurrent
    ) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = timeZone

        return dateFormatter.date(from: self)
    }

    /// Change date format.
    /// - Parameters:
    ///   - inputDateFormat: Sets the input `dateFormat`. The default is `yyyy-MM-dd HH:mm:ss`.
    ///   - inputTimeZone: Sets the input `timeZone`. The default is `.pst`.
    ///   - outputDateFormat: Sets the output `dateFormat`. The default is `yyyy-MM-dd HH:mm:ss`.
    ///   - outputTimeZone: Sets the output `timeZone`. The default is `.autoupdatingCurrent`.
    /// - Returns: Formatted date as an optional `String`. Returns `nil` if fails.
    func changeDateFormat(
        from inputDateFormat: String = "yyyy-MM-dd HH:mm:ss",
        fromTimeZone inputTimeZone: TimeZone,
        to outputDateFormat: String = "yyyy-MM-dd HH:mm:ss",
        toTimeZone outputTimeZone: TimeZone = .autoupdatingCurrent
    ) -> String? {
        toDate(
            dateFormat: inputDateFormat,
            timeZone: inputTimeZone
        ).toString(
            dateFormat: outputDateFormat,
            timeZone: outputTimeZone
        )
    }

    ///  Provides a date using current timezone.
    /// - Returns: `Date` in "yyyy-MM-dd" format. It will use local timezone as source timezone.
    func toDateFromYMDWithLocalTZ() throws -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: self) else {
            throw DateConvertError(description: "Could not parse")
        }
        return date
    }

    @available(*, deprecated, renamed: "toDate(dateFormat:timeZone:)", message: "Please use `toDate()`.")
    /// Converted string to a `Date` object using the specified format.
    ///
    /// - Returns: Converted `Date`. Returns `nil` if it fails.
    func getDate(
        format: String = "yyyy-MM-dd"
    ) -> Date? {
        if isEmpty {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        return dateFormatter.date(from: self)
    }
}

public extension Optional where Wrapped == String {
    /// An optional implementation of `toDate()`.
    /// - Parameters:
    ///   - dateFormat: Sets the input `dateFormat`.
    ///   - timeZone: Sets the input `timeZone`.
    /// - Returns: An optional `Date` object. Returns `nil` if fails.
    func toDate(
        dateFormat: String = "yyyy-MM-dd HH:mm:ss",
        timeZone: TimeZone = .autoupdatingCurrent
    ) -> Date? {
        return self?.toDate(
            dateFormat: dateFormat,
            timeZone: timeZone
        )
    }

    /// An optional implementation of `changeDateFormat()`.
    /// - Parameters:
    ///   - inputDateFormat: Sets the input `dateFormat`. The default is `yyyy-MM-dd HH:mm:ss`.
    ///   - inputTimeZone: Sets the input `timeZone`. The default is `.pst`.
    ///   - outputDateFormat: Sets the output `dateFormat`. The default is `yyyy-MM-dd HH:mm:ss`.
    ///   - outputTimeZone: Sets the output `timeZone`. The default is `.autoupdatingCurrent`.
    /// - Returns: Formatted date as optional `String`. Returns `nil` if fails.
    func changeDateFormat(
        from inputDateFormat: String = "yyyy-MM-dd HH:mm:ss",
        fromTimeZone inputTimeZone: TimeZone,
        to outputDateFormat: String = "yyyy-MM-dd HH:mm:ss",
        toTimeZone outputTimeZone: TimeZone = .autoupdatingCurrent
    ) -> String? {
        return self?.changeDateFormat(
            from: inputDateFormat,
            fromTimeZone: inputTimeZone,
            to: outputDateFormat,
            toTimeZone: outputTimeZone
        )
    }
}

struct DateConvertError: Error {
    let description: String
}
