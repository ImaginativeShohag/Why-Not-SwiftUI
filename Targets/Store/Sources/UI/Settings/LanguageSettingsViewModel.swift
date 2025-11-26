//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import LocalizeKit
import SuperLog

@MainActor
@Observable
final class LanguageSettingsViewModel {
    enum State {
        case loading
        case data
        case error(String)
    }

    var state: State = .loading
    var availableLanguages: [Language] = []
    var selectedLanguage: String = "en"
    var isChangingLanguage: Bool = false

    private let localizationManager = LocalizationManager.shared

    init() {
        // Get current language from manager
        selectedLanguage = localizationManager.currentLanguage
    }

    // MARK: - Preview Initializer

    #if DEBUG
    init(forPreview: Bool, isLoading: Bool = false, isError: Bool = false) {
        if isLoading {
            state = .loading
        } else if isError {
            state = .error("Failed to load languages")
        } else {
            state = .data
            availableLanguages = [
                Language(code: "en", name: "English", nativeName: "English"),
                Language(code: "bn", name: "Bengali", nativeName: "বাংলা"),
                Language(code: "ar", name: "Arabic", nativeName: "العربية")
            ]
            selectedLanguage = "en"
        }
    }
    #endif

    // MARK: - Public Methods

    func loadLanguages() async {
        state = .loading

        await localizationManager.loadAvailableLanguages()

        // Check if we have languages
        if localizationManager.availableLanguages.isEmpty {
            state = .error("No languages available")
            SuperLog.e("No available languages loaded")
        } else {
            availableLanguages = localizationManager.availableLanguages
            selectedLanguage = localizationManager.currentLanguage
            state = .data
            SuperLog.d("Loaded \(availableLanguages.count) languages")
        }
    }

    func changeLanguage(to languageCode: String) async {
        guard languageCode != selectedLanguage else { return }

        SuperLog.d("Changing language to: \(languageCode)")
        isChangingLanguage = true

        await localizationManager.changeLanguage(to: languageCode)

        selectedLanguage = localizationManager.currentLanguage
        isChangingLanguage = false

        SuperLog.d("Language changed to: \(selectedLanguage)")
    }

    func isSelected(_ languageCode: String) -> Bool {
        selectedLanguage == languageCode
    }
}
