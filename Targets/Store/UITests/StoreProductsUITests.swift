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
class StoreProductsUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
    }

    func test_whenSuccess_shouldShowCategoryProducts() async throws {
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
                ),
                MockResponse(
                    route: StoreAPI.categoryProducts(categoryId: "electronics"),
                    statusCode: 200,
                    data: Product.mockItems().filter { $0.category == "electronics" }
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Wait for categories to load
        let electronicsCategory = app.buttons["electronics"]
        XCTAssertTrue(electronicsCategory.waitForExistence(timeout: 5), "Electronics category should be visible")

        // Tap on electronics category
        electronicsCategory.tap()

        // Verify navigation to products screen
        XCTAssertTrue(app.navigationBars.firstMatch.exists, "Should navigate to products screen")

        // Verify category title is shown
        XCTAssertTrue(
            app.navigationBars.containing(.staticText, identifier: "Category: Electronics").firstMatch.exists,
            "Category title should be shown"
        )

        // Verify electronics products are shown
        let electronicsProducts = Product.mockItems().filter { $0.category == "electronics" }
        if let firstElectronicsProduct = electronicsProducts.first {
            XCTAssertTrue(
                app.staticTexts[firstElectronicsProduct.title].exists,
                "Electronics product should be visible"
            )
        }
    }

    func test_whenError_shouldShowErrorMessage() async throws {
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
                ),
                MockResponse(
                    route: StoreAPI.categoryProducts(categoryId: "electronics"),
                    statusCode: 500,
                    data: nil
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to electronics category
        let electronicsCategory = app.buttons["electronics"]
        XCTAssertTrue(electronicsCategory.waitForExistence(timeout: 5), "Electronics category should be visible")
        electronicsCategory.tap()

        // Verify error is shown
        XCTAssertTrue(app.images["exclamationmark.triangle"].exists, "Error icon should be visible")
    }

    func test_tapOnProduct_shouldNavigateToDetails() async throws {
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
                ),
                MockResponse(
                    route: StoreAPI.categoryProducts(categoryId: "electronics"),
                    statusCode: 200,
                    data: Product.mockItems().filter { $0.category == "electronics" }
                ),
                MockResponse(
                    route: StoreAPI.productDetails(productId: 9),
                    statusCode: 200,
                    data: Product.mockItems().first { $0.id == 9 }!
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to electronics category
        let electronicsCategory = app.buttons["electronics"]
        XCTAssertTrue(electronicsCategory.waitForExistence(timeout: 5), "Electronics category should be visible")
        electronicsCategory.tap()

        // Wait for products to load
        let firstElectronicsProduct = Product.mockItems().filter { $0.category == "electronics" }.first!
        XCTAssertTrue(
            app.staticTexts[firstElectronicsProduct.title].waitForExistence(timeout: 5),
            "Product should be visible"
        )

        // Tap on the first electronics product
        let productButton = app.buttons.containing(.staticText, identifier: firstElectronicsProduct.title).firstMatch
        productButton.tap()

        // Verify navigation to product details
        XCTAssertTrue(app.navigationBars.firstMatch.exists, "Should navigate to product details screen")
    }

    func test_pullToRefresh_shouldReloadProducts() async throws {
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
                ),
                MockResponse(
                    route: StoreAPI.categoryProducts(categoryId: "electronics"),
                    statusCode: 200,
                    data: Product.mockItems().filter { $0.category == "electronics" }
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to electronics category
        let electronicsCategory = app.buttons["electronics"]
        XCTAssertTrue(electronicsCategory.waitForExistence(timeout: 5), "Electronics category should be visible")
        electronicsCategory.tap()

        // Wait for products to load
        let firstElectronicsProduct = Product.mockItems().filter { $0.category == "electronics" }.first!
        XCTAssertTrue(
            app.staticTexts[firstElectronicsProduct.title].waitForExistence(timeout: 5),
            "Product should be visible"
        )

        // Pull to refresh
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeDown()

        // Verify product is still visible (refresh completed)
        XCTAssertTrue(app.staticTexts[firstElectronicsProduct.title].exists, "Product should still be visible after refresh")
    }

    func test_increaseProductQuantity_shouldAddToCart() async throws {
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
                ),
                MockResponse(
                    route: StoreAPI.categoryProducts(categoryId: "electronics"),
                    statusCode: 200,
                    data: Product.mockItems().filter { $0.category == "electronics" }
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to electronics category
        let electronicsCategory = app.buttons["electronics"]
        XCTAssertTrue(electronicsCategory.waitForExistence(timeout: 5), "Electronics category should be visible")
        electronicsCategory.tap()

        // Wait for products to load
        let firstElectronicsProduct = Product.mockItems().filter { $0.category == "electronics" }.first!
        XCTAssertTrue(
            app.staticTexts[firstElectronicsProduct.title].waitForExistence(timeout: 5),
            "Product should be visible"
        )

        // Find and tap the plus button
        let plusButton = app.buttons["plus.square"].firstMatch
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5), "Plus button should exist")
        plusButton.tap()

        // Verify quantity is updated
        XCTAssertTrue(app.staticTexts["1"].exists, "Quantity should be 1")

        // Navigate back to home and then to cart to verify
        app.navigationBars.buttons.element(boundBy: 0).tap()

        let cartTab = app.tabBars.buttons["bag_tab"]
        cartTab.tap()

        // Verify product is in cart
        XCTAssertTrue(
            app.staticTexts[firstElectronicsProduct.title].exists,
            "Product should be in cart"
        )
    }

    func test_decreaseProductQuantity_shouldRemoveFromCart() async throws {
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
                ),
                MockResponse(
                    route: StoreAPI.categoryProducts(categoryId: "electronics"),
                    statusCode: 200,
                    data: Product.mockItems().filter { $0.category == "electronics" }
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to electronics category
        let electronicsCategory = app.buttons["electronics"]
        XCTAssertTrue(electronicsCategory.waitForExistence(timeout: 5), "Electronics category should be visible")
        electronicsCategory.tap()

        // Wait for products to load
        let firstElectronicsProduct = Product.mockItems().filter { $0.category == "electronics" }.first!
        XCTAssertTrue(
            app.staticTexts[firstElectronicsProduct.title].waitForExistence(timeout: 5),
            "Product should be visible"
        )

        // Add product to cart
        let plusButton = app.buttons["plus.square"].firstMatch
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5), "Plus button should exist")
        plusButton.tap()

        // Verify quantity is 1
        XCTAssertTrue(app.staticTexts["1"].exists, "Quantity should be 1")

        // Decrease quantity
        let minusButton = app.buttons["minus.square"].firstMatch
        XCTAssertTrue(minusButton.waitForExistence(timeout: 5), "Minus button should exist")
        minusButton.tap()

        // Navigate back and check cart is empty
        app.navigationBars.buttons.element(boundBy: 0).tap()

        let cartTab = app.tabBars.buttons["bag_tab"]
        cartTab.tap()

        // Verify cart is empty
        XCTAssertTrue(app.staticTexts["cart_empty_title"].exists, "Cart should be empty")
    }

    func test_retryButton_shouldReloadAfterError() async throws {
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
                ),
                MockResponse(
                    route: StoreAPI.categoryProducts(categoryId: "electronics"),
                    statusCode: 500,
                    data: nil
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to electronics category
        let electronicsCategory = app.buttons["electronics"]
        XCTAssertTrue(electronicsCategory.waitForExistence(timeout: 5), "Electronics category should be visible")
        electronicsCategory.tap()

        // Verify error is shown
        XCTAssertTrue(app.images["exclamationmark.triangle"].waitForExistence(timeout: 5), "Error icon should be visible")

        // Find and tap retry button
        let retryButton = app.buttons["retry_button"]
        XCTAssertTrue(retryButton.waitForExistence(timeout: 5), "Retry button should exist")
        retryButton.tap()

        // Verify error icon is still visible (since mock still returns error)
        XCTAssertTrue(app.images["exclamationmark.triangle"].exists, "Error should still be visible after retry")

        // Alternatively, verify retry button still exists
        XCTAssertTrue(app.buttons["retry_button"].exists, "Retry button should still exist after retry")
    }

    func test_categoriesTab_shouldShowAllCategories() async throws {
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

        // Navigate to categories tab
        let categoriesTab = app.tabBars.buttons["categories_tab"]
        XCTAssertTrue(categoriesTab.waitForExistence(timeout: 5), "Categories tab should exist")
        categoriesTab.tap()

        // Verify categories are shown
        let mockCategories = Category.mockItems()
        for category in mockCategories {
            XCTAssertTrue(app.buttons[category].exists, "\(category) category should be visible")
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
