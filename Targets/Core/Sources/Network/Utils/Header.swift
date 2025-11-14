//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import Foundation

public enum Header {
    /// This is the common API authentication header.
    public static func getAuthHeaders() -> [String: String] {
        [
            "Authorization": Preferences.authToken ?? "",
        ]
    }
}
