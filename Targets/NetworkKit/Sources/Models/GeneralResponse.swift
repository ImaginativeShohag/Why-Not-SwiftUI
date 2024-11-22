//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// This is used as the common model for receiving api response.
public struct GeneralResponse: Codable {
    let success: Bool?
    let message: String?

    public func isSuccess() -> Bool {
        return self.success ?? false
    }

    public func getMessage(orDefault message: String = "Something went wrong. Try again.") -> String {
        return self.message == nil || self.message?.isEmpty == true ? message : self.message!
    }
}
