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
class StoreLanguageUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
    }

    func test_openLanguageSettings_shouldShowCountryList() async throws {
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
                    route: StoreAPI.userDetails(userId: 1),
                    statusCode: 200,
                    data: StoreUser.mockItem()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Wait for products to load first to ensure Home screen is fully ready
        XCTAssertTrue(app.waitForElement(matching: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops", timeout: 5))

        // Open profile sheet
        let profileButton = app.buttons["profile_button"]
        if profileButton.waitForExistence(timeout: 5) {
            profileButton.tap()

            // Wait for profile sheet to appear by checking for navigation title
            XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5), "Profile sheet should appear")

            // Tap on Language Settings
            let languageSettingsButton = app.buttons["language_settings_button"]
            XCTAssertTrue(languageSettingsButton.waitForExistence(timeout: 5), "Language Settings button should exist")
            languageSettingsButton.tap()

            // Verify country list is shown (wait for data to load)
            XCTAssertTrue(app.staticTexts["Bangladesh"].waitForExistence(timeout: 5), "Bangladesh should be visible")
            XCTAssertTrue(app.staticTexts["United Arab Emirates"].exists, "United Arab Emirates should be visible")
            XCTAssertTrue(app.staticTexts["United States"].exists, "United States should be visible")
        }
    }

    func test_selectCountry_shouldShowLanguageList() async throws {
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
                    route: StoreAPI.userDetails(userId: 1),
                    statusCode: 200,
                    data: StoreUser.mockItem()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to language settings
        navigateToLanguageSettings()

        // Tap on Bangladesh
        let bangladeshText = app.staticTexts["Bangladesh"]
        XCTAssertTrue(bangladeshText.waitForExistence(timeout: 5), "Bangladesh should exist")
        bangladeshText.tap()

        // Verify language list is shown
        XCTAssertTrue(app.staticTexts["বাংলা"].exists, "Bengali (বাংলা) should be visible")
        XCTAssertTrue(app.staticTexts["English"].exists, "English should be visible")
    }

    func test_selectLanguage_shouldShowApplyButton() async throws {
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
                    route: StoreAPI.userDetails(userId: 1),
                    statusCode: 200,
                    data: StoreUser.mockItem()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to language settings
        navigateToLanguageSettings()

        // Select Bangladesh
        let bangladeshText = app.staticTexts["Bangladesh"]
        XCTAssertTrue(bangladeshText.waitForExistence(timeout: 5), "Bangladesh should exist")
        bangladeshText.tap()

        // Select Bengali
        let bengaliText = app.staticTexts["বাংলা"]
        XCTAssertTrue(bengaliText.waitForExistence(timeout: 5), "Bengali should exist")
        bengaliText.tap()

        // Verify Apply button appears in toolbar (language selection uses Apply button, not alert)
        let applyButton = app.buttons["apply_button"]
        XCTAssertTrue(applyButton.waitForExistence(timeout: 5), "Apply button should appear after selecting a language")
    }

    func test_languageCountBadge_shouldShowCorrectCount() async throws {
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
                    route: StoreAPI.userDetails(userId: 1),
                    statusCode: 200,
                    data: StoreUser.mockItem()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to language settings
        navigateToLanguageSettings()

        // Verify Bangladesh has 2 languages
        let bangladeshText = app.staticTexts["Bangladesh"]
        XCTAssertTrue(bangladeshText.waitForExistence(timeout: 5), "Bangladesh should exist")

        // Verify the count badge "2" exists for Bangladesh
        XCTAssertTrue(app.staticTexts["2"].exists, "Bangladesh should show 2 languages badge")

        // Verify United States has 1 language
        let usText = app.staticTexts["United States"]
        XCTAssertTrue(usText.exists, "United States should exist")
        XCTAssertTrue(app.staticTexts["1"].exists, "United States should show 1 language badge")
    }

    func test_whenLanguageLoadingError_shouldShowError() async throws {
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
                    route: StoreAPI.userDetails(userId: 1),
                    statusCode: 200,
                    data: StoreUser.mockItem()
                ),
                MockResponse(
                    route: LocalizationAPI.availableLanguages,
                    statusCode: 500,
                    data: nil
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to language settings
        navigateToLanguageSettings()

        // Verify error is shown by checking for Retry button
        XCTAssertTrue(app.buttons["retry_button"].waitForExistence(timeout: 5), "Retry button should be visible on error")
    }

    func test_retryAfterLanguageLoadingError_shouldReload() async throws {
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
                    route: StoreAPI.userDetails(userId: 1),
                    statusCode: 200,
                    data: StoreUser.mockItem()
                ),
                MockResponse(
                    route: LocalizationAPI.availableLanguages,
                    statusCode: 500,
                    data: nil
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to language settings
        navigateToLanguageSettings()

        // Verify error is shown by checking for Retry button
        let retryButton = app.buttons["retry_button"]
        XCTAssertTrue(retryButton.waitForExistence(timeout: 5), "Retry button should be visible on error")

        // Tap retry button
        retryButton.tap()

        // After retry, error should still be visible since mock returns error
        XCTAssertTrue(app.buttons["retry_button"].waitForExistence(timeout: 5), "Retry button should still be visible after retry")
    }

    func test_closeLanguageSettings_shouldDismissSheet() async throws {
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
                    route: StoreAPI.userDetails(userId: 1),
                    statusCode: 200,
                    data: StoreUser.mockItem()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Navigate to language settings
        navigateToLanguageSettings()

        // Verify language settings sheet is shown by checking navigation title
        let languageNavBar = app.navigationBars["Language"]
        XCTAssertTrue(languageNavBar.waitForExistence(timeout: 5), "Language navigation bar should be visible")

        // Tap Done button in the Language navigation bar
        let doneButton = languageNavBar.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 3), "Done button should exist")
        doneButton.tap()

        // Wait for language settings sheet to dismiss and verify Profile is visible again
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5), "Profile navigation bar should be visible after dismissing Language settings")

        // Wait for language navigation bar to disappear (sheet dismissal animation)
        let languageNavBar2 = app.navigationBars["Language"]
        let dismissed = languageNavBar2.waitForNonExistence(timeout: 5)
        XCTAssertTrue(dismissed, "Language settings should be dismissed")
    }

    func test_profileDetails_shouldShowUserInfo() async throws {
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
                    route: StoreAPI.userDetails(userId: 1),
                    statusCode: 200,
                    data: StoreUser.mockItem()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Open profile sheet
        let profileButton = app.buttons["profile_button"]
        if profileButton.waitForExistence(timeout: 5) {
            profileButton.tap()

            // Wait for profile sheet to appear by checking for navigation title
            XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5), "Profile sheet should appear")

            // Verify user details are shown (wait for data to load)
            let mockUser = StoreUser.mockItem()
            let fullName = mockUser.name.getFullName()

            // Check using predicate to find any descendant containing the text
            let nameElement = app.descendants(matching: .any).containing(NSPredicate(format: "label CONTAINS %@", fullName)).firstMatch
            XCTAssertTrue(nameElement.waitForExistence(timeout: 5), "User name '\(fullName)' should be visible")

            let usernameElement = app.descendants(matching: .any).containing(NSPredicate(format: "label CONTAINS %@", mockUser.username)).firstMatch
            XCTAssertTrue(usernameElement.exists, "Username '\(mockUser.username)' should be visible")

            let emailElement = app.descendants(matching: .any).containing(NSPredicate(format: "label CONTAINS %@", mockUser.email)).firstMatch
            XCTAssertTrue(emailElement.exists, "Email '\(mockUser.email)' should be visible")

            let phoneElement = app.descendants(matching: .any).containing(NSPredicate(format: "label CONTAINS %@", mockUser.phone)).firstMatch
            XCTAssertTrue(phoneElement.exists, "Phone '\(mockUser.phone)' should be visible")
        }
    }

    func test_signOutAlert_shouldAppearWhenSignOutTapped() async throws {
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
                    route: StoreAPI.userDetails(userId: 1),
                    statusCode: 200,
                    data: StoreUser.mockItem()
                )
            ],
            userData: StoreUser.mockItem()
        )
        runAppAndGoToModule()

        // Open profile sheet
        let profileButton = app.buttons["profile_button"]
        if profileButton.waitForExistence(timeout: 5) {
            profileButton.tap()

            // Wait for profile sheet to appear by checking for navigation title
            XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5), "Profile sheet should appear")

            // Scroll down to see Sign Out button
            app.swipeUp()

            // Tap Sign Out button
            let signOutButton = app.buttons["sign_out_button"]
            if signOutButton.exists {
                signOutButton.tap()

                // Verify alert appears
                XCTAssertTrue(app.alerts.firstMatch.exists, "Sign out alert should appear")
            }
        }
    }

    // MARK: - Helper Methods

    private func navigateToLanguageSettings() {
        // Wait for products to load first
        XCTAssertTrue(app.waitForElement(matching: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops", timeout: 5))

        // Open profile sheet
        let profileButton = app.buttons["profile_button"]
        XCTAssertTrue(profileButton.waitForExistence(timeout: 5), "Profile button should exist")
        profileButton.tap()

        // Wait for profile sheet to appear by checking for the navigation title
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5), "Profile sheet should appear")

        // Tap on Language Settings
        let languageSettingsButton = app.buttons["language_settings_button"]
        XCTAssertTrue(languageSettingsButton.waitForExistence(timeout: 5), "Language Settings button should exist")
        languageSettingsButton.tap()

        // Wait for language settings to load
        sleep(1)
    }

    private func runAppAndGoToModule() {
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
