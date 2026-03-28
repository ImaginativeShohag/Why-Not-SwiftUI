import XCTest
@testable import LocalizeKit

final class LocalizeKitStorageTests: XCTestCase {

    var storage: LocalizeKitStorage!
    var mockUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "com.localizekit.tests")!
        mockUserDefaults.removePersistentDomain(forName: "com.localizekit.tests")
        storage = LocalizeKitStorage(userDefaults: mockUserDefaults)
    }

    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: "com.localizekit.tests")
        storage = nil
        mockUserDefaults = nil
        super.tearDown()
    }

    // MARK: - Selected Language

    func testSelectedLanguage_InitiallyNil() {
        XCTAssertNil(storage.selectedLanguage)
    }

    func testSelectedLanguage_SetAndGet() {
        storage.selectedLanguage = "bn"
        XCTAssertEqual(storage.selectedLanguage, "bn")
    }

    func testSelectedLanguage_SetToNil() {
        storage.selectedLanguage = "en"
        storage.selectedLanguage = nil
        XCTAssertNil(storage.selectedLanguage)
    }

    // MARK: - Selected Country

    func testSelectedCountry_InitiallyNil() {
        XCTAssertNil(storage.selectedCountry)
    }

    func testSelectedCountry_SetAndGet() {
        storage.selectedCountry = "Bangladesh"
        XCTAssertEqual(storage.selectedCountry, "Bangladesh")
    }

    func testSelectedCountry_SetToNil() {
        storage.selectedCountry = "United States"
        storage.selectedCountry = nil
        XCTAssertNil(storage.selectedCountry)
    }

    // MARK: - Selected Language Version

    func testSelectedLanguageVersion_InitiallyNil() {
        XCTAssertNil(storage.selectedLanguageVersion)
    }

    func testSelectedLanguageVersion_SetAndGet() {
        storage.selectedLanguageVersion = 42
        XCTAssertEqual(storage.selectedLanguageVersion, 42)
    }

    func testSelectedLanguageVersion_SetToNil() {
        storage.selectedLanguageVersion = 10
        storage.selectedLanguageVersion = nil
        XCTAssertNil(storage.selectedLanguageVersion)
    }

    // MARK: - Selected Language Name

    func testSelectedLanguageName_InitiallyNil() {
        XCTAssertNil(storage.selectedLanguageName)
    }

    func testSelectedLanguageName_SetAndGet() {
        storage.selectedLanguageName = "বাংলা"
        XCTAssertEqual(storage.selectedLanguageName, "বাংলা")
    }

    func testSelectedLanguageName_SetToNil() {
        storage.selectedLanguageName = "English"
        storage.selectedLanguageName = nil
        XCTAssertNil(storage.selectedLanguageName)
    }

    // MARK: - Clear All

    func testClearAll() {
        storage.selectedLanguage = "ar"
        storage.selectedCountry = "United Arab Emirates"
        storage.selectedLanguageVersion = 5
        storage.selectedLanguageName = "العربية"

        storage.clearAll()

        XCTAssertNil(storage.selectedLanguage)
        XCTAssertNil(storage.selectedCountry)
        XCTAssertNil(storage.selectedLanguageVersion)
        XCTAssertNil(storage.selectedLanguageName)
    }

    // MARK: - UserDefaults Integration

    func testStorageKeysAreWrittenToUserDefaults() {
        storage.selectedLanguage = "bn"
        storage.selectedCountry = "Bangladesh"
        storage.selectedLanguageVersion = 12
        storage.selectedLanguageName = "বাংলা"

        XCTAssertEqual(mockUserDefaults.string(forKey: "selectedLanguage"), "bn")
        XCTAssertEqual(mockUserDefaults.string(forKey: "selectedCountry"), "Bangladesh")
        XCTAssertEqual(mockUserDefaults.integer(forKey: "selectedLanguageVersion"), 12)
        XCTAssertEqual(mockUserDefaults.string(forKey: "selectedLanguageName"), "বাংলা")
    }

    // MARK: - Default Init

    func testDefaultInitUsesCustomSuite() {
        let key = "selectedLanguage"
        let sentinel = "test_sentinel"

        // Place a known sentinel in .standard so we can verify it stays untouched.
        UserDefaults.standard.set(sentinel, forKey: key)

        let defaultStorage = LocalizeKitStorage()
        defaultStorage.selectedLanguage = "ar"

        // .standard should still hold the sentinel, not the value we wrote
        XCTAssertEqual(UserDefaults.standard.string(forKey: key), sentinel)

        // Cleanup
        defaultStorage.clearAll()
        UserDefaults.standard.removeObject(forKey: key)
    }
}
