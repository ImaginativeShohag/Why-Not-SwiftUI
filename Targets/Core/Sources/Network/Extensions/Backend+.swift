//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

public extension Backend {
    convenience init() {
        self.init(
            session: Env.shared.defaultSession
        )
    }
}
