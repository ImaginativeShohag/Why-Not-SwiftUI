//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

public enum Config {
    static let HOST_URL = Bundle.main.object(forInfoDictionaryKey: "CONF_HOST_URL") as! String
}
