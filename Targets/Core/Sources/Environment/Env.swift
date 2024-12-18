//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import Foundation

public struct Env {
    public nonisolated(unsafe) static let shared = Env()

    public let environment: Environment

    // MARK: - URLs

    public let hostUrl: String = Config.HOST_URL
    public let baseURL: String = "\(Config.HOST_URL)/api"

    private init() {
        #if DEVELOPMENT

            environment = .development

        #elseif STAGING

            environment = .staging

        #elseif PRODUCTION

            environment = .production

        #endif
    }
}
