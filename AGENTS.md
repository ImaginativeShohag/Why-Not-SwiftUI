# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Project Overview

Why-Not-SwiftUI is a showcase application demonstrating Swift, SwiftUI, and iOS development best practices. It's a modular iOS app built with Tuist, featuring various SwiftUI components, examples, and patterns.

## Build System: Tuist

This project uses [Tuist](https://tuist.io) for project generation and management.

### Essential Commands

```bash
# Install dependencies (run after cloning or changing dependencies)
tuist install

# Generate and open the Xcode project
tuist generate

# Generate without opening the project in Xcode
tuist generate --no-open

# Build the project
tuist build 'WhyNotSwiftUI Development'

# Update dependency versions
tuist install --update

# Open Tuist manifest files for editing
tuist edit
```

**Important Notes:**
- NEVER open `.xcodeproj` directly - always use `tuist generate`
- Run `tuist generate --no-open` after switching branches to generate `.xcodeproj` file
- Run `tuist build 'WhyNotSwiftUI Development'` to build the project
- Run `tuist test` to run the tests
- Run `tuist install` after modifying dependencies in `Package.swift` or `Project.swift`
- Do NOT use Xcode's built-in Source Control ([known issue](https://github.com/tuist/tuist/issues/4630))

### Testing

```bash
# Run all tests except NetworkProdTests
tuist test 'WhyNotSwiftUI Development' \
    --skip-test-targets NetworkKitTests/NetworkProdTests

# Run Store module UI tests
tuist test 'WhyNotSwiftUI Development' \
    --test-targets StoreUITests
```

**UI Testing Infrastructure:**
- `TestUtils` module provides shared UI testing utilities:
  - `XCUIApplication+` extensions for common operations
  - `XCUIElement+` extensions with `tabBarButton(withLabel:)` for reliable tab selection
  - `MockResponse` system for API stubbing in UI tests
  - `launchApp(with:userData:)` for launching with mock data
- **Store Module UI Tests** (37 tests across 4 suites):
  - `StoreHomeUITests`: Home screen, products, categories, profile navigation
  - `StoreCartUITests`: Cart operations, quantity management, checkout flow
  - `StoreProductsUITests`: Product listing, details, error handling
  - `StoreLanguageUITests`: Language settings and country selection
- **UI Test Best Practices:**
  - Use `tabBarButton(withLabel:)` for tab selection (more reliable than accessibility IDs for SwiftUI TabView)
  - Splash screen delays are automatically skipped in UI test mode for faster execution
  - TabView uses `.automatic` style for better test behavior across devices
- **Accessibility Identifiers:** All interactive elements have identifiers for reliable UI testing
- **Mock User Data:** Tests can inject mock user data via `uiTestEnvKeyUserData` environment variable
- **API Mocking:** Both `StoreAPI` and `LocalizationAPI` support error status codes in UI test mode
- See `Docs/StoreUITestsReport.md` for comprehensive test results and known issues

## Architecture

### Module Structure

The project is organized into modular frameworks defined in `Project.swift`:

**Core Modules:**
- `Core`: Shared utilities, extensions, networking, theme, environment configuration
- `CommonUI`: Reusable UI components (SuperToast, SuperProgress, CustomTextField, etc.)
- `SuperLog`: Logging framework
- `NetworkKit`: Network layer with Alamofire/Moya integration
- `NavigationKit`: Navigation wrapper on top of NavigationStack
- `LocalizeKit`: **Fully independent** runtime localization system with plural support, caching, and language management (zero external dependencies)

**Feature Modules:**
- `Home`: Main home screen with navigation to all examples
- `Todo`: Todo app with SwiftData and CoreData implementations
- `News`: News module with mock data for UI testing
- `Store`: Store/shop example module with runtime localization (Bengali, Arabic) and comprehensive UI test coverage (37 tests)

**Translation Management:**
- `Tools/LocalizeKit`: CLI tool for extracting, merging, validating, and diffing translations

**Testing Modules:**
- `TestUtils`: Shared utilities for UI tests including API mocking, app launch helpers, and XCUIApplication extensions

**Main Target:**
- `WhyNotSwiftUI`: Main app target that depends on all modules

### Directory Structure

```
Targets/
  └── ModuleName/
      ├── Resources/          # Assets, localization files
      ├── Sources/            # Source code
      │   ├── Models/         # Data models (organized by screen/feature)
      │   ├── UI/
      │   │   ├── Components/ # Shared UI components for the module
      │   │   └── Screens/    # Screen implementations
      │   │       └── XYZScreen/
      │   │           ├── Components/      # Screen-specific components
      │   │           ├── XYZScreen.swift  # Screen view
      │   │           └── XYZViewModel.swift # View model
      │   └── ViewModels/     # Shared view models
      ├── Tests/              # Unit tests
      └── UITests/            # UI tests
```

### Naming Conventions

**Important:** Follow these naming patterns:
- Screens: `XYZScreen.swift` (e.g., `HomeScreen`, `MapScreen`)
- Sheets: `XYZSheet.swift` (e.g., `SettingsSheet`, `TodoAddSheet`)
- Alerts: `XYZAlert.swift` (e.g., `ConfirmAlert`, `DeleteAlert`)
- Generic components: Can end with `View` (e.g., `CustomTextFieldView`, `RingChartView`)
- ViewModels: Located in same directory as their screen (e.g., `HomeScreen.swift` + `HomeViewModel.swift`)

### Toolbar Button Conventions

**Important:** Use semantic button roles and placements for toolbar items:

**Dismissal/Close Buttons (for Sheets and Modals):**
```swift
.toolbar {
    ToolbarItem(placement: .cancellationAction) {
        Button("Done", role: .close) {
            dismiss()
        }
    }
}
```
- Use `placement: .cancellationAction` for dismiss/close buttons
- Use `role: .close` to indicate cancellation action
- Automatically positions left (LTR) or right (RTL)
- VoiceOver announces as cancellation, Escape key support

**Confirmation/Apply Buttons:**
```swift
.toolbar {
    ToolbarItem(placement: .confirmationAction) {
        Button("Apply", role: .confirm) {
            applyChanges()
        }
    }
}
```
- Use `role: .confirm` for confirm/apply/save buttons
- Automatically positions right (LTR) or left (RTL)
- Follows iOS HIG for primary actions

### Key Architectural Patterns

**Repository Pattern:**
- Used in Todo module with abstraction over CoreData and SwiftData
- Used in Store module for translation network operations (TranslationRepository)
- Repositories handle data source switching transparently
- ViewModels depend on repository interfaces, not concrete implementations
- LocalizeKit is a pure localization engine; Store module owns translation fetching

**Navigation:**
- Uses `NavigationKit` module with `NavController` and `Destination` pattern
- Centralized navigation logic
- Type-safe navigation with enum-based destinations

**No ViewModels in Components:**
- Components should be stateless/dumb and reusable
- Never pass ViewModels to components
- Pass only required data and callbacks

**ViewModel Patterns:**
- **IMPORTANT:** Always follow existing code patterns when creating or modifying ViewModels
- Use `UIState<T>` from Core module for state management (never create custom state enums)
- Structure pattern (see `ProfileViewModel.swift` or `HomeViewModel.swift` as reference):
  ```swift
  @MainActor
  @Observable
  final class MyViewModel {
      var state: UIState<MyDataType> = .loading

      private var isPreview: Bool = false
      private let repository: MyRepository

      init(repository: MyRepository = MyRepository()) {
          self.repository = repository
      }

      func loadData() async {
          guard !isPreview else { return }
          state = .loading
          // ... fetch data logic
      }
  }

  #if DEBUG
  extension MyViewModel {
      convenience init(forPreview: Bool, isLoading: Bool, isError: Bool) {
          self.init()
          isPreview = true
          // ... set preview state
      }
  }
  #endif
  ```
- Preview initializers must be `convenience init` in a separate extension under `#if DEBUG`
- Always guard against `isPreview` in methods that perform network/data operations
- Use `state.isLoading`, `state.isError`, `state.hasData`, `state.getData()` for state checks

**Localization:**
- **Home module:** Uses `Localizable.xcstrings` for string resources with `NSLocalizedString("key", bundle: .module, comment: "")`
- **Store module:** Uses runtime localization system (LocalizeKit) with full Bengali and Arabic translations
- **Runtime system architecture:**
  - TranslationRepository (Store module) fetches translations from server (currently stubbed in NetworkKit)
  - LocalizationManager (LocalizeKit) handles version-aware caching, lookup, and language activation
  - LocalizeKit has no NetworkKit dependency - pure localization logic
  - LanguageSettingsViewModel coordinates language changes with cache-first strategy
  - **Cache-First Flow:** Check cache version → If valid, use cache (instant) → If stale/missing, fetch from API
  - **Permanent storage:** `Library/Application Support/LocalizeKit/Translations/`
  - **Per-language versioning:** Each language tracks its own version (e.g., bn_BD: v12, ar_AE: v2)
  - **Version comparison:** Cached file version vs server version → only fetch if mismatch
  - **Cache states:** valid (instant load), stale (re-fetch), missing (fetch), corrupted (delete + re-fetch)
  - CLDR-compliant plural support (all 6 categories)
  - Custom plural rules (Vue-i18n style)
  - Three-tier fallback: Server → Cache → English default in code
  - Observable language changes with `.onLanguageChange()` modifier
  - Language selection UI in ProfileSheet
- **Translation files:** Located in `Translations/` directory (base.json for English source, bn.json, ar.json for target languages)
  - **base.json** (source): Contains `version` (int), `language`, `generatedAt`, `modules`, and per-key `metadata` with version tracking
  - **Target files** (bn.json, ar.json, etc.): Simplified format with only `version` (int) and `modules` - NO `language`, `generatedAt`, or `metadata` fields
  - Target files are auto-generated by CLI merge command and should match `TargetTranslationFile` model structure
- **CLI tool:** `Tools/LocalizeKit` - CLI for extracting, merging, validating, and diffing translations
- **CLI features:** Auto-versioning, per-key change tracking, multi-language batch operations
- **Usage:** See [LocalizeKit Runtime Guide](docs/LocalizeKit/LocalizeKitRuntime.md) and [LocalizeKit CLI Guide](docs/LocalizeKit/LocalizeKitCLI.md)

**String Localization API:**
```swift
// Simple string
"key".localize(default: "English text", comment: "Description")

// With interpolation
"key".localize(default: "Hello, %@!", comment: "Greeting", with: name)

// With plurals
"key".localize(
    defaultPlural: [.one: "1 item", .other: "%d items"],
    comment: "Item count",
    count: itemCount
)
```

**Translation Management Workflow:**
1. Add `.localize()` calls in code with English defaults
2. Extract strings: `localizekit extract --project-path .` (auto-increments version, creates/updates base.json)
3. Create target languages: `localizekit merge --language bn --language ar` or `--all`
4. Translate values in target JSON files (bn.json, ar.json)
5. Validate: `localizekit validate --all`
6. Preview changes: `localizekit diff --all`
7. Upload JSON files to server or update stub data in `LocalizationAPI.swift`

**LocalizeKit Key Features:**
- **Fully Independent Module**: Zero dependencies on Core, SuperLog, or any other project modules
- **Internal Utilities**:
  - `LocalizeKitStorage`: Minimal UserDefaults accessor for language preferences (backward compatible with existing keys)
  - `LocalizeKitLogger`: DEBUG-only logging using OSLog (zero overhead in Release builds)
- No manual version specification (auto-managed integer versions)
- `base.json` instead of `en.json` for source language
- Per-key version tracking (tracks which keys changed)
- Simplified target files (includes comments for translator context, no version metadata)
- Smart merge based on version comparison
- Comprehensive Swift unit tests using XCTest framework
- Built-in test suite: `swift test --package-path Tools/LocalizeKit --disable-sandbox`
- **Portable**: Can be copied to any Swift/iOS project or extracted as a standalone Swift Package

## Build Configuration

The project has three build environments defined in `Tuist/ProjectDescriptionHelpers/BuildEnvironment.swift`:
- Development
- Staging
- Production

Each environment has Debug and Release variants, configured via `.xcconfig` files in `ConfigurationFiles/`.

Access environment variables in code:
```swift
Env.hostUrl  // Configured per environment
```

## Tuist-Specific Patterns

### Adding a New Module

1. Add to `Project.swift` modules array:
```swift
Module(
    name: "NewModule",
    hasResources: true,
    hasUnitTest: true,
    hasUITest: false,
    dependencies: ["Core", "CommonUI", "SuperLog"]
)
```

2. Create directory structure using the script:
```bash
./create_tuist_module_directories.sh NewModule
```

3. Run `tuist generate` to regenerate project files

### Accessing Resources with Tuist

**Bundle access:**
```swift
// Current module's bundle
let bundle = Bundle.module

// Specific module's bundle (generated by Tuist)
let bundle = CoreResources.bundle
```

**Asset access (type-safe):**
```swift
// Colors
let color: Color = CoreAsset.exampleColor.swiftUIColor

// Images
let image: UIImage = CoreAsset.exampleImage.image
```

This is safer than string-based asset access and works across module boundaries.

## SwiftData Implementation

The Todo module demonstrates SwiftData usage alongside CoreData:

**Key Files:**
- `Targets/Todo/Sources/Models/SwiftData/SDTodo.swift` - SwiftData model
- `Targets/Todo/Sources/DataSource/SwiftData/SwiftDataDatabase.swift` - `@ModelActor` wrapper
- `Targets/Todo/Sources/DataSource/SwiftData/SwiftDataTodoDao.swift` - Data access layer
- `Targets/Todo/Sources/Repository/TodoRepository.swift` - Repository pattern with data source switching

**SwiftData Preview Setup:**
In-memory containers for previews are configured in `SwiftDataPreviewSampleData.swift`.

## Custom UI Components

The project includes several reusable components in `CommonUI` module:
- `SuperToast` - Android-like toast notifications
- `SuperProgress` - Custom progress indicators
- `CustomTextFieldView` - Text field with validation
- `NativeAlert` - UIAlertController wrapper with color customization
- `RingChart` - Fitness-style ring charts
- `LabelToggle` - Toggle with embedded label
- `ShimmerUI` - Loading shimmer effects
- `AlwaysPopover` - Popover that works consistently across devices

## External Dependencies

Key external packages (defined in `Package.swift` and `Project.swift`):
- Alamofire & Moya - Networking
- Realm & RealmSwift - Database (example usage)
- Kingfisher - Image loading
- DGCharts - Charting
- Lottie - Animations
- Shimmer - Shimmer effects
- MarkdownUI - Markdown rendering
- SwiftUIIntrospect - UIKit bridging

## Development Notes

- **Strict Concurrency:** Enabled (`SWIFT_STRICT_CONCURRENCY: complete`) for Swift 6 readiness
- **Deployment Target:** iOS 18.0
- **Supported Platforms:** iPhone, iPad, Mac with iPad Design, Apple Vision with iPad Design
- **Custom Fonts:** SF Pro Rounded and Roboto Slab are included
- **CoreData:** `TodoDB.xcdatamodeld` in `CoreData/` directory
- **Playground Books:** Located in `Playgrounds/` for GCD, Concurrency, and Combine examples

## Useful Extensions

Located in `Targets/Core/Sources/Extensions/`:

**String Extensions:**
- `md5()` - MD5 hash
- `fileName()` / `fileExtension()` - File path utilities
- `isValidEmail()` - Email validation
- `isBlank()` - Whitespace check

**Array Extensions:**
- `commaSeparatedString(emptyValue:)` - Join string arrays with commas

**View Extensions:**
- `fontStyle(size:weight:)` - Custom font styling using project fonts

## Important Constraints

1. **Never commit** the generated `.xcodeproj` or `.xcworkspace` to git (they're gitignored)
2. **Always use Tuist commands** for project management
3. **Run `tuist install`** before `tuist generate` when dependencies change
4. **Don't use Xcode's Source Control** - use git CLI or external git tools instead
5. **Components must be stateless** - never pass ViewModels to reusable components
6. Use Tuist MCP to get project graph
