//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import UIKit

public extension UIDevice {
    var isPhone: Bool {
        return userInterfaceIdiom == .phone
    }
}
