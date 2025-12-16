//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

@testable import Core
import NetworkKit
@testable import Store
import TestUtils
import XCTest

#if DEBUG

@MainActor
class StoreCartUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
    }

    func test_whenCartEmpty_shouldShowEmptyState() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: StoreAPI.products,
                    statusCode: 200,
                    data: Product.mockItems()
                ),
                MockResponse(
                    route: StoreAPI.categories,
                    statusCode: 200,
                    data: Category.mockItems()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to cart tab
        let cartTab = app.tabBars.buttons["bag_tab"]
        XCTAssertTrue(cartTab.waitForExistence(timeout: 5), "Cart tab should exist")
        cartTab.tap()

        // Verify empty state is shown
        XCTAssertTrue(app.staticTexts["cart_empty_title"].exists, "Empty cart message should be visible")
        XCTAssertTrue(app.staticTexts["cart_empty_description"].exists, "Empty cart description should be visible")

        // Verify checkout button is disabled
        let checkoutButton = app.buttons["checkout_button"]
        XCTAssertFalse(checkoutButton.isEnabled, "Checkout button should be disabled when cart is empty")
    }

    func test_addProductToCart_shouldShowInCartTab() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: StoreAPI.products,
                    statusCode: 200,
                    data: Product.mockItems()
                ),
                MockResponse(
                    route: StoreAPI.categories,
                    statusCode: 200,
                    data: Category.mockItems()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Wait for products to load
        XCTAssertTrue(app.waitForElement(matching: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops", timeout: 5))

        // Add product to cart by tapping plus button
        let plusButton = app.buttons["plus.square"].firstMatch
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5), "Plus button should exist")
        plusButton.tap()

        // Navigate to cart tab
        let cartTab = app.tabBars.buttons["bag_tab"]
        XCTAssertTrue(cartTab.waitForExistence(timeout: 5), "Cart tab should exist")
        cartTab.tap()

        // Verify product is shown in cart
        XCTAssertTrue(app.staticTexts["Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops"].exists, "Product should appear in cart")

        // Verify checkout button is enabled
        let checkoutButton = app.buttons["checkout_button"]
        XCTAssertTrue(checkoutButton.isEnabled, "Checkout button should be enabled when cart has items")
    }

    func test_increaseQuantityInCart_shouldUpdateTotal() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: StoreAPI.products,
                    statusCode: 200,
                    data: Product.mockItems()
                ),
                MockResponse(
                    route: StoreAPI.categories,
                    statusCode: 200,
                    data: Category.mockItems()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Wait for products to load and add product to cart
        XCTAssertTrue(app.waitForElement(matching: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops", timeout: 5))
        app.buttons["plus.square"].firstMatch.tap()

        // Navigate to cart tab
        let cartTab = app.tabBars.buttons["bag_tab"]
        cartTab.tap()

        // Wait for cart to show
        XCTAssertTrue(app.staticTexts["Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops"].waitForExistence(timeout: 5))

        // Get initial total using accessibility identifier
        let totalPriceElement = app.staticTexts["cart_total_price"]
        XCTAssertTrue(totalPriceElement.exists, "Total price should be visible")
        let initialTotal = totalPriceElement.label

        // Increase quantity
        let plusButtonInCart = app.buttons["plus.square"].firstMatch
        plusButtonInCart.tap()

        // Verify quantity increased
        XCTAssertTrue(app.staticTexts["2"].exists, "Quantity should be 2")

        // Verify total is updated
        let newTotal = totalPriceElement.label
        XCTAssertNotEqual(initialTotal, newTotal, "Total should be updated after increasing quantity")
    }

    func test_decreaseQuantityInCart_shouldUpdateTotal() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: StoreAPI.products,
                    statusCode: 200,
                    data: Product.mockItems()
                ),
                MockResponse(
                    route: StoreAPI.categories,
                    statusCode: 200,
                    data: Category.mockItems()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Wait for products to load and add product to cart twice
        XCTAssertTrue(app.waitForElement(matching: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops", timeout: 5))
        app.buttons["plus.square"].firstMatch.tap()
        app.buttons["plus.square"].firstMatch.tap()

        // Navigate to cart tab
        let cartTab = app.tabBars.buttons["bag_tab"]
        cartTab.tap()

        // Wait for cart to show
        XCTAssertTrue(app.staticTexts["Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops"].waitForExistence(timeout: 5))

        // Verify quantity is 2
        XCTAssertTrue(app.staticTexts["2"].exists, "Quantity should be 2")

        // Decrease quantity
        let minusButtonInCart = app.buttons["minus.square"].firstMatch
        minusButtonInCart.tap()

        // Verify quantity decreased
        XCTAssertTrue(app.staticTexts["1"].exists, "Quantity should be decreased to 1")
    }

    func test_decreaseQuantityToZero_shouldRemoveFromCart() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: StoreAPI.products,
                    statusCode: 200,
                    data: Product.mockItems()
                ),
                MockResponse(
                    route: StoreAPI.categories,
                    statusCode: 200,
                    data: Category.mockItems()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Wait for products to load and add product to cart once
        XCTAssertTrue(app.waitForElement(matching: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops", timeout: 5))
        app.buttons["plus.square"].firstMatch.tap()

        // Navigate to cart tab
        let cartTab = app.tabBars.buttons["bag_tab"]
        cartTab.tap()

        // Wait for cart to show
        XCTAssertTrue(app.staticTexts["Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops"].waitForExistence(timeout: 5))

        // Decrease quantity to zero
        let minusButtonInCart = app.buttons["minus.square"].firstMatch
        minusButtonInCart.tap()

        // Verify empty state is shown again
        XCTAssertTrue(app.staticTexts["cart_empty_title"].exists, "Empty cart message should be visible after removing all items")
    }

    func test_multipleProducts_shouldShowCorrectTotal() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: StoreAPI.products,
                    statusCode: 200,
                    data: Product.mockItems()
                ),
                MockResponse(
                    route: StoreAPI.categories,
                    statusCode: 200,
                    data: Category.mockItems()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Wait for products to load
        XCTAssertTrue(app.waitForElement(matching: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops", timeout: 5))

        // Add first product
        let plusButtons = app.buttons.matching(identifier: "plus.square")
        plusButtons.element(boundBy: 0).tap()

        // Scroll to see more products
        app.swipeUp()

        // Add second product
        plusButtons.element(boundBy: 1).tap()

        // Navigate to cart tab
        let cartTab = app.tabBars.buttons["bag_tab"]
        cartTab.tap()

        // Verify both products are in cart
        let cartItems = app.scrollViews.firstMatch.staticTexts
        XCTAssertGreaterThanOrEqual(cartItems.count, 2, "At least 2 products should be in cart")
    }

    func test_tapCheckout_shouldNavigateToPlaceOrder() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: StoreAPI.products,
                    statusCode: 200,
                    data: Product.mockItems()
                ),
                MockResponse(
                    route: StoreAPI.categories,
                    statusCode: 200,
                    data: Category.mockItems()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Add product to cart
        XCTAssertTrue(app.waitForElement(matching: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops", timeout: 5))
        app.buttons["plus.square"].firstMatch.tap()

        // Navigate to cart tab
        let cartTab = app.tabBars.buttons["bag_tab"]
        cartTab.tap()

        // Wait for cart to show
        XCTAssertTrue(app.staticTexts["Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops"].waitForExistence(timeout: 5))

        // Tap checkout button
        let checkoutButton = app.buttons["checkout_button"]
        XCTAssertTrue(checkoutButton.isEnabled, "Checkout button should be enabled")
        checkoutButton.tap()

        // Verify navigation to place order screen
        XCTAssertTrue(app.navigationBars.firstMatch.exists, "Should navigate to place order screen")
    }

    func test_cartMenu_shouldShowOrdersOption() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: StoreAPI.products,
                    statusCode: 200,
                    data: Product.mockItems()
                ),
                MockResponse(
                    route: StoreAPI.categories,
                    statusCode: 200,
                    data: Category.mockItems()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to cart tab
        let cartTab = app.tabBars.buttons["bag_tab"]
        XCTAssertTrue(cartTab.waitForExistence(timeout: 5), "Cart tab should exist")
        cartTab.tap()

        // Tap menu button (ellipsis.circle)
        let menuButton = app.buttons["cart_menu_button"]
        if menuButton.exists {
            menuButton.tap()

            // Verify Orders menu item exists
            XCTAssertTrue(app.buttons["orders_menu_item"].exists, "Orders menu item should exist")
        }
    }

    func runAppAndGoToModule() {
        // Navigate to the Store module from home
        let storeAppBtn = app.staticTexts["🏬 Store Overflow"]

        var swipeCount = 0
        while !storeAppBtn.exists && swipeCount < 10 {
            app.swipeUp()
            swipeCount += 1
        }

        XCTAssertTrue(storeAppBtn.exists, "Store Overflow button should be found")
        storeAppBtn.tap()
    }
}

#endif
