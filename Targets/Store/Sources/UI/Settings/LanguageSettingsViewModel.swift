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
    var pendingLanguage: String? = nil
    var isChangingLanguage: Bool = false

    private let localizationManager: LocalizationManager
    private let translationRepository: TranslationRepository

    init(
        localizationManager: LocalizationManager = .shared,
        translationRepository: TranslationRepository = TranslationRepository()
    ) {
        self.localizationManager = localizationManager
        self.translationRepository = translationRepository
        selectedLanguage = localizationManager.currentLanguage
    }

    // MARK: - Preview Initializer

    #if DEBUG
    init(forPreview: Bool, isLoading: Bool = false, isError: Bool = false) {
        self.localizationManager = .shared
        self.translationRepository = TranslationRepository()

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

    func selectLanguage(_ languageCode: String) {
        pendingLanguage = languageCode
    }

    func applyPendingLanguageChange() async {
        guard let languageCode = pendingLanguage else { return }
        await changeLanguage(to: languageCode)
        pendingLanguage = nil
    }

    func hasPendingChanges() -> Bool {
        guard let pending = pendingLanguage else { return false }
        return pending != selectedLanguage
    }

    func loadLanguages() async {
        state = .loading

        let result = await translationRepository.fetchAvailableLanguages()

        switch result {
        case .success(let languages):
            localizationManager.setAvailableLanguages(languages)
            availableLanguages = languages
            selectedLanguage = localizationManager.currentLanguage
            state = .data
            SuperLog.d("LanguageSettingsViewModel: Loaded \(languages.count) languages")

        case .failure(let error):
            state = .error(error.localizedDescription)
            SuperLog.e("LanguageSettingsViewModel: Failed to load languages - \(error)")
        }
    }

    func changeLanguage(to languageCode: String) async {
        guard languageCode != selectedLanguage else { return }

        SuperLog.d("LanguageSettingsViewModel: Changing language to: \(languageCode)")
        isChangingLanguage = true

        // Step 1: Fetch translations from repository
        let result = await translationRepository.fetchTranslations(for: languageCode)

        switch result {
        case .success(let translationFile):
            // Step 2: Push translations to LocalizationManager (caches internally)
            await localizationManager.setTranslations(translationFile, for: languageCode)

            // Step 3: Activate the language (loads from cache)
            await localizationManager.changeLanguage(to: languageCode)

            // Step 4: Update ViewModel state
            selectedLanguage = localizationManager.currentLanguage
            SuperLog.d("LanguageSettingsViewModel: Language changed to \(selectedLanguage)")

        case .failure(let error):
            SuperLog.e("LanguageSettingsViewModel: Failed to change language - \(error)")
        }

        isChangingLanguage = false
    }

    func isSelected(_ languageCode: String) -> Bool {
        pendingLanguage ?? selectedLanguage == languageCode
    }
}
