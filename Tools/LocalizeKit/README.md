# LocalizeKit CLI

A powerful command-line tool for managing translations in SwiftUI projects with runtime localization support, featuring automatic version management and per-key change tracking.

## Features

- **Extract** strings from Swift source files using SwiftSyntax
- **Merge** translations with intelligent version-based synchronization
- **Validate** translation files for completeness and correctness
- **Preview Diff** between base and target languages (terminal output)
- **Lint** `.localize` / `Text.localized` call sites for arg-count and arg-type mismatches (Xcode build-phase ready)
- **Interactive Menu** for easy access to all commands
- Supports both `String.localize()` and `Text.localized()` patterns
- **Auto-managed versioning** - No manual version specification needed
- **Per-key version tracking** - Track changes at individual string level
- **Multi-language support** - Process multiple languages with `--all` flag

## Installation

### Build from Source

```bash
cd Tools/LocalizeKit
swift build -c release --disable-sandbox
```

The executable will be located at `.build/release/LocalizeKit`.

### Optional: Install to PATH

```bash
# Copy to /usr/local/bin (requires sudo)
sudo cp .build/release/LocalizeKit /usr/local/bin/localizekit

# Or copy to your user bin directory
mkdir -p ~/bin
cp .build/release/LocalizeKit ~/bin/localizekit
# Add ~/bin to your PATH in ~/.zshrc or ~/.bashrc
```

### Verify Installation

```bash
localizekit --version
# Output: 1.0.0
```

## Quick Start

### 1. Extract Strings (First Time)

```bash
localizekit extract --project-path .
```

This creates `Translations/base.json` with version 1 and all extracted strings.

### 2. Create Target Languages

```bash
# Create Arabic translation
localizekit merge --language ar

# Create multiple languages
localizekit merge --language bn --language es
```

### 3. Translate the JSON Files

Edit `ar.json`, `bn.json`, etc. and translate the values from English to target languages.

### 4. After Code Changes

```bash
# Extract again (version auto-increments to 2)
localizekit extract --project-path .

# Sync all languages with base
localizekit merge --all
```

### 5. Validate & Preview

```bash
# Validate all languages
localizekit validate --all

# Preview what needs translation
localizekit diff --language ar
```

## Usage

### Interactive Menu (Default)

Simply run the tool without arguments:

```bash
localizekit
# or
localizekit menu
```

### Command Line Interface

#### Extract Strings

Extract localization strings and update `base.json`:

```bash
# First extraction (creates base.json with version 1)
localizekit extract --project-path .

# Incremental extraction (auto-increments version)
localizekit extract --project-path . --ignore-comment-changes
```

**Options:**
- `--project-path`: Root directory of the project (default: current directory)
- `--ignore-comment-changes`: Skip interactive prompts for comment changes
- `--verbose`: Enable verbose output

**What it does:**
- **First time**: Creates `Translations/base.json` with version 1
- **Subsequent runs**: Increments version and tracks changes per-key
  - **New keys**: Added with current version
  - **Modified keys**: Version updated, marked as modified
  - **Removed keys**: Deleted from base.json
  - **Comment changes**: Interactive prompt (unless `--ignore-comment-changes`)

**Example base.json:**
```json
{
  "version": 2,
  "language": "en",
  "generatedAt": "2025-11-28T10:30:00Z",
  "modules": {
    "Store": {
      "store_welcome": {
        "value": "Welcome, **%@**!",
        "type": "interpolation",
        "comment": "Welcome message with user name",
        "version": 2,
        "metadata": {
          "addedInVersion": 1,
          "lastModifiedVersion": 2,
          "status": "modified"
        }
      }
    }
  }
}
```

#### Merge Translations

Sync target language files with `base.json`:

```bash
# Single language
localizekit merge --language ar

# Multiple languages
localizekit merge --language ar --language bn --language es

# All languages in Translations/
localizekit merge --all
```

**Options:**
- `--language`: Target language code(s) (repeatable)
- `--all`: Merge all available language files
- `--project-path`: Root directory (default: current directory)
- `--verbose`: Enable verbose output

**Version Comparison Logic:**
- Replaces target values when `base_key.version > target_file.version`
- Preserves translations for up-to-date keys
- Adds new keys from base
- Removes keys not in base
- Syncs file version with base

**Example target file (ar.json):**
```json
{
  "version": 2,
  "language": "ar",
  "generatedAt": "2025-11-28T10:31:00Z",
  "modules": {
    "Store": {
      "store_welcome": {
        "value": "!**%@** ،مرحباً",
        "type": "interpolation"
      }
    }
  }
}
```

Note: Target files are simplified (no comments or metadata).

#### Validate Translations

Validate translation files against `base.json`:

```bash
# Single language
localizekit validate --language ar

# Multiple languages
localizekit validate --language ar --language bn

# All languages including base
localizekit validate --all
```

**Options:**
- `--language`: Language code(s) to validate (repeatable)
- `--all`: Validate all files including base.json
- `--project-path`: Root directory (default: current directory)
- `--check-missing`: Check for missing translations (default: true)
- `--check-format`: Check for format string mismatches (default: true)
- `--check-plurals`: Check for plural forms (default: true)
- `--verbose`: Enable verbose output

**Validation Checks:**
1. **Base file**:
   - Version consistency (key version ≤ file version)
   - Format specifiers match type
   - Plural forms completeness

2. **Target files**:
   - Missing keys (in base, not in target)
   - Extra keys (in target, not in base)
   - Untranslated strings (still in English)
   - Format specifier mismatches
   - Plural form mismatches
   - Version status (warns if behind base)

#### Preview Diff

Show translation differences in terminal:

```bash
# Single language
localizekit diff --language ar

# Multiple languages
localizekit diff --language ar --language bn

# All languages
localizekit diff --all
```

**Options:**
- `--language`: Language code(s) to compare (repeatable)
- `--all`: Compare all languages with base
- `--project-path`: Root directory (default: current directory)
- `--verbose`: Show detailed values

**Output Format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Diff: ar.json ↔ base.json
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
  🆕 New keys:      3
  🔄 Modified:      2
  ❌ Removed:       1
  ✅ Up-to-date:    42

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🆕 NEW KEYS (not in ar.json):

  Module: Store
    • store_checkout_title
      Base v2: "Checkout"

🔄 MODIFIED (base changed, needs re-translation):

  Module: Store
    • store_welcome
      Base v3: "Welcome, **%@**!"
      ar v2:   "!**%@** ،مرحباً" ⚠️ OUTDATED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Recommendation:
   Run: merge --language ar
   This will add 3 new keys and update 2 modified keys.
```

#### Lint Call Sites

Statically analyse every `.localize(...)` / `Text.localized(...)` call site and verify that the format specifiers in the default value (or each plural form) match the number and type of `with:` arguments supplied. Catches `String(format:)` crashes (e.g. `%d` given a `String`) before they reach runtime. Designed to run from a terminal or as an Xcode build phase.

```bash
# Pretty terminal report
localizekit lint --project-path .

# Xcode-parsable output (auto-selected inside a build phase)
localizekit lint --reporter xcode --project-path .

# Treat warnings as errors (CI gate)
localizekit lint --strict --project-path .
```

**Options:**
- `--project-path`: Root directory of the project (default: current directory)
- `--reporter`: `pretty`, `xcode`, or `auto` (default — Xcode is auto-detected via build-phase environment variables)
- `--strict`: Treat warnings as errors and exit non-zero on any issue
- `--warn-unverified` / `--no-warn-unverified`: Warn for every call site whose argument type could not be resolved (custom type/typealias, complex expression, or stale index) so it can be checked by hand (default: on)
- `--index-store-path`: Override Xcode's index store path (default: auto-discovered from `~/Library/Developer/Xcode/DerivedData`)
- `--verbose`: Enable verbose extraction output

**Requires an up-to-date Xcode index.** Literal arguments (`with: 42`, `with: "x"`) are classified directly from SwiftSyntax; every other argument's type is resolved authoritatively from Xcode's IndexStoreDB — the same symbol index the compiler produces. Open the project in Xcode and build (⌘B) before linting. If the index is missing, lint fails loudly with a remediation message; files newer than the indexed unit are skipped (reported as "stale index") and only their literal arguments are checked until you rebuild.

**Rules:**

| Rule ID | Severity | Triggered when |
|---------|----------|----------------|
| `empty_key` | error | The localization key is an empty string. |
| `format_arg_count_mismatch` | error | Format specifier count ≠ `with:` argument count (non-positional formats), or a positional `%N$` references a slot beyond the supplied count. |
| `format_missing_args` | error | Default contains specifiers but no `with:` was supplied. |
| `format_unused_args` | error | Default has no specifiers but `with:` arguments were supplied. |
| `format_arg_type_mismatch` | error / warning | Argument's resolved type is incompatible with its specifier. Demoted to warning for non-fatal mismatches (e.g. `Bool` for `%d`). |
| `format_arg_type_unverified` | warning | Argument type could not be resolved; emitted only when `--warn-unverified` is on (default). |
| `unescaped_percent` | error | Default contains an unescaped `%X` (non-specifier letter) **and** `with:` args are passed through `String(format:)`. Suggests `%%X` as the fix. Decorative `%` (e.g. `"%Compliance"`) with no `with:` args is allowed silently. |
| `plural_empty` | error | `defaultPlural` dictionary is empty. |
| `plural_missing_other` | error | `defaultPlural` is missing the CLDR-required `.other` form. |
| `plural_form_inconsistent` | warning | Plural forms have differing specifier counts. Often legitimate, but surfaced for translators. |
| `plural_count_type` | error | `count:` argument cannot resolve to an integer type. |

**Type compatibility:**

| Specifier | Accepts |
|-----------|---------|
| `%@` | `String` (auto-bridges to `NSString`) and `NSObject` subclasses. **Not** Swift `Int` / `Double` / `Bool` — those don't bridge through `CVarArg`; use `%d` / `%lld` / `%f`, or wrap with `String(value)`. |
| `%d` `%i` `%ld` `%lld` `%u` `%x` `%X` `%o` | `Int` / `UInt` only |
| `%f` `%.2f` `%g` `%e` | `Double` / `Float` / `Int` (auto-promoted) |
| `%s` | `String` only (rare in Swift — usually a mistake) |
| `%c` | Integer code point |

Arguments that neither the literal nor the semantic resolver can classify resolve to `unknown`; the linter stays silent for that slot (unless `--warn-unverified` is on) rather than emitting a false positive.

**Pretty reporter output:**
```
🔎 Linting localization call sites...

Project:  /path/to/project
Reporter: pretty
Strict:   no

📦 Scanned 68 localized call site(s)

📄 Targets/Store/Sources/UI/Cart/CartScreen.swift
   ❌ 42:18  [format_arg_type_mismatch] Argument 'userName' is String, but format specifier '%d' for key 'cart_score' expects Int.
   ⚠️  56:9   [plural_form_inconsistent] Plural form '.one' for 'cart_items' has 0 format specifier(s); '.other' has 1.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Call sites: 68
Errors:     1
Warnings:   1

❌ Lint failed.
```

**Xcode reporter output:**
```
/path/to/file.swift:42:18: error: [LocalizeKit:format_arg_type_mismatch] Argument 'userName' is String, but format specifier '%d' for key 'cart_score' expects Int.
```
Xcode parses these lines into the issue navigator on the correct file and line.

**Exit codes:** `0` when no errors are found (warnings are allowed), `1` when any error is reported or any issue exists under `--strict`.

**Run as an Xcode build phase** (Target → Build Phases → "+" → New Run Script Phase):
```bash
# Run only on debug builds to keep release builds fast.
if [ "${CONFIGURATION}" = "Debug" ]; then
    "${SRCROOT}/Tools/LocalizeKit/.build/release/LocalizeKit" lint --project-path "${SRCROOT}"
fi
```
With the default `auto` reporter, the tool detects the Xcode environment and emits `file:line:col:` diagnostics into the issue navigator. See the [LocalizeKit CLI Guide](../../docs/LocalizeKit/LocalizeKitCLI.md#lint-command) for full build-phase setup and the type-resolution details.

## Project Structure

The CLI expects this structure:

```
YourProject/
├── Targets/
│   ├── Module1/
│   │   └── Sources/
│   │       └── *.swift
│   ├── Module2/
│   │   └── Sources/
│   │       └── *.swift
│   └── ...
└── Translations/
    ├── base.json     # Base language (English) with metadata
    ├── ar.json       # Arabic (simplified)
    ├── bn.json       # Bengali (simplified)
    └── es.json       # Spanish (simplified)
```

## String Extraction

The tool automatically detects and extracts localization strings from Swift code. It supports **two patterns**:

### Pattern 1: String Extension (`.localize()`)

```swift
// Simple strings
"store_welcome".localize(
    default: "Welcome!",
    comment: "Welcome message"
)

// With interpolation
"store_greeting".localize(
    default: "Hello, %@!",
    comment: "Greeting with name",
    with: userName
)

// With plurals
"store_cart_items".localize(
    defaultPlural: [
        .zero: "No items",
        .one: "1 item",
        .other: "%d items"
    ],
    comment: "Cart items count",
    count: cartCount
)
```

### Pattern 2: Text Static Method (`Text.localized()`)

```swift
// Simple strings
Text.localized(
    "store_welcome",
    default: "Welcome!",
    comment: "Welcome message"
)

// With interpolation
Text.localized(
    "store_greeting",
    default: "Welcome, **%@**!",
    comment: "Welcome message with user name",
    with: user.name
)

// With plurals
Text.localized(
    "store_cart_items",
    defaultPlural: [
        .zero: "No items",
        .one: "1 item",
        .other: "%d items"
    ],
    comment: "Cart items count",
    count: cartCount
)
```

**Note:** Both patterns are automatically detected during extraction.

## Workflow Examples

### Initial Setup

```bash
# 1. Extract strings to create base.json
localizekit extract

# 2. Create target languages
localizekit merge --language ar --language bn

# 3. Translate the JSON files manually
# Edit ar.json and bn.json

# 4. Validate
localizekit validate --all
```

### After Adding New Features

```bash
# 1. Extract again (version auto-increments)
localizekit extract

# 2. Preview what changed
localizekit diff --all

# 3. Sync all languages (adds new keys, marks modified ones)
localizekit merge --all

# 4. Translate new/modified strings in target files

# 5. Validate
localizekit validate --all
```

## Translation File Format

### Base File (base.json)

Contains metadata and per-key versioning:

```json
{
  "version": 2,
  "language": "en",
  "generatedAt": "2025-11-28T10:30:00Z",
  "modules": {
    "Store": {
      "store_welcome": {
        "value": "Welcome!",
        "type": "simple",
        "comment": "Welcome message",
        "version": 1,
        "metadata": {
          "addedInVersion": 1,
          "status": "unchanged"
        }
      },
      "store_items": {
        "value": {
          "zero": "No items",
          "one": "1 item",
          "other": "%d items"
        },
        "type": "plural",
        "comment": "Items count",
        "version": 2,
        "metadata": {
          "addedInVersion": 1,
          "lastModifiedVersion": 2,
          "status": "modified"
        }
      }
    }
  }
}
```

### Target File (ar.json, bn.json, etc.)

Simplified format without metadata:

```json
{
  "version": 2,
  "language": "ar",
  "generatedAt": "2025-11-28T10:31:00Z",
  "modules": {
    "Store": {
      "store_welcome": {
        "value": "!مرحباً",
        "type": "simple"
      },
      "store_items": {
        "value": {
          "zero": "لا توجد عناصر",
          "one": "عنصر واحد",
          "two": "عنصران",
          "few": "%d عناصر",
          "many": "%d عنصرًا",
          "other": "%d عنصر"
        },
        "type": "plural"
      }
    }
  }
}
```

### Value Types

1. **Simple**: Plain string
   ```json
   "value": "Hello, World!"
   ```

2. **Plural**: Dictionary of plural forms
   ```json
   "value": {
     "zero": "No items",
     "one": "1 item",
     "other": "%d items"
   }
   ```

### Translation Types

- `simple`: Plain text with no variables
- `interpolation`: Text with format specifiers (%@, %d, etc.)
- `plural`: Text with plural forms

### Translation Status (base.json only)

- `new`: Newly added key
- `modified`: Key value changed
- `unchanged`: Key hasn't changed

## Version Management

### How Versioning Works

1. **File Version**: Integer incremented on each extract
2. **Key Version**: Tracks when each key was last modified
3. **Version Comparison**: `base_key.version > target_file.version`

### Example Scenario

```
base.json v3:
  store_welcome: version 2 (modified in v2)
  store_checkout: version 3 (new in v3)

ar.json v2:
  store_welcome: "مرحباً" (translated at v2)

After merge --language ar:
  - store_welcome: KEPT (v2 ≤ v2, translation is up-to-date)
  - store_checkout: ADDED (new key, uses English)
  - ar.json version updated to 3
```

## Tips

1. **Always use base.json**: Never manually edit `base.json`, always use `extract` command
2. **Version Control**: Commit all JSON files to git
3. **Comments**: Add meaningful comments for translators
4. **Format Specifiers**: Ensure %@, %d match between languages
5. **Plural Forms**: Provide all required forms for each language (CLDR rules)
6. **Validation**: Run `validate --all` before committing
7. **Diff Preview**: Use `diff` to see what needs translation
8. **Batch Operations**: Use `--all` flag for multi-language operations

## Troubleshooting

### No strings found

**Problem:** CLI reports no localization strings found.

**Solutions:**
- Use `.localize()` or `Text.localized()` patterns
- Check `--project-path` points to project root
- Ensure `Targets/*/Sources/` structure exists
- Run with `--verbose` to see processed files

### Format validation errors

**Problem:** Format specifier validation fails.

**Solutions:**
- Match specifiers between languages: `%@` for strings, `%d` for integers
- Check specifier count and order
- Note: Markdown `**text**` is NOT a format specifier

### Plural validation errors

**Problem:** Plural form validation fails.

**Solutions:**
- Different languages need different forms (CLDR rules):
  - **English, Bengali**: one, other
  - **Arabic**: zero, one, two, few, many, other
- Provide all required forms for target language

### Build errors

**Problem:** `swift build` fails with sandbox errors.

**Solution:** Use `--disable-sandbox` flag:
```bash
swift build -c release --disable-sandbox
```

### Lint cannot find the Xcode index

**Problem:** `lint` reports it could not locate Xcode's index store.

**Solutions:**
- Open the project in Xcode and run a build (⌘B) so the index store is generated.
- Override the path explicitly with `--index-store-path /path/to/DerivedData/<id>/Index.noindex/DataStore`.
- Ensure `xcode-select -p` points at a valid Xcode toolchain (so `libIndexStore.dylib` is discoverable).

### Lint reports "stale index" warnings

**Problem:** Files changed since the last Xcode build are only literal-checked.

**Solution:** Rebuild the project in Xcode (⌘B) to refresh the index, then re-run `lint`. Non-literal arguments in those files stay unchecked until the index catches up.

## Testing

LocalizeKit includes a comprehensive unit test suite using Swift's XCTest framework.

### Run Tests

```bash
# From LocalizeKit directory
cd Tools/LocalizeKit
swift test --disable-sandbox

# Or from anywhere
swift test --package-path Tools/LocalizeKit --disable-sandbox
```

### Test Coverage

The test suite covers:
- Translation model encoding/decoding (simple, interpolation, plural)
- Base and target translation file structures
- JSON serialization and deserialization
- Format specifier preservation
- Plural forms with all CLDR categories
- Translation status and type validation
- Performance benchmarks

### CI/CD Integration

The Swift tests can easily be integrated into CI/CD pipelines:

```bash
# GitHub Actions example
- name: Run LocalizeKit Tests
  run: |
    cd Tools/LocalizeKit
    swift test --disable-sandbox
```

## License

Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
