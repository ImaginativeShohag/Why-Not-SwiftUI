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
```

## Architecture

### Module Structure

The project is organized into modular frameworks defined in `Project.swift`:

**Core Modules:**
- `Core`: Shared utilities, extensions, networking, theme, environment configuration
- `CommonUI`: Reusable UI components (SuperToast, SuperProgress, CustomTextField, etc.)
- `SuperLog`: Logging framework
- `NetworkKit`: Network layer with Alamofire/Moya integration
- `NavigationKit`: Navigation wrapper on top of NavigationStack

**Feature Modules:**
- `Home`: Main home screen with navigation to all examples
- `Todo`: Todo app with SwiftData and CoreData implementations
- `News`: News module with mock data for UI testing
- `Store`: Store/shop example module

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

### Key Architectural Patterns

**Repository Pattern:**
- Used in Todo module with abstraction over CoreData and SwiftData
- Repositories handle data source switching transparently
- ViewModels depend on repository interfaces, not concrete implementations

**Navigation:**
- Uses `NavigationKit` module with `NavController` and `Destination` pattern
- Centralized navigation logic
- Type-safe navigation with enum-based destinations

**No ViewModels in Components:**
- Components should be stateless/dumb and reusable
- Never pass ViewModels to components
- Pass only required data and callbacks

**Localization:**
- **Home module:** Uses `Localizable.xcstrings` for string resources with `NSLocalizedString("key", bundle: .module, comment: "")`
- **New modules (Todo, Store, News):** Will use runtime localization system - see [Runtime Localization Plan](Docs/RuntimeLocalizationPlan.md)
- Runtime translations fetched from server, cached locally, with English fallback in code

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
