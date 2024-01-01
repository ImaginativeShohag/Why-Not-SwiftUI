//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

public extension Calendar {
    /// Returns number of days between two date.
    ///
    /// - Returns: Number of days as `Int`.
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)

        return numberOfDays.day!
    }
}
