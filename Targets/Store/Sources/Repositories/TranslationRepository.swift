//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import NetworkKit
import LocalizeKit
import Core
import SuperLog

/// Repository for fetching translation data from the server
/// Handles all network operations for localization
final class TranslationRepository: Sendable {

    /// Fetch available languages from the server
    /// - Returns: Result containing AvailableLanguages (country-grouped) or error
    func fetchAvailableLanguages() async -> Result<AvailableLanguages, Error> {
        SuperLog.d("TranslationRepository: Fetching available languages...")

        let result: ApiResult<AvailableLanguages> = await DataSource.Localization.request(
            on: .availableLanguages
        )

        switch result {
        case .success(let response):
            SuperLog.d("TranslationRepository: Fetched languages from \(response.countries.count) countries")
            return .success(response)

        case .failure(_, let errorMessage, let statusCode):
            SuperLog.e("TranslationRepository: Failed to fetch languages - \(errorMessage) (Status: \(statusCode))")
            return .failure(TranslationError.networkError(message: errorMessage, statusCode: statusCode))
        }
    }

    /// Fetch translation file for a specific language
    /// - Parameter languageCode: Language code (e.g., "en_US", "bn_BD", "ar_AE")
    /// - Returns: Result containing translation file or error
    func fetchTranslations(for languageCode: String) async -> Result<TranslationFile, Error> {
        SuperLog.d("TranslationRepository: Fetching translations for \(languageCode)...")

        let result: ApiResult<TranslationFile> = await DataSource.Localization.request(
            on: .translationFile(languageCode: languageCode)
        )

        switch result {
        case .success(let translationFile):
            SuperLog.d("TranslationRepository: Fetched translations for \(languageCode), version: \(translationFile.version)")
            return .success(translationFile)

        case .failure(_, let errorMessage, let statusCode):
            SuperLog.e("TranslationRepository: Failed to fetch translations - \(errorMessage) (Status: \(statusCode))")
            return .failure(TranslationError.networkError(message: errorMessage, statusCode: statusCode))
        }
    }
}

// MARK: - Translation Errors

/// Errors specific to translation operations
enum TranslationError: LocalizedError {
    case networkError(message: String, statusCode: Int)
    case languageNotAvailable(String)
    case cacheError(String)

    var errorDescription: String? {
        switch self {
        case .networkError(let message, let statusCode):
            return "Network error (\(statusCode)): \(message)"
        case .languageNotAvailable(let code):
            return "Language '\(code)' is not available"
        case .cacheError(let message):
            return "Cache error: \(message)"
        }
    }
}
