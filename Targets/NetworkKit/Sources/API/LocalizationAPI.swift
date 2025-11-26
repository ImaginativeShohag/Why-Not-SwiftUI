//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import Moya

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
          "version": "1.0.0",
          "language": "en",
          "generatedAt": "2025-11-27T10:30:00Z",
          "modules": {
            "Store": {
              "store_welcome": {
                "value": "Welcome, **%@**!",
                "type": "interpolation",
                "comment": "Welcome message with user's full name on home screen"
              },
              "store_retry": {
                "value": "Retry",
                "type": "simple",
                "comment": "Retry button text"
              },
              "store_profile": {
                "value": "Profile",
                "type": "simple",
                "comment": "Profile screen title"
              },
              "store_done": {
                "value": "Done",
                "type": "simple",
                "comment": "Done button text"
              },
              "store_details": {
                "value": "Details",
                "type": "simple",
                "comment": "Profile details section header"
              },
              "store_name": {
                "value": "Name",
                "type": "simple",
                "comment": "User name label"
              },
              "store_username": {
                "value": "Username",
                "type": "simple",
                "comment": "Username label"
              },
              "store_email": {
                "value": "Email",
                "type": "simple",
                "comment": "Email address label"
              },
              "store_phone": {
                "value": "Phone",
                "type": "simple",
                "comment": "Phone number label"
              },
              "store_address": {
                "value": "Address",
                "type": "simple",
                "comment": "Address label"
              },
              "store_orders": {
                "value": "Orders",
                "type": "simple",
                "comment": "Orders button text"
              },
              "store_language_settings": {
                "value": "Language Settings",
                "type": "simple",
                "comment": "Language settings button text"
              },
              "store_sign_out": {
                "value": "Sign Out",
                "type": "simple",
                "comment": "Sign out button text"
              },
              "store_sign_out_alert_title": {
                "value": "Sign out from Store?",
                "type": "simple",
                "comment": "Alert title for sign out confirmation"
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
          "version": "1.0.0",
          "language": "bn",
          "generatedAt": "2025-11-27T10:35:00Z",
          "modules": {
            "Store": {
              "store_welcome": {
                "value": "স্বাগতম, **%@**!",
                "type": "interpolation",
                "comment": "Welcome message with user's full name on home screen"
              },
              "store_retry": {
                "value": "পুনরায় চেষ্টা করুন",
                "type": "simple",
                "comment": "Retry button text"
              },
              "store_profile": {
                "value": "প্রোফাইল",
                "type": "simple",
                "comment": "Profile screen title"
              },
              "store_done": {
                "value": "সম্পন্ন",
                "type": "simple",
                "comment": "Done button text"
              },
              "store_details": {
                "value": "বিস্তারিত",
                "type": "simple",
                "comment": "Profile details section header"
              },
              "store_name": {
                "value": "নাম",
                "type": "simple",
                "comment": "User name label"
              },
              "store_username": {
                "value": "ব্যবহারকারীর নাম",
                "type": "simple",
                "comment": "Username label"
              },
              "store_email": {
                "value": "ইমেইল",
                "type": "simple",
                "comment": "Email address label"
              },
              "store_phone": {
                "value": "ফোন",
                "type": "simple",
                "comment": "Phone number label"
              },
              "store_address": {
                "value": "ঠিকানা",
                "type": "simple",
                "comment": "Address label"
              },
              "store_orders": {
                "value": "অর্ডার",
                "type": "simple",
                "comment": "Orders button text"
              },
              "store_language_settings": {
                "value": "ভাষা সেটিংস",
                "type": "simple",
                "comment": "Language settings button text"
              },
              "store_sign_out": {
                "value": "সাইন আউট",
                "type": "simple",
                "comment": "Sign out button text"
              },
              "store_sign_out_alert_title": {
                "value": "স্টোর থেকে সাইন আউট করবেন?",
                "type": "simple",
                "comment": "Alert title for sign out confirmation"
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
          "version": "1.0.0",
          "language": "ar",
          "generatedAt": "2025-11-27T10:40:00Z",
          "modules": {
            "Store": {
              "store_welcome": {
                "value": "!**%@** ،مرحباً",
                "type": "interpolation",
                "comment": "Welcome message with user's full name on home screen"
              },
              "store_retry": {
                "value": "إعادة المحاولة",
                "type": "simple",
                "comment": "Retry button text"
              },
              "store_profile": {
                "value": "الملف الشخصي",
                "type": "simple",
                "comment": "Profile screen title"
              },
              "store_done": {
                "value": "تم",
                "type": "simple",
                "comment": "Done button text"
              },
              "store_details": {
                "value": "التفاصيل",
                "type": "simple",
                "comment": "Profile details section header"
              },
              "store_name": {
                "value": "الاسم",
                "type": "simple",
                "comment": "User name label"
              },
              "store_username": {
                "value": "اسم المستخدم",
                "type": "simple",
                "comment": "Username label"
              },
              "store_email": {
                "value": "البريد الإلكتروني",
                "type": "simple",
                "comment": "Email address label"
              },
              "store_phone": {
                "value": "الهاتف",
                "type": "simple",
                "comment": "Phone number label"
              },
              "store_address": {
                "value": "العنوان",
                "type": "simple",
                "comment": "Address label"
              },
              "store_orders": {
                "value": "الطلبات",
                "type": "simple",
                "comment": "Orders button text"
              },
              "store_language_settings": {
                "value": "إعدادات اللغة",
                "type": "simple",
                "comment": "Language settings button text"
              },
              "store_sign_out": {
                "value": "تسجيل الخروج",
                "type": "simple",
                "comment": "Sign out button text"
              },
              "store_sign_out_alert_title": {
                "value": "تسجيل الخروج من المتجر؟",
                "type": "simple",
                "comment": "Alert title for sign out confirmation"
              }
            }
          }
        }
        """
        return json.data(using: .utf8)!
    }
}
