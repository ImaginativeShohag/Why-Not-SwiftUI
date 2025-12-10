//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import LocalizeKit
import SwiftUI

struct LanguageSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = LanguageSettingsViewModel()

    init(viewModel: LanguageSettingsViewModel = LanguageSettingsViewModel()) {
        self.viewModel = viewModel
    }

    private var state: UIState<AvailableLanguages> {
        viewModel.state
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if state.isLoading {
                    ProgressView("store_language_loading".localize(default: "Loading languages...", comment: "Loading text while fetching languages"))
                } else if state.isError {
                    ContentUnavailableView(
                        label: {
                            Label(state.getErrorMessage() ?? "Error", systemImage: "exclamationmark.triangle")
                        },
                        actions: {
                            Button("store_retry".localize(default: "Retry", comment: "Retry button text")) {
                                Task {
                                    await viewModel.loadLanguages()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top)
                        }
                    )
                } else if state.hasData {
                    countryListView
                }
            }
            .navigationTitle("store_language_title".localize(default: "Language", comment: "Language settings screen title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("store_done".localize(default: "Done", comment: "Done button text"), role: .close) {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadLanguages()
            }
            .overlay {
                if viewModel.isChangingLanguage {
                    LoadingOverlay(
                        message: "store_language_changing".localize(
                            default: "Changing language...",
                            comment: "Progress message while changing language"
                        )
                    )
                }
            }
            .onLanguageChange()
        }
    }

    @ViewBuilder
    private var countryListView: some View {
        List {
            Section {
                ForEach(viewModel.countries, id: \.self) { country in
                    NavigationLink(destination: languageListView(for: country)) {
                        HStack {
                            Text(country)
                                .font(.body)
                                .foregroundStyle(.primary)

                            Spacer()

                            // Show count badge
                            let languageCount = viewModel.languages(for: country).count
                            Text("\(languageCount)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray5))
                                )
                        }
                    }
                }
            } header: {
                Text.localized(
                    "store_country_select_header",
                    default: "Select Country",
                    comment: "Header for country selection list"
                )
            } footer: {
                Text.localized(
                    "store_country_select_footer",
                    default: "Choose a country to see available languages.",
                    comment: "Footer explaining country selection"
                )
                .font(.footnote)
            }
        }
    }

    @ViewBuilder
    private func languageListView(for country: String) -> some View {
        List {
            Section {
                ForEach(viewModel.languages(for: country)) { language in
                    languageRow(language)
                }
            } header: {
                Text.localized(
                    "store_language_select_header",
                    default: "Select Language",
                    comment: "Header for language selection list"
                )
            } footer: {
                Text.localized(
                    "store_language_select_footer",
                    default: "Choose your preferred language for the app. The interface will be translated immediately.",
                    comment: "Footer explaining language selection"
                )
                .font(.footnote)
            }
        }
        .navigationTitle(country)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.hasPendingChanges() {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        Task {
                            await viewModel.applyPendingLanguageChange()
                        }
                    } label: {
                        Text.localized(
                            "store_apply",
                            default: "Apply",
                            comment: "Apply button text to confirm language change"
                        )
                    }
                    .disabled(viewModel.isChangingLanguage)
                }
            }
        }
    }

    @ViewBuilder
    private func languageRow(_ language: Language) -> some View {
        Button {
            viewModel.selectLanguage(language.code)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.nameLocale)
                        .font(.body)
                        .foregroundStyle(.primary)

                    Text(language.nameEn)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if viewModel.isSelected(language.code) {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                        .font(.body.weight(.semibold))
                }
            }
        }
        .disabled(viewModel.isChangingLanguage)
    }
}

#if DEBUG

#Preview("With Data") {
    LanguageSettingsSheet(
        viewModel: .init(
            forPreview: true,
            isLoading: false,
            isError: false
        )
    )
}

#Preview("Loading") {
    LanguageSettingsSheet(
        viewModel: .init(
            forPreview: true,
            isLoading: true,
            isError: false
        )
    )
}

#Preview("Error") {
    LanguageSettingsSheet(
        viewModel: .init(
            forPreview: true,
            isLoading: false,
            isError: true
        )
    )
}

#endif

private struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .tint(Color.label)

                Text(message)
                    .foregroundStyle(Color.label)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: 200)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

#if DEBUG

#Preview("Loading - Short Message") {
    LoadingOverlay(
        message: "Changing language..."
    )
}

#Preview("Loading - Long Message") {
    LoadingOverlay(
        message: "Please wait while we process your request. This may take a few moments..."
    )
}

#Preview("Loading - On Content") {
    ZStack {
        // Simulated background content
        List(1 ... 20, id: \.self) { item in
            Text("Item \(item)")
        }

        LoadingOverlay(message: "Loading...")
    }
}

#endif
