//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import LocalizeKit
import NetworkKit
import SuperLog

@MainActor
@Observable
class SplashViewModel {
    private let translationRepository: TranslationRepository
    var nextAction: SplashNextAction?

    private var isPreview: Bool = false

    init(
        translationRepository: TranslationRepository = TranslationRepository()
    ) {
        self.translationRepository = translationRepository
    }

    func checkNextAction() async {
        guard !isPreview else { return }

        // Load and apply user's selected language
        await loadAndApplyUserLanguage()
        
        // Skip delay in UI test mode for faster test execution
        if !ProcessInfo.processInfo.arguments.contains(uiTestArgEnable) {
            try? await Task.sleep(for: .seconds(1))
        }

        if Preferences.user != nil {
            nextAction = .home
        } else {
            nextAction = .auth
        }
    }

    // MARK: - Language Auto-Loading

    /// Load available languages and auto-apply user's selected language on app startup
    private func loadAndApplyUserLanguage() async {
        let localizationManager = LocalizationManager.shared
        let currentLang = localizationManager.currentLanguage

        // Step 1: Check if current language is English FIRST (before any API call)
        // English uses built-in text from the app, no server translation needed
        if currentLang == "en" || currentLang == "en_US" {
            SuperLog.d("MainViewModel: Current language is English, activating with built-in text (no API call)")

            // Use saved country if available, otherwise default to "United States"
            let country = localizationManager.currentCountry

            // Create empty translation file - localize() will use default values from code
            let emptyTranslation = TranslationFile(modules: [:])
            localizationManager.activateLanguage(languageCode: currentLang, languageName: "English", country: country, version: 0, translationFile: emptyTranslation)
            SuperLog.d("MainViewModel: English language activated (v0, built-in)")
            return
        }

        // Step 2: Fetch available languages from server (only for non-English languages)
        let languagesResult = await translationRepository.fetchAvailableLanguages()

        switch languagesResult {
        case .success(let availableLanguages):
            // Store available languages in LocalizationManager
            localizationManager.setAvailableLanguages(availableLanguages.allLanguages)
            SuperLog.d("MainViewModel: Loaded \(availableLanguages.allLanguages.count) available languages")

            // Step 3: Find the language info from available languages
            guard let language = availableLanguages.allLanguages.first(where: { $0.code == currentLang }) else {
                SuperLog.w("MainViewModel: Current language '\(currentLang)' not found in available languages")
                return
            }

            // Use saved country if available, otherwise default to "United States"
            let country = localizationManager.currentCountry

            // Step 4: Check cache state and apply accordingly
            let cacheState = await localizationManager.getCacheState(for: language)

            switch cacheState {
            case .valid(let cachedFile):
                // Cache is valid - activate immediately
                SuperLog.d("MainViewModel: Using cached translation for \(currentLang) (v\(cachedFile.version))")
                localizationManager.activateLanguage(languageCode: currentLang, languageName: language.nameLocale, country: country, version: language.version, translationFile: cachedFile.translationFile)

            case .stale(let cachedVersion):
                // Cache is outdated - fetch fresh from network
                SuperLog.d("MainViewModel: Cache stale for \(currentLang) (v\(cachedVersion)), fetching v\(language.version)")
                await fetchAndCacheLanguage(languageCode: currentLang, country: country, version: language.version, languageName: language.nameLocale)

            case .missing:
                // No cache - fetch from network
                SuperLog.d("MainViewModel: No cache for \(currentLang), fetching from network")
                await fetchAndCacheLanguage(languageCode: currentLang, country: country, version: language.version, languageName: language.nameLocale)

            case .corrupted:
                // Cache corrupted - delete and re-fetch
                SuperLog.w("MainViewModel: Cache corrupted for \(currentLang), re-fetching")
                try? await localizationManager.deleteCacheFile(for: currentLang)
                await fetchAndCacheLanguage(languageCode: currentLang, country: country, version: language.version, languageName: language.nameLocale)
            }

        case .failure(let error):
            SuperLog.e("MainViewModel: Failed to fetch available languages - \(error)")
            // Don't fail authentication if language loading fails
            // App will continue with default English or cached language
        }
    }

    /// Fetch translations from network and cache them
    private func fetchAndCacheLanguage(languageCode: String, country: String, version: Int, languageName: String) async {
        let localizationManager = LocalizationManager.shared

        let result = await translationRepository.fetchTranslations(for: languageCode)

        switch result {
        case .success(let translationFile):
            // Cache and activate the language
            await localizationManager.setTranslations(translationFile, for: languageCode, version: version)
            localizationManager.activateLanguage(languageCode: languageCode, languageName: languageName, country: country, version: version, translationFile: translationFile)
            SuperLog.d("MainViewModel: Language \(languageCode) fetched and applied (v\(version))")

        case .failure(let error):
            SuperLog.e("MainViewModel: Failed to fetch translations for \(languageCode) - \(error)")
            // App will continue with default English or existing cached language
        }
    }
}

enum SplashNextAction {
    case auth
    case home
}

#if DEBUG

extension SplashViewModel {
    convenience init(
        forPreview: Bool
    ) {
        self.init()

        isPreview = true
    }
}

#endif
