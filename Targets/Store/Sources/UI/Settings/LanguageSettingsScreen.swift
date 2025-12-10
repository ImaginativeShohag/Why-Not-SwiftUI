//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import LocalizeKit
import SwiftUI

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
                        Task {
                            if viewModel.hasPendingChanges() {
                                await viewModel.applyPendingLanguageChange()
                            }
                            dismiss()
                        }
                    } label: {
                        if viewModel.hasPendingChanges() {
                            Text.localized(
                                "store_apply",
                                default: "Apply",
                                comment: "Apply button text to confirm language change"
                            )
                            .fontWeight(.semibold)
                        } else {
                            Text.localized(
                                "store_done",
                                default: "Done",
                                comment: "Done button text"
                            )
                        }
                    }
                    .disabled(viewModel.isChangingLanguage)
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
            viewModel.selectLanguage(language.code)
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
