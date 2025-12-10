# LocalizeKit Quick Start Guide

This guide shows how to use the LocalizeKit CLI tool with the Why-Not-SwiftUI project.

## Setup

### 1. Build the CLI Tool

```bash
cd Tools/LocalizeKit
swift build -c release
```

### 2. Create an Alias (Optional)

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
alias localizekit="/path/to/Why-Not-SwiftUI/Tools/LocalizeKit/.build/release/LocalizeKit"
```

Or use directly:

```bash
Tools/LocalizeKit/.build/release/LocalizeKit
```

## Current Project Status

The Store module has been localized with the following strings:

### HomeScreen.swift
- `store_welcome` - Welcome message with interpolation

### ProfileSheet.swift
- `store_retry` - Retry button
- `store_profile` - Profile title
- `store_done` - Done button
- `store_details` - Details section
- `store_name` - Name label
- `store_username` - Username label
- `store_email` - Email label
- `store_phone` - Phone label
- `store_address` - Address label
- `store_orders` - Orders button
- `store_language_settings` - Language settings button
- `store_sign_out` - Sign out button
- `store_sign_out_alert_title` - Sign out alert title

## Step-by-Step Workflow

### Step 1: Extract Base Language (English)

```bash
# From project root
Tools/LocalizeKit/.build/release/LocalizeKit extract \
  --project-path . \
  --output-path ./Translations \
  --language en \
  --version 1.0.0
```

**Expected Output:**
- File: `./Translations/en.json`
- Contains all strings from Store module
- Statistics showing ~14 strings extracted

### Step 2: Create Bengali Translation

```bash
# Copy English file as template
cp ./Translations/en.json ./Translations/bn.json

# Edit bn.json and translate the values
# Keep the keys the same, translate only the "value" fields
```

**Example Translation:**
```json
{
  "store_welcome": {
    "value": "স্বাগতম, **%@**!",
    "type": "interpolation",
    "comment": "Welcome message with user's full name on home screen"
  }
}
```

### Step 3: Validate Bengali Translation

```bash
Tools/LocalizeKit/.build/release/LocalizeKit validate \
  --file-path ./Translations/bn.json \
  --base-path ./Translations/en.json
```

**This checks:**
- Missing translations
- Format specifier mismatches
- Missing keys compared to English

### Step 4: After Adding New Strings

When you add more `.localize()` calls to the code:

```bash
# 1. Extract new strings
Tools/LocalizeKit/.build/release/LocalizeKit extract \
  --project-path . \
  --output-path ./Translations/temp \
  --language en \
  --version 1.1.0

# 2. Merge with existing Bengali translation
Tools/LocalizeKit/.build/release/LocalizeKit merge \
  --new-file ./Translations/temp/en.json \
  --existing-file ./Translations/bn.json \
  --output-path ./Translations/bn.json

# 3. Review strings marked as "needs_review"
# 4. Translate new strings marked as "untranslated"
```

### Step 5: Generate Change Report for Translators

```bash
# Generate markdown diff
Tools/LocalizeKit/.build/release/LocalizeKit diff \
  --old-file ./Translations/archive/v1.0.0-en.json \
  --new-file ./Translations/en.json \
  --output-path ./Translations/changes-v1.0.0-to-v1.1.0.md \
  --format markdown
```

**Send `changes-v1.0.0-to-v1.1.0.md` to translators** so they know what changed.

## Interactive Menu

For a more user-friendly experience, just run:

```bash
Tools/LocalizeKit/.build/release/LocalizeKit
```

This launches an interactive menu that guides you through each operation.

## Integration with Server

Once you have translation JSON files ready:

### 1. Upload to Server

Place the JSON files on your server at:
```
https://api.example.com/api/translations/en.json
https://api.example.com/api/translations/bn.json
https://api.example.com/api/translations/ar.json
```

### 2. Update Stub Data (for Development)

Edit `Targets/NetworkKit/Sources/API/LocalizationAPI.swift` and update the stub data to match your JSON files.

### 3. Switch to Production

In `Targets/NetworkKit/Sources/DataSource.swift`:
```swift
public nonisolated(unsafe) static let Localization = Backend<LocalizationAPI>(
    isStubbed: false,  // Change to false
    stubBehavior: .delayed(seconds: 1),
    session: NetworkSession.create()
)
```

## Testing Runtime Localization

### In Simulator/Device

1. Run the app
2. Go to Store tab
3. Open Profile (top-right avatar)
4. Tap "Language Settings"
5. Select a language (e.g., Bengali)
6. UI should instantly update with translated text

### Verify Language Persistence

1. Close and reopen the app
2. Language should be remembered (saved in UserDefaults via Preferences)

## Translation Status Workflow

### Status Values

- **untranslated**: New key, needs translation
- **needs_review**: Default text changed, review needed
- **validated**: Reviewed and approved

### Workflow for Translators

1. Filter for `"translationStatus": "untranslated"` → Translate these
2. Filter for `"translationStatus": "needs_review"` → Review and update
3. Mark as `"validated"` after review

## Common Issues

### CLI Tool Not Found
```bash
# Make sure it's built
cd Tools/LocalizeKit
swift build -c release

# Check the path
ls .build/release/LocalizeKit
```

### No Strings Extracted
- Verify `Targets/` directory exists
- Check that you're using `.localize()` methods
- Run with `--verbose` flag to see what's happening

### Format Specifier Errors
- Make sure translated strings have same format specifiers as English
- English: "You have %d items" → Bengali: "আপনার %d টি আইটেম আছে"

### Missing Plural Forms
- Arabic needs all 6 forms: zero, one, two, few, many, other
- English needs 2 forms: one, other
- Check CLDR plural rules for your language

## Example: Complete Bengali Translation

```json
{
  "version": 1,
  "modules": {
    "Store": {
      "store_welcome": {
        "value": "স্বাগতম, **%@**!",
        "type": "interpolation",
        "comment": "Welcome message with user's full name on home screen"
      },
      "store_profile": {
        "value": "প্রোফাইল",
        "type": "simple",
        "comment": "Profile screen title"
      },
      "store_orders": {
        "value": "অর্ডার",
        "type": "simple",
        "comment": "Orders button text"
      }
    }
  }
}
```

## Tips

1. **Always keep English as base**: Extract from code → generates en.json
2. **Use meaningful keys**: Prefix with module name (store_, home_, etc.)
3. **Add helpful comments**: Translators need context
4. **Version control**: Commit JSON files to git
5. **Archive old versions**: Keep old versions in `Translations/archive/`
6. **Test thoroughly**: Switch languages in app and check all screens
7. **Use diff reports**: Help translators see exactly what changed

## Next Steps

1. Build the CLI tool
2. Extract current Store module strings
3. Create Bengali translation file
4. Update stub data in LocalizationAPI.swift
5. Test language switching in app
6. Apply localization to other modules (Home, News, Todo)

InshaAllah, this will make managing translations much easier!
