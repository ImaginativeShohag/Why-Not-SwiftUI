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
          "success": true,
          "message": "Request processed successfully",
          "data": {
            "Bangladesh": [
              {
                "code": "bn_BD",
                "name_en": "Bengali",
                "name_locale": "বাংলা",
                "version": 1
              },
              {
                "code": "en_US",
                "name_en": "English",
                "name_locale": "English",
                "version": 4
              }
            ],
            "United Arab Emirates": [
              {
                "code": "ar_AE",
                "name_en": "Arabic (U.A.E.)",
                "name_locale": "العربية",
                "version": 2
              },
              {
                "code": "en_US",
                "name_en": "English",
                "name_locale": "English",
                "version": 4
              }
            ],
            "United States": [
              {
                "code": "en_US",
                "name_en": "English",
                "name_locale": "English",
                "version": 4
              }
            ],
            "China": [
              {
                "code": "zh_CN",
                "name_en": "Chinese (China)",
                "name_locale": "中文",
                "version": 1
              },
              {
                "code": "en_US",
                "name_en": "English",
                "name_locale": "English",
                "version": 4
              }
            ]
          }
        }
        """
        return json.data(using: .utf8)!
    }

    /// Stub data for translation file endpoint
    /// - Parameter languageCode: Language code
    /// - Returns: Stub translation JSON data
    private func translationFileStubData(for languageCode: String) -> Data {
        switch languageCode {
        case "bn_BD":
            return bengaliStubData
        case "ar_AE":
            return arabicStubData
        default:
            return "".data(using: .utf8)!
        }
    }

    /// Bengali translation stub data
    private var bengaliStubData: Data {
        let json = """
        {
          "version": 1,
          "modules": {
            "Store": {
              "welcome": {
                "value": "স্বাগতম, **%@**!",
                "type": "interpolation",
                "comment": "Welcome message with user's full name on home screen"
              },
              "welcome_to": {
                "value": "স্বাগতম",
                "type": "simple",
                "comment": "Splash screen welcome text"
              },
              "app_name": {
                "value": "স্টোর ওভারফ্লো",
                "type": "simple",
                "comment": "Application name"
              },
              "login": {
                "value": "লগইন",
                "type": "simple",
                "comment": "Login button text"
              },
              "username": {
                "value": "ব্যবহারকারীর নাম",
                "type": "simple",
                "comment": "Username field placeholder"
              },
              "password": {
                "value": "পাসওয়ার্ড",
                "type": "simple",
                "comment": "Password field placeholder"
              },
              "tab_home": {
                "value": "হোম",
                "type": "simple",
                "comment": "Tab bar label for home"
              },
              "tab_categories": {
                "value": "ক্যাটাগরি",
                "type": "simple",
                "comment": "Tab bar label for categories"
              },
              "tab_bag": {
                "value": "ব্যাগ",
                "type": "simple",
                "comment": "Tab bar label for shopping bag"
              },
              "cart_empty_title": {
                "value": "আপনার কার্ট খালি।",
                "type": "simple",
                "comment": "Title shown when cart has no items"
              },
              "cart_empty_description": {
                "value": "চালিয়ে যেতে কিছু পণ্য যোগ করুন।",
                "type": "simple",
                "comment": "Description for empty cart state"
              },
              "cart_total": {
                "value": "মোট",
                "type": "simple",
                "comment": "Label for total price in cart"
              },
              "cart_checkout": {
                "value": "চেকআউট",
                "type": "simple",
                "comment": "Button to proceed to checkout"
              },
              "cart_title": {
                "value": "কার্ট",
                "type": "simple",
                "comment": "Cart screen title"
              },
              "cart_menu_orders": {
                "value": "অর্ডার",
                "type": "simple",
                "comment": "Menu item to view orders"
              },
              "product_details_title": {
                "value": "পণ্যের বিবরণ",
                "type": "simple",
                "comment": "Product details screen title"
              },
              "retry": {
                "value": "পুনরায় চেষ্টা করুন",
                "type": "simple",
                "comment": "Retry button text"
              },
              "products_category_title": {
                "value": "ক্যাটাগরি: %@",
                "type": "interpolation",
                "comment": "Title showing the current category name"
              },
              "categories_title": {
                "value": "ক্যাটাগরি",
                "type": "simple",
                "comment": "Categories screen title"
              },
              "checkout_completed_title": {
                "value": "চেকআউট সম্পন্ন হয়েছে।",
                "type": "simple",
                "comment": "Title shown when checkout is complete"
              },
              "checkout_completed_description": {
                "value": "আবার চালিয়ে যেতে কিছু পণ্য যোগ করুন।",
                "type": "simple",
                "comment": "Description for completed checkout"
              },
              "checkout_title": {
                "value": "চেকআউট",
                "type": "simple",
                "comment": "Checkout screen title"
              },
              "checkout_shipping_address": {
                "value": "শিপিং ঠিকানা",
                "type": "simple",
                "comment": "Label for shipping address section"
              },
              "checkout_name_placeholder": {
                "value": "আপনার নাম...",
                "type": "simple",
                "comment": "Name TextField placeholder"
              },
              "checkout_phone_placeholder": {
                "value": "ফোন নম্বর...",
                "type": "simple",
                "comment": "Phone TextField placeholder"
              },
              "checkout_address_placeholder": {
                "value": "ঠিকানা...",
                "type": "simple",
                "comment": "Address TextField placeholder"
              },
              "checkout_total": {
                "value": "মোট",
                "type": "simple",
                "comment": "Label for total price in checkout"
              },
              "checkout_placing_order": {
                "value": "অর্ডার করা হচ্ছে...",
                "type": "simple",
                "comment": "Button text while placing order"
              },
              "checkout_place_order": {
                "value": "অর্ডার করুন",
                "type": "simple",
                "comment": "Button to place order"
              },
              "checkout_success_title": {
                "value": "অর্ডার সফলভাবে সম্পন্ন হয়েছে!",
                "type": "simple",
                "comment": "Success alert title"
              },
              "ok": {
                "value": "ঠিক আছে",
                "type": "simple",
                "comment": "OK button text"
              },
              "orders_title": {
                "value": "অর্ডার",
                "type": "simple",
                "comment": "Orders screen title"
              },
              "language_loading": {
                "value": "ভাষা লোড হচ্ছে...",
                "type": "simple",
                "comment": "Loading text while fetching languages"
              },
              "language_title": {
                "value": "ভাষা",
                "type": "simple",
                "comment": "Language settings screen title"
              },
              "done": {
                "value": "সম্পন্ন",
                "type": "simple",
                "comment": "Done button text"
              },
              "language_changing": {
                "value": "ভাষা পরিবর্তন করা হচ্ছে...",
                "type": "simple",
                "comment": "Progress message while changing language"
              },
              "language_select_header": {
                "value": "ভাষা নির্বাচন করুন",
                "type": "simple",
                "comment": "Header for language selection list"
              },
              "language_select_footer": {
                "value": "অ্যাপের জন্য আপনার পছন্দের ভাষা চয়ন করুন। ইন্টারফেস অবিলম্বে অনুবাদ করা হবে।",
                "type": "simple",
                "comment": "Footer explaining language selection"
              },
              "profile": {
                "value": "প্রোফাইল",
                "type": "simple",
                "comment": "Profile screen title"
              },
              "details": {
                "value": "বিস্তারিত",
                "type": "simple",
                "comment": "Profile details section header"
              },
              "name": {
                "value": "নাম",
                "type": "simple",
                "comment": "User name label"
              },
              "email": {
                "value": "ইমেইল",
                "type": "simple",
                "comment": "Email address label"
              },
              "phone": {
                "value": "ফোন",
                "type": "simple",
                "comment": "Phone number label"
              },
              "address": {
                "value": "ঠিকানা",
                "type": "simple",
                "comment": "Address label"
              },
              "orders": {
                "value": "অর্ডার",
                "type": "simple",
                "comment": "Orders button text"
              },
              "language_settings": {
                "value": "ভাষা সেটিংস",
                "type": "simple",
                "comment": "Language settings button text"
              },
              "sign_out": {
                "value": "সাইন আউট",
                "type": "simple",
                "comment": "Sign out button text"
              },
              "sign_out_alert_title": {
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
          "version": 1,
          "modules": {
            "Store": {
              "welcome": {
                "value": "!**%@** ،مرحباً",
                "type": "interpolation",
                "comment": "Welcome message with user's full name on home screen"
              },
              "welcome_to": {
                "value": "مرحباً بك في",
                "type": "simple",
                "comment": "Splash screen welcome text"
              },
              "app_name": {
                "value": "متجر أوفرفلو",
                "type": "simple",
                "comment": "Application name"
              },
              "login": {
                "value": "تسجيل الدخول",
                "type": "simple",
                "comment": "Login button text"
              },
              "username": {
                "value": "اسم المستخدم",
                "type": "simple",
                "comment": "Username field placeholder"
              },
              "password": {
                "value": "كلمة المرور",
                "type": "simple",
                "comment": "Password field placeholder"
              },
              "tab_home": {
                "value": "الرئيسية",
                "type": "simple",
                "comment": "Tab bar label for home"
              },
              "tab_categories": {
                "value": "الفئات",
                "type": "simple",
                "comment": "Tab bar label for categories"
              },
              "tab_bag": {
                "value": "الحقيبة",
                "type": "simple",
                "comment": "Tab bar label for shopping bag"
              },
              "cart_empty_title": {
                "value": "عربة التسوق فارغة.",
                "type": "simple",
                "comment": "Title shown when cart has no items"
              },
              "cart_empty_description": {
                "value": "أضف بعض المنتجات للمتابعة.",
                "type": "simple",
                "comment": "Description for empty cart state"
              },
              "cart_total": {
                "value": "المجموع",
                "type": "simple",
                "comment": "Label for total price in cart"
              },
              "cart_checkout": {
                "value": "الدفع",
                "type": "simple",
                "comment": "Button to proceed to checkout"
              },
              "cart_title": {
                "value": "عربة التسوق",
                "type": "simple",
                "comment": "Cart screen title"
              },
              "cart_menu_orders": {
                "value": "الطلبات",
                "type": "simple",
                "comment": "Menu item to view orders"
              },
              "product_details_title": {
                "value": "تفاصيل المنتج",
                "type": "simple",
                "comment": "Product details screen title"
              },
              "retry": {
                "value": "إعادة المحاولة",
                "type": "simple",
                "comment": "Retry button text"
              },
              "products_category_title": {
                "value": "الفئة: %@",
                "type": "interpolation",
                "comment": "Title showing the current category name"
              },
              "categories_title": {
                "value": "الفئات",
                "type": "simple",
                "comment": "Categories screen title"
              },
              "checkout_completed_title": {
                "value": "اكتمل الدفع.",
                "type": "simple",
                "comment": "Title shown when checkout is complete"
              },
              "checkout_completed_description": {
                "value": "أضف بعض المنتجات للمتابعة مرة أخرى.",
                "type": "simple",
                "comment": "Description for completed checkout"
              },
              "checkout_title": {
                "value": "الدفع",
                "type": "simple",
                "comment": "Checkout screen title"
              },
              "checkout_shipping_address": {
                "value": "عنوان الشحن",
                "type": "simple",
                "comment": "Label for shipping address section"
              },
              "checkout_name_placeholder": {
                "value": "اسمك...",
                "type": "simple",
                "comment": "Name TextField placeholder"
              },
              "checkout_phone_placeholder": {
                "value": "رقم الهاتف...",
                "type": "simple",
                "comment": "Phone TextField placeholder"
              },
              "checkout_address_placeholder": {
                "value": "العنوان...",
                "type": "simple",
                "comment": "Address TextField placeholder"
              },
              "checkout_total": {
                "value": "المجموع",
                "type": "simple",
                "comment": "Label for total price in checkout"
              },
              "checkout_placing_order": {
                "value": "جاري تقديم الطلب...",
                "type": "simple",
                "comment": "Button text while placing order"
              },
              "checkout_place_order": {
                "value": "تقديم الطلب",
                "type": "simple",
                "comment": "Button to place order"
              },
              "checkout_success_title": {
                "value": "تم تقديم الطلب بنجاح!",
                "type": "simple",
                "comment": "Success alert title"
              },
              "ok": {
                "value": "حسناً",
                "type": "simple",
                "comment": "OK button text"
              },
              "orders_title": {
                "value": "الطلبات",
                "type": "simple",
                "comment": "Orders screen title"
              },
              "language_loading": {
                "value": "جاري تحميل اللغات...",
                "type": "simple",
                "comment": "Loading text while fetching languages"
              },
              "language_title": {
                "value": "اللغة",
                "type": "simple",
                "comment": "Language settings screen title"
              },
              "done": {
                "value": "تم",
                "type": "simple",
                "comment": "Done button text"
              },
              "language_changing": {
                "value": "جاري تغيير اللغة...",
                "type": "simple",
                "comment": "Progress message while changing language"
              },
              "language_select_header": {
                "value": "اختر اللغة",
                "type": "simple",
                "comment": "Header for language selection list"
              },
              "language_select_footer": {
                "value": "اختر لغتك المفضلة للتطبيق. سيتم ترجمة الواجهة على الفور.",
                "type": "simple",
                "comment": "Footer explaining language selection"
              },
              "profile": {
                "value": "الملف الشخصي",
                "type": "simple",
                "comment": "Profile screen title"
              },
              "details": {
                "value": "التفاصيل",
                "type": "simple",
                "comment": "Profile details section header"
              },
              "name": {
                "value": "الاسم",
                "type": "simple",
                "comment": "User name label"
              },
              "email": {
                "value": "البريد الإلكتروني",
                "type": "simple",
                "comment": "Email address label"
              },
              "phone": {
                "value": "الهاتف",
                "type": "simple",
                "comment": "Phone number label"
              },
              "address": {
                "value": "العنوان",
                "type": "simple",
                "comment": "Address label"
              },
              "orders": {
                "value": "الطلبات",
                "type": "simple",
                "comment": "Orders button text"
              },
              "language_settings": {
                "value": "إعدادات اللغة",
                "type": "simple",
                "comment": "Language settings button text"
              },
              "sign_out": {
                "value": "تسجيل الخروج",
                "type": "simple",
                "comment": "Sign out button text"
              },
              "sign_out_alert_title": {
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
