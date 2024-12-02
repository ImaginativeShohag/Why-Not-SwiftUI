//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// A model for passing mock data during UI testing.
///
/// The `MockResponse` struct is used to encapsulate mock data,
/// providing essential information about the API route, status code,
/// and data payload. This enables seamless testing by simulating
/// network responses based on different `ApiEndpoint` scenarios.
public struct MockResponse {
    /// The API endpoint associated with the mock response.
    ///
    /// This property specifies the API route, represented as an
    /// `ApiEndpoint` instance, which allows for easy identification
    /// of the target endpoint within the application during UI testing.
    let route: ApiEndpoint

    /// The HTTP status code for the mock response.
    ///
    /// This property enables control over the status code, allowing
    /// the simulation of various server response scenarios, such as
    /// successful (200) or error-based responses (e.g., 404, 500).
    let statusCode: Int

    /// The data payload for the mock response.
    ///
    /// An optional `Encodable` object representing the response data
    /// returned from the endpoint. This allows the customization of
    /// mock data for specific testing requirements.
    let data: Encodable?

    public init(route: ApiEndpoint, statusCode: Int, data: Encodable?) {
        self.route = route
        self.statusCode = statusCode
        self.data = data
    }
}
