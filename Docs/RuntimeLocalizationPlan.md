# Runtime Localization System - Implementation Plan

## Overview
Build a runtime translation system that fetches localization JSON from server. Apply to **Store module** initially while keeping Home module's existing .xcstrings. Default fallback is English text embedded in code. Other modules (Todo, News) can adopt this system later.

---

## Phase 1: Core Localization Infrastructure (LocalizeKit Module)

### 1.1 Create LocalizationKit Components
**Location:** `Targets/LocalizeKit/Sources/`

**Note:** The LocalizeKit module already exists with proper dependencies (Core, SuperLog, NetworkKit).

**Files to create:**
- `PluralCategory.swift` - Enum for plural categories (zero/one/two/few/many/other) with locale-aware rules
- `LocalizationManager.swift` - Main manager (singleton) handling translation loading/retrieval
- `TranslationStorage.swift` - FileManager-based caching (JSON files in Caches directory)
- `TranslationModels.swift` - Codable models for JSON structure with plurals support

**Key features:**
- Fallback chain: Runtime JSON → Cached JSON → Default English text from code
- Support for plurals with all 6 CLDR categories (zero/one/two/few/many/other)
- **Custom plural rules** per language (Vue-i18n style)
- Support for string interpolation variables
- Observable pattern for language changes
- PluralCategory enum with locale-aware plural rule detection

### 1.2 Custom Plural Rules Configuration

**Custom Plural Rule Support:**

LocalizeKit supports custom plural rule functions per language, similar to Vue-i18n's `pluralizationRules`. This allows proper pluralization for languages with complex rules (Russian, Arabic, Polish, etc.).

**Type Definition:**
```swift
/// Plural rule function signature
/// - Parameters:
///   - choice: The numeric value to determine plural form
///   - choicesLength: Number of available plural categories (always 6 for CLDR)
/// - Returns: Index of the plural category to use (0-5)
public typealias PluralRule = (Int, Int) -> Int
```

**Configuration:**
```swift
// Configure at app startup (e.g., in AppDelegate or @main)
LocalizationManager.shared.configure(
    pluralRules: [
        "en": { choice, choicesLength in
            // English: zero, one, other
            if choice == 0 { return 0 }  // zero
            if choice == 1 { return 1 }  // one
            return 5  // other
        },

        "ar": { choice, choicesLength in
            // Arabic: Uses all 6 categories
            if choice == 0 { return 0 }  // zero
            if choice == 1 { return 1 }  // one
            if choice == 2 { return 2 }  // two
            if choice % 100 >= 3 && choice % 100 <= 10 { return 3 }  // few
            if choice % 100 >= 11 { return 4 }  // many
            return 5  // other
        },

        "ru": { choice, choicesLength in
            // Russian: one, few, many, other
            if choice == 0 { return 4 }  // many

            let teen = choice > 10 && choice < 20
            let endsWithOne = choice % 10 == 1

            if !teen && endsWithOne { return 1 }  // one (1, 21, 31...)
            if !teen && choice % 10 >= 2 && choice % 10 <= 4 { return 3 }  // few (2-4, 22-24...)

            return 4  // many (0, 5-20, 25-30...)
        }
    ]
)
```

**Plural Category Mapping:**
- Index 0 → `.zero`
- Index 1 → `.one`
- Index 2 → `.two`
- Index 3 → `.few`
- Index 4 → `.many`
- Index 5 → `.other`

**Notes:**
- Custom rules are **optional** - LocalizeKit has built-in rules for common languages
- Custom rules override built-in rules when configured
- If no rule found, defaults to simple English-style pluralization

### 1.3 Add Network Layer for Translations
**Location:** `Targets/NetworkKit/Sources/`

**Files to create:**
- `LocalizationAPI.swift` - API endpoint definition for fetching translations
  - Endpoint: `GET /translations/{languageCode}.json`
  - Supports version headers for cache invalidation

**Files to modify:**
- `DataSource.swift` - Add `static let Localization = Backend<LocalizationAPI>()`

### 1.3 Update Preferences System
**Location:** `Targets/Core/Sources/Preferences/`

**Files to modify:**
- `Preferences.swift` - Add:
  ```swift
  @UserDefault(key: .selectedLanguage)
  public static var selectedLanguage: String? // Language code (e.g., "en", "bn")

  @UserDefault(key: .translationVersion)
  public static var translationVersion: String? // For cache invalidation
  ```
- `PreferenceKey.swift` - Add new keys

---

## Phase 2: Translation Management Tool (Interactive CLI)

### 2.1 Single Interactive Translation Tool
**Location:** `Tools/LocalizeKit/`

This is a unified command-line tool with an interactive menu system for all translation management tasks.

**Structure:**
```
Tools/LocalizeKit/
├── Package.swift
└── Sources/
    └── LocalizeKit/
        ├── main.swift                  # Entry point with menu system
        ├── Commands/
        │   ├── ExtractCommand.swift    # Extract strings from code
        │   ├── MergeCommand.swift      # Merge translations
        │   ├── ValidateCommand.swift   # Validate translations
        │   └── DiffCommand.swift       # Generate diff
        ├── Core/
        │   ├── StringParser.swift      # Parse Swift files using SwiftSyntax
        │   ├── ModuleScanner.swift     # Scan Targets/ folder for modules
        │   ├── JSONGenerator.swift     # Generate JSON
        │   ├── MergeEngine.swift       # Merge logic
        │   ├── Validator.swift         # Validation logic
        │   └── DiffGenerator.swift     # Compare versions
        ├── UI/
        │   ├── MenuSystem.swift        # Interactive menu
        │   ├── ProgressBar.swift       # Progress indicators
        │   └── Colors.swift            # Terminal colors
        └── Models/
            └── TranslationModels.swift # Data models
```

**Interactive Menu System:**
```
╔════════════════════════════════════════════╗
║   LocalizeKit - Translation Manager        ║
╠════════════════════════════════════════════╣
║                                            ║
║  📁 Project: Why-Not-SwiftUI              ║
║  📂 Modules: Store, Todo, News, Home      ║
║  🌍 Version: 1.1                          ║
║                                            ║
╠════════════════════════════════════════════╣
║                                            ║
║  1. 📤 Extract strings from code          ║
║  2. 🔄 Merge translations                 ║
║  3. ✅ Validate translations              ║
║  4. 📊 Generate diff                      ║
║  5. ⚙️  Settings                          ║
║  6. ❌ Exit                               ║
║                                            ║
╚════════════════════════════════════════════╝

Select an option (1-6): _
```

---

### 2.2 Module-Based Organization

**Module Detection:**
- Tool automatically scans `Targets/` folder in project root
- Each subfolder in `Targets/` is treated as a module
- If `Targets/` folder not found → Exit with error
- Modules detected: `Store`, `Todo`, `News`, `Home`, `Core`, etc.

**JSON Structure by Module:**
```json
{
  "version": 1,
  "modules": {
    "Store": {
      "store_welcome": {
        "value": "স্টোরে স্বাগতম!",
        "type": "simple",
        "comment": "Greeting shown on store home screen"
      },
      "store_items_count": {
        "type": "plural",
        "comment": "Apple count in shopping cart",
        "value": {
          "zero": "কোন আইটেম নেই",
          "one": "১টি আইটেম",
          "other": "%d টি আইটেম"
        }
      }
    },
    "Todo": {
      "todo_add": {
        "value": "যোগ করুন",
        "type": "simple",
        "comment": "Add button"
      }
    },
    "News": {
      "news_latest": {
        "value": "সর্বশেষ খবর",
        "type": "simple",
        "comment": "Latest news section title"
      }
    }
  }
}
```

**Notes:**
- Single language per JSON file (no `defaultValue` field)
- English JSON has English text in `value` field
- Bengali JSON has Bengali text in `value` field
- Strings grouped by module (based on Targets/ folder structure)
- Each module contains only its own strings

---

### 2.3 Command 1: Extract Strings

**Interactive Flow:**
```
╔════════════════════════════════════════════╗
║   Extract Strings from Code                ║
╠════════════════════════════════════════════╣

📁 Scanning Targets/ folder...
   ✓ Found 4 modules: Store, Todo, News, Core

📦 Select modules to extract:
   [✓] 1. Store (45 strings found)
   [✓] 2. Todo (23 strings found)
   [✓] 3. News (18 strings found)
   [ ] 4. Core (0 localized strings)
   [✓] 5. All modules

🔢 Enter version number: 1.1

📄 Compare with previous version?
   [Y/n]: y

📂 Select previous version file:
   > Exports/base/en_v1.0.json

🎯 Output location:
   > Exports/base/en_v1.1.json

📊 Processing...
   [████████████████████] 100%

✅ Extraction complete!
   - New keys: 8
   - Modified keys: 3
   - Removed keys: 1
   - Total keys: 86

📑 Diff saved to: Exports/diff/diff_v1.0_to_v1.1.json

Press Enter to continue...
```

**Generated Base English JSON:**
```json
{
  "version": "1.1",
  "language": "en",
  "generatedAt": "2025-11-27T10:30:00Z",
  "modules": {
    "Store": {
      "store_welcome": {
        "value": "Welcome to the Store!",
        "type": "simple",
        "comment": "Greeting shown on store home screen",
        "metadata": {
          "addedInVersion": "1.0",
          "lastModifiedVersion": "1.1",
          "status": "modified"
        }
      },
      "store_items_count": {
        "type": "plural",
        "comment": "Apple count in shopping cart",
        "value": {
          "zero": "No items",
          "one": "1 item",
          "other": "%d items"
        },
        "metadata": {
          "addedInVersion": "1.0",
          "status": "unchanged"
        }
      }
    },
    "Todo": {
      "todo_add": {
        "value": "Add",
        "type": "simple",
        "comment": "Add button",
        "metadata": {
          "addedInVersion": "1.1",
          "status": "new"
        }
      }
    }
  }
}
```

**Diff File Format:**
```json
{
  "version": "1.1",
  "previousVersion": "1.0",
  "generatedAt": "2025-11-27T10:30:00Z",
  "summary": {
    "new": 8,
    "modified": 3,
    "removed": 1,
    "unchanged": 74
  },
  "changesByModule": {
    "Store": {
      "new": {
        "store_new_feature": {
          "value": "New Feature!",
          "type": "simple",
          "comment": "Button for new feature"
        }
      },
      "modified": {
        "store_welcome": {
          "oldValue": "Welcome!",
          "newValue": "Welcome to the Store!",
          "type": "simple",
          "comment": "Updated greeting text"
        }
      },
      "removed": {}
    },
    "Todo": {
      "new": {
        "todo_add": {
          "value": "Add",
          "type": "simple",
          "comment": "Add button"
        }
      },
      "modified": {},
      "removed": {}
    }
  }
}
```

---

### 2.4 Command 2: Merge Translations

**Interactive Flow:**
```
╔════════════════════════════════════════════╗
║   Merge Translations                       ║
╠════════════════════════════════════════════╣

📂 Select new base file:
   > Exports/base/en_v1.1.json

📂 Select old base file:
   > Exports/base/en_v1.0.json

📂 Select existing translation:
   > Exports/validated/bn.json

🌍 Language detected: Bengali (bn)

📊 Processing...
   [████████████████████] 100%

✅ Merge complete!
   - Preserved translations: 74
   - Flagged for review: 3
   - Needs translation: 8
   - Total keys: 85

💾 Saved to: Exports/translations/pending/bn_v1.1_pending.json

Press Enter to continue...
```

**Output Format:**
```json
{
  "version": "1.1",
  "language": "bn",
  "baseVersion": "1.1",
  "translationStatus": "pending",
  "modules": {
    "Store": {
      "store_welcome": {
        "value": "স্টোরে স্বাগতম",
        "type": "simple",
        "comment": "Greeting shown on store home screen",
        "metadata": {
          "translationStatus": "needs_review",
          "changeReason": "English text modified"
        }
      },
      "store_new_feature": {
        "value": "[NEEDS TRANSLATION] New Feature!",
        "type": "simple",
        "comment": "Button for new feature",
        "metadata": {
          "translationStatus": "untranslated"
        }
      }
    }
  }
}
```

---

### 2.5 Command 3: Validate Translations

**Interactive Flow:**
```
╔════════════════════════════════════════════╗
║   Validate Translation                     ║
╠════════════════════════════════════════════╣

📂 Select base file:
   > Exports/base/en_v1.1.json

📂 Select translation file:
   > Exports/translations/completed/bn_v1.1_completed.json

🔍 Validating...
   [████████████████████] 100%

Validation Results:
╔════════════════════════════════════════════╗
║ ✅ Passed with warnings                   ║
╠════════════════════════════════════════════╣
║ Total keys: 85                             ║
║ Translated: 85                             ║
║ Errors: 0                                  ║
║ Warnings: 1                                ║
╚════════════════════════════════════════════╝

⚠️  Warnings:
   - store_old_key: Extra key (not in base)

💾 Save validated file to: Exports/validated/bn.json
📄 Report saved to: Exports/validation_reports/bn_v1.1_report.json

Press Enter to continue...
```

---

### 2.6 Command 4: Generate Diff

**Interactive Flow:**
```
╔════════════════════════════════════════════╗
║   Generate Diff                            ║
╠════════════════════════════════════════════╣

📂 Select old version:
   > Exports/base/en_v1.0.json

📂 Select new version:
   > Exports/base/en_v1.1.json

📊 Comparing...
   [████████████████████] 100%

Changes Summary:
╔════════════════════════════════════════════╗
║ Module: Store                              ║
║   New: 5                                   ║
║   Modified: 2                              ║
║   Removed: 0                               ║
║                                            ║
║ Module: Todo                               ║
║   New: 3                                   ║
║   Modified: 1                              ║
║   Removed: 1                               ║
╚════════════════════════════════════════════╝

💾 Diff saved to: Exports/diff/diff_v1.0_to_v1.1.json

Press Enter to continue...
```

---

### 2.7 Settings

**Interactive Flow:**
```
╔════════════════════════════════════════════╗
║   Settings                                 ║
╠════════════════════════════════════════════╣

📁 Project root: /Users/name/Why-Not-SwiftUI
📂 Exports folder: /Users/name/Exports
🎯 Default output: Exports/base/

1. Change project root
2. Change exports folder
3. Set default language
4. Back to main menu

Select option: _
```

---

### 2.8 Error Handling

**If Targets/ Folder Not Found:**
```
╔════════════════════════════════════════════╗
║   ❌ Error                                 ║
╠════════════════════════════════════════════╣
║                                            ║
║  Targets/ folder not found!                ║
║                                            ║
║  Current directory:                        ║
║  /Users/name/SomeProject                   ║
║                                            ║
║  This tool must be run from the project    ║
║  root directory that contains a Targets/   ║
║  folder.                                   ║
║                                            ║
║  Expected structure:                       ║
║  YourProject/                              ║
║  ├── Targets/                              ║
║  │   ├── Store/                            ║
║  │   ├── Todo/                             ║
║  │   └── ...                               ║
║  └── Tools/                                ║
║                                            ║
╚════════════════════════════════════════════╝

Press Enter to exit...
```

---

### 2.9 Usage

**Installation:**
```bash
cd Tools/LocalizeKit
swift build -c release
```

**Run:**
```bash
# From project root
./Tools/LocalizeKit/.build/release/LocalizeKit

# Or add to PATH and run from anywhere
localizekit
```

**Non-Interactive Mode (for CI/CD):**
```bash
# Extract
localizekit extract --modules Store,Todo --version 1.1 \
  --output Exports/base/en_v1.1.json

# Merge
localizekit merge \
  --base-new Exports/base/en_v1.1.json \
  --base-old Exports/base/en_v1.0.json \
  --existing Exports/validated/bn.json \
  --output Exports/translations/pending/bn_v1.1_pending.json

# Validate
localizekit validate \
  --base Exports/base/en_v1.1.json \
  --translated Exports/translations/completed/bn_v1.1.json \
  --output Exports/validated/bn.json
```

#### **Workflow 1: Initial Setup (v1.0)**

**Using Interactive CLI:**
```bash
# Step 1: Run LocalizeKit tool
cd Tools/LocalizeKit
./build/release/LocalizeKit

# In the menu:
# 1. Select "Extract strings from code"
# 2. Select all modules (Store, Todo, News)
# 3. Enter version: 1.0
# 4. No previous version to compare
# 5. Output: Exports/base/en_v1.0.json

# Step 2: Send en_v1.0.json to translators
# Translator returns: bn_v1.0.json, ar_v1.0.json

# Step 3: Validate translations
# In the menu:
# 1. Select "Validate translations"
# 2. Base: Exports/base/en_v1.0.json
# 3. Translation: bn_v1.0.json
# 4. Output: Exports/validated/bn.json
# Repeat for each language

# Step 4: Upload Exports/validated/*.json to server
```

**Using CLI Mode (Non-Interactive):**
```bash
# Step 1: Extract
localizekit extract --modules Store,Todo,News --version 1.0 \
  --output Exports/base/en_v1.0.json

# Step 2: Send to translators (manual)

# Step 3: Validate
localizekit validate \
  --base Exports/base/en_v1.0.json \
  --translated bn_v1.0.json \
  --output Exports/validated/bn.json

# Step 4: Upload to server
```

---

#### **Workflow 2: Updates (v1.0 → v1.1)**

**Using Interactive CLI:**
```bash
# Step 1: Extract with diff
# In menu:
# 1. Select "Extract strings from code"
# 2. Select all modules
# 3. Enter version: 1.1
# 4. Compare with previous: Yes
# 5. Previous file: Exports/base/en_v1.0.json
# 6. Output: Exports/base/en_v1.1.json
# 7. Diff saved to: Exports/diff/diff_v1.0_to_v1.1.json

# Step 2: Merge into existing translations
# In menu:
# 1. Select "Merge translations"
# 2. New base: Exports/base/en_v1.1.json
# 3. Old base: Exports/base/en_v1.0.json
# 4. Existing translation: Exports/validated/bn.json
# 5. Output: Exports/translations/pending/bn_v1.1_pending.json

# Step 3: Send to translators
# Files: diff_v1.0_to_v1.1.json + bn_v1.1_pending.json
# Translator returns: bn_v1.1_completed.json

# Step 4: Validate
# In menu:
# 1. Select "Validate translations"
# 2. Base: Exports/base/en_v1.1.json
# 3. Translation: bn_v1.1_completed.json
# 4. Output: Exports/validated/bn.json

# Step 5: Upload to server
```

---

#### **Workflow 3: Emergency Hotfix**

```bash
# For critical translation fixes

# Step 1: Edit validated file directly
# Edit: Exports/validated/bn.json
# Fix incorrect translation

# Step 2: Optional re-validation
localizekit validate \
  --base Exports/base/en_v1.1.json \
  --translated Exports/validated/bn.json \
  --output Exports/validated/bn.json

# Step 3: Upload to server
```

---

## Phase 3: Runtime Translation Wrapper

### 3.1 Create String Extension for Localization
**Location:** `Targets/LocalizeKit/Sources/`

**Files to create:**
- `String+Localization.swift` - String extension with localization methods
- `PluralCategory.swift` - Enum for plural categories (if not created in Phase 1)

**PluralCategory Implementation:**
```swift
public enum PluralCategory: String, Codable, CaseIterable {
    case zero
    case one
    case two
    case few
    case many
    case other

    /// Determine plural category for a count based on custom rules or built-in locale rules
    /// - Parameters:
    ///   - count: The numeric value
    ///   - locale: The locale (defaults to current)
    /// - Returns: The appropriate plural category
    public static func category(
        for count: Int,
        locale: Locale = .current
    ) -> PluralCategory {

        let allCategories: [PluralCategory] = [.zero, .one, .two, .few, .many, .other]
        let languageCode = locale.languageCode ?? "en"

        // 1. Check if LocalizationManager has a custom rule for current language
        if let customRule = LocalizationManager.shared.pluralRules[languageCode] {
            let index = customRule(count, allCategories.count)
            // Clamp index to valid range (0-5)
            let safeIndex = max(0, min(index, allCategories.count - 1))
            return allCategories[safeIndex]
        }

        // 2. Fallback to built-in ICU/CLDR rules
        return builtInCategory(for: count, languageCode: languageCode)
    }

    /// Built-in plural rules following CLDR standards
    private static func builtInCategory(for count: Int, languageCode: String) -> PluralCategory {
        switch languageCode {
        case "en":
            // English: zero, one, other
            if count == 0 { return .zero }
            if count == 1 { return .one }
            return .other

        case "ar":
            // Arabic: Uses all 6 categories
            if count == 0 { return .zero }
            if count == 1 { return .one }
            if count == 2 { return .two }
            if count % 100 >= 3 && count % 100 <= 10 { return .few }
            if count % 100 >= 11 { return .many }
            return .other

        case "ru", "uk":
            // Russian/Ukrainian: one, few, many, other
            let mod10 = count % 10
            let mod100 = count % 100

            if mod10 == 1 && mod100 != 11 { return .one }
            if mod10 >= 2 && mod10 <= 4 && !(mod100 >= 12 && mod100 <= 14) { return .few }
            if mod10 == 0 || (mod10 >= 5 && mod10 <= 9) || (mod100 >= 11 && mod100 <= 14) { return .many }
            return .other

        case "pl":
            // Polish: one, few, many, other
            if count == 1 { return .one }
            let mod10 = count % 10
            let mod100 = count % 100
            if mod10 >= 2 && mod10 <= 4 && !(mod100 >= 12 && mod100 <= 14) { return .few }
            return .many

        default:
            // Default simple rule for unknown languages
            if count == 0 { return .zero }
            if count == 1 { return .one }
            return .other
        }
    }
}
```

**String Extension Implementation:**
```swift
extension String {
    /// Simple localization with default fallback
    /// - Parameters:
    ///   - defaultValue: English text to show if translation not found
    ///   - comment: Context for translators (optional)
    /// - Returns: Localized string or default value
    func localize(
        default defaultValue: String,
        comment: String = ""
    ) -> String {
        LocalizationManager.shared.string(for: self) ?? defaultValue
    }

    /// Localization with string interpolation
    /// - Parameters:
    ///   - defaultValue: English format string
    ///   - comment: Context for translators
    ///   - arguments: Values to interpolate
    /// - Returns: Formatted localized string
    func localize(
        default defaultValue: String,
        comment: String = "",
        with arguments: CVarArg...
    ) -> String {
        let format = localize(default: defaultValue, comment: comment)
        return String(format: format, arguments: arguments)
    }

    /// Localization with plural support
    /// - Parameters:
    ///   - defaultPlural: Dictionary of plural forms for English
    ///   - comment: Context for translators
    ///   - count: The count to determine plural form
    /// - Returns: Localized plural string
    func localize(
        defaultPlural: [PluralCategory: String],
        comment: String = "",
        count: Int
    ) -> String {
        // Try to get from server/cache first
        if let translated = LocalizationManager.shared.pluralString(for: self, count: count) {
            return translated
        }

        // Fallback to default plurals
        let category = PluralCategory.category(for: count)

        // Try exact category match first
        if let value = defaultPlural[category] {
            return value
        }

        // Fallback chain: other → many → few → two → one → zero → key
        return defaultPlural[.other]
            ?? defaultPlural[.many]
            ?? defaultPlural[.few]
            ?? defaultPlural[.two]
            ?? defaultPlural[.one]
            ?? defaultPlural[.zero]
            ?? self  // Last resort: return key
    }

    /// Localization with plural and interpolation
    /// - Parameters:
    ///   - defaultPlural: Dictionary of plural format strings for English
    ///   - comment: Context for translators
    ///   - count: The count for plural form
    ///   - arguments: Values to interpolate
    /// - Returns: Formatted localized plural string
    func localize(
        defaultPlural: [PluralCategory: String],
        comment: String = "",
        count: Int,
        with arguments: CVarArg...
    ) -> String {
        let format = localize(defaultPlural: defaultPlural, comment: comment, count: count)
        return String(format: format, arguments: arguments)
    }
}
```

**Usage Examples:**

```swift
// 1. Simple localization
Text("store_welcome".localize(
    default: "Welcome to the Store!",
    comment: "Greeting shown on store home screen"
))

// 2. String interpolation (single parameter)
Text("store_greeting".localize(
    default: "Hello, %@!",
    comment: "Personal greeting with user's name",
    with: userName
))

// 3. String interpolation (multiple parameters)
Text("store_order_summary".localize(
    default: "Order #%@ contains %d items",
    comment: "Order summary with ID and item count",
    with: orderID, itemCount
))

// 4. Plural without interpolation
Text("store_apple_count".localize(
    defaultPlural: [
        .zero: "No apples",
        .one: "1 apple",
        .other: "%d apples"
    ],
    comment: "Apple count in shopping cart",
    count: appleCount
))

// 5. Plural with interpolation
Text("store_apple_count".localize(
    defaultPlural: [
        .zero: "No apples",
        .one: "1 apple",
        .other: "%d apples"
    ],
    comment: "Apple count in shopping cart",
    count: appleCount,
    with: appleCount
))

// 6. Complex plural (more categories for other languages)
Text("store_item_summary".localize(
    defaultPlural: [
        .zero: "Your cart is empty",
        .one: "You have 1 item",
        .two: "You have a pair of items",  // For languages that have 'two' category
        .other: "You have %d items"
    ],
    comment: "Cart summary message",
    count: itemCount,
    with: itemCount
))

// 7. Price formatting
Text("store_price".localize(
    default: "Price: %@",
    comment: "Product price label",
    with: formattedPrice
))

// 8. Percentage discount
Text("store_discount".localize(
    default: "Save %d%%",
    comment: "Discount percentage",
    with: discountPercent
))
```

### 3.2 Create View Modifier for Auto-Refresh
**File to create:**
- `LocalizationObserver.swift` - View modifier that refreshes UI when language changes

**Usage:**
```swift
ContentView()
    .onLanguageChange() // Auto-refreshes when LocalizationManager publishes change
```

---

## Phase 4: Language Selection UI in Store Module

### 4.1 Create Language Selection Screen in Store
**Location:** `Targets/Store/Sources/UI/Settings/`

**Files to create:**
- `LanguageSettingsScreen.swift` - Language selection screen
- `LanguageSettingsViewModel.swift` - View model for language management
- `LanguageModel.swift` - Available languages model

**Features:**
- Display current language
- Show available languages (fetched from server or hardcoded list)
- Show download status/progress when fetching translations
- Preview sample text in selected language before confirming
- Language selection persisted in Preferences

**Integration:**
- User selects language on login or from a settings button within Store
- No app-wide Settings module needed
- Language preference applies to Store module only (other modules unaffected)

### 4.2 Integrate into Store Navigation
**Files to modify:**
- `Targets/Store/Sources/UI/Home/HomeScreen.swift` - Add language settings navigation
- Add language selection screen to Store's internal navigation flow

---

## Phase 5: Apply to Store Module

### 5.1 Update Store Module
**Location:** `Targets/Store/Sources/`

**Changes:**
1. Add LocalizeKit as a dependency to Store module in `Project.swift`
2. Replace all hardcoded strings with `.localize()` extension
3. Test with fetched translations from server

**Example transformation:**
```swift
// Before:
Text("Add to Cart")

// After:
Text("store_add_to_cart".localize(
    default: "Add to Cart",
    comment: "Button to add product to shopping cart"
))

// Before (with count):
Text("\(count) items")

// After (with plural):
Text("store_item_count".localize(
    defaultPlural: [
        .zero: "No items",
        .one: "1 item",
        .other: "%d items"
    ],
    comment: "Number of items in cart",
    count: count,
    with: count
))
```

**Store Module Screens to Update:**
- HomeScreen
- SplashScreen
- ProductsScreen
- ProductDetailsScreen
- CartScreen
- PlaceOrderScreen
- OrdersScreen
- ProfileSheet

**Note:** Todo and News modules can adopt this localization system in the future following the same pattern.

---

## Phase 6: Server Integration & Testing

### 6.1 Define Server API Contract
**API Endpoints required:**

1. **Get Available Languages:**
   - `GET /api/translations/languages`
   - Response:
     ```json
     {
       "languages": [
         {"code": "en", "name": "English", "nativeName": "English"},
         {"code": "bn", "name": "Bengali", "nativeName": "বাংলা"},
         {"code": "ar", "name": "Arabic", "nativeName": "العربية"}
       ]
     }
     ```

2. **Get Translation File for Specific Language:**
   - `GET /api/translations/{languageCode}.json`
   - Example: `GET /api/translations/bn.json`
   - Response: Single language JSON file organized by modules
     ```json
     {
       "version": 1,
       "modules": {
         "Store": {
           "store_welcome": {
             "value": "স্টোরে স্বাগতম!",
             "type": "simple",
             "comment": "Greeting shown on store home screen"
           },
           "store_items_count": {
             "type": "plural",
             "comment": "Apple count in shopping cart",
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
         },
         "Todo": {
           "todo_add": {
             "value": "যোগ করুন",
             "type": "simple",
             "comment": "Add todo button"
           }
         },
         "News": {
           "news_latest": {
             "value": "সর্বশেষ খবর",
             "type": "simple",
             "comment": "Latest news section"
           }
         }
       }
     }
     ```

**Notes:**
- Server provides one JSON file per language
- Each file organized by modules (from Targets/ folder)
- Single `value` field (no `defaultValue`)
- `comment` field provides context for reference
- Version field used for cache invalidation

### 6.2 Use Moya Mock Stubbing for Development
**Location:** `Targets/NetworkKit/Sources/`

**Implementation:**
- Use Moya's `endpointClosure` with stub responses
- Create local JSON files for different languages in `Targets/LocalizeKit/Tests/Resources/`
- Mock files:
  - `translations_en.json` - English translations
  - `translations_bn.json` - Bengali translations
  - `translations_ar.json` - Arabic translations
  - `languages.json` - Available languages list

**Example stubbing setup:**
```swift
let localizationProvider = MoyaProvider<LocalizationAPI>(
    endpointClosure: { target in
        return Endpoint(
            url: URL(target: target).absoluteString,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    },
    stubClosure: MoyaProvider.immediatelyStub
)
```

### 6.3 Testing Strategy
1. Unit tests for LocalizationManager (fallback logic)
2. Test extraction tool with Store module Swift files
3. Test language switching with Moya stubbed data
4. Test offline behavior (cached translations)
5. Test missing key fallback (string returns itself)
6. Test all variation types (simple, plural, interpolation)

---

## LocalizeKit Configuration

### App Startup Configuration

Configure LocalizeKit at app startup to set up custom plural rules:

**Location:** `Targets/WhyNotSwiftUI/Sources/WhyNotSwiftUIApp.swift` (or Store module's entry point)

```swift
import SwiftUI
import LocalizeKit

@main
struct WhyNotSwiftUIApp: App {
    init() {
        // Configure LocalizeKit with custom plural rules
        configureLocalization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func configureLocalization() {
        LocalizationManager.shared.configure(
            pluralRules: [
                "en": englishPluralRule,
                "bn": bengaliPluralRule,
                "ar": arabicPluralRule,
                "ru": russianPluralRule
            ]
        )
    }

    // English plural rule: zero, one, other
    private var englishPluralRule: PluralRule {
        { choice, _ in
            if choice == 0 { return 0 }
            if choice == 1 { return 1 }
            return 5  // other
        }
    }

    // Bengali plural rule: Similar to English
    private var bengaliPluralRule: PluralRule {
        { choice, _ in
            if choice == 0 { return 0 }
            if choice == 1 { return 1 }
            return 5
        }
    }

    // Arabic plural rule: All 6 categories
    private var arabicPluralRule: PluralRule {
        { choice, _ in
            if choice == 0 { return 0 }  // zero
            if choice == 1 { return 1 }  // one
            if choice == 2 { return 2 }  // two
            if choice % 100 >= 3 && choice % 100 <= 10 { return 3 }  // few
            if choice % 100 >= 11 { return 4 }  // many
            return 5  // other
        }
    }

    // Russian plural rule: Complex Slavic rules
    private var russianPluralRule: PluralRule {
        { choice, choicesLength in
            if choice == 0 { return 4 }  // many

            let teen = choice > 10 && choice < 20
            let endsWithOne = choice % 10 == 1

            if !teen && endsWithOne { return 1 }  // one
            if !teen && choice % 10 >= 2 && choice % 10 <= 4 { return 3 }  // few

            return 4  // many
        }
    }
}
```

**Notes:**
- Custom rules are **optional** - built-in rules work for most cases
- Configure only languages you need special handling for
- Rules can be moved to separate file for better organization (e.g., `LocalizationConfig.swift`)

---

## Phase 7: Documentation & Migration Guide

### 7.1 Update AGENTS.md
Add section on localization best practices:
- How to add localized strings in Store module using `.localize()` extension
- How to use different localization methods (simple, plural, interpolation)
- How to configure custom plural rules for complex languages
- How to run extraction tool
- Server API contract

### 7.2 Create LocalizeKit Developer Guide
**Location:** `Docs/LocalizeKitGuide.md`

Contents:
- Architecture overview
- Adding new translatable strings with `.localize()` extension
- Dictionary-based plural forms with all 6 CLDR categories
- **Configuring custom plural rules** (Vue-i18n style)
- Built-in plural rules for common languages
- **Translation management workflow:**
  - Using LocalizationExtractor tool
  - Using TranslationMerger tool
  - Using TranslationValidator tool
  - Complete workflows for initial setup and updates
- Translation JSON format specification
- Directory structure for translation files
- Language selection flow diagram
- Troubleshooting common issues
- All usage examples from Phase 3
- Custom plural rule examples for Arabic, Russian, Polish, etc.
- **Best practices for translator collaboration**

### 7.3 Update CLAUDE.md
Add instruction: "Use `.localize()` String extension from LocalizeKit for all user-facing strings in Store module. Other modules (Todo, News) can adopt later. Home module still uses NSLocalizedString with .xcstrings."

---

## Implementation Order

1. **Week 1:** Phase 1 (LocalizeKit infrastructure with String extension + Custom plural rules) + Phase 2 (Three translation tools)
2. **Week 2:** Phase 3 (String extension methods) + Phase 6.2 (Moya mock stubbing)
3. **Week 3:** Phase 4 (Language selection in Store) + Phase 6.1 (API integration)
4. **Week 4:** Phase 5 (Apply to Store module) + Phase 6.3 (Testing)
5. **Week 5:** Phase 7 (Documentation) + Polish & bug fixes

**Translation Management Timeline:**
- **Initial Setup:** 1-2 days for first extraction and translator onboarding
- **Updates:** 2-3 days (extraction → merge → translate → validate → deploy)
- **Hotfixes:** < 1 hour (manual edit → validate → deploy)

---

## Key Design Decisions

✅ **Dedicated LocalizeKit module** - Separate module for all localization logic with proper dependencies
✅ **String extension API with defaults** - `.localize(default:comment:)` with English fallback in code
✅ **Dictionary-based plurals** - `defaultPlural: [PluralCategory: String]` for all 6 CLDR plural categories
✅ **Custom plural rules (Vue-i18n style)** - Configure per-language plural logic for complex languages
✅ **Built-in plural rules** - Fallback CLDR-compliant rules for English, Arabic, Russian, Polish, etc.
✅ **Translator comments** - Optional `comment` parameter provides context for better translations
✅ **Single interactive CLI tool** - Unified LocalizeKit tool with menu system (not 3 separate tools)
✅ **Module-based organization** - JSON organized by Targets/ folder structure
✅ **Automatic module detection** - Scans Targets/ folder, exits if not found
✅ **No defaultValue field** - Single language per JSON, only `value` field
✅ **Diff generation** - Track new, modified, removed keys between versions by module
✅ **Automated merging** - Merge new keys into existing translations with flags
✅ **Validation pipeline** - Catch errors before deployment (format specifiers, missing keys, etc.)
✅ **Version tracking** - Metadata tracks when keys added/modified
✅ **Status flags** - `untranslated` and `needs_review` guide translators
✅ **Interactive + CLI modes** - Menu system for developers, command-line for CI/CD
✅ **Initial Store module rollout** - Apply to Store module first, then expand to other modules (Todo, News) later
✅ **Store-scoped settings** - Language selection within Store module, no app-wide Settings needed
✅ **Scoped to new modules** - Home keeps .xcstrings (247 strings, 17 languages intact)
✅ **FileManager caching** - Translations cached in Library/Caches, auto-cleaned by system
✅ **Single-language JSON files** - Server provides one JSON per language (not multi-language files)
✅ **Enhanced JSON structure** - Includes `value`, `comment`, `metadata`, `type`, organized by `modules`
✅ **Moya stubbing for dev** - Local JSON files with Moya mock stubbing (no separate server needed)
✅ **SwiftSyntax extraction** - Robust parsing of Swift source files
✅ **English default fallback** - Shows readable English text when translations missing, not ugly keys
✅ **Type-safe variations** - Separate methods for simple, plural, and interpolation
✅ **Observable updates** - UI refreshes automatically on language change

---

## Dependencies to Add

**Extraction/Merger/Validator Tools (Package.swift for each tool):**
- SwiftSyntax - For parsing Swift source files
- Swift Argument Parser (optional) - For better CLI argument handling

All other required dependencies (Alamofire, Moya) already present in main project.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Network failure on first launch | English default text from code shown (e.g., "Welcome to the Store!") |
| Large translation files | FileManager caching + single-language files reduce payload size |
| Memory overhead | Load translations lazily, keep only active language in memory |
| Server downtime | Cache validation + serve cached translations offline |
| Version conflicts | Include version in JSON + cache invalidation logic |
| Missing translations | Default English text displayed (from `defaultValue` parameter) |
| Developer forgets default text | Compile-time error - `default:` parameter is required |
| Translator lacks context | `comment` parameter provides context in JSON |
| **Lost translation history** | **Version tracking in metadata + Git for Exports/ folder** |
| **Translator overwrites good translations** | **Merger preserves existing translations, only flags for review** |
| **Format specifier mismatch** | **Validator checks %@, %d match between languages** |
| **Incomplete plural forms** | **Validator ensures all required categories present** |
| **Deployment of invalid translations** | **Validation pipeline catches errors before upload** |
| **Manual merge errors** | **Automated TranslationMerger tool prevents human error** |
| **Translation cost overruns** | **Diff files show only changed strings - pay for incremental work** |

---

## Current Localization Context

### Existing Setup
- **Home module** has extensive localization with 247 strings in 17 languages via `Localizable.xcstrings`
- Uses `NSLocalizedString("key", bundle: .module, comment: "")` pattern
- Feature modules (Store, Todo, News) currently have no localization
- **LocalizeKit module** already exists with proper dependencies (Core, SuperLog, NetworkKit)

### What Changes
- Store module will use `.localize(default:comment:)` String extension from LocalizeKit
- Default English text embedded in code via `default:` parameter
- Translator context provided via `comment:` parameter
- Plural forms handled with dictionary-based `defaultPlural:` parameter
- Translations fetched from server at runtime as single-language JSON files
- Cached locally with FileManager
- JSON includes both translated `value` and English `defaultValue` for reference
- Home module remains unchanged with its .xcstrings approach

### Migration Path
This is an additive feature - no migration of existing Home module strings required. Store module will be the first to adopt the runtime system with the `.localize(default:comment:)` extension API, serving as a template for Todo and News modules in the future.

**Developer Workflow:**
1. Write code with `.localize(default:comment:)` in Swift files
2. Run extraction tool to generate base English JSON with all strings
3. Send JSON to translators with context from `comment` fields
4. Receive translated JSONs (bn.json, ar.json, etc.)
5. Upload to server
6. App fetches and caches translations at runtime
