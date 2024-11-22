//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import Moya

/// Represents the result of an API call.
///
/// Use `ApiResult` to handle the outcome of API requests. It encapsulates both the successful
/// result and various types of errors that can occur during the request.
///
/// Example:
/// ```
/// fetchUserData { result in
///     switch result {
///     case .success(let user):
///         print("User data: \(user)")
///     case .failure(let error):
///         print("Error: \(error)")
///     }
/// }
/// ```
public enum ApiResult<T: Decodable> {
    /// The API call was successful, and the associated value contains the result.
    case success(response: T)

    /// The API call failed, and the associated value contains details of the error.
    case failure(error: MoyaError, errorMessage: String, statusCode: Int)
}
