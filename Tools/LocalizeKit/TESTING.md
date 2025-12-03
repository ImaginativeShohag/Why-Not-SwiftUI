# LocalizeKit CLI Test Suite

Comprehensive integration test suite for the LocalizeKit CLI tool v2.

## Features

- **Self-contained**: Creates its own test project with sample Swift files
- **No dependencies**: Doesn't rely on parent project structure
- **Comprehensive**: Tests all CLI commands and new v2 features
- **Automated cleanup**: Removes test artifacts on exit
- **Color-coded output**: Easy-to-read test results

## Test Coverage

### Commands Tested (16 tests)
1. ✅ **Initial Extract** - Creates base.json with version 1
2. ✅ **Per-Key Versioning** - Verifies version tracking at key level
3. ✅ **String.localize() Pattern** - Detects extension method pattern
4. ✅ **Text.localized() Pattern** - Detects static method pattern
5. ✅ **Interpolation Detection** - Identifies format specifiers
6. ✅ **Plural Detection** - Identifies plural forms
7. ✅ **Incremental Extract** - Version increment and new key tracking
8. ✅ **Merge (Create)** - Creates new target language from base
9. ✅ **Merge (Sync)** - Version comparison logic
10. ✅ **Validate Command** - Validates target against base
11. ✅ **Diff Command** - Terminal output generation
12. ✅ **Merge --all Flag** - Multi-language merge
13. ✅ **Validate --all Flag** - Multi-language validation
14. ✅ **Migration Command** - v1 to v2 conversion
15. ✅ **Format Specifiers** - Preserves %@, %d specifiers
16. ✅ **Plural Forms** - Preserves zero, one, other forms

## Usage

### Run Tests

```bash
# From anywhere
bash Tools/LocalizeKit/test_localizekit.sh

# Or from LocalizeKit directory
cd Tools/LocalizeKit
bash test_localizekit.sh
```

### Prerequisites

The CLI must be built first:

```bash
cd Tools/LocalizeKit
swift build -c release --disable-sandbox
```

## Test Structure

The test suite automatically creates:

```
/tmp/localizekit-tests-{PID}/
├── Targets/
│   └── TestModule/
│       └── Sources/
│           └── UI/
│               └── Screens/
│                   ├── HomeScreen.swift     # String.localize() examples
│                   └── ProfileScreen.swift  # Text.localized() examples
├── Translations/
│   ├── base.json          # Generated from extraction (v2 format)
│   ├── ar.json            # Created by merge command
│   └── bn.json            # Created for --all flag test
└── MigrationTest/
    └── Translations/
        ├── en.json        # v1 format (for migration test)
        └── base.json      # Migrated to v2 format
```

## Sample Test Files

### HomeScreen.swift
Contains examples of:
- Simple strings with `.localize()`
- Interpolation strings with format specifiers
- Plural strings with `.zero`, `.one`, `.other`

### ProfileScreen.swift
Contains examples of:
- Simple strings with `Text.localized()`
- Static method pattern detection

## Expected Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
LocalizeKit CLI v2 Integration Tests
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ CLI found at .build/release/LocalizeKit
✅ CLI version is 2.0.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Setting up test project
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Test project created at /tmp/localizekit-tests-12345

... (all tests)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Tests: 16
Passed: 16
All tests passed! ✅
```

## New v2 Features Tested

### Per-Key Versioning
- Verifies each key has individual version tracking
- Tests version increment on key modification
- Tests version comparison in merge command

### Auto-Managed base.json
- Tests initial extract creates base.json with version 1
- Tests incremental extract increments file version
- Tests new keys get current version number

### Multi-Language Support
- Tests `--language` parameter (repeatable)
- Tests `--all` flag for batch operations
- Tests merge/validate across multiple languages

### Version Comparison Logic
- Tests that keys with `base_key.version > target_file.version` are replaced
- Tests that up-to-date keys are preserved
- Tests file version synchronization

### Migration
- Tests v1 to v2 format conversion
- Tests version string to int conversion
- Tests backup creation
- Tests simplified target file generation

## Troubleshooting

### CLI not found

```bash
# Build the CLI first
cd Tools/LocalizeKit
swift build -c release --disable-sandbox
```

### Tests failing

If tests fail, the test directory is preserved for inspection:

```bash
# Check test artifacts
ls -la /tmp/localizekit-tests-{PID}/
cat /tmp/localizekit-tests-{PID}/Translations/base.json
```

### jq not installed

The tests require `jq` for JSON parsing:

```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

## Continuous Integration

Add to your CI pipeline:

```yaml
# .github/workflows/test.yml
- name: Test LocalizeKit CLI
  run: |
    cd Tools/LocalizeKit
    swift build -c release --disable-sandbox
    bash test_localizekit.sh
```

## Contributing

When adding new CLI features:
1. Add corresponding test case to `test_localizekit.sh`
2. Ensure test is self-contained (doesn't depend on parent project)
3. Run tests to verify all pass
4. Update this README with new test description

## License

Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
