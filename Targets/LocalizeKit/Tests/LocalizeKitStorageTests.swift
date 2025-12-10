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

    func testClearAll() {
        storage.selectedLanguage = "ar"

        storage.clearAll()

        XCTAssertNil(storage.selectedLanguage)
    }

    func testBackwardCompatibility_SameKeysAsPreferences() {
        storage.selectedLanguage = "bn"

        let directValue = mockUserDefaults.string(forKey: "selectedLanguage")
        XCTAssertEqual(directValue, "bn")
    }
}
