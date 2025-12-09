# LocalizeKit Usage Guide

This guide shows how to use LocalizeKit for runtime localization in your Swift code. It focuses on API usage with practical examples.

## Overview

LocalizeKit provides a simple String extension API for runtime localization. Translations are fetched from a server, cached locally, and fall back to English text embedded in your code.

### Key Features
- **English defaults in code**: No translation keys, actual readable English text
- **Runtime translation**: Fetch translations from server
- **Local caching**: Works offline with cached translations
- **Plural support**: All 6 CLDR plural categories (zero, one, two, few, many, other)
- **String interpolation**: Support for variables in localized strings
- **Observable updates**: UI auto-refreshes when language changes

---

## Basic API

### Simple Localization

Replace hardcoded strings with `.localize()`:

```swift
// Before
Text("Welcome to the Store!")

// After
Text("store_welcome".localize(
    default: "Welcome to the Store!",
    comment: "Greeting shown on store home screen"
))
```

**API Signature:**
```swift
func localize(
    default defaultValue: String,
    comment: String? = nil
) -> String
```

**Parameters:**
- `default`: English text to display if translation not found
- `comment`: Context for translators (helps them understand where/how it's used). Optional, defaults to `nil`

---

### String Interpolation

For strings with variables:

```swift
// Before
Text("Hello, \(userName)!")

// After
Text("store_greeting".localize(
    default: "Hello, %@!",
    comment: "Personal greeting with user's name",
    with: userName
))
```

**API Signature:**
```swift
func localize(
    default defaultValue: String,
    comment: String? = nil,
    with arguments: CVarArg...
) -> String
```

**Format Specifiers:**
- `%@` - String
- `%d` - Integer
- `%f` - Float/Double
- `%.2f` - Float with 2 decimal places

**Multiple Parameters:**
```swift
// Before
Text("Order #\(orderID) contains \(itemCount) items")

// After
Text("store_order_summary".localize(
    default: "Order #%@ contains %d items",
    comment: "Order summary with ID and item count",
    with: orderID, itemCount
))
```

---

### Plural Forms

For strings that change based on count:

```swift
// Before
Text("\(appleCount) apple\(appleCount == 1 ? "" : "s")")

// After
Text("store_apple_count".localize(
    defaultPlural: [
        .zero: "No apples",
        .one: "1 apple",
        .other: "%d apples"
    ],
    comment: "Apple count in shopping cart",
    count: appleCount,
    with: appleCount
))
```

**API Signature:**
```swift
func localize(
    defaultPlural: [PluralCategory: String],
    comment: String? = nil,
    count: Int,
    with arguments: CVarArg...
) -> String
```

**PluralCategory Enum:**
```swift
public enum PluralCategory: String, Codable, CaseIterable {
    case zero   // 0 items
    case one    // 1 item
    case two    // 2 items (used in Arabic, for example)
    case few    // 3-10 items (language specific)
    case many   // 11+ items (language specific)
    case other  // Catch-all (always required)
}
```

---

## Usage Examples

### Example 1: Simple Button Text

```swift
// Before
Button("Add to Cart") {
    addToCart()
}

// After
Button("store_add_to_cart".localize(
    default: "Add to Cart",
    comment: "Button to add product to shopping cart"
)) {
    addToCart()
}
```

---

### Example 2: Welcome Message with Name

```swift
// Before
Text("Welcome back, \(user.fullName)!")

// After
Text("store_welcome_back".localize(
    default: "Welcome back, %@!",
    comment: "Welcome message with user's full name",
    with: user.fullName
))
```

---

### Example 3: Price Display

```swift
// Before
Text("Price: $\(price)")

// After
Text("store_price".localize(
    default: "Price: %@",
    comment: "Product price label",
    with: formattedPrice
))
```

---

### Example 4: Item Count (Plural)

```swift
// Before
if itemCount == 0 {
    Text("Your cart is empty")
} else if itemCount == 1 {
    Text("You have 1 item")
} else {
    Text("You have \(itemCount) items")
}

// After
Text("store_item_count".localize(
    defaultPlural: [
        .zero: "Your cart is empty",
        .one: "You have 1 item",
        .other: "You have %d items"
    ],
    comment: "Cart item count message",
    count: itemCount,
    with: itemCount
))
```

---

### Example 5: Complex Plural with Multiple Categories

For languages like Arabic that use all plural categories:

```swift
// Before
Text("\(days) day\(days == 1 ? "" : "s") remaining")

// After
Text("store_days_remaining".localize(
    defaultPlural: [
        .zero: "No days remaining",
        .one: "1 day remaining",
        .two: "2 days remaining",
        .few: "%d days remaining",
        .many: "%d days remaining",
        .other: "%d days remaining"
    ],
    comment: "Days until order delivery",
    count: days,
    with: days
))
```

**Note:** English only uses `.one` and `.other`, but Arabic translators will use all 6 categories. Always provide at least `.one` and `.other`.

---

### Example 6: Discount Percentage

```swift
// Before
Text("Save \(discount)%")

// After
Text("store_discount".localize(
    default: "Save %d%%",  // %% = literal %
    comment: "Discount percentage",
    with: discount
))
```

---

### Example 7: Multi-Parameter Interpolation

```swift
// Before
Text("Order #\(orderID) - \(itemCount) items - $\(total)")

// After
Text("store_order_details".localize(
    default: "Order #%@ - %d items - %@",
    comment: "Order details with ID, count, and total",
    with: orderID, itemCount, formattedTotal
))
```

---

### Example 8: Conditional Text with Plural

```swift
// Before
Text(itemsInStock > 0 ? "\(itemsInStock) in stock" : "Out of stock")

// After
Text("store_stock_status".localize(
    defaultPlural: [
        .zero: "Out of stock",
        .one: "1 in stock",
        .other: "%d in stock"
    ],
    comment: "Product stock availability",
    count: itemsInStock,
    with: itemsInStock
))
```

---

## Language Change Handling

### Auto-Refresh on Language Change

Add `.onLanguageChange()` to your root view:

```swift
import LocalizeKit

struct StoreModuleView: View {
    var body: some View {
        NavigationStack {
            HomeScreen()
        }
        .onLanguageChange()  // Auto-refreshes when language changes
    }
}
```

This modifier listens to `LocalizationManager` and refreshes the UI when the user changes language.

---

## Best Practices

### 1. Use Meaningful Keys

Prefix keys with module name for organization:

```swift
// Good
"store_welcome"
"store_add_to_cart"
"store_item_count"

// Bad
"welcome"
"button1"
"text"
```

---

### 2. Always Provide English Defaults

Never use empty strings or placeholder text:

```swift
// Good
.localize(default: "Welcome to the Store!", comment: "...")

// Bad
.localize(default: "", comment: "...")
.localize(default: "TODO", comment: "...")
```

---

### 3. Write Helpful Comments

Comments help translators provide accurate translations:

```swift
// Good - Specific context
"store_add_to_cart".localize(
    default: "Add to Cart",
    comment: "Button to add product to shopping cart"
)

// Bad - Vague or missing
"store_add_to_cart".localize(
    default: "Add to Cart"
    // No comment provided - translator has no context
)
```

---

### 4. Always Include `.other` in Plurals

Even if you only need `.one` and `.other` for English, other languages may need more:

```swift
// Good
defaultPlural: [
    .one: "1 item",
    .other: "%d items"
]

// Also good - covers more categories
defaultPlural: [
    .zero: "No items",
    .one: "1 item",
    .two: "2 items",
    .other: "%d items"
]
```

---

### 5. Match Format Specifiers in All Languages

If English uses `%d`, all translations must also use `%d`:

```swift
// English
"store_item_count": "You have %d items"

// Bengali (correct)
"store_item_count": "আপনার %d টি আইটেম আছে"

// Bengali (wrong - missing %d)
"store_item_count": "আপনার আইটেম আছে"
```

---

### 6. Test with Different Languages

Always test your app with multiple languages to ensure:
- Layout handles longer text (e.g., German)
- Right-to-left languages work (e.g., Arabic)
- Plurals work correctly
- Format specifiers are preserved

---

## Common Patterns

### Navigation Titles

```swift
.navigationTitle("store_profile".localize(
    default: "Profile",
    comment: "Profile screen title"
))
```

---

### Alert Messages

```swift
Alert(
    title: Text("store_delete_alert_title".localize(
        default: "Delete Item?",
        comment: "Alert title for item deletion"
    )),
    message: Text("store_delete_alert_message".localize(
        default: "This action cannot be undone.",
        comment: "Alert message for item deletion"
    )),
    primaryButton: .destructive(Text("store_delete".localize(
        default: "Delete",
        comment: "Delete button in alert"
    ))),
    secondaryButton: .cancel(Text("store_cancel".localize(
        default: "Cancel",
        comment: "Cancel button in alert"
    )))
)
```

---

### Form Labels

```swift
VStack(alignment: .leading) {
    Text("store_name_label".localize(
        default: "Name",
        comment: "Name label in form"
    ))
    .font(.caption)
    .foregroundColor(.secondary)

    TextField("", text: $name)
}
```

---

### Empty State Messages

```swift
if items.isEmpty {
    VStack {
        Image(systemName: "cart")
            .font(.system(size: 60))
            .foregroundColor(.gray)

        Text("store_cart_empty".localize(
            default: "Your cart is empty",
            comment: "Empty cart message"
        ))
        .font(.headline)

        Text("store_cart_empty_subtitle".localize(
            default: "Add items from the store",
            comment: "Empty cart subtitle"
        ))
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
}
```

---

## Quick Reference

| Use Case | Method | Example |
|----------|--------|---------|
| Simple text | `.localize(default:comment:)` | `"key".localize(default: "Hello", comment: "...")` |
| With variable | `.localize(default:comment:with:)` | `"key".localize(default: "Hello %@", comment: "...", with: name)` |
| Plural | `.localize(defaultPlural:comment:count:with:)` | `"key".localize(defaultPlural: [.one: "1 item", .other: "%d items"], comment: "...", count: n, with: n)` |

---

## Format Specifier Quick Reference

| Type | Specifier | Example |
|------|-----------|---------|
| String | `%@` | `"Hello, %@!"` → `"Hello, John!"` |
| Integer | `%d` | `"Count: %d"` → `"Count: 5"` |
| Float | `%f` | `"Price: %f"` → `"Price: 19.99"` |
| Float (2 decimals) | `%.2f` | `"Price: %.2f"` → `"Price: 19.99"` |
| Literal % | `%%` | `"Save %d%%"` → `"Save 20%"` |

---

## Troubleshooting

### String Not Translating

**Check:**
1. Is the key extracted? Run `localizekit extract`
2. Is translation uploaded to server?
3. Is device online for first fetch?
4. Check cache: `Library/Caches/translations/`

---

### Format Specifier Errors

If you see incorrect values:
- Ensure specifiers match between languages
- Use correct specifier type (`%@` for String, `%d` for Int)
- Escape literal % as `%%`

---

### Plural Not Working

**Check:**
1. Include `.other` category (required)
2. Pass correct `count` parameter
3. Use `with:` parameter for interpolation
4. Verify translator provided all needed categories

---

## Migration Pattern

When converting existing code, follow this pattern:

```swift
// Step 1: Identify the string
Text("Welcome to the Store!")

// Step 2: Create a key (prefix with module name)
// Key: store_welcome

// Step 3: Replace with localize call
Text("store_welcome".localize(
    default: "Welcome to the Store!",  // Keep original text
    comment: "Greeting shown on store home screen"  // Add context
))

// Step 4: Extract strings
// Run: localizekit extract --project-path .

// Step 5: Translators do their work
// You receive translated JSON files

// Step 6: Upload to server and test
```

---

You now know how to use LocalizeKit in your code. Remember: always provide English defaults and helpful comments for translators.
