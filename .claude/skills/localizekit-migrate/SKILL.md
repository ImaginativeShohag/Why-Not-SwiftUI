---
name: localizekit-migrate
alias: /localizekit-migrate
description: Migrate strings to LocalizeKit runtime localization
model: opus
---

# LocalizeKit Migration Skill

Systematically migrate all hardcoded strings, NSLocalizedString calls, and SwiftUI native plurals to LocalizeKit's runtime localization system.

## Process Overview

This skill follows a comprehensive migration process:

1. **Learn Migration Patterns** - Read LocalizeKit documentation
2. **Audit Target Files** - Find all strings requiring migration
3. **Migrate Strings** - Convert to LocalizeKit syntax
4. **Verify Completion** - Re-check for any remaining strings
5. **Iterate Until Complete** - Repeat until no strings remain
6. **Build and Test** - Ensure migrations work correctly
7. **Final Report** - Summarize results

## When Invoked

### Step 1: Read Documentation

First, read the LocalizeKit migration guide to understand patterns.

**IMPORTANT:** Use the Read tool with the absolute path from the project root:
- Path: `docs/LocalizeKit/LocalizeKitRuntime.md` (from project root, NOT from .claude/skills directory)
- This is located in the main project directory, not inside .claude/

Use the Read tool directly:
```
Read tool with file_path: docs/LocalizeKit/LocalizeKitRuntime.md
```

Focus on these sections from the documentation:
- Migration Guides → Pre-Migration Audit Checklist
- Migration Guides → From NSLocalizedString
- Migration Guides → From SwiftUI Native Plurals
- String Localization API

### Step 2: Ask User for Target

Tell the user they can provide the target in any of these formats:
- **Single file:** `Targets/Survey/Sources/UI/Screens/SurveyListScreen.swift`
- **Multiple files (space-separated):** `Targets/Survey/Sources/UI/Screens/SurveyListScreen.swift Targets/Survey/Sources/UI/Screens/SurveyDetailScreen.swift`
- **Single directory:** `Targets/Survey/`
- **Multiple directories (space-separated):** `Targets/Survey/ Targets/FocusAudit/`
- **Mixed (files and directories):** `Targets/Survey/ Targets/Home/Sources/UI/HomeScreen.swift`

Then ask: "Please provide the file path(s) and/or directory path(s) in your next message."

Do NOT use AskUserQuestion. Just display the message and wait for their next message with the path(s).

**Processing user input:**
1. Parse the input by splitting on spaces
2. For each path, check if it's a file or directory:
   - If it's a file (ends with .swift): Add to file list
   - If it's a directory (doesn't end with .swift): Find all .swift files recursively using `find [DIR] -name "*.swift" -type f`
3. Combine all files into a single list for auditing
4. Remove duplicates if any

### Step 3: Audit Phase

Run grep patterns to find all strings requiring migration:

```bash
# 1. Find NSLocalizedString usage
grep -r "NSLocalizedString" --include="*.swift" [TARGET_PATH]

# 2. Find SwiftUI native plurals (CRITICAL - easy to miss!)
grep -r '\^\[' --include="*.swift" [TARGET_PATH]

# 3. Find hardcoded Text() strings
grep -r 'Text("' --include="*.swift" [TARGET_PATH] | grep -v '".localize'

# 4. Find hardcoded Button labels
grep -r 'Button("' --include="*.swift" [TARGET_PATH] | grep -v '".localize'

# 5. Find hardcoded navigationTitle
grep -r '.navigationTitle("' --include="*.swift" [TARGET_PATH] | grep -v '".localize'
```

**Important Notes:**
- Exclude preview code in `#if DEBUG` blocks
- Exclude dynamic content like `Text("\(count)")`
- Exclude system symbols like `Image(systemName: "star")`

Create a TodoWrite list with all files that need migration.

### Step 4: Migration Phase

For each file requiring migration:

1. **Read the file** using Read tool

2. **Check for LocalizeKit import:**
   - Look for `import LocalizeKit` in the imports section
   - If NOT present, add it at the top with other imports (after Foundation/SwiftUI)
   - Example: Add `import LocalizeKit` after existing imports

3. **Identify migration patterns:**
   - NSLocalizedString → `.localize(default:, comment:)`
   - `String(format: NSLocalizedString(...), args)` → `.localize(default:, comment:, with: args)`
   - `Text("\(n) ^[item](\(n))")` → `.localize(defaultPlural: [.one: "1 item", .other: "%d items"], count: n, with: n)`
   - Hardcoded strings → `.localize(default:, comment:)`

4. **Apply migrations** using Edit tool:
   - **CRITICAL:** Add `import LocalizeKit` if missing (do this FIRST before any string migrations)
   - Use `Text("key".localize(...))` for plain text (most cases)
   - Use `Text.localized("key", ...)` ONLY for markdown formatting
   - Follow naming convention: `screen_element_description`
   - Always provide English default value
   - Add helpful comments for translators

5. **Mark todo as completed** and move to next file

### Step 5: Verification Phase

After migrating all files, run comprehensive verification using the patterns from LocalizeKit documentation.

**Run all verification patterns in parallel:**

```bash
# 1. NSLocalizedString usage
grep -r "NSLocalizedString" --include="*.swift" [TARGET_PATH]

# 2. SwiftUI native plurals (CRITICAL - easy to miss!)
grep -r '\^\[' --include="*.swift" [TARGET_PATH]

# 3. All hardcoded string literals (comprehensive pattern)
grep -rn '"' --include="*.swift" [TARGET_PATH] | \
  grep -v '".localize' | \
  grep -v '^\s*//' | \
  grep -v '#if DEBUG' | \
  grep -v '#Preview' | \
  grep -v 'systemName:' | \
  grep -v 'accessibilityIdentifier' | \
  grep -v '^\s*import'

# 4. Multi-line strings
grep -rn '"""' --include="*.swift" [TARGET_PATH] | \
  grep -v '".localize' | \
  grep -v '#if DEBUG' | \
  grep -v '#Preview'
```

**Analyze verification results:**

For each pattern that returns results, manually review each line and determine:
- ✅ **Legitimate skip** - Examples:
  - `Image(systemName: "star")` - SF Symbol names
  - `Text("\(price)")` - Purely dynamic content (no static text)
  - `#Preview { Text("Preview") }` - Preview code
  - `.accessibilityIdentifier("home_tab")` - Test identifiers
  - `let url = "https://api.example.com"` - API endpoints/URLs
  - `let key = "userPreferences"` - UserDefaults keys
  - Code within `#if DEBUG` blocks
  - Notification names, file extensions, data model IDs

- ❌ **Missing migration** - User-facing strings that need localization:
  - `Text("Welcome")` → Needs migration
  - `Button("Save") { }` → Needs migration
  - `.navigationTitle("Profile")` → Needs migration
  - `.alert("Error", ...)` → Needs migration
  - Form labels, placeholders, error messages → Needs migration

**Verification summary format:**

After reviewing all results, create a summary:

```
Verification Results:
✅ NSLocalizedString: 0 remaining
✅ SwiftUI plurals (^[): 0 remaining
✅ String literals: 15 remaining (all legitimate - URLs, SF Symbols, dynamic content)
✅ Multi-line strings: 1 remaining (HTML template in debug code - OK)

Status: VERIFICATION PASSED ✓
```

**If missing migrations are found:**

```
Verification Results:
✅ NSLocalizedString: 0 remaining
✅ SwiftUI plurals (^[): 0 remaining
❌ String literals: 8 remaining - 5 need migration:
   - ProfileScreen.swift:45 - Text("Edit Profile")
   - ProfileScreen.swift:67 - Button("Save Changes")
   - ProfileScreen.swift:89 - .navigationTitle("Settings")
   - SettingsScreen.swift:123 - Toggle("Enable notifications")
   - SettingsScreen.swift:145 - .alert("Confirm Delete")
   (3 others are legitimate: systemName, URL, dynamic)
✅ Multi-line strings: 0 remaining

Status: VERIFICATION FAILED - 5 strings need migration
```

Then:
1. Add those specific files/lines back to the todo list
2. Return to Step 4 (Migration Phase)
3. Continue until verification passes

**Verification passes when:**
- All patterns return zero results, OR
- All remaining results are legitimate skips (system identifiers, dynamic content, preview code, configuration)

### Step 6: Build and Test

After verification passes, build the project to ensure migrations didn't break anything:

1. **Build the project:**
   ```bash
   tuist generate --no-open && tuist build 'BackstageART Development'
   ```

2. **Analyze build results:**
   - If build succeeds with no errors → Proceed to Step 7 (Final Report)
   - If build fails with errors:
     - Check if errors are related to the migration (missing imports, incorrect syntax, wrong method calls)
     - If migration-related: Fix the issues and rebuild
     - If NOT migration-related: Ask user if they want you to continue fixing these issues

3. **Fix migration-related errors automatically:**
   - Missing `import LocalizeKit` → Add it
   - Incorrect `.localize()` syntax → Fix it
   - Wrong string interpolation → Correct it
   - Plural syntax errors → Fix them
   - After fixes, rebuild and verify

4. **For non-migration errors:**
   - Show the errors to the user
   - Ask: "These errors appear unrelated to the LocalizeKit migration. Would you like me to fix them, or should I stop here?"
   - Wait for user response before proceeding

### Step 7: Final Report

When build succeeds:

1. Summarize migration statistics:
   - Total files migrated
   - NSLocalizedString conversions
   - SwiftUI plural conversions
   - Hardcoded string conversions
   - Build status: ✅ Success

2. Remind user to:
   - Test with different languages
   - Test RTL languages (Arabic, Hebrew)
   - Test plural forms with various counts (0, 1, 2, 5, 11, 21, 100)
   - Verify layout with longer text (German, Russian)

## Migration Examples

### NSLocalizedString → LocalizeKit

**Before:**
```swift
let title = NSLocalizedString("title", comment: "Home screen title")
let greeting = String(format: NSLocalizedString("greeting", comment: ""), userName)
```

**After:**
```swift
let title = "title".localize(
    default: "Home",
    comment: "Home screen title"
)

let greeting = "greeting".localize(
    default: "Hello, %@!",
    comment: "Greeting with user name",
    with: userName
)
```

### SwiftUI Native Plurals → LocalizeKit

**Before:**
```swift
Text("\(count) ^[items](\(count))")
```

**After:**
```swift
Text("cart_count_items".localize(
    defaultPlural: [
        .one: "1 item",
        .other: "%d items"
    ],
    comment: "Shopping cart item count",
    count: count,
    with: count
))
```

### Hardcoded Strings → LocalizeKit

**Before:**
```swift
Text("Welcome to our app!")
Button("Save") { save() }
.navigationTitle("Profile")
```

**After:**
```swift
Text("home_title_welcome".localize(
    default: "Welcome to our app!",
    comment: "Home screen welcome message"
))

Button("profile_button_save".localize(
    default: "Save",
    comment: "Save button in profile form"
)) { save() }

.navigationTitle("profile_title".localize(
    default: "Profile",
    comment: "Profile screen navigation title"
))
```

## Key Naming Convention

Use `screen_element_description` format (snake_case):

- `cart_button_checkout` - Checkout button in cart
- `profile_label_email` - Email label in profile
- `cart_message_empty` - Empty cart message
- `error_message_network` - Network error message
- `cart_count_items` - Item count plural

## Important Rules

1. **Text.localized() vs Text() with .localize():**
   - Use `Text("key".localize(...))` for plain text (default)
   - Use `Text.localized("key", ...)` ONLY for markdown support

2. **Always provide English defaults** - Never use empty strings or "TODO"

3. **Write helpful comments** - Provide context for translators

4. **Handle plurals correctly** - Always include `.other` category

5. **Avoid string concatenation** - Use interpolation instead

6. **Test thoroughly** - Different languages, RTL, plurals, offline mode

## Completion Criteria

Migration is complete when:
- ✅ All grep patterns return zero results (excluding debug/preview code)
- ✅ All user-facing strings use `.localize()`
- ✅ No NSLocalizedString calls remain
- ✅ No SwiftUI native plural syntax (`^[...]`) remains
- ✅ All navigation titles, buttons, alerts use LocalizeKit
- ✅ Verification audit passes
- ✅ Project builds successfully

## Notes

- Always use TodoWrite to track progress
- Update todos as you complete each file
- Ask clarification if migration pattern is ambiguous
- Be thorough - missing strings break the user experience
- InshaAllah, this systematic approach ensures complete migration
