//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// - Returns: `True` if the `URL` is a QuickTime local video.
extension URL {
    func isLocalQuickTimeVideoURL() -> Bool {
        return scheme == "file" && host == nil && absoluteString.fileExtension().lowercased() == "mov"
    }
}
