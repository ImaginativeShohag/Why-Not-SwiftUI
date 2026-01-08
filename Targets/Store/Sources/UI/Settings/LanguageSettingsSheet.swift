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
                    ProgressView("language_loading".localize(default: "Loading languages...", comment: "Loading text while fetching languages"))
                } else if state.isError {
                    ContentUnavailableView(
                        label: {
                            Label(state.getErrorMessage() ?? "Error", systemImage: "exclamationmark.triangle")
                        },
                        actions: {
                            Button("retry".localize(default: "Retry", comment: "Retry button text")) {
                                Task {
                                    await viewModel.loadLanguages()
                                }
                            }
                            .accessibilityIdentifier("retry_button")
                            .buttonStyle(.borderedProminent)
                            .padding(.top)
                        }
                    )
                    .accessibilityIdentifier("error_view")
                } else if state.hasData {
                    countryListView
                }
            }
            .navigationTitle("language_title".localize(default: "Language", comment: "Language settings screen title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("done".localize(default: "Done", comment: "Done button text"), role: .close) {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadLanguages()
            }
            .onLanguageChange()
        }
    }

    @ViewBuilder
    private var countryListView: some View {
        List {
            Section {
                ForEach(viewModel.countries, id: \.self) { country in
                    NavigationLink(destination: LanguageListSheet(country: country, viewModel: viewModel)) {
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
                    .accessibilityIdentifier(country)
                }
            } header: {
                Text.localized(
                    "country_select_header",
                    default: "Select Country",
                    comment: "Header for country selection list"
                )
            } footer: {
                Text.localized(
                    "country_select_footer",
                    default: "Choose a country to see available languages.",
                    comment: "Footer explaining country selection"
                )
                .font(.footnote)
            }
        }
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
