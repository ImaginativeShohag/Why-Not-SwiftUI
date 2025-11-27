# LocalizeKit CLI

A powerful command-line tool for managing translations in SwiftUI projects with runtime localization support.

## Features

- **Extract** strings from Swift source files using SwiftSyntax
- **Merge** new extracted strings with existing translations
- **Validate** translation files for completeness and correctness
- **Generate Diff** between translation versions
- **Interactive Menu** for easy access to all commands
- Supports both `String.localize()` and `Text.localized()` patterns

## Installation

### Build from Source

```bash
cd Tools/LocalizeKit
swift build -c release --disable-sandbox
```

The executable will be located at `.build/release/LocalizeKit`.

### Optional: Install to PATH

You can copy it to a location in your PATH for easier access:

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

## Usage

### Interactive Menu (Default)

Simply run the tool without arguments to access the interactive menu:

```bash
localizekit
# or
localizekit menu
```

### Command Line Interface

#### Extract Strings

Extract localization strings from your project's Swift files:

```bash
localizekit extract \
  --project-path /path/to/project \
  --output-path ./Translations \
  --language en \
  --version 1.0.0
```

**Options:**
- `--project-path`: Root directory of the project (default: current directory)
- `--output-path`: Output directory for generated JSON files (default: ./Translations)
- `--language`: Language code for the extracted strings (default: en)
- `--version`: Version string for the translation file (required)
- `--verbose`: Enable verbose output

**Example Output:**

```json
{
  "version": "1.0.0",
  "language": "en",
  "generatedAt": "2025-11-27T10:30:00Z",
  "modules": {
    "Store": {
      "store_welcome": {
        "value": "Welcome, **%@**!",
        "type": "interpolation",
        "comment": "Welcome message with user's full name",
        "metadata": {
          "addedInVersion": "1.0.0",
          "status": "new",
          "translationStatus": "untranslated"
        }
      }
    }
  }
}
```

#### Merge Translations

Merge newly extracted strings with existing translations:

```bash
localizekit merge \
  --new-file ./Translations/en-new.json \
  --existing-file ./Translations/bn.json \
  --output-path ./Translations/bn-merged.json \
  --keep-removed
```

**Options:**
- `--new-file`: Path to the new extracted translation file
- `--existing-file`: Path to the existing translation file
- `--output-path`: Output path for the merged translation file
- `--keep-removed`: Keep strings that were removed from source code (optional)
- `--verbose`: Enable verbose output

**Merge Behavior:**
- **New keys**: Added with `status: new` and `translationStatus: untranslated`
- **Modified keys**: Keeps existing translation but marks as `needsReview`
- **Unchanged keys**: Preserved as-is
- **Removed keys**: Either kept with `status: removed` or discarded (based on `--keep-removed`)

#### Validate Translations

Validate translation files for errors and completeness:

```bash
localizekit validate \
  --file-path ./Translations/bn.json \
  --base-path ./Translations/en.json \
  --check-missing \
  --check-format \
  --check-plurals
```

**Options:**
- `--file-path`: Path to the translation file to validate
- `--base-path`: Base language file for comparison (optional)
- `--check-missing`: Check for missing translations (default: true)
- `--check-format`: Check for format string mismatches (default: true)
- `--check-plurals`: Check for plural forms (default: true)
- `--verbose`: Enable verbose output

**Validation Checks:**
1. Missing translations (empty values)
2. Format specifier count and type matching
3. Required plural forms for language
4. Missing keys compared to base language
5. Translation status tracking

#### Generate Diff

Generate a diff between two translation versions:

```bash
localizekit diff \
  --old-file ./Translations/v1.0.0/en.json \
  --new-file ./Translations/v1.1.0/en.json \
  --output-path ./Diffs/v1.0.0-to-v1.1.0.json \
  --format json
```

**Options:**
- `--old-file`: Path to the old translation file
- `--new-file`: Path to the new translation file
- `--output-path`: Output path for the diff file
- `--format`: Output format (`json` or `markdown`)
- `--verbose`: Enable verbose output

**Diff Output (JSON):**
```json
{
  "version": "1.1.0",
  "previousVersion": "1.0.0",
  "generatedAt": "2025-11-27T10:30:00Z",
  "summary": {
    "new": 5,
    "modified": 3,
    "removed": 1,
    "unchanged": 42
  },
  "changesByModule": {
    "Store": {
      "new": {...},
      "modified": {...},
      "removed": {...}
    }
  }
}
```

## Project Structure

The CLI tool expects your project to follow this structure:

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
    ├── en.json
    ├── bn.json
    └── ar.json
```

## String Extraction

The tool automatically detects and extracts localization strings from your Swift code. It supports **two patterns**:

### Pattern 1: String Extension (`.localize()`)

```swift
// Simple strings
"store_welcome".localize(
    default: "Welcome!",
    comment: "Welcome message"
)

// With interpolation
"store_items_count".localize(
    default: "You have %d items",
    comment: "Items count message",
    with: itemCount
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
    comment: "Welcome message with user's full name on home screen",
    with: user.name.getFullName()
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

**Note:** The CLI automatically detects both patterns during extraction. You can use whichever pattern fits your use case better.

## Translation File Format

Translation files follow this JSON structure:

```json
{
  "version": "1.0.0",
  "language": "en",
  "generatedAt": "2025-11-27T10:30:00Z",
  "modules": {
    "ModuleName": {
      "translation_key": {
        "value": "Translated text",
        "type": "simple",
        "comment": "Translator comment",
        "metadata": {
          "addedInVersion": "1.0.0",
          "lastModifiedVersion": null,
          "status": "new",
          "translationStatus": "untranslated",
          "changeReason": null
        }
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

### Translation Status

- `untranslated`: Not yet translated (default for new keys)
- `needs_review`: Translation needs review (after source text changed)
- `validated`: Reviewed and approved

## Workflow

### 1. Initial Extraction

```bash
# Extract English strings (base language)
localizekit extract --version 1.0.0 --language en
```

### 2. Create Translations

Copy `en.json` to `bn.json`, `ar.json`, etc. and translate the values.

### 3. After Code Changes

```bash
# Extract new strings
localizekit extract --version 1.1.0 --language en

# Merge with existing translations
localizekit merge \
  --new-file ./Translations/en.json \
  --existing-file ./Translations/bn.json \
  --output-path ./Translations/bn.json
```

### 4. Validate Translations

```bash
# Validate Bengali translation against English base
localizekit validate \
  --file-path ./Translations/bn.json \
  --base-path ./Translations/en.json
```

### 5. Generate Change Report

```bash
# Generate markdown diff for translators
localizekit diff \
  --old-file ./old-versions/en-1.0.0.json \
  --new-file ./Translations/en.json \
  --output-path ./changes.md \
  --format markdown
```

## Tips

1. **Version Control**: Commit translation files to git to track changes
2. **Base Language**: Always use English as the base language for extraction
3. **Comments**: Add meaningful comments for translators to understand context
4. **Format Specifiers**: Use proper format specifiers (%@, %d) for dynamic content
5. **Plural Forms**: Always provide all required plural forms for target languages
6. **Validation**: Run validation before committing translation changes
7. **Diff Reports**: Generate markdown diffs to help translators see what changed

## Troubleshooting

### No strings found

**Problem:** The CLI reports no localization strings found in the project.

**Solutions:**
- Make sure you're using either `.localize()` or `Text.localized()` patterns
- Check that `--project-path` points to the correct project root
- Verify that `Targets/` directory exists in your project
- Ensure your Swift files are in `Targets/ModuleName/Sources/` directories
- Try running with `--verbose` flag to see which files are being processed

**Example:**
```bash
# Run with verbose output to debug
.build/release/LocalizeKit extract \
  --project-path /path/to/project \
  --version 1.0.0 \
  --language en \
  --verbose
```

### Format validation errors

**Problem:** Format specifier validation fails when checking translations.

**Solutions:**
- Ensure format specifiers match between languages
- Use `%@` for strings, `%d` for integers, `%f` for floats
- Check that the order and count of specifiers is consistent
- Markdown formatting (like `**text**`) is NOT a format specifier

**Example:**
```swift
// Correct - both have %@
default: "Welcome, **%@**!"
translation: "স্বাগতম, **%@**!"

// Incorrect - missing %d
default: "You have %d items"
translation: "You have items"  // Missing %d
```

### Plural validation errors

**Problem:** Plural form validation fails.

**Solutions:**
- Different languages require different plural forms (CLDR rules)
- **Arabic** requires 6 forms: zero, one, two, few, many, other
- **English** requires 2 forms: one, other
- **Bengali** requires 2 forms: one, other
- Check CLDR plural rules for your target language

**Required forms by language:**
```
en, bn:      one, other
ar:          zero, one, two, few, many, other
```

### Build errors

**Problem:** `swift build` fails with sandbox errors.

**Solution:** Use the `--disable-sandbox` flag:
```bash
swift build -c release --disable-sandbox
```

### Text.localized() not detected

**Problem:** Strings using `Text.localized()` are not being extracted.

**Solution:** This was fixed in the latest version. Make sure you're using the latest build:
```bash
cd Tools/LocalizeKit
swift build -c release --disable-sandbox
```

The CLI now supports both patterns:
- ✅ `"key".localize(default: "value", comment: "...")`
- ✅ `Text.localized("key", default: "value", comment: "...")`

## License

Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
