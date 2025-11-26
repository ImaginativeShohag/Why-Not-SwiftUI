import SwiftUI

// MARK: - Localization Observer View Modifier

/// View modifier that refreshes the view when language changes
private struct LocalizationObserverModifier: ViewModifier {
    @State private var localizationManager = LocalizationManager.shared

    func body(content: Content) -> some View {
        content
            .id(localizationManager.currentLanguage) // Force view refresh on language change
    }
}

// MARK: - View Extension

extension View {
    /// Observe language changes and refresh view automatically
    ///
    /// Usage:
    /// ```swift
    /// ContentView()
    ///     .onLanguageChange()
    /// ```
    public func onLanguageChange() -> some View {
        modifier(LocalizationObserverModifier())
    }
}
