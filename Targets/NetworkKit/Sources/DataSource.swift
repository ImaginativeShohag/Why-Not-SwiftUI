//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// This will be use as an entry point for the data sources.
public enum DataSource {
    /// Localization API backend for fetching translations
    /// Uses stub behavior with 1 second delay for realistic development testing
    public nonisolated(unsafe) static let Localization = Backend<LocalizationAPI>(
        isStubbed: true,
        stubBehavior: .delayed(seconds: 1),
        session: NetworkSession.create()
    )
}

