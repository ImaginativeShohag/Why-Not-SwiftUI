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
                    ProgressView("Loading languages...")

                case .error(let message):
                    ContentUnavailableView(
                        label: {
                            Label(message, systemImage: "exclamationmark.triangle")
                        },
                        actions: {
                            Button("Retry") {
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
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
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

                            Text("Changing language...")
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
                Text("Select Language")
            } footer: {
                Text("Choose your preferred language for the app. The interface will be translated immediately.")
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
