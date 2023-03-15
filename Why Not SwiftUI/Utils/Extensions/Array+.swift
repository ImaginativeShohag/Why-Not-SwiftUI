//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

extension [String] {
    /// Combine string array separated by a comma.
    ///
    /// Usage:
    ///
    /// ```swift
    /// print(["a", "b", "c"].commaSeparatedString()) // a, b, c
    /// print([].commaSeparatedString(emptyValue: "N/A")) // N/A
    /// ```
    func commaSeparatedString(emptyValue: String = "") -> String {
        if count > 0 {
            return map { $0 }.joined(separator: ", ")
        } else {
            return emptyValue
        }
    }
}
