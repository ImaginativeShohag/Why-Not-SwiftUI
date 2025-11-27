//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI
import LocalizeKit

struct LanguageSettingsScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = LanguageSettingsViewModel()

    init(viewModel: LanguageSettingsViewModel = LanguageSettingsViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.state {
                case .loading:
                    ProgressView("store_language_loading".localize(default: "Loading languages...", comment: "Loading text while fetching languages"))

                case .error(let message):
                    ContentUnavailableView(
                        label: {
                            Label(message, systemImage: "exclamationmark.triangle")
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

                case .data:
                    languageListView
                }
            }
            .navigationTitle("store_language_title".localize(default: "Language", comment: "Language settings screen title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text.localized(
                            "store_done",
                            default: "Done",
                            comment: "Done button text"
                        )
                    }
                }
            }
            .task {
                await viewModel.loadLanguages()
            }
            .overlay {
                if viewModel.isChangingLanguage {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(.white)

                            Text.localized(
                                "store_language_changing",
                                default: "Changing language...",
                                comment: "Progress message while changing language"
                            )
                                .foregroundStyle(.white)
                                .font(.subheadline)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
            }
            .onLanguageChange()
        }
    }

    @ViewBuilder
    private var languageListView: some View {
        List {
            Section {
                ForEach(viewModel.availableLanguages) { language in
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
    }

    @ViewBuilder
    private func languageRow(_ language: Language) -> some View {
        Button {
            Task {
                await viewModel.changeLanguage(to: language.code)
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.nativeName)
                        .font(.body)
                        .foregroundStyle(.primary)

                    Text(language.name)
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
    LanguageSettingsScreen(
        viewModel: .init(
            forPreview: true,
            isLoading: false,
            isError: false
        )
    )
}

#Preview("Loading") {
    LanguageSettingsScreen(
        viewModel: .init(
            forPreview: true,
            isLoading: true,
            isError: false
        )
    )
}

#Preview("Error") {
    LanguageSettingsScreen(
        viewModel: .init(
            forPreview: true,
            isLoading: false,
            isError: true
        )
    )
}

#endif
