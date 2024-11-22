//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

extension String {
    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}
