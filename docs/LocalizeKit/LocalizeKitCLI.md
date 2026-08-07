# LocalizeKit CLI Usage Guide

A comprehensive guide to using the LocalizeKit command-line tool for managing localization strings in Swift projects.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Commands Reference](#commands-reference)
  - [Extract](#extract-command)
  - [Merge](#merge-command)
  - [Validate](#validate-command)
  - [Diff](#diff-command)
  - [Lint](#lint-command)
  - [Interactive Menu](#interactive-menu)
- [Translation File Format](#translation-file-format)
- [Workflow Guide](#workflow-guide)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## Overview

LocalizeKit CLI is a Swift-based command-line tool that automates the extraction, management, and validation of localization strings from Swift source files. It works with the LocalizeKit runtime library to provide a complete localization solution.

### Key Features

| Feature | Description |
|---------|-------------|
| **String Extraction** | Automatically extract `.localize()` calls from Swift files |
| **Version Management** | Auto-increment versions and track per-key changes |
| **Multi-Language Support** | Manage unlimited target languages from a single base file |
| **Validation** | Check for missing translations, format mismatches, and plural issues |
| **Code Lint** | Static check of `.localize` / `Text.localized` call sites for arg-count and arg-type mismatches (runs as Xcode build phase) |
| **Diff Reports** | Generate change reports for translators |
| **Interactive Mode** | Guided menu for all operations |

---

## Requirements

| Requirement | Version |
|-------------|---------|
| macOS | 14.0+ |
| Swift | 5.9+ |
| Xcode | 15.0+ (for Swift toolchain) |

---

## Installation

### Option 1: Run Directly (Recommended)

Use `swift run` to execute without building separately:

```bash
cd path/to/LocalizeKit
swift run LocalizeKit <command> [options]
```

**Example:**
```bash
swift run LocalizeKit extract --project-path /path/to/your/project
```

### Option 2: Build Release Binary

```bash
cd path/to/LocalizeKit
swift build -c release
```

The binary is located at:
```
.build/release/LocalizeKit
```

### Option 3: Create Shell Alias

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
alias localizekit="swift run --package-path /path/to/LocalizeKit LocalizeKit"
```

Then use:
```bash
localizekit extract --project-path .
```

---

## Quick Start

### 1. Initial Setup

Navigate to your Swift project:

```bash
cd /path/to/your/project
```

### 2. Extract Strings

Extract all `.localize()` calls to `Translations/base.json`:

```bash
swift run LocalizeKit extract --project-path .
```

### 3. Create Target Languages

Generate translation files for target languages:

```bash
# Single language
swift run LocalizeKit merge --language bn

# Multiple languages
swift run LocalizeKit merge --language ar --language es --language fr

# All existing language files
swift run LocalizeKit merge --all
```

### 4. Translate

Edit the generated JSON files (`Translations/bn.json`, `Translations/ar.json`, etc.) and translate the `value` fields.

### 5. Validate

Check translations for issues:

```bash
swift run LocalizeKit validate --all
```

---

## Commands Reference

### Extract Command

Extracts localization strings from Swift source files and creates/updates `base.json`.

**Syntax:**
```bash
swift run LocalizeKit extract [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `--project-path <path>` | Root directory of the project | Current directory |
| `--ignore-comment-changes` | Skip prompts for comment-only changes | `false` |
| `--verbose` | Enable detailed output | `false` |

**Examples:**

```bash
# Basic extraction
swift run LocalizeKit extract --project-path .

# Skip comment change prompts
swift run LocalizeKit extract --ignore-comment-changes

# Verbose output
swift run LocalizeKit extract --verbose
```

**Output:**
```
📊 Changes Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🆕 New keys:      5
🔄 Modified:      2
❌ Removed:       1
💬 Comments:      3

✅ Saved to: Translations/base.json (version 2)
```

**Behavior:**
- Creates `Translations/` directory if it doesn't exist
- Auto-increments version number (1 → 2 → 3...)
- Tracks which keys were added, modified, or removed
- Preserves metadata for existing keys

---

### Merge Command

Synchronizes target language files with `base.json`.

**Syntax:**
```bash
swift run LocalizeKit merge [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `--language <code>` | Target language code (repeatable) | - |
| `--all` | Merge all existing language files | `false` |
| `--project-path <path>` | Root directory | Current directory |
| `--verbose` | Enable detailed output | `false` |

**Examples:**

```bash
# Single language
swift run LocalizeKit merge --language bn

# Multiple languages
swift run LocalizeKit merge --language ar --language bn --language es

# All existing languages
swift run LocalizeKit merge --all

# With verbose output
swift run LocalizeKit merge --language bn --verbose
```

**Output:**
```
🌐 Language: bn
📊 Changes:
   🆕 Added:   3
   🔄 Updated: 1
   ❌ Removed: 0
   ✅ Kept:    10

✅ Saved: Translations/bn.json
```

**Behavior:**
- **New language:** Creates file from `base.json` with English values as placeholders
- **Existing language:** Syncs structure, preserves existing translations
- Updates version to match `base.json`

---

### Validate Command

Validates translation files for issues.

**Syntax:**
```bash
swift run LocalizeKit validate [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `--language <code>` | Language code(s) to validate (repeatable) | - |
| `--all` | Validate all language files | `false` |
| `--project-path <path>` | Root directory | Current directory |
| `--check-missing` | Check for missing translations | `true` |
| `--check-format` | Check format specifier mismatches | `true` |
| `--check-plurals` | Check plural form completeness | `true` |
| `--verbose` | Enable detailed output | `false` |

**Examples:**

```bash
# Single language
swift run LocalizeKit validate --language bn

# All languages
swift run LocalizeKit validate --all

# Specific checks only
swift run LocalizeKit validate --language ar --check-plurals --check-format
```

**Output:**
```
🔍 Validating: bn.json

📊 Statistics:
   File version:    3 (base: 3) ✅
   Total keys:      15
   Missing:         0 ✅
   Extra:           0 ✅
   Untranslated:    2 ⚠️
   Format issues:   0 ✅

⚠️  Issues Found:
   • welcome: Untranslated (same as English)
   • greeting: Untranslated (same as English)
```

**Validation Checks:**

| Check | Description |
|-------|-------------|
| Missing keys | Keys in `base.json` but not in target |
| Extra keys | Keys in target but not in `base.json` |
| Untranslated | Values identical to English (likely not translated) |
| Format specifiers | Mismatch in `%@`, `%d`, `%f` between base and target |
| Plural forms | Missing required plural categories |

---

### Diff Command

Shows translation differences between target languages and `base.json`.

**Syntax:**
```bash
swift run LocalizeKit diff [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `--language <code>` | Language code(s) to compare (repeatable) | - |
| `--all` | Compare all languages with base | `false` |
| `--project-path <path>` | Root directory | Current directory |
| `--verbose` | Show full values for each key | `false` |

**Examples:**

```bash
# Single language diff
swift run LocalizeKit diff --language bn

# All languages
swift run LocalizeKit diff --all

# Detailed output
swift run LocalizeKit diff --language ar --verbose
```

**Output:**
```
📋 Diff Report: bn.json vs base.json

Summary:
  🆕 New keys:      3
  🔄 Modified:      1
  ❌ Removed:       0
  ✅ Up-to-date:    11

⚠️  Target file version (2) is behind base version (3)

🆕 NEW KEYS (not in bn.json):
  Module: Store
    • checkout_button
    • cart_empty
    • order_placed

🔄 MODIFIED (base changed since translation):
  Module: Store
    • welcome (v1 → v2)
```

**Use Cases:**
- Identify what needs translation after code changes
- Generate reports for translators
- Track version drift between base and targets

---

### Lint Command

Statically analyses every `.localize(...)` and `Text.localized(...)` call site in the project and validates that the format specifiers in the default value match the number and type of `with:` arguments supplied.

The linter parses Swift files directly with SwiftSyntax to find call sites and classify *literal* arguments, and resolves the type of every other argument against Xcode's IndexStoreDB — the same symbol index Xcode's compiler produces. It therefore requires a recent Xcode build of the project (open in Xcode and build with ⌘B); when the index is missing or unreadable, lint fails loudly with a remediation message.

**Syntax:**
```bash
swift run LocalizeKit lint [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `--project-path <path>` | Root directory of the project | Current directory |
| `--reporter <style>` | `pretty`, `xcode`, or `auto` (Xcode auto-detected via `XCODE_PRODUCT_BUILD_VERSION` env var) | `auto` |
| `--strict` | Treat warnings as errors and exit non-zero on any issue | `false` |
| `--verbose` | Verbose extraction output | `false` |
| `--index-store-path <path>` | Override the Xcode index store path. Defaults to auto-discovery from `~/Library/Developer/Xcode/DerivedData`. | auto |

**Examples:**

```bash
# Run lint with the pretty reporter from a terminal
swift run LocalizeKit lint --project-path .

# Force the Xcode-parsable reporter
swift run LocalizeKit lint --reporter xcode --project-path .

# Treat warnings as errors (CI mode)
swift run LocalizeKit lint --strict --project-path .
```

**Pretty Reporter Output:**
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

**Xcode Reporter Output:**
```
/path/to/file.swift:42:18: error: [LocalizeKit:format_arg_type_mismatch] Argument 'userName' is String, but format specifier '%d' for key 'cart_score' expects Int.
/path/to/file.swift:56:9: warning: [LocalizeKit:plural_form_inconsistent] …
```

Xcode parses these lines automatically and surfaces them in the issue navigator on the correct file/line.

**Rules:**

| Rule ID | Severity | Triggered when |
|---------|----------|----------------|
| `empty_key` | error | The localization key is an empty string. |
| `format_arg_count_mismatch` | error | Number of format specifiers in default ≠ number of `with:` arguments (non-positional formats only). |
| `format_missing_args` | error | Default contains specifiers but no `with:` was supplied. |
| `format_unused_args` | error | Default has no specifiers but `with:` arguments were supplied. |
| `format_arg_type_mismatch` | error / warning | Argument's resolved type is incompatible with the format specifier. Demoted to warning when the mismatch is non-fatal (e.g., `Bool` for `%d`). |
| `unescaped_percent` | error | Default contains an unescaped `%X` (non-specifier letter) AND the call passes `with:` arguments through `String(format:)`. Suggests `%%X` as the fix. Without `with:` args, decorative `%` like `"%Compliance"` is allowed silently because the default is returned verbatim. |
| `plural_empty` | error | `defaultPlural` dictionary is empty. |
| `plural_missing_other` | error | `defaultPlural` is missing the `.other` form (CLDR requires it). |
| `plural_form_inconsistent` | warning | Plural forms have differing specifier counts. Often legitimate (e.g., `.one: "1 item"` with no `%d`), but worth surfacing for translators. |
| `plural_count_type` | error | `count:` argument cannot resolve to an integer type. |

**Type Compatibility Matrix:**

| Specifier | Accepts |
|-----------|---------|
| `%@` | `String` (auto-bridges to `NSString`) and types conforming to `NSObject`. Does **not** accept Swift `Int` / `Double` / `Bool` — those don't auto-bridge through `CVarArg` and produce garbage or crashes at runtime. Use `%d` / `%lld` / `%f` instead, or wrap the value with `String(value)`. |
| `%d` / `%i` / `%ld` / `%lld` | Int / UInt only (Bool / Double → warning or error) |
| `%u` / `%x` / `%X` / `%o` | Int / UInt only |
| `%f` / `%.2f` / `%g` / `%e` | Double / Float / Int (auto-promoted) |
| `%s` | String only (rare in Swift — almost always a mistake) |

When a `with:` argument cannot be type-resolved (e.g., a method call returning a generic type, or a method defined in an external module), the linter remains silent for that slot rather than emitting a false-positive.

**Type resolution:** argument types come from two complementary sources:

* **Literal classification** (SwiftSyntax) — literal arguments are typed directly from the AST: `"x"` → String, `42` → Int, `3.14` → Double, `true` → Bool, `nil` → nil, array/dictionary literals → object (parentheses and a leading unary sign are peeled first). The IndexStoreDB only records *symbol references*, so it cannot see literals — this fills that gap.
* **Semantic resolution** (Xcode's IndexStoreDB) — for every non-literal `with:` / `count:` argument, the linter reads Xcode's index at `~/Library/Developer/Xcode/DerivedData/<project>/Index.noindex/DataStore`. Each argument's source position is queried; the matched symbol's USR is demangled via `xcrun swift-demangle` to recover its full signature (e.g. `Core.ItemInfo.getItemQty() -> Swift.Int`); the return / value type is extracted and mapped to `ResolvedType`. This is the **authoritative** answer because the data was produced by Swift's actual type checker. Files whose source is newer than the indexed unit are detected and skipped (and listed under "stale index" warnings) — only their literal arguments are checked until you rebuild in Xcode. When the index is missing entirely, lint fails loudly with a clear remediation message.

Arguments that neither source can classify resolve to `.unknown`, and the linter stays silent for that slot rather than emitting a false positive.

**Use Cases:**
- Catch `String(format:)` crashes before they reach production (e.g., `%d` with a `String`).
- Verify that translated plural forms have consistent interpolation shapes.
- Block CI on lint errors via `--strict`.
- Run as an Xcode build phase for inline IDE feedback.

#### Adding the Lint to an Xcode Build Phase

In your project, select the target → Build Phases → "+" → New Run Script Phase, then paste:

```bash
# Run only on debug builds to keep release fast.
if [ "${CONFIGURATION}" = "Debug" ]; then
    cd "${SRCROOT}/Tools/LocalizeKit"
    swift run --package-path . LocalizeKit lint --project-path "${SRCROOT}"
fi
```

Place the phase **before** "Compile Sources" so issues surface before build failures, or after to gate the build only when localization is broken.

The `--reporter auto` default sees the Xcode environment variables and emits the `file:line:col: severity: message` format Xcode parses into the issue navigator.

For faster CI/build-phase runs, build a release binary once and check it in:

```bash
cd Tools/LocalizeKit
swift build -c release
```

Then use the prebuilt binary in the build phase:

```bash
"${SRCROOT}/Tools/LocalizeKit/.build/release/LocalizeKit" lint --project-path "${SRCROOT}"
```

---

### Interactive Menu

Launch an interactive guided menu for all operations.

**Syntax:**
```bash
swift run LocalizeKit
# or
swift run LocalizeKit menu
```

**Menu Options:**
```
╭─────────────────────────────────────────────────╮
│           LocalizeKit CLI v1.0.0                │
├─────────────────────────────────────────────────┤
│                                                 │
│  1. Extract strings from project                │
│  2. Merge translations                          │
│  3. Validate translations                       │
│  4. Preview diff                                │
│  5. Lint .localize call sites                   │
│  6. Exit                                        │
│                                                 │
╰─────────────────────────────────────────────────╯

Enter your choice (1-6):
```

Each option guides you through the operation with prompts for required inputs.

---

## Translation File Format

### Base File (base.json)

The source file containing English strings and metadata:

```json
{
  "version": 3,
  "language": "en",
  "generatedAt": "2025-01-07T10:30:00Z",
  "modules": {
    "Store": {
      "welcome": {
        "value": "Welcome, %@!",
        "type": "interpolation",
        "version": 2,
        "comment": "Welcome message with user's full name",
        "metadata": {
          "addedInVersion": "1",
          "lastModifiedVersion": "2",
          "status": "modified"
        }
      },
      "item_count": {
        "value": {
          "zero": "No items",
          "one": "1 item",
          "other": "%d items"
        },
        "type": "plural",
        "version": 1,
        "comment": "Item count in shopping cart"
      }
    }
  }
}
```

### Target Files (bn.json, ar.json, etc.)

Simplified format for translators:

```json
{
  "version": 3,
  "modules": {
    "Store": {
      "welcome": {
        "value": "স্বাগতম, %@!",
        "type": "interpolation",
        "comment": "Welcome message with user's full name"
      },
      "item_count": {
        "value": {
          "zero": "কোন আইটেম নেই",
          "one": "১টি আইটেম",
          "other": "%dটি আইটেম"
        },
        "type": "plural",
        "comment": "Item count in shopping cart"
      }
    }
  }
}
```

### Translation Types

| Type | Description | Value Format |
|------|-------------|--------------|
| `simple` | Plain text | `"value": "Hello"` |
| `interpolation` | Contains format specifiers | `"value": "Hello, %@!"` |
| `plural` | Count-dependent text | `"value": { "one": "...", "other": "..." }` |

### Plural Categories

| Category | Description | Example Languages |
|----------|-------------|-------------------|
| `zero` | Zero items | Arabic, Latvian |
| `one` | Singular | English, German, Spanish |
| `two` | Dual | Arabic, Welsh |
| `few` | Few items (3-10) | Russian, Polish, Arabic |
| `many` | Many items (11+) | Russian, Polish, Arabic |
| `other` | Default/catch-all | All languages (required) |

---

## Workflow Guide

### Initial Localization Setup

```bash
# 1. Extract strings from code
swift run LocalizeKit extract --project-path .

# 2. Create target language files
swift run LocalizeKit merge --language bn --language ar

# 3. Translate the values in bn.json and ar.json

# 4. Validate translations
swift run LocalizeKit validate --all
```

### Adding New Strings

After adding new `.localize()` calls to your code:

```bash
# 1. Extract new strings (auto-increments version)
swift run LocalizeKit extract --project-path .

# 2. Sync target languages with new keys
swift run LocalizeKit merge --all

# 3. Check what needs translation
swift run LocalizeKit diff --all

# 4. Translate new keys in target files

# 5. Validate
swift run LocalizeKit validate --all
```

### Updating Existing Strings

When English text changes:

```bash
# 1. Extract (detects modifications)
swift run LocalizeKit extract --project-path .

# 2. Sync targets (marks modified keys)
swift run LocalizeKit merge --all

# 3. Check modified keys
swift run LocalizeKit diff --all --verbose

# 4. Update translations

# 5. Validate
swift run LocalizeKit validate --all
```

### Managing Translations for Translators

Generate a report for translators:

```bash
# Show what needs translation
swift run LocalizeKit diff --language bn --verbose > translation_needed_bn.txt

# Validate before sending to translator
swift run LocalizeKit validate --language bn
```

---

## Best Practices

### Key Naming

Use consistent, descriptive keys with module prefixes:

```swift
// Good
"welcome"
"store_add_to_cart"
"checkout_payment_method"
"profile_edit_name"

// Bad
"welcome"
"btn1"
"text"
"string123"
```

### Comments

Provide context for translators:

```swift
// Good - specific context
"cart_empty".localize(
    default: "Your cart is empty",
    comment: "Shown on cart screen when no items added"
)

// Bad - vague or missing
"cart_empty".localize(
    default: "Your cart is empty"
)
```

### Format Specifiers

Ensure consistency across translations:

| Specifier | Type | Example |
|-----------|------|---------|
| `%@` | String | `"Hello, %@!"` → `"Hello, John!"` |
| `%d` | Integer | `"Count: %d"` → `"Count: 5"` |
| `%f` | Float | `"Price: %f"` → `"Price: 19.99"` |
| `%.2f` | Float (2 decimals) | `"$%.2f"` → `"$19.99"` |
| `%%` | Literal % | `"Save %d%%"` → `"Save 20%"` |

### Plural Forms

Always include `.other` and language-specific forms:

```json
// English (minimum)
"value": {
  "one": "1 item",
  "other": "%d items"
}

// Arabic (comprehensive)
"value": {
  "zero": "لا عناصر",
  "one": "عنصر واحد",
  "two": "عنصران",
  "few": "%d عناصر",
  "many": "%d عنصرًا",
  "other": "%d عنصر"
}
```

### Version Control

- Commit `Translations/` directory to git

---

## Troubleshooting

### CLI Not Found

```bash
# Verify Swift is installed
swift --version

# Build and verify binary exists
cd path/to/LocalizeKit
swift build -c release
ls .build/release/LocalizeKit
```

### No Strings Extracted

**Possible causes:**
- Source files don't use `.localize()` extension
- Project path is incorrect
- Files are excluded from search

**Solutions:**
```bash
# Verify project path
swift run LocalizeKit extract --project-path . --verbose

# Check for .localize() calls in your code
grep -r "\.localize(" --include="*.swift" .
```

### Format Specifier Errors

**Symptom:** Validation shows format mismatches

**Solution:** Ensure translated strings have identical specifiers:

```
English:  "You have %d items in %@"
Bengali:  "আপনার %@ এ %d টি আইটেম আছে"  ✅ (same specifiers, order can differ)
Bengali:  "আপনার আইটেম আছে"              ❌ (missing specifiers)
```

### Missing Plural Forms

**Symptom:** Validation warns about plural categories

**Solution:** Add all required categories for the language. Check [CLDR Plural Rules](https://cldr.unicode.org/index/cldr-spec/plural-rules) for language-specific requirements.

### Version Mismatch

**Symptom:** Diff shows version behind

**Solution:**
```bash
# Sync target with base
swift run LocalizeKit merge --language bn
```

---

## API Reference for AI Agents

### Command Patterns

```bash
# Extract
swift run LocalizeKit extract --project-path <path> [--ignore-comment-changes] [--verbose]

# Merge
swift run LocalizeKit merge --language <code> [--language <code>...] [--all] [--project-path <path>]

# Validate
swift run LocalizeKit validate --language <code> [--all] [--check-missing] [--check-format] [--check-plurals]

# Diff
swift run LocalizeKit diff --language <code> [--all] [--verbose]

# Lint
swift run LocalizeKit lint [--reporter pretty|xcode|auto] [--strict] [--project-path <path>] [--verbose]

# Interactive
swift run LocalizeKit menu
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Validation errors found |
| 2 | File not found |
| 3 | Parse error |
| 4 | Invalid arguments |

### File Paths

| File | Path |
|------|------|
| Base translations | `<project>/Translations/base.json` |
| Target translations | `<project>/Translations/<language>.json` |
| Archive | `<project>/Translations/archive/` |

---

## Related Documentation

- [LocalizeKit Runtime Usage Guide](LocalizeKitRuntime.md) - Using LocalizeKit in Swift code
- [CLDR Plural Rules](https://cldr.unicode.org/index/cldr-spec/plural-rules) - Language-specific plural categories

---

*LocalizeKit CLI v1.0.0*

---

**Last Updated:** January 14, 2026
