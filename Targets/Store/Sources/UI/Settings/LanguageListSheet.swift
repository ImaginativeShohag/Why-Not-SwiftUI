//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import LocalizeKit
import SwiftUI

struct LanguageListSheet: View {
    let country: String
    @Bindable var viewModel: LanguageSettingsViewModel

    var body: some View {
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
                    .accessibilityIdentifier("apply_button")
                    .disabled(viewModel.isChangingLanguage)
                }
            }
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
    }

    @ViewBuilder
    private func languageRow(_ language: Language) -> some View {
        Button {
            viewModel.selectLanguage(language)
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
        .accessibilityIdentifier(language.nameLocale)
        .disabled(viewModel.isChangingLanguage)
    }
}

#if DEBUG

#Preview("Bengali Languages") {
    NavigationStack {
        LanguageListSheet(
            country: "Bangladesh",
            viewModel: .init(
                forPreview: true,
                isLoading: false,
                isError: false
            )
        )
    }
}

#Preview("With Pending Changes") {
    let viewModel = LanguageSettingsViewModel(
        forPreview: true,
        isLoading: false,
        isError: false
    )

    NavigationStack {
        LanguageListSheet(
            country: "Bangladesh",
            viewModel: viewModel
        )
        .onAppear {
            viewModel.selectLanguage(Language.init(code: "bn_BD", nameEn: "Bengali", nameLocale: "বাংলা", version: 1))
        }
    }
}

#Preview("With Loading Overlay") {
    let viewModel = LanguageSettingsViewModel(
        forPreview: true,
        isLoading: false,
        isError: false
    )

    NavigationStack {
        LanguageListSheet(
            country: "United Arab Emirates",
            viewModel: viewModel
        )
        .onAppear {
            viewModel.isChangingLanguage = true
        }
    }
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
