//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import LocalizeKit
import SuperLog

@MainActor
@Observable
final class LanguageSettingsViewModel {
    var state: UIState<AvailableLanguages> = .loading
    var selectedCountry: String? = nil
    var selectedLanguage: String = "en"
    var pendingLanguage: String? = nil
    var isChangingLanguage: Bool = false

    private var isPreview: Bool = false
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

    // MARK: - Public Properties

    var countries: [String] {
        state.getData()?.countries ?? []
    }

    func languages(for country: String) -> [Language] {
        state.getData()?.languages(for: country) ?? []
    }

    // MARK: - Public Methods

    func selectCountry(_ country: String) {
        selectedCountry = country
    }

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
        guard !isPreview, !state.hasData else { return }

        state = .loading

        let result = await translationRepository.fetchAvailableLanguages()

        switch result {
        case .success(let languages):
            localizationManager.setAvailableLanguages(languages.allLanguages)
            state = .data(data: languages)
            selectedLanguage = localizationManager.currentLanguage
            SuperLog.d("LanguageSettingsViewModel: Loaded languages from \(languages.countries.count) countries")

        case .failure(let error):
            state = .error(message: error.localizedDescription)
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

#if DEBUG

extension LanguageSettingsViewModel {
    convenience init(
        forPreview: Bool,
        isLoading: Bool,
        isError: Bool
    ) {
        self.init()

        isPreview = true

        if isLoading {
            state = .loading
        } else if isError {
            state = .error(message: "Failed to load languages")
        } else {
            // Create preview data with country grouping
            let previewData: [String: [Language]] = [
                "Bangladesh": [
                    Language(code: "bn_BD", nameEn: "Bengali", nameLocale: "বাংলা", version: 12),
                    Language(code: "en_US", nameEn: "English", nameLocale: "English", version: 4)
                ],
                "United Arab Emirates": [
                    Language(code: "ar_AE", nameEn: "Arabic (U.A.E.)", nameLocale: "العربية", version: 2),
                    Language(code: "en_US", nameEn: "English", nameLocale: "English", version: 4)
                ]
            ]
            state = .data(data: AvailableLanguages(data: previewData))
            selectedLanguage = "en"
        }
    }
}

#endif

