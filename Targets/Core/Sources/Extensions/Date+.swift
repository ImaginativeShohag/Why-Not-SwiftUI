//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

public extension Date {
    /// Returns start date of day.
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// Returns a date add extra 24 hours from startOfDay.
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    /// Returns start date of month.
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    /// Returns a date that provide extra one month from the startOfMonth.
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }

    /// Returns `true` if self date is between two provided date otherwise return `false`.
    ///
    /// - Returns: `true` if self date is between two provided date else returns `false`.
    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self) == compare(date2)
    }

    /// Returns yesterday date.
    static var yesterday: Date { return Date().dayBefore }

    /// Returns tomorrow date.
    static var tomorrow: Date { return Date().dayAfter }

    /// Returns previous day.
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }

    /// Returns next day.
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }

    /// Returns noon time.
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }

    /// Returns  current day.
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }

    /// Returns  current month.
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    /// Returns  current year.
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    /// Returns true if next day is not current month month otherwise return false.
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }

    /// Returns true if the day is less than current date otherwise return false.
    var isPastDate: Bool {
        return self < Date()
    }

    /// Returns date by adding given number of week.
    ///
    /// - Returns: `Date` adding given week.
    func addWeek(noOfWeeks: Int) -> Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: noOfWeeks, to: self)!
    }
    
    /// Converts the date object to `String`.
    /// - Parameters:
    ///   - dateFormat: The format of the output `String`. The default is `yyyy-MM-dd HH:mm:ss`
    ///   - timeZone: Sets the `timeZone` for the output `String`
    /// - Returns: An optional `String` representing the provided date using specified format. Returns `nil` if fails.
    func toString(
        dateFormat: String = "yyyy-MM-dd HH:mm:ss",
        timeZone: TimeZone = .autoupdatingCurrent
    ) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = timeZone

        return dateFormatter.string(from: self)
    }

    /// Returns time Interval between given date to current date.
    /// - Parameters:
    ///   - allowedUnits: Sets the `allowedUnits` of `DateComponentsFormatter`. The default is `[.second, .minute, .hour, .day, .weekOfMonth, .month, .year]`.
    ///   - maximumUnitCount: Sets the `maximumUnitCount` of `DateComponentsFormatter`. The default is `1`.
    ///   - unitsStyle: Sets the `unitsStyle` of `DateComponentsFormatter`. The default is `.full`.
    /// - Returns: Optional `String` that describes the time interval till current date. Returns `nil` if fails.
    func timeIntervalSinceNow(
        allowedUnits: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth, .month, .year],
        maximumUnitCount: Int = 1,
        unitsStyle: DateComponentsFormatter.UnitsStyle = .full
    ) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.maximumUnitCount = maximumUnitCount
        formatter.unitsStyle = unitsStyle

        return formatter.string(from: self, to: Date())
    }
}


public extension Optional where Wrapped == Date {
    /// An optional implementation of the `toString()` function.
    /// - Parameters:
    ///  - dateFormat: Sets the output `dateFormat`. The default is `yyyy-MM-dd HH:mm:ss`.
    ///  - timeZone: Sets the output `timeZone`. The default is `.autoupdatingCurrent`.
    /// - Returns: An optional `String` representing the provided date using specified format. Returns `nil` if fails.
    func toString(
        dateFormat: String = "yyyy-MM-dd HH:mm:ss",
        timeZone: TimeZone = .autoupdatingCurrent
    ) -> String? {
        self?.toString(
            dateFormat: dateFormat,
            timeZone: timeZone
        )
    }

    /// An optional implementation of the `timeIntervalSinceNow()` function.
    /// - Parameters:
    ///   - allowedUnits: Sets the `allowedUnits` of `DateComponentsFormatter`. The default is `[.second, .minute, .hour, .day, .weekOfMonth, .month, .year]`.
    ///   - maximumUnitCount: Sets the `maximumUnitCount` of `DateComponentsFormatter`. The default is `1`.
    ///   - unitsStyle: Sets the `unitsStyle` of `DateComponentsFormatter`. The default is `.full`.
    /// - Returns: Optional `String` that describes the time interval till current date. Returns `nil` if fails.
    func timeIntervalSinceNow(
        allowedUnits: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth, .month, .year],
        maximumUnitCount: Int = 1,
        unitsStyle: DateComponentsFormatter.UnitsStyle = .full
    ) -> String? {
        return self?.timeIntervalSinceNow(
            allowedUnits: allowedUnits,
            maximumUnitCount: maximumUnitCount,
            unitsStyle: unitsStyle
        )
    }
}
