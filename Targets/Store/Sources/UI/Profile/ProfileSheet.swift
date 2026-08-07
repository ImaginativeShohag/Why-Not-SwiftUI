//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Kingfisher
import LocalizeKit
import SwiftUI
import NavigationKit

struct ProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ProfileViewModel
    @State private var showSignOutAlert: Bool = false
    @State private var showLanguageSettings: Bool = false
    private let localizationManager = LocalizationManager.shared

    private var currentLanguageDisplay: String {
        return "\(localizationManager.currentCountry) - \(localizationManager.currentLanguageName)"
    }

    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.state {
                case .loading:
                    ProgressView()

                case .error(let message):
                    ContentUnavailableView(
                        label: {
                            Label(message, systemImage: "exclamationmark.triangle")
                        },
                        actions: {
                            Button("retry".localize(
                                default: "Retry",
                                comment: "Retry button text"
                            )) {
                                Task {
                                    await viewModel.getUserDetails()
                                }
                            }
                            .accessibilityIdentifier("retry_button")
                            .buttonStyle(.borderedProminent)
                            .padding(.top)
                        }
                    )

                case .data(let user):
                    VStack {
                        Form {
                            HStack(alignment: .center) {
                                KFImage(URL(string: "https://picsum.photos/seed/\(user.id)/200/200"))
                                    .placeholder {
                                        Image(systemName: "person.crop.circle")
                                            .resizable()
                                            .foregroundStyle(Color(.label).opacity(0.5))
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .clipped()
                            }
                            .frame(maxWidth: .infinity)

                            Section("details".localize(
                                default: "Details",
                                comment: "Profile details section header"
                            )) {
                                LabeledContent(
                                    "name".localize(
                                        default: "Name",
                                        comment: "User name label"
                                    ),
                                    value: user.name.getFullName()
                                )
                                .accessibilityIdentifier("profile_name_\(user.name.getFullName())")

                                LabeledContent(
                                    "username".localize(
                                        default: "Username",
                                        comment: "Username label"
                                    ),
                                    value: user.username
                                )
                                .accessibilityIdentifier("profile_username_\(user.username)")

                                LabeledContent(
                                    "email".localize(
                                        default: "Email",
                                        comment: "Email address label"
                                    ),
                                    value: user.email
                                )
                                .accessibilityIdentifier("profile_email_\(user.email)")

                                LabeledContent(
                                    "phone".localize(
                                        default: "Phone",
                                        comment: "Phone number label"
                                    ),
                                    value: user.phone
                                )
                                .accessibilityIdentifier("profile_phone_\(user.phone)")

                                LabeledContent(
                                    "address".localize(
                                        default: "Address",
                                        comment: "Address label"
                                    ),
                                    value: user.address?.getAddress() ?? "-"
                                )
                            }

                            Section {
                                Button("orders".localize(
                                    default: "Orders",
                                    comment: "Orders button text"
                                )) {
                                    dismiss()

                                    NavController.shared.navigateTo(
                                        Destination.Orders()
                                    )
                                }
                                .accessibilityIdentifier("orders_button")

                                Button {
                                    showLanguageSettings.toggle()
                                } label: {
                                    HStack {
                                        Text("language_settings".localize(
                                            default: "Language Settings",
                                            comment: "Language settings button text"
                                        ))
                                        Spacer()
                                        Text(currentLanguageDisplay)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .accessibilityIdentifier("language_settings_button")
                            }

                            Section {
                                Button("sign_out".localize(
                                    default: "Sign Out",
                                    comment: "Sign out button text"
                                )) {
                                    showSignOutAlert.toggle()
                                }
                                .accessibilityIdentifier("sign_out_button")
                                .tint(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("profile".localize(
                default: "Profile",
                comment: "Profile screen title"
            ))
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.systemGroupedBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("done".localize(
                            default: "Done",
                            comment: "Done button text"
                        ))
                    }
                }
            }
            .refreshable {
                await viewModel.getUserDetails()
            }
            .task {
                await viewModel.getUserDetails()
            }
            .alert(
                "sign_out_alert_title".localize(
                    default: "Sign out from Store?",
                    comment: "Alert title for sign out confirmation"
                ),
                isPresented: $showSignOutAlert) {
                    Button("sign_out".localize(
                        default: "Sign Out",
                        comment: "Sign out confirmation button"
                    ), role: .destructive) {
                        viewModel.signOut()

                        NavController.shared.navigateTo(
                            Destination.Login(),
                            popUpTo: Destination.Main.self,
                            inclusive: true
                        )
                    }
                    .tint(.red)
                }
            .sheet(isPresented: $showLanguageSettings) {
                LanguageSettingsSheet()
            }
            .onLanguageChange()
        }
    }
}

#if DEBUG

#Preview("With Data") {
    ZStack {
        Text("Nothing")
    }
    .sheet(isPresented: .constant(true)) {
        ProfileSheet(
            viewModel: .init(
                forPreview: true,
                isLoading: false,
                isError: false
            )
        )
    }
}

#Preview("With Error") {
    ZStack {
        Text("Nothing")
    }
    .sheet(isPresented: .constant(true)) {
        ProfileSheet(
            viewModel: .init(
                forPreview: true,
                isLoading: false,
                isError: true
            )
        )
    }
}

#Preview("Loading") {
    ZStack {
        Text("Nothing")
    }
    .sheet(isPresented: .constant(true)) {
        ProfileSheet(
            viewModel: .init(
                forPreview: true,
                isLoading: true,
                isError: false
            )
        )
    }
}

#endif
