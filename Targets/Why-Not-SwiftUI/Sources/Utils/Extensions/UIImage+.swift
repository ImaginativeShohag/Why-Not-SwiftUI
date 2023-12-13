//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import UIKit

extension UIImage {
    /// - Returns: The file size in KB.
    func fileSize() -> Int {
        guard let imageData = jpegData(compressionQuality: 1) else { return 0 }
        return imageData.count / 1000
    }
}
