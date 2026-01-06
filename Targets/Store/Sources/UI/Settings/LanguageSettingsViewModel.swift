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
    var selectedCountry: String?
    var selectedLanguage: String?
    var pendingLanguage: String?
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

        Task { @MainActor in
            selectedCountry = localizationManager.currentCountry
            selectedLanguage = localizationManager.currentLanguage
        }
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

    func selectLanguage(_ language: Language) {
        pendingLanguage = language.code
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
            selectedCountry = localizationManager.currentCountry
            selectedLanguage = localizationManager.currentLanguage
            SuperLog.d("LanguageChangeViewModel: Loaded languages from \(languages.countries.count) countries")

        case .failure(let error):
            state = .error(message: error.localizedDescription)
            SuperLog.e("LanguageChangeViewModel: Failed to load languages - \(error)")
        }
    }

    func changeLanguage(to languageCode: String) async {
        guard languageCode != selectedLanguage else { return }
        guard let language = findLanguage(code: languageCode) else {
            SuperLog.e("LanguageChangeViewModel: Language not found: \(languageCode)")
            return
        }

        SuperLog.d("LanguageChangeViewModel: Changing language to: \(languageCode)")
        isChangingLanguage = true

        // Special case: Default English language doesn't need API call (uses code defaults)
        if languageCode == "en" || languageCode == "en_US" {
            SuperLog.d("LanguageChangeViewModel: Using default English (no API call needed)")
            // Create empty translation file - localize() will use default values
            let emptyTranslation = TranslationFile(modules: [:])
            localizationManager.activateLanguage(languageCode: languageCode, languageName: "English", country: "United States", version: 0, emptyTranslation)
            selectedLanguage = languageCode
            selectedCountry = "United States"
            isChangingLanguage = false
            return
        }

        guard let country = selectedCountry else {
            SuperLog.e("LanguageChangeViewModel: Country not selected")
            isChangingLanguage = false
            return
        }

        // Step 1: Check cache state (version comparison)
        let cacheState = await localizationManager.getCacheState(for: language)

        switch cacheState {
        case .valid(let cachedFile):
            // Cache is valid and version matches - use it directly (instant, no API call)
            SuperLog.d("LanguageChangeViewModel: Using cached translation (v\(cachedFile.version))")
            localizationManager.activateLanguage(languageCode: languageCode, languageName: language.nameLocale, country: country, version: language.version, cachedFile.translationFile)
            selectedLanguage = languageCode

        case .stale(let cachedVersion):
            // Cache exists but version is outdated - fetch fresh from network
            SuperLog.d("LanguageChangeViewModel: Cache stale (v\(cachedVersion)), fetching v\(language.version)")
            await fetchAndCache(languageCode: languageCode, version: language.version, languageName: language.nameLocale, country: country)

        case .missing:
            // No cache exists - fetch from network
            SuperLog.d("LanguageChangeViewModel: No cache found, fetching from network")
            await fetchAndCache(languageCode: languageCode, version: language.version, languageName: language.nameLocale, country: country)

        case .corrupted:
            // Cache file is corrupted - delete and fetch fresh
            SuperLog.w("LanguageChangeViewModel: Cache corrupted, deleting and re-fetching")
            try? await localizationManager.deleteCacheFile(for: languageCode)
            await fetchAndCache(languageCode: languageCode, version: language.version, languageName: language.nameLocale, country: country)
        }

        isChangingLanguage = false
    }

    // MARK: - Private Helpers

    private func fetchAndCache(languageCode: String, version: Int, languageName: String, country: String) async {
        let result = await translationRepository.fetchTranslations(for: languageCode)

        switch result {
        case .success(let translationFile):
            // Cache and activate
            await localizationManager.setTranslations(translationFile, for: languageCode, version: version)
            localizationManager.activateLanguage(languageCode: languageCode, languageName: languageName, country: country, version: version, translationFile)

            selectedLanguage = languageCode
            SuperLog.d("LanguageChangeViewModel: Language changed to \(selectedLanguage ?? "nil"), version: \(version)")

        case .failure(let error):
            // Show error (offline or network issue)
            state = .error(message: error.localizedDescription)
            SuperLog.e("LanguageChangeViewModel: Failed to fetch translations - \(error)")
        }
    }

    private func findLanguage(code: String) -> Language? {
        state.getData()?.allLanguages.first { $0.code == code }
    }

    func isSelected(_ languageCode: String) -> Bool {
        (pendingLanguage ?? selectedLanguage) == languageCode
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
            selectedCountry = "United States"
            selectedLanguage = "en_US"
        }
    }
}

#endif
