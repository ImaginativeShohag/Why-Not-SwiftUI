//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import Moya
import NetworkKit

public extension DataSource {
    /// Localization API backend for fetching translations
    /// Uses stub behavior with 1 second delay for realistic development testing
    nonisolated(unsafe) static let Localization = Backend<LocalizationAPI>(
        isStubbed: true,
        stubBehavior: .delayed(seconds: 1),
        session: NetworkSession.create()
    )
}

/// Localization API endpoints
/// Provides access to translation files and available languages from server
public enum LocalizationAPI {
    /// Fetch available languages list
    case availableLanguages

    /// Fetch translation file for specific language
    /// - Parameter languageCode: Language code (e.g., "en", "bn", "ar")
    case translationFile(languageCode: String)
}

extension LocalizationAPI: ApiEndpoint {
    public var baseURL: URL {
        // TODO: Replace with actual server URL in production
        // For now, using a placeholder that will be overridden by stub data
        URL(string: "https://api.example.com")!
    }

    public var path: String {
        switch self {
        case .availableLanguages:
            return "/api/translations/languages"

        case .translationFile(let languageCode):
            return "/api/translations/\(languageCode).json"
        }
    }

    public var method: Moya.Method {
        // All localization endpoints are GET
        return .get
    }

    public var task: Moya.Task {
        // All endpoints use plain requests (no parameters)
        return .requestPlain
    }

    public var headers: [String: String]? {
        // Add version header for cache invalidation if needed
        // Can be enhanced to include translation version from Preferences
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    // MARK: - Stub Configuration

    public var stubResponseType: StubResponseType {
        // Check if we're in UI test mode with error status code
        if let statusCode = uiTestStatusCode, statusCode >= 400 {
            return .failure
        }
        // Use success stub for development
        return .success
    }

    public var stubStatusCode: Int {
        return uiTestStatusCode ?? 200
    }

    public var stubData: Data? {
        switch stubResponseType {
        case .success:
            // Return stub data if in UI test mode
            if let testData = uiTestStubData {
                return testData
            }

            // Default stub data for development
            switch self {
            case .availableLanguages:
                return try? Bundle.module.loadAsData("AvailableLanguagesResponse.json")

            case .translationFile(let languageCode):
                return try? Bundle.module.loadAsData("\(languageCode)_mock.json")
            }

        case .failure:
            return try? Bundle.module.loadAsData("LocalizationFailureResponse.json")

        default:
            return "".data(using: .utf8)!
        }
    }
}
