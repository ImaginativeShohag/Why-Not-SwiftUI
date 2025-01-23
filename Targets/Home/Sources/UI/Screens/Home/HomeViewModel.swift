//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import UIKit

@MainActor
@Observable
class HomeViewModel {
    let isJailBroken = UIDevice.current.isJailBroken
}
