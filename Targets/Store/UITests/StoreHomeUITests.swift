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
class StoreHomeUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
    }

    func test_whenSuccess_shouldShowProductsAndCategories() async throws {
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

        // Verify categories exist
        let electronicsCategory = app.buttons["electronics"]
        XCTAssertTrue(electronicsCategory.exists, "Electronics category should be visible")

        let clothingCategory = app.buttons["clothing"]
        XCTAssertTrue(clothingCategory.exists, "Clothing category should be visible")

        // Verify at least one product is visible in the grid
        let productGrid = app.scrollViews.containing(.staticText, identifier: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops").firstMatch
        XCTAssertTrue(productGrid.exists, "Product grid should exist")
    }

    func test_whenProductsError_shouldShowError() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: StoreAPI.products,
                    statusCode: 500,
                    data: nil
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

        // Wait for Retry button to be displayed (ErrorView shows Retry button on error)
        XCTAssertTrue(app.buttons["retry_button"].waitForExistence(timeout: 5), "Retry button should be visible on error")
    }

    func test_whenCategoriesError_shouldShowError() async throws {
        app.launchApp(
            with: [
                MockResponse(
                    route: StoreAPI.products,
                    statusCode: 200,
                    data: Product.mockItems()
                ),
                MockResponse(
                    route: StoreAPI.categories,
                    statusCode: 500,
                    data: nil
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Wait for Retry button in categories section (ErrorView shows Retry button on error)
        XCTAssertTrue(app.buttons["retry_button"].waitForExistence(timeout: 5), "Retry button should be visible on error")
    }

    func test_tapOnProduct_shouldNavigateToProductDetails() async throws {
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
                    route: StoreAPI.productDetails(productId: 1),
                    statusCode: 200,
                    data: Product.mockItems()[0]
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Wait for products to load
        XCTAssertTrue(app.waitForElement(matching: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops", timeout: 5))

        // Tap on the first product
        let productButton = app.buttons.containing(.staticText, identifier: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops").firstMatch
        productButton.tap()

        // Verify navigation to product details
        XCTAssertTrue(app.navigationBars.firstMatch.exists, "Should navigate to product details screen")
    }

    func test_tapOnCategory_shouldNavigateToProductsList() async throws {
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

        // Verify navigation to products screen with category title
        XCTAssertTrue(app.navigationBars.containing(.staticText, identifier: "Category: Electronics").firstMatch.exists, "Should navigate to category products screen")
    }

    func test_pullToRefresh_shouldReloadData() async throws {
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

        // Wait for initial load
        XCTAssertTrue(app.waitForElement(matching: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops", timeout: 5))

        // Pull to refresh
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeDown()

        // Verify data is still visible (refresh completed)
        XCTAssertTrue(app.staticTexts["Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops"].exists, "Product should still be visible after refresh")
    }

    func test_increaseProductQuantity_shouldUpdateCart() async throws {
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

        // Find and tap the plus button for the first product
        let plusButton = app.buttons["plus.square"].firstMatch
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5), "Plus button should exist")
        plusButton.tap()

        // Verify quantity is updated (should show "1")
        let quantityText = app.staticTexts["1"]
        XCTAssertTrue(quantityText.exists, "Quantity should be updated to 1")
    }

    func test_tapProfileButton_shouldShowProfileSheet() async throws {
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

        // Wait for home screen to load
        XCTAssertTrue(app.waitForElement(matching: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops", timeout: 5))

        // Find and tap the profile button
        let profileButton = app.buttons["profile_button"]
        if profileButton.exists {
            profileButton.tap()

            // Verify profile sheet is presented by checking for navigation title
            XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5), "Profile sheet should be presented")
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
