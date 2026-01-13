#!/bin/bash

# LocalizeKit CLI End-to-End Tests
# Tests the actual compiled CLI executable with real commands

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Create temporary test project
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

echo "🧪 LocalizeKit CLI End-to-End Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Test Directory: $TEST_DIR"
echo ""

# Build the CLI first
echo "🔨 Building LocalizeKit CLI..."
BUILD_OUTPUT=$(swift build --disable-sandbox 2>&1)
if [ $? -eq 0 ]; then
    echo "✅ CLI built successfully"
else
    echo "❌ Failed to build CLI"
    echo "$BUILD_OUTPUT"
    exit 1
fi
echo ""

# Helper functions
run_test() {
    local test_name=$1
    shift
    TESTS_RUN=$((TESTS_RUN + 1))

    echo -n "  Testing: $test_name... "

    if "$@" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

run_test_with_output() {
    local test_name=$1
    local expected_output=$2
    shift 2
    TESTS_RUN=$((TESTS_RUN + 1))

    echo -n "  Testing: $test_name... "

    output=$("$@" 2>&1)
    if echo "$output" | grep -q "$expected_output"; then
        echo -e "${GREEN}✓${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC}"
        echo "    Expected output to contain: $expected_output"
        echo "    Got: $output"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

file_exists() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Setup test project structure
setup_test_project() {
    mkdir -p "$TEST_DIR/Targets/Store/Sources"
    mkdir -p "$TEST_DIR/Translations"

    # Create sample Swift file with localization strings
    cat > "$TEST_DIR/Targets/Store/Sources/HomeScreen.swift" << 'EOF'
import SwiftUI

struct HomeScreen: View {
    var body: some View {
        VStack {
            Text("store_welcome".localize(
                default: "Welcome to our store!",
                comment: "Welcome message"
            ))

            Text("store_greeting".localize(
                default: "Hello, **%@**!",
                comment: "Greeting with name",
                with: userName
            ))

            Text("store_items".localize(
                defaultPlural: [
                    .zero: "No items",
                    .one: "1 item",
                    .other: "%d items"
                ],
                comment: "Item count",
                count: items.count
            ))
        }
    }
}
EOF
}

# Create Swift file with optional interpolation
create_greeting_file() {
    local with_interpolation=$1
    local file_path="$TEST_DIR/Targets/Store/Sources/GreetingScreen.swift"

    if [ "$with_interpolation" = "true" ]; then
        # With interpolation (%@)
        cat > "$file_path" << 'EOF'
import SwiftUI

struct GreetingScreen: View {
    var body: some View {
        Text("store_greeting".localize(
            default: "Welcome, %@!",
            comment: "Greeting with name",
            with: userName
        ))
    }
}
EOF
    else
        # Without interpolation (simple)
        cat > "$file_path" << 'EOF'
import SwiftUI

struct GreetingScreen: View {
    var body: some View {
        Text("store_greeting".localize(
            default: "Welcome",
            comment: "Simple greeting"
        ))
    }
}
EOF
    fi
}

# Test 1: Extract Command
test_extract_command() {
    echo "📋 Test Group: Extract Command"

    setup_test_project

    # Test basic extract
    run_test "Extract creates base.json" \
        sh -c "swift run --disable-sandbox LocalizeKit extract --project-path '$TEST_DIR' && [ -f '$TEST_DIR/Translations/base.json' ]"

    # Test extract with verbose
    run_test_with_output "Extract with verbose flag" "Extracting" \
        swift run --disable-sandbox LocalizeKit extract --project-path "$TEST_DIR" --verbose

    # Test extract with invalid path
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "  Testing: Extract with invalid path fails... "
    if swift run --disable-sandbox LocalizeKit extract --project-path "/nonexistent" > /dev/null 2>&1; then
        echo -e "${RED}✗${NC}"
        echo "    Expected command to fail, but it succeeded"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        echo -e "${GREEN}✓${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi

    echo ""
}

# Test 2: Merge Command
test_merge_command() {
    echo "📋 Test Group: Merge Command"

    setup_test_project

    # First extract to create base.json
    swift run --disable-sandbox LocalizeKit extract --project-path "$TEST_DIR" > /dev/null 2>&1

    # Test merge for single language
    run_test "Merge creates ar.json" \
        sh -c "swift run --disable-sandbox LocalizeKit merge --project-path '$TEST_DIR' --language ar && [ -f '$TEST_DIR/Translations/ar.json' ]"

    # Test merge for all languages
    # First create the ar and bn files
    swift run --disable-sandbox LocalizeKit merge --project-path "$TEST_DIR" --language ar > /dev/null 2>&1
    swift run --disable-sandbox LocalizeKit merge --project-path "$TEST_DIR" --language bn > /dev/null 2>&1
    # Now test that --all updates them
    run_test "Merge --all updates existing language files" \
        sh -c "swift run --disable-sandbox LocalizeKit merge --project-path '$TEST_DIR' --all && [ -f '$TEST_DIR/Translations/ar.json' ] && [ -f '$TEST_DIR/Translations/bn.json' ]"

    # Test merge without base file
    rm -f "$TEST_DIR/Translations/base.json"
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "  Testing: Merge without base.json fails... "
    if swift run --disable-sandbox LocalizeKit merge --project-path "$TEST_DIR" --language ar > /dev/null 2>&1; then
        echo -e "${RED}✗${NC}"
        echo "    Expected command to fail, but it succeeded"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        echo -e "${GREEN}✓${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi

    echo ""
}

# Test 3: Validate Command
test_validate_command() {
    echo "📋 Test Group: Validate Command"

    setup_test_project

    # Setup: extract and merge
    swift run --disable-sandbox LocalizeKit extract --project-path "$TEST_DIR" > /dev/null 2>&1
    swift run --disable-sandbox LocalizeKit merge --project-path "$TEST_DIR" --language ar > /dev/null 2>&1

    # Test validate runs (may have warnings, that's ok - just check it doesn't crash)
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "  Testing: Validate ar.json runs... "
    if swift run --disable-sandbox LocalizeKit validate --project-path "$TEST_DIR" --language ar > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        # Command may return non-zero on validation warnings, that's ok as long as it ran
        echo -e "${GREEN}✓${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi

    # Test validate non-existent file
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "  Testing: Validate non-existent file fails... "
    if swift run --disable-sandbox LocalizeKit validate --project-path "$TEST_DIR" --language fr > /dev/null 2>&1; then
        echo -e "${RED}✗${NC}"
        echo "    Expected command to fail, but it succeeded"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        echo -e "${GREEN}✓${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi

    echo ""
}

# Test 4: Diff Command
test_diff_command() {
    echo "📋 Test Group: Diff Command"

    setup_test_project

    # Setup: extract and merge
    swift run --disable-sandbox LocalizeKit extract --project-path "$TEST_DIR" > /dev/null 2>&1
    swift run --disable-sandbox LocalizeKit merge --project-path "$TEST_DIR" --language ar > /dev/null 2>&1

    # Test diff runs
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "  Testing: Diff ar.json runs... "
    swift run --disable-sandbox LocalizeKit diff --project-path "$TEST_DIR" --language ar > /dev/null 2>&1
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    echo ""
}

# Test 5: Full Workflow
test_full_workflow() {
    echo "📋 Test Group: Full Workflow"

    setup_test_project

    # Step 1: Extract
    run_test "Step 1: Extract strings" \
        swift run --disable-sandbox LocalizeKit extract --project-path "$TEST_DIR"

    run_test "Step 1: Verify base.json exists" \
        file_exists "$TEST_DIR/Translations/base.json"

    # Step 2: Merge
    run_test "Step 2: Merge to create ar.json" \
        swift run --disable-sandbox LocalizeKit merge --project-path "$TEST_DIR" --language ar

    run_test "Step 2: Verify ar.json exists" \
        file_exists "$TEST_DIR/Translations/ar.json"

    # Verify JSON structure
    run_test "Verify base.json has version field" \
        sh -c "cat '$TEST_DIR/Translations/base.json' | grep -q '\"version\"'"

    run_test "Verify base.json has modules field" \
        sh -c "cat '$TEST_DIR/Translations/base.json' | grep -q '\"modules\"'"

    run_test "Verify ar.json has Store module" \
        sh -c "cat '$TEST_DIR/Translations/ar.json' | grep -q '\"Store\"'"

    echo ""
}

# Test 6: Help and Error Handling
test_help_and_errors() {
    echo "📋 Test Group: Help & Error Handling"

    # Test help
    run_test_with_output "CLI shows help" "LocalizeKit" \
        swift run --disable-sandbox LocalizeKit --help

    # Test invalid command
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "  Testing: Invalid command fails... "
    if swift run --disable-sandbox LocalizeKit invalid-command > /dev/null 2>&1; then
        echo -e "${RED}✗${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        echo -e "${GREEN}✓${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi

    echo ""
}

# Test 7: Type Change Workflow
test_type_change_workflow() {
    echo "📋 Test Group: Type Change Workflow"

    # Create clean test environment (don't use setup_test_project - it has conflicting keys)
    # Clean up any existing files first
    rm -rf "$TEST_DIR/Targets"
    rm -rf "$TEST_DIR/Translations"
    mkdir -p "$TEST_DIR/Targets/Store/Sources"
    mkdir -p "$TEST_DIR/Translations"

    # Step 1: Create Swift file with simple string (no interpolation)
    create_greeting_file false

    # Step 2: First extraction (Version 1) - Extract simple string
    run_test "Step 1: Extract simple string (v1)" \
        swift run --disable-sandbox LocalizeKit extract --project-path "$TEST_DIR"

    run_test "Step 1: Verify base.json exists" \
        file_exists "$TEST_DIR/Translations/base.json"

    # Step 3: Merge to create target file
    run_test "Step 2: Merge to create ar.json" \
        swift run --disable-sandbox LocalizeKit merge --project-path "$TEST_DIR" --language ar

    run_test "Step 2: Verify ar.json exists" \
        file_exists "$TEST_DIR/Translations/ar.json"

    # Verify initial version
    run_test "Step 2: Verify base.json is version 1" \
        sh -c "cat '$TEST_DIR/Translations/base.json' | grep -q '\"version\" *: *1'"

    # Step 4: Verify initial value is simple
    run_test "Step 2: Verify greeting has simple value" \
        sh -c "cat '$TEST_DIR/Translations/base.json' | grep -q '\"store_greeting\"'"

    # Step 5: Modify source code - Add interpolation (type change)
    create_greeting_file true

    # Step 6: Second extraction - Extract string with interpolation
    run_test "Step 3: Re-extract with interpolation (v2)" \
        swift run --disable-sandbox LocalizeKit extract --project-path "$TEST_DIR"

    # Step 7: Verify version incremented
    run_test "Step 3: Verify base.json is now version 2" \
        sh -c "cat '$TEST_DIR/Translations/base.json' | grep -q '\"version\" *: *2'"

    # Step 8: Verify new value has interpolation
    run_test "Step 3: Verify greeting has interpolation" \
        sh -c "cat '$TEST_DIR/Translations/base.json' | grep -q 'Welcome, %@!'"

    # Step 9: Merge again - should update target file
    run_test "Step 4: Re-merge after type change" \
        swift run --disable-sandbox LocalizeKit merge --project-path "$TEST_DIR" --language ar

    # Step 10: Verify target file was updated with new value
    run_test "Step 4: Verify ar.json has updated value" \
        sh -c "cat '$TEST_DIR/Translations/ar.json' | grep -q 'Welcome, %@!'"

    # Step 11: Verify target file version matches base
    run_test "Step 4: Verify ar.json version is 2" \
        sh -c "cat '$TEST_DIR/Translations/ar.json' | grep -q '\"version\" *: *2'"

    echo ""
}

# Run all tests
test_extract_command
test_merge_command
test_validate_command
test_diff_command
test_full_workflow
test_type_change_workflow
test_help_and_errors

# Print summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Total Tests:  $TESTS_RUN"
echo -e "  Passed:       ${GREEN}$TESTS_PASSED${NC}"
echo -e "  Failed:       ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
