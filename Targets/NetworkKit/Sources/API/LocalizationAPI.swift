//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import Moya

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
        // Use success stub for development
        return .success
    }

    public var stubStatusCode: Int {
        return uiTestStatusCode ?? 200
    }

    public var stubData: Data? {
        // Return stub data if in UI test mode
        if let testData = uiTestStubData {
            return testData
        }

        // Default stub data for development
        switch self {
        case .availableLanguages:
            return availableLanguagesStubData

        case .translationFile(let languageCode):
            return translationFileStubData(for: languageCode)
        }
    }

    // MARK: - Private Stub Data Generators

    /// Stub data for available languages endpoint
    private var availableLanguagesStubData: Data {
        let json = """
        {
          "languages": [
            {
              "code": "en",
              "name": "English",
              "nativeName": "English"
            },
            {
              "code": "bn",
              "name": "Bengali",
              "nativeName": "বাংলা"
            },
            {
              "code": "ar",
              "name": "Arabic",
              "nativeName": "العربية"
            }
          ]
        }
        """
        return json.data(using: .utf8)!
    }

    /// Stub data for translation file endpoint
    /// - Parameter languageCode: Language code
    /// - Returns: Stub translation JSON data
    private func translationFileStubData(for languageCode: String) -> Data {
        switch languageCode {
        case "bn":
            return bengaliStubData
        case "ar":
            return arabicStubData
        default:
            return englishStubData
        }
    }

    /// English translation stub data
    private var englishStubData: Data {
        let json = """
        {
          "version": "1.0",
          "language": "en",
          "generatedAt": "2024-11-27T10:30:00Z",
          "modules": {
            "Store": {
              "store_welcome": {
                "value": "Welcome to the Store!",
                "type": "simple",
                "comment": "Greeting shown on store home screen"
              },
              "store_items_count": {
                "type": "plural",
                "comment": "Item count in shopping cart",
                "value": {
                  "zero": "No items",
                  "one": "1 item",
                  "other": "%d items"
                }
              },
              "store_greeting": {
                "value": "Hello, %@!",
                "type": "interpolation",
                "comment": "Personal greeting with user name"
              }
            }
          }
        }
        """
        return json.data(using: .utf8)!
    }

    /// Bengali translation stub data
    private var bengaliStubData: Data {
        let json = """
        {
          "version": "1.0",
          "language": "bn",
          "generatedAt": "2024-11-27T10:30:00Z",
          "modules": {
            "Store": {
              "store_welcome": {
                "value": "স্টোরে স্বাগতম!",
                "type": "simple",
                "comment": "Greeting shown on store home screen"
              },
              "store_items_count": {
                "type": "plural",
                "comment": "Item count in shopping cart",
                "value": {
                  "zero": "কোন আইটেম নেই",
                  "one": "১টি আইটেম",
                  "other": "%d টি আইটেম"
                }
              },
              "store_greeting": {
                "value": "হ্যালো, %@!",
                "type": "interpolation",
                "comment": "Personal greeting with user name"
              }
            }
          }
        }
        """
        return json.data(using: .utf8)!
    }

    /// Arabic translation stub data
    private var arabicStubData: Data {
        let json = """
        {
          "version": "1.0",
          "language": "ar",
          "generatedAt": "2024-11-27T10:30:00Z",
          "modules": {
            "Store": {
              "store_welcome": {
                "value": "مرحبا بك في المتجر!",
                "type": "simple",
                "comment": "Greeting shown on store home screen"
              },
              "store_items_count": {
                "type": "plural",
                "comment": "Item count in shopping cart",
                "value": {
                  "zero": "لا توجد عناصر",
                  "one": "عنصر واحد",
                  "two": "عنصران",
                  "few": "%d عناصر",
                  "many": "%d عنصرًا",
                  "other": "%d عنصر"
                }
              },
              "store_greeting": {
                "value": "مرحبا، %@!",
                "type": "interpolation",
                "comment": "Personal greeting with user name"
              }
            }
          }
        }
        """
        return json.data(using: .utf8)!
    }
}
