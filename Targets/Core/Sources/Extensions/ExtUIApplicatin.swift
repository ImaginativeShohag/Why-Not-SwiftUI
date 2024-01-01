//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import UIKit

public extension UIApplication {
    var keyWindow: UIWindow? {
        return UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
    }
}
