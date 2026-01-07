# LocalizeKit Runtime Usage Guide

A comprehensive guide to using LocalizeKit for runtime localization in Swift applications. This guide covers installation, configuration, and API usage for SwiftUI, UIKit, and general Swift code.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [String Localization API](#string-localization-api)
  - [Simple Strings](#simple-strings)
  - [String Interpolation](#string-interpolation)
  - [Plural Forms](#plural-forms)
- [SwiftUI Integration](#swiftui-integration)
- [UIKit Integration](#uikit-integration)
- [General Swift Usage](#general-swift-usage)
- [Language Management](#language-management)
- [Caching System](#caching-system)
- [Best Practices](#best-practices)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)

---

## Overview

LocalizeKit is a runtime localization library for Swift that enables dynamic language switching without app restarts. Unlike compile-time localization (`.strings` files), LocalizeKit fetches translations from a server, caches them locally, and provides instant language switching with automatic UI updates.

### Key Features

| Feature | Description |
|---------|-------------|
| **Runtime Translation** | Load translations from API at runtime |
| **Smart Caching** | Version-aware caching with offline support |
| **English Defaults** | Readable English text in code as fallback |
| **CLDR Plural Support** | All 6 plural categories (zero, one, two, few, many, other) |
| **String Interpolation** | Support for `%@`, `%d`, `%f` format specifiers |
| **Observable Updates** | Automatic UI refresh on language change |
| **Zero Dependencies** | Only requires Foundation framework |

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Your Application                       │
├─────────────────────────────────────────────────────────────┤
│  SwiftUI Views    │    UIKit Views    │    ViewModels       │
│  .localize()      │    .localize()    │    .localize()      │
├───────────────────┴───────────────────┴─────────────────────┤
│                    LocalizationManager                      │
│  • Language switching    • Translation lookup               │
│  • Cache management      • Plural rules                     │
├─────────────────────────────────────────────────────────────┤
│                    TranslationStorage                       │
│  • File-based caching    • Version tracking                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Requirements

| Requirement | Version |
|-------------|---------|
| iOS | 17.0+ |
| macOS | 14.0+ |
| Swift | 5.9+ |
| Xcode | 15.0+ |

---

## Installation

### Swift Package Manager

Add LocalizeKit to your project using Swift Package Manager.

#### In Xcode

1. Go to **File → Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/aspect-apps/LocalizeKit.git
   ```
3. Select version: **1.0.0** or later
4. Click **Add Package**

#### In Package.swift

```swift
dependencies: [
    .package(url: "https://example.com/localizekit/LocalizeKit.git", from: "1.0.0")
]
```

Then add to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["LocalizeKit"]
)
```

---

## Quick Start

### 1. Import LocalizeKit

```swift
import LocalizeKit
```

### 2. Configure on App Launch

```swift
@main
struct MyApp: App {
    init() {
        // Optional: Configure custom plural rules
        LocalizationManager.shared.configure(pluralRules: [:])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onLanguageChange() // Enable auto-refresh
        }
    }
}
```

### 3. Localize Strings

```swift
Text("welcome_message".localize(
    default: "Welcome to our app!",
    comment: "Main screen greeting"
))
```

### 4. Switch Languages

```swift
await LocalizationManager.shared.changeLanguage(to: "bn_BD")
```

---

## Configuration

### LocalizationManager Setup

The `LocalizationManager` is a singleton that manages all localization operations.

```swift
import LocalizeKit

// Access the shared instance
let manager = LocalizationManager.shared

// Configure custom plural rules (optional)
manager.configure(pluralRules: [
    "ar": arabicPluralRule,
    "ru": russianPluralRule
])
```

### Custom Plural Rules

For languages with complex plural rules not covered by default:

```swift
// PluralRule: (count: Int, categoriesCount: Int) -> Int
// Returns index: 0=zero, 1=one, 2=two, 3=few, 4=many, 5=other

let arabicPluralRule: PluralRule = { count, _ in
    if count == 0 { return 0 }      // zero
    if count == 1 { return 1 }      // one
    if count == 2 { return 2 }      // two
    if count % 100 >= 3 && count % 100 <= 10 { return 3 }  // few
    if count % 100 >= 11 { return 4 }  // many
    return 5  // other
}

LocalizationManager.shared.configure(pluralRules: [
    "ar": arabicPluralRule
])
```

### Setting Available Languages

Provide the list of available languages from your API:

```swift
let languages = [
    Language(code: "en_US", nameEn: "English", nameLocale: "English", version: 1),
    Language(code: "bn_BD", nameEn: "Bengali", nameLocale: "বাংলা", version: 3),
    Language(code: "ar_AE", nameEn: "Arabic", nameLocale: "العربية", version: 2)
]

LocalizationManager.shared.setAvailableLanguages(languages)
```

---

## String Localization API

LocalizeKit extends `String` with localization methods. All methods follow the pattern:
- **Key**: The string itself (e.g., `"store_welcome"`)
- **Default**: English text to display if translation not found
- **Comment**: Context for translators (optional but recommended)

### Simple Strings

For plain text without variables:

```swift
func localize(
    default defaultValue: String,
    comment: String? = nil
) -> String
```

**Examples:**

```swift
// Basic usage
let title = "app_title".localize(
    default: "My App",
    comment: "App name shown in navigation bar"
)

// In SwiftUI
Text("welcome_message".localize(
    default: "Welcome to our app!",
    comment: "Main screen greeting"
))

// Button text
Button("save_button".localize(
    default: "Save",
    comment: "Save button in form"
)) {
    save()
}
```

---

### String Interpolation

For strings with dynamic values:

```swift
// Single argument
func localize(
    default defaultValue: String,
    comment: String? = nil,
    with argument: CVarArg
) -> String

// Multiple arguments
func localize(
    default defaultValue: String,
    comment: String? = nil,
    with arguments: CVarArg...
) -> String
```

**Format Specifiers:**

| Specifier | Type | Example |
|-----------|------|---------|
| `%@` | String | `"Hello, %@!"` → `"Hello, John!"` |
| `%d` | Integer | `"Count: %d"` → `"Count: 5"` |
| `%f` | Float/Double | `"Price: %f"` → `"Price: 19.99"` |
| `%.2f` | Float (2 decimals) | `"$%.2f"` → `"$19.99"` |
| `%%` | Literal % | `"Save %d%%"` → `"Save 20%"` |

**Examples:**

```swift
// Single variable
let greeting = "user_greeting".localize(
    default: "Hello, %@!",
    comment: "Personalized greeting",
    with: userName
)

// Multiple variables
let orderSummary = "order_summary".localize(
    default: "Order #%@ contains %d items totaling %@",
    comment: "Order summary with ID, count, and total",
    with: orderID, itemCount, formattedTotal
)

// Percentage
let discount = "discount_label".localize(
    default: "Save %d%%",
    comment: "Discount percentage",
    with: discountPercent
)
```

---

### Plural Forms

For count-dependent strings:

```swift
// Without additional interpolation
func localize(
    defaultPlural: [PluralCategory: String],
    comment: String? = nil,
    count: Int
) -> String

// With interpolation
func localize(
    defaultPlural: [PluralCategory: String],
    comment: String? = nil,
    count: Int,
    with arguments: CVarArg...
) -> String
```

**Plural Categories:**

| Category | Description | Example Languages |
|----------|-------------|-------------------|
| `.zero` | Zero items | Arabic, Latvian, Welsh |
| `.one` | Singular (1) | English, German, Spanish |
| `.two` | Dual (2) | Arabic, Welsh, Slovenian |
| `.few` | Few items (2-4 or 3-10) | Russian, Polish, Arabic |
| `.many` | Many items (5+ or 11+) | Russian, Polish, Arabic |
| `.other` | Default (always required) | All languages |

**Examples:**

```swift
// Basic plural without interpolation (no format specifiers)
let status = "cart_status".localize(
    defaultPlural: [
        .zero: "Cart is empty",
        .one: "One item in cart",
        .other: "Multiple items in cart"
    ],
    comment: "Cart status message",
    count: itemCount
)

// Plural with interpolation (has format specifiers)
let itemCount = "cart_items".localize(
    defaultPlural: [
        .one: "1 item in cart",
        .other: "%d items in cart"
    ],
    comment: "Shopping cart item count",
    count: count,
    with: count
)

// Comprehensive plural (for Arabic/Russian support)
let daysRemaining = "days_remaining".localize(
    defaultPlural: [
        .zero: "No days remaining",
        .one: "1 day remaining",
        .two: "2 days remaining",
        .few: "%d days remaining",
        .many: "%d days remaining",
        .other: "%d days remaining"
    ],
    comment: "Countdown to delivery",
    count: days,
    with: days
)

// Zero state with interpolation
let notifications = "notifications_count".localize(
    defaultPlural: [
        .zero: "No new notifications",
        .one: "1 new notification",
        .other: "%d new notifications"
    ],
    comment: "Notification badge count",
    count: count,
    with: count
)

// Plural with multiple interpolation arguments
Text("store_item_summary".localize(
    defaultPlural: [
        .zero: "Your cart is empty",
        .one: "You have 1 item worth %@",
        .other: "You have %d items worth %@"
    ],
    comment: "Cart summary with count and total price",
    count: itemCount,
    with: itemCount, totalPrice
))
```

**Note:**
- Use `count` only when no format specifiers are needed
- Use `count` + `with` when format specifiers (`%d`, `%@`, etc.) are present
- The `count` parameter determines which plural form to use
- The `with` arguments are used for string interpolation in order

---

## SwiftUI Integration

### Basic Usage

```swift
import SwiftUI
import LocalizeKit

struct HomeScreen: View {
    var body: some View {
        VStack {
            Text("home_title".localize(
                default: "Home",
                comment: "Home screen title"
            ))
            .font(.largeTitle)

            Text("home_subtitle".localize(
                default: "Welcome back!",
                comment: "Home screen subtitle"
            ))
            .foregroundColor(.secondary)
        }
    }
}
```

### Auto-Refresh on Language Change

Add `.onLanguageChange()` to your root view:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onLanguageChange()  // Refreshes all views on language change
        }
    }
}
```

### Text with Markdown Support

Use `Text.localized()` for markdown-formatted strings:

```swift
// Bold text
Text.localized(
    "welcome_user",
    default: "Welcome, **%@**!",
    comment: "Welcome with bold name",
    with: userName
)

// Italic and bold
Text.localized(
    "promo_message",
    default: "Get **50% off** on *all items*!",
    comment: "Promotional banner text"
)
```

### Navigation and Toolbars

```swift
struct ProfileScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Form content
            }
            .navigationTitle("profile_title".localize(
                default: "Profile",
                comment: "Profile screen title"
            ))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("done_button".localize(
                        default: "Done",
                        comment: "Dismiss button"
                    )) {
                        dismiss()
                    }
                }
            }
        }
    }
}
```

### Alerts and Confirmations

```swift
struct DeleteButton: View {
    @State private var showingAlert = false

    var body: some View {
        Button("delete_button".localize(
            default: "Delete",
            comment: "Delete action button"
        )) {
            showingAlert = true
        }
        .alert(
            "delete_alert_title".localize(
                default: "Delete Item?",
                comment: "Delete confirmation title"
            ),
            isPresented: $showingAlert
        ) {
            Button("cancel_button".localize(
                default: "Cancel",
                comment: "Cancel action"
            ), role: .cancel) { }

            Button("delete_confirm".localize(
                default: "Delete",
                comment: "Confirm delete"
            ), role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("delete_alert_message".localize(
                default: "This action cannot be undone.",
                comment: "Delete warning message"
            ))
        }
    }
}
```

### Lists and ForEach

```swift
struct SettingsScreen: View {
    let options = ["notifications", "privacy", "appearance"]

    var body: some View {
        List(options, id: \.self) { option in
            Text("settings_\(option)".localize(
                default: option.capitalized,
                comment: "Settings option: \(option)"
            ))
        }
    }
}
```

---

## UIKit Integration

### Basic UILabel

```swift
import UIKit
import LocalizeKit

class HomeViewController: UIViewController {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateLocalizedStrings()
    }

    private func updateLocalizedStrings() {
        titleLabel.text = "home_title".localize(
            default: "Home",
            comment: "Home screen title"
        )

        subtitleLabel.text = "home_subtitle".localize(
            default: "Welcome back!",
            comment: "Home screen subtitle"
        )

        title = "home_nav_title".localize(
            default: "Home",
            comment: "Navigation bar title"
        )
    }
}
```

### UIButton

```swift
class CartViewController: UIViewController {
    private let checkoutButton = UIButton(type: .system)

    private func setupCheckoutButton() {
        let title = "checkout_button".localize(
            default: "Proceed to Checkout",
            comment: "Checkout button in cart"
        )
        checkoutButton.setTitle(title, for: .normal)
    }
}
```

### UIAlertController

```swift
class ProfileViewController: UIViewController {
    func showDeleteConfirmation() {
        let alert = UIAlertController(
            title: "delete_alert_title".localize(
                default: "Delete Account?",
                comment: "Account deletion alert title"
            ),
            message: "delete_alert_message".localize(
                default: "This will permanently delete your account and all data.",
                comment: "Account deletion warning"
            ),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "cancel_button".localize(
                default: "Cancel",
                comment: "Cancel action"
            ),
            style: .cancel
        ))

        alert.addAction(UIAlertAction(
            title: "delete_button".localize(
                default: "Delete",
                comment: "Confirm delete"
            ),
            style: .destructive
        ) { _ in
            self.deleteAccount()
        })

        present(alert, animated: true)
    }
}
```

### Language Change Observer (UIKit)

**Note:** LocalizeKit uses Swift's `@Observable` macro for state management, which is designed for SwiftUI. For UIKit integration, you need to manually refresh your UI after language changes.

**Approach 1: Manual Refresh (Recommended)**

```swift
class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateLocalizedStrings()
    }

    func updateLocalizedStrings() {
        // Override in subclasses to update UI with new translations
    }

    func changeLanguage(to languageCode: String) async {
        // Change language through your repository/view model
        // Then manually refresh UI
        await LocalizationManager.shared.changeLanguage(to: languageCode)
        updateLocalizedStrings()
    }
}
```

**Approach 2: SwiftUI Integration (iOS 17+)**

For new UIKit projects, consider embedding SwiftUI views that automatically observe language changes:

```swift
import SwiftUI

class ModernViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Embed SwiftUI view with automatic language observation
        let swiftUIView = MySwiftUIView()
            .onLanguageChange()

        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
```

### UITableView

```swift
class SettingsViewController: UITableViewController {
    let sections = ["account", "notifications", "privacy"]

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        let key = "settings_section_\(sections[section])"
        return key.localize(
            default: sections[section].capitalized,
            comment: "Settings section header"
        )
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        )

        let key = "settings_item_\(indexPath.row)"
        cell.textLabel?.text = key.localize(
            default: "Setting \(indexPath.row)",
            comment: "Settings item"
        )

        return cell
    }
}
```

---

## General Swift Usage

### In ViewModels

```swift
import Foundation
import LocalizeKit

@MainActor
@Observable
final class CartViewModel {
    var cartSummary: String = ""
    var emptyCartMessage: String = ""

    private var items: [CartItem] = []

    func updateLocalizedStrings() {
        let count = items.count

        cartSummary = "cart_summary".localize(
            defaultPlural: [
                .zero: "Your cart is empty",
                .one: "1 item in your cart",
                .other: "%d items in your cart"
            ],
            comment: "Cart summary in header",
            count: count,
            with: count
        )

        emptyCartMessage = "cart_empty_message".localize(
            default: "Start shopping to add items to your cart",
            comment: "Message shown when cart is empty"
        )
    }

    func getItemDescription(_ item: CartItem) -> String {
        return "cart_item_description".localize(
            default: "%@ - Qty: %d",
            comment: "Cart item with name and quantity",
            with: item.name, item.quantity
        )
    }
}
```

### In Services/Managers

```swift
import Foundation
import LocalizeKit

actor NotificationService {
    func getNotificationTitle(for type: NotificationType) -> String {
        switch type {
        case .orderShipped:
            return "notification_order_shipped".localize(
                default: "Your order has shipped!",
                comment: "Push notification for shipped order"
            )
        case .orderDelivered:
            return "notification_order_delivered".localize(
                default: "Your order has been delivered",
                comment: "Push notification for delivered order"
            )
        case .promotion:
            return "notification_promotion".localize(
                default: "New deals available!",
                comment: "Push notification for promotions"
            )
        }
    }
}
```

### Error Messages

```swift
enum AppError: LocalizedError {
    case networkError
    case invalidCredentials
    case serverError(code: Int)

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "error_network".localize(
                default: "Unable to connect. Please check your internet connection.",
                comment: "Network connectivity error"
            )
        case .invalidCredentials:
            return "error_invalid_credentials".localize(
                default: "Invalid email or password",
                comment: "Login authentication error"
            )
        case .serverError(let code):
            return "error_server".localize(
                default: "Server error (Code: %d). Please try again later.",
                comment: "Server error with code",
                with: code
            )
        }
    }
}
```

### Validation Messages

```swift
struct FormValidator {
    static func validateEmail(_ email: String) -> String? {
        guard !email.isEmpty else {
            return "validation_email_required".localize(
                default: "Email is required",
                comment: "Empty email validation error"
            )
        }

        guard email.contains("@") else {
            return "validation_email_invalid".localize(
                default: "Please enter a valid email address",
                comment: "Invalid email format error"
            )
        }

        return nil
    }

    static func validatePassword(_ password: String) -> String? {
        guard password.count >= 8 else {
            return "validation_password_length".localize(
                default: "Password must be at least %d characters",
                comment: "Password minimum length error",
                with: 8
            )
        }

        return nil
    }
}
```

---

## Language Management

### Changing Language

```swift
// Change language (loads from cache or keeps current if not cached)
await LocalizationManager.shared.changeLanguage(to: "bn_BD")

// Activate with full translation data
LocalizationManager.shared.activateLanguage(
    languageCode: "bn_BD",
    languageName: "বাংলা",
    country: "Bangladesh",
    version: 3,
    translationFile
)
```

### Getting Current Language

```swift
let manager = LocalizationManager.shared

// Current language code
let code = manager.currentLanguage  // e.g., "bn_BD"

// Current language name (in native locale)
let name = manager.currentLanguageName  // e.g., "বাংলা"

// Current country
let country = manager.currentCountry  // e.g., "Bangladesh"

// Current version
let version = manager.currentLanguageVersion  // e.g., 3
```

### Available Languages

```swift
let manager = LocalizationManager.shared

// Get all available languages
let languages = manager.availableLanguages

// Check if loading
let isLoading = manager.isLoading
```

### Loading Translations from API

Implement a translation repository to fetch and cache translations:

```swift
class TranslationRepository {
    func loadTranslations(for language: Language) async throws {
        let manager = LocalizationManager.shared

        // Check cache state
        let cacheState = await manager.getCacheState(for: language)

        switch cacheState {
        case .valid(let cached):
            // Use cached translations
            manager.activateLanguage(
                languageCode: language.code,
                languageName: language.nameLocale,
                country: "Country",
                version: cached.version,
                cached.translationFile
            )

        case .stale, .missing, .corrupted:
            // Fetch from server
            let translationFile = try await api.fetchTranslations(
                for: language.code
            )

            // Cache and activate
            await manager.setTranslations(
                translationFile,
                for: language.code,
                version: language.version
            )
        }
    }
}
```

---

## Caching System

LocalizeKit includes a file-based caching system for offline support.

### Cache Location

```
~/Library/Application Support/LocalizeKit/Translations/
├── en_US.json
├── bn_BD.json
└── ar_AE.json
```

### Cache States

| State | Description | Action |
|-------|-------------|--------|
| `valid` | Cache matches server version | Use cache (instant) |
| `stale` | Cache version < server version | Re-fetch from server |
| `missing` | No cache file exists | Fetch from server |
| `corrupted` | Cache file is invalid | Delete and re-fetch |

### Checking Cache State

```swift
let manager = LocalizationManager.shared

let language = Language(
    code: "bn_BD",
    nameEn: "Bengali",
    nameLocale: "বাংলা",
    version: 5
)

let state = await manager.getCacheState(for: language)

switch state {
case .valid(let cached):
    print("Cache valid, version: \(cached.version)")
case .stale(let cachedVersion):
    print("Cache stale: \(cachedVersion), server: \(language.version)")
case .missing:
    print("No cache exists")
case .corrupted:
    print("Cache corrupted, will re-fetch")
}
```

### Cache Management

```swift
let manager = LocalizationManager.shared

// Get cached languages
let cachedLanguages = await manager.getCachedLanguages()

// Clear all cache
await manager.clearCache()

// Delete specific language cache
try await manager.deleteCacheFile(for: "bn_BD")

// Get cache directory path (for debugging)
let cachePath = await manager.getCacheDirectory()
```

---

## Best Practices

### 1. Use Descriptive Keys

```swift
// Good - descriptive with module prefix
"cart_checkout_button"
"profile_edit_name"
"settings_notifications_toggle"

// Bad - vague or generic
"button1"
"text"
"label"
```

### 2. Always Provide English Defaults

```swift
// Good
"welcome".localize(
    default: "Welcome to our app!",
    comment: "..."
)

// Bad - empty or placeholder
"welcome".localize(default: "", comment: "...")
"welcome".localize(default: "TODO", comment: "...")
```

### 3. Write Helpful Comments

```swift
// Good - specific context
"cart_empty".localize(
    default: "Your cart is empty",
    comment: "Shown on cart screen when user has no items"
)

// Bad - vague or missing
"cart_empty".localize(
    default: "Your cart is empty"
)
```

### 4. Handle Plurals Correctly

```swift
// Good - includes .other (required)
defaultPlural: [
    .one: "1 item",
    .other: "%d items"
]

// Better - supports more languages
defaultPlural: [
    .zero: "No items",
    .one: "1 item",
    .two: "2 items",
    .few: "%d items",
    .many: "%d items",
    .other: "%d items"
]
```

### 5. Test Multiple Languages

- Test with **longer text** (German, Russian) for layout issues
- Test **RTL languages** (Arabic, Hebrew) for mirroring
- Test **plural forms** with various counts (0, 1, 2, 5, 11, 21, 100)
- Test **offline mode** by disabling network

### 6. Avoid String Concatenation

```swift
// Bad - concatenation breaks translation
let message = "Hello, " + userName + "!"

// Good - use interpolation
let message = "greeting".localize(
    default: "Hello, %@!",
    comment: "...",
    with: userName
)
```

---

## API Reference

### LocalizationManager

```swift
@MainActor
@Observable
public final class LocalizationManager {
    // Singleton
    public static let shared: LocalizationManager

    // Observable Properties
    public private(set) var currentLanguage: String
    public private(set) var currentLanguageName: String
    public private(set) var currentCountry: String
    public private(set) var currentLanguageVersion: Int?
    public private(set) var availableLanguages: [Language]
    public private(set) var isLoading: Bool

    // Configuration
    public func configure(pluralRules: [String: PluralRule])

    // Language Management
    public func changeLanguage(to languageCode: String) async
    public func setAvailableLanguages(_ languages: [Language])
    public func setTranslations(_ file: TranslationFile, for code: String, version: Int) async
    public func activateLanguage(languageCode: String, languageName: String, country: String, version: Int, _ file: TranslationFile)

    // Translation Lookup
    public func string(for key: String) -> String?
    public func pluralString(for key: String, count: Int) -> String?

    // Cache Management
    public func getCacheState(for language: Language) async -> CacheState
    public func cacheTranslations(_ file: TranslationFile, for code: String, version: Int) async
    public func clearCache() async
    public func getCachedLanguages() async -> [String]
    public func deleteCacheFile(for code: String) async throws
    public func getCacheDirectory() async -> String
}
```

### String Extensions

```swift
extension String {
    // Simple
    public func localize(default: String, comment: String? = nil) -> String

    // With single argument
    public func localize(default: String, comment: String? = nil, with: CVarArg) -> String

    // With multiple arguments
    public func localize(default: String, comment: String? = nil, with: CVarArg...) -> String

    // Plural without interpolation
    public func localize(defaultPlural: [PluralCategory: String], comment: String? = nil, count: Int) -> String

    // Plural with single argument
    public func localize(defaultPlural: [PluralCategory: String], comment: String? = nil, count: Int, with: CVarArg) -> String

    // Plural with multiple arguments
    public func localize(defaultPlural: [PluralCategory: String], comment: String? = nil, count: Int, with: CVarArg...) -> String
}
```

### Text Extensions (SwiftUI)

```swift
extension Text {
    public static func localized(_ key: String, default: String, comment: String = "") -> Text
    public static func localized(_ key: String, default: String, comment: String = "", with: CVarArg) -> Text
    public static func localized(_ key: String, default: String, comment: String = "", with: CVarArg...) -> Text
}
```

### View Modifier

```swift
extension View {
    public func onLanguageChange() -> some View
}
```

### Models

```swift
public struct Language: Codable, Sendable, Identifiable {
    public let code: String
    public let nameEn: String
    public let nameLocale: String
    public let version: Int
}

public enum PluralCategory: String, Codable, CaseIterable, Sendable {
    case zero, one, two, few, many, other
}

public enum CacheState: Sendable {
    case valid(cachedFile: CachedTranslationFile)
    case stale(cachedVersion: Int)
    case missing
    case corrupted
}

public typealias PluralRule = (Int, Int) -> Int
```

---

## Troubleshooting

### String Not Translating

**Possible causes:**
1. Translation not loaded from server
2. Key mismatch between code and JSON
3. Device offline on first launch

**Solutions:**
```swift
// Check if translation exists
if let translation = LocalizationManager.shared.string(for: "my_key") {
    print("Found: \(translation)")
} else {
    print("Key not found, using default")
}

// Verify cached languages
let cached = await LocalizationManager.shared.getCachedLanguages()
print("Cached: \(cached)")
```

### UI Not Updating on Language Change

**Ensure `.onLanguageChange()` is applied:**
```swift
// Must be on root view
WindowGroup {
    ContentView()
        .onLanguageChange()  // Required
}
```

### Format Specifier Errors

**Symptoms:** Wrong values, crashes, garbled text

**Solutions:**
- Verify specifier types match (`%@` for String, `%d` for Int)
- Check that translation has same specifiers as English
- Escape literal `%` as `%%`

### Plural Not Working

**Checklist:**
1. Include `.other` category (always required)
2. Pass `count` parameter for category selection
3. Pass value in `with` for interpolation
4. Verify translator provided needed categories

```swift
// Correct usage
"items".localize(
    defaultPlural: [.one: "1 item", .other: "%d items"],
    comment: "...",
    count: itemCount,      // For category selection
    with: itemCount        // For %d interpolation
)
```

### Cache Issues

```swift
// Clear and reload
await LocalizationManager.shared.clearCache()
await loadTranslations()

// Check cache location
let path = await LocalizationManager.shared.getCacheDirectory()
print("Cache: \(path)")
```

---

## Related Documentation

- [LocalizeKit CLI Usage Guide](LocalizeKitCLI.md) - Managing translation files
- [CLDR Plural Rules](https://cldr.unicode.org/index/cldr-spec/plural-rules) - Language-specific pluralization

---

*LocalizeKit v1.0.0*
