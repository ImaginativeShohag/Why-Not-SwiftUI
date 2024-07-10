//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import Foundation

enum Header {
    /// This is the common API authentication header.
    static func getAuthHeaders() -> [String: String] {
        [
            "Authorization": Preferences.authToken ?? "",
        ]
    }
}
