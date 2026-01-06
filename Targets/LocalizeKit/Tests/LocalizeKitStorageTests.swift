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

    func testBackwardCompatibility_SameKeysAsPreferences() {
        storage.selectedLanguage = "bn"
        storage.selectedCountry = "Bangladesh"
        storage.selectedLanguageVersion = 12
        storage.selectedLanguageName = "বাংলা"

        let languageValue = mockUserDefaults.string(forKey: "selectedLanguage")
        let countryValue = mockUserDefaults.string(forKey: "selectedCountry")
        let versionValue = mockUserDefaults.integer(forKey: "selectedLanguageVersion")
        let nameValue = mockUserDefaults.string(forKey: "selectedLanguageName")

        XCTAssertEqual(languageValue, "bn")
        XCTAssertEqual(countryValue, "Bangladesh")
        XCTAssertEqual(versionValue, 12)
        XCTAssertEqual(nameValue, "বাংলা")
    }
}
