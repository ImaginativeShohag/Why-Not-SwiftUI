#!/bin/bash

# LocalizeKit CLI v2 Integration Tests
# Self-contained test suite for the new workflow with base.json and per-key versioning

set -e

# Get script directory and change to it
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test configuration
TEST_DIR="/tmp/localizekit-tests-$$"
CLI_PATH=".build/release/LocalizeKit"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
print_header() {
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

cleanup() {
    echo -e "\n${YELLOW}Cleaning up test directory...${NC}"
    rm -rf "$TEST_DIR"
}

# Trap to ensure cleanup happens
trap cleanup EXIT

# Create test project structure
create_test_project() {
    print_header "Setting up test project"

    # Create directory structure
    mkdir -p "$TEST_DIR/Targets/TestModule/Sources/UI/Screens"
    mkdir -p "$TEST_DIR/Translations"

    # Create sample Swift file with String.localize() pattern
    cat > "$TEST_DIR/Targets/TestModule/Sources/UI/Screens/HomeScreen.swift" <<'EOF'
import SwiftUI

struct HomeScreen: View {
    var body: some View {
        VStack {
            Text("test_welcome".localize(
                default: "Welcome to LocalizeKit!",
                comment: "Welcome message on home screen"
            ))

            Text("test_greeting".localize(
                default: "Hello, %@!",
                comment: "Greeting with name",
                with: userName
            ))

            Text("test_items_count".localize(
                defaultPlural: [
                    .zero: "No items",
                    .one: "1 item",
                    .other: "%d items"
                ],
                comment: "Number of items",
                count: itemCount
            ))
        }
    }
}
EOF

    # Create sample Swift file with Text.localized() pattern
    cat > "$TEST_DIR/Targets/TestModule/Sources/UI/Screens/ProfileScreen.swift" <<'EOF'
import SwiftUI

struct ProfileScreen: View {
    var body: some View {
        VStack {
            Text.localized(
                "test_profile_title",
                default: "User Profile",
                comment: "Profile screen title"
            )

            Text.localized(
                "test_logout",
                default: "Logout",
                comment: "Logout button text"
            )
        }
    }
}
EOF

    print_success "Test project created at $TEST_DIR"
}

# Main test execution
main() {
    print_header "LocalizeKit CLI v2 Integration Tests"

    # Check if CLI exists
    if [ ! -f "$CLI_PATH" ]; then
        print_error "CLI not found at $CLI_PATH. Please build first with: swift build -c release --disable-sandbox"
        exit 1
    fi
    print_success "CLI found at $CLI_PATH"

    # Check CLI version
    VERSION=$($CLI_PATH --version 2>&1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "unknown")
    if [[ "$VERSION" == "2.0.0" ]]; then
        print_success "CLI version is 2.0.0"
    else
        print_error "CLI version is $VERSION (expected 2.0.0)"
    fi

    # Create test project
    create_test_project

    # Test 1: Initial Extract (creates base.json with version 1)
    print_header "Test 1: Initial Extract Command"
    if $CLI_PATH extract --project-path "$TEST_DIR" > /dev/null 2>&1; then
        if [ -f "$TEST_DIR/Translations/base.json" ]; then
            # Check version is 1
            BASE_VERSION=$(cat "$TEST_DIR/Translations/base.json" | jq -r '.version')
            if [ "$BASE_VERSION" = "1" ]; then
                print_success "Initial extract created base.json with version 1"
            else
                print_error "Base.json version is $BASE_VERSION (expected 1)"
            fi

            # Check string count
            STRING_COUNT=$(cat "$TEST_DIR/Translations/base.json" | jq '.modules.TestModule | length')
            if [ "$STRING_COUNT" -ge 5 ]; then
                print_success "Extract found $STRING_COUNT strings"
            else
                print_error "Extract found only $STRING_COUNT strings (expected at least 5)"
            fi
        else
            print_error "Extract did not create base.json"
        fi
    else
        print_error "Initial extract command failed"
    fi

    # Test 2: Verify per-key versioning
    print_header "Test 2: Per-Key Version Tracking"
    if [ -f "$TEST_DIR/Translations/base.json" ]; then
        KEY_VERSION=$(cat "$TEST_DIR/Translations/base.json" | jq -r '.modules.TestModule.test_welcome.version')
        if [ "$KEY_VERSION" = "1" ]; then
            print_success "Per-key version tracking works (test_welcome has version 1)"
        else
            print_error "Per-key version is $KEY_VERSION (expected 1)"
        fi
    else
        print_error "base.json not found"
    fi

    # Test 3: String.localize() pattern detection
    print_header "Test 3: String.localize() Pattern Detection"
    if grep -q '"test_welcome"' "$TEST_DIR/Translations/base.json" 2>/dev/null; then
        print_success "String.localize() pattern detected (test_welcome found)"
    else
        print_error "String.localize() pattern NOT detected"
    fi

    # Test 4: Text.localized() pattern detection
    print_header "Test 4: Text.localized() Pattern Detection"
    if grep -q '"test_profile_title"' "$TEST_DIR/Translations/base.json" 2>/dev/null; then
        print_success "Text.localized() pattern detected (test_profile_title found)"
    else
        print_error "Text.localized() pattern NOT detected"
    fi

    # Test 5: Interpolation type detection
    print_header "Test 5: Interpolation Type Detection"
    GREETING_TYPE=$(cat "$TEST_DIR/Translations/base.json" | jq -r '.modules.TestModule.test_greeting.type' 2>/dev/null)
    if [ "$GREETING_TYPE" = "interpolation" ]; then
        print_success "Interpolation type correctly detected"
    else
        print_error "Interpolation type NOT detected (got: $GREETING_TYPE)"
    fi

    # Test 6: Plural type detection
    print_header "Test 6: Plural Type Detection"
    ITEMS_TYPE=$(cat "$TEST_DIR/Translations/base.json" | jq -r '.modules.TestModule.test_items_count.type' 2>/dev/null)
    if [ "$ITEMS_TYPE" = "plural" ]; then
        print_success "Plural type correctly detected"
    else
        print_error "Plural type NOT detected (got: $ITEMS_TYPE)"
    fi

    # Test 7: Incremental extract (version increment)
    print_header "Test 7: Incremental Extract (Version Increment)"

    # Modify Swift file to add a new string
    cat >> "$TEST_DIR/Targets/TestModule/Sources/UI/Screens/HomeScreen.swift" <<'EOF'

extension HomeScreen {
    var newFeature: some View {
        Text("test_new_feature".localize(
            default: "New Feature",
            comment: "A new feature added"
        ))
    }
}
EOF

    if $CLI_PATH extract --project-path "$TEST_DIR" --ignore-comment-changes > /dev/null 2>&1; then
        NEW_VERSION=$(cat "$TEST_DIR/Translations/base.json" | jq -r '.version')
        if [ "$NEW_VERSION" = "2" ]; then
            print_success "Incremental extract incremented version to 2"
        else
            print_error "Version is $NEW_VERSION (expected 2)"
        fi

        # Check if new key was added
        if grep -q '"test_new_feature"' "$TEST_DIR/Translations/base.json" 2>/dev/null; then
            NEW_KEY_VERSION=$(cat "$TEST_DIR/Translations/base.json" | jq -r '.modules.TestModule.test_new_feature.version')
            if [ "$NEW_KEY_VERSION" = "2" ]; then
                print_success "New key added with version 2"
            else
                print_error "New key version is $NEW_KEY_VERSION (expected 2)"
            fi
        else
            print_error "New key 'test_new_feature' not found"
        fi
    else
        print_error "Incremental extract failed"
    fi

    # Test 8: Merge - Create new target language
    print_header "Test 8: Merge Command (Create New Language)"
    if $CLI_PATH merge --project-path "$TEST_DIR" --language ar > /dev/null 2>&1; then
        if [ -f "$TEST_DIR/Translations/ar.json" ]; then
            AR_VERSION=$(cat "$TEST_DIR/Translations/ar.json" | jq -r '.version')
            if [ "$AR_VERSION" = "2" ]; then
                print_success "Merge created ar.json with version 2 (matches base)"
            else
                print_error "ar.json version is $AR_VERSION (expected 2)"
            fi

            # Check that ar.json is simplified (no metadata)
            HAS_METADATA=$(cat "$TEST_DIR/Translations/ar.json" | jq '.modules.TestModule.test_welcome.metadata' 2>/dev/null)
            if [ "$HAS_METADATA" = "null" ]; then
                print_success "Target file is simplified (no metadata)"
            else
                print_error "Target file has metadata (should be simplified)"
            fi
        else
            print_error "Merge did not create ar.json"
        fi
    else
        print_error "Merge command failed"
    fi

    # Test 9: Merge - Sync existing target (version comparison)
    print_header "Test 9: Merge Command (Sync with Version Comparison)"

    # Manually edit base.json to increment a key version
    TMP_BASE=$(mktemp)
    cat "$TEST_DIR/Translations/base.json" | jq '.modules.TestModule.test_welcome.value = "Welcome Updated!" | .modules.TestModule.test_welcome.version = 3 | .version = 3' > "$TMP_BASE"
    mv "$TMP_BASE" "$TEST_DIR/Translations/base.json"

    if $CLI_PATH merge --project-path "$TEST_DIR" --language ar > /dev/null 2>&1; then
        AR_WELCOME=$(cat "$TEST_DIR/Translations/ar.json" | jq -r '.modules.TestModule.test_welcome.value')
        if [ "$AR_WELCOME" = "Welcome Updated!" ]; then
            print_success "Merge updated outdated key (version comparison works)"
        else
            print_error "Merge did not update outdated key (got: $AR_WELCOME)"
        fi
    else
        print_error "Merge sync failed"
    fi

    # Test 10: Validate command
    print_header "Test 10: Validate Command"
    if $CLI_PATH validate --project-path "$TEST_DIR" --language ar > /dev/null 2>&1; then
        print_success "Validate command passed"
    else
        print_error "Validate command failed"
    fi

    # Test 11: Diff command (terminal output)
    print_header "Test 11: Diff Command"
    DIFF_OUTPUT=$($CLI_PATH diff --project-path "$TEST_DIR" --language ar 2>&1)
    if echo "$DIFF_OUTPUT" | grep -q "Diff: ar.json"; then
        print_success "Diff command generates terminal output"
    else
        print_error "Diff command output format incorrect"
    fi

    # Test 12: Merge --all flag
    print_header "Test 12: Merge --all Flag"

    # Create another language file manually
    cat "$TEST_DIR/Translations/ar.json" | jq '.language = "bn"' > "$TEST_DIR/Translations/bn.json"

    if $CLI_PATH merge --project-path "$TEST_DIR" --all > /dev/null 2>&1; then
        # Check that both ar and bn were processed
        AR_VERSION_AFTER=$(cat "$TEST_DIR/Translations/ar.json" | jq -r '.version')
        BN_VERSION_AFTER=$(cat "$TEST_DIR/Translations/bn.json" | jq -r '.version')

        if [ "$AR_VERSION_AFTER" = "3" ] && [ "$BN_VERSION_AFTER" = "3" ]; then
            print_success "Merge --all updated all language files"
        else
            print_error "Merge --all did not update all files correctly"
        fi
    else
        print_error "Merge --all failed"
    fi

    # Test 13: Validate --all flag
    print_header "Test 13: Validate --all Flag"
    if $CLI_PATH validate --project-path "$TEST_DIR" --all > /dev/null 2>&1; then
        print_success "Validate --all passed"
    else
        print_error "Validate --all failed"
    fi

    # Test 14: Migration command (v1 to v2)
    print_header "Test 14: Migration Command"

    # Create a v1 format file
    mkdir -p "$TEST_DIR/MigrationTest/Translations"
    cat > "$TEST_DIR/MigrationTest/Translations/en.json" <<'EOF'
{
  "version": "1.0.0",
  "language": "en",
  "generatedAt": "2025-01-01T00:00:00Z",
  "modules": {
    "Test": {
      "test_key": {
        "value": "Test Value",
        "type": "simple",
        "comment": "Test comment",
        "metadata": {
          "addedInVersion": "1.0.0",
          "status": "new"
        }
      }
    }
  }
}
EOF

    if $CLI_PATH migrate --project-path "$TEST_DIR/MigrationTest" --base-language en --backup > /dev/null 2>&1; then
        if [ -f "$TEST_DIR/MigrationTest/Translations/base.json" ]; then
            MIGRATED_VERSION=$(cat "$TEST_DIR/MigrationTest/Translations/base.json" | jq -r '.version')
            if [ "$MIGRATED_VERSION" = "1" ]; then
                print_success "Migration command converted v1 to v2 format"
            else
                print_error "Migrated version is $MIGRATED_VERSION (expected 1)"
            fi

            # Check backup was created
            if [ -d "$TEST_DIR/MigrationTest/Translations.backup" ]; then
                print_success "Migration created backup"
            else
                print_error "Migration did not create backup"
            fi
        else
            print_error "Migration did not create base.json"
        fi
    else
        print_error "Migration command failed"
    fi

    # Test 15: Format specifier preservation
    print_header "Test 15: Format Specifier Preservation"
    GREETING_VALUE=$(cat "$TEST_DIR/Translations/base.json" | jq -r '.modules.TestModule.test_greeting.value' 2>/dev/null)
    if echo "$GREETING_VALUE" | grep -q '%@'; then
        print_success "Format specifiers preserved (%@ found)"
    else
        print_error "Format specifiers NOT preserved"
    fi

    # Test 16: Plural forms preservation
    print_header "Test 16: Plural Forms Preservation"
    PLURAL_VALUE=$(cat "$TEST_DIR/Translations/base.json" | jq '.modules.TestModule.test_items_count.value' 2>/dev/null)
    if echo "$PLURAL_VALUE" | jq -e '.zero' > /dev/null 2>&1; then
        print_success "Plural forms preserved (zero, one, other)"
    else
        print_error "Plural forms NOT preserved"
    fi

    # Final summary
    print_header "Test Summary"
    TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"

    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}Failed: $TESTS_FAILED${NC}"
        echo ""
        echo "Test artifacts available at: $TEST_DIR"
        echo "Run 'ls -la $TEST_DIR' to inspect"
        exit 1
    else
        echo -e "${GREEN}All tests passed! ✅${NC}"
        exit 0
    fi
}

# Run main function
main
