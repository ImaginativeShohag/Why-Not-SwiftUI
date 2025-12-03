# LocalizeKit Test Suite

Comprehensive unit test suite for LocalizeKit CLI using Swift's XCTest framework.

## Overview

The test suite provides automated testing for LocalizeKit's core functionality using Swift's native testing framework (XCTest). Tests are written in Swift and can be easily integrated into CI/CD pipelines.

## Running Tests

### Quick Start

```bash
# From LocalizeKit directory
cd Tools/LocalizeKit
swift test --disable-sandbox
```

### From Project Root

```bash
swift test --package-path Tools/LocalizeKit --disable-sandbox
```

### Verbose Output

```bash
swift test --disable-sandbox --verbose
```

### Run Specific Tests

```bash
# Run only LocalizeKitCoreTests
swift test --disable-sandbox --filter LocalizeKitCoreTests

# Run a specific test method
swift test --disable-sandbox --filter LocalizeKitCoreTests/testBaseTranslationFileEncoding
```

## Test Coverage

### Translation Models (12 Tests)

1. ✅ **Simple Value Encoding** - Tests encoding of simple string values
2. ✅ **Plural Value Encoding** - Tests encoding of plural forms
3. ✅ **Base Translation File Encoding** - Tests full base.json structure
4. ✅ **Target Translation File Encoding** - Tests target language file structure
5. ✅ **Translation Type Validation** - Tests simple, interpolation, and plural types
6. ✅ **Translation Status Validation** - Tests new, modified, and unchanged statuses
7. ✅ **Base File JSON Loading** - Tests loading base.json from JSON string
8. ✅ **Target File JSON Loading** - Tests loading target files from JSON
9. ✅ **Plural Forms Preservation** - Tests all 6 CLDR plural categories
10. ✅ **Format Specifier Detection** - Tests %@, %d detection
11. ✅ **Translation Value Performance** - Benchmarks encoding performance
12. ✅ **Base File Performance** - Benchmarks file encoding performance

## Test Structure

```
Tests/
└── LocalizeKitTests/
    └── LocalizeKitCoreTests.swift     # Core functionality tests
```

## What's Tested

### JSON Serialization
- Encoding and decoding of base translation files
- Encoding and decoding of target translation files
- Proper handling of simple, interpolation, and plural types
- Metadata preservation (version, status, comments)

### Translation Values
- Simple string values
- Interpolation with format specifiers (%@, %d, %f)
- Plural forms with all CLDR categories:
  - zero, one, two, few, many, other

### File Structures
- Base file structure with metadata
- Target file structure (simplified)
- Module organization
- Version tracking

### Performance
- Translation value encoding benchmarks
- Base file encoding benchmarks
- Measured against baseline for regression detection

## CI/CD Integration

### GitHub Actions

```yaml
name: LocalizeKit Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Tests
        run: |
          cd Tools/LocalizeKit
          swift test --disable-sandbox
```

### GitLab CI

```yaml
test:
  stage: test
  script:
    - cd Tools/LocalizeKit
    - swift test --disable-sandbox
  only:
    - main
    - merge_requests
```

## Advantages Over Bash Tests

1. **Type Safety** - Swift's type system catches errors at compile time
2. **IDE Integration** - Works seamlessly with Xcode and VS Code
3. **Better Assertions** - XCTest provides rich assertion APIs
4. **Performance Testing** - Built-in performance measurement
5. **Parallel Execution** - Tests can run in parallel for speed
6. **CI/CD Friendly** - Standard test reporting formats
7. **Debugging** - Can use Xcode debugger on failing tests
8. **Maintainable** - Swift code is easier to maintain than bash scripts

## Writing New Tests

To add new tests, create test methods in `LocalizeKitCoreTests.swift`:

```swift
func testNewFeature() throws {
    // Arrange
    let input = "test input"

    // Act
    let result = processInput(input)

    // Assert
    XCTAssertEqual(result, "expected output")
}
```

## Test Output

Successful test run:

```
Test Suite 'All tests' started.
Test Suite 'LocalizeKitCoreTests' started.
Test Case 'testBaseTranslationFileEncoding' passed (0.001 seconds).
Test Case 'testTranslationValuePluralEncoding' passed (0.000 seconds).
...
Test Suite 'LocalizeKitCoreTests' passed.
    Executed 12 tests, with 0 failures in 0.708 seconds
```

## Troubleshooting

### Build Errors

If you encounter sandbox errors:
```bash
swift build --disable-sandbox
swift test --disable-sandbox
```

### Missing Dependencies

If dependencies are missing:
```bash
swift package resolve
swift build --disable-sandbox
```

### Clean Build

For a fresh start:
```bash
rm -rf .build
swift build --disable-sandbox
swift test --disable-sandbox
```

## Future Enhancements

Potential areas for additional test coverage:
- String extraction from Swift files (requires mocking file system)
- Translation validation logic
- Diff generation
- Merge logic with version comparison
- CLI command integration tests

## License

Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
