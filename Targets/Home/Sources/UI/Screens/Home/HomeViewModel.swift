//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import UIKit

@Observable
class HomeViewModel {
    let isJailBroken = UIDevice.current.isJailBroken
}
