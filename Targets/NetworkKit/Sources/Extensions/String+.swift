//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

extension String {
    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}

extension Optional where Wrapped == String {
    /// Check if the String is blank or not.
    ///
    /// - Returns: `true` only if it is `nil`, empty or consists only whitespace and newline characters.
    var isBlank: Bool {
        return self?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }
}
