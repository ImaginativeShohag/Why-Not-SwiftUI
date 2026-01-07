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
   • store_welcome: Untranslated (same as English)
   • store_greeting: Untranslated (same as English)
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
    • store_checkout_button
    • store_cart_empty
    • store_order_placed

🔄 MODIFIED (base changed since translation):
  Module: Store
    • store_welcome (v1 → v2)
```

**Use Cases:**
- Identify what needs translation after code changes
- Generate reports for translators
- Track version drift between base and targets

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
│  5. Exit                                        │
│                                                 │
╰─────────────────────────────────────────────────╯

Enter your choice (1-5):
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
      "store_welcome": {
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
      "store_item_count": {
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
      "store_welcome": {
        "value": "স্বাগতম, %@!",
        "type": "interpolation",
        "comment": "Welcome message with user's full name"
      },
      "store_item_count": {
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
"store_welcome"
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
"store_cart_empty".localize(
    default: "Your cart is empty",
    comment: "Shown on cart screen when no items added"
)

// Bad - vague or missing
"store_cart_empty".localize(
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
