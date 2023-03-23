//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

extension URL {
    /// - Returns: The file size in KB.
    func fileSize() -> Int {
        var fileSize = 0.0
        var fileSizeValue = 0.0
        try? fileSizeValue = (self.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
        if fileSizeValue > 0.0 {
            fileSize = (Double(fileSizeValue) / 1000)
        }
        return Int(fileSize)
    }
}
