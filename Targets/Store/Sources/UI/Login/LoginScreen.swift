//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import LocalizeKit
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class Login: BaseDestination {
        override public func getScreen() -> any View {
            LoginScreen()
        }
    }
}

// MARK: - UI

struct LoginScreen: View {
    @State private var viewModel: LoginViewModel

    @State private var username: String = Constant.username
    @State private var password: String = Constant.password

    init(viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text.localized(
                        "store_welcome_to",
                        default: "Welcome to",
                        comment: "Login screen welcome text"
                    )
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                    Text.localized(
                        "store_app_name",
                        default: "Store Overflow",
                        comment: "Application name"
                    )
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                }
                .padding()
                .frame(minHeight: 200)
                .frame(maxWidth: .infinity)
                .background {
                    BackgroundView()
                }

                VStack(spacing: 16) {
                    if let errorMessage = viewModel.state?.getErrorMessage() {
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.yellow.opacity(0.2))

                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.yellow, lineWidth: 2)
                            }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text.localized(
                            "store_username",
                            default: "Username",
                            comment: "Username field label"
                        )
                        .font(.footnote)
                        .foregroundStyle(.gray)

                        TextField(
                            "store_username".localize(default: "Username", comment: "Username field placeholder"),
                            text: $username
                        )
                    }
                    .padding()
                    .background(Color.tertiarySystemGroupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 4) {
                        Text.localized(
                            "store_password",
                            default: "Password",
                            comment: "Password field label"
                        )
                        .font(.footnote)
                        .foregroundStyle(.gray)

                        TextField(
                            "store_password".localize(default: "Password", comment: "Password field placeholder"),
                            text: $password
                        )
                    }
                    .padding()
                    .background(Color.tertiarySystemGroupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Button {
                        Task {
                            await viewModel.login(
                                username: username,
                                password: password
                            )
                        }
                    } label: {
                        HStack {
                            if viewModel.state?.isLoading == true {
                                ProgressView()
                            } else {
                                Text.localized(
                                    "store_login",
                                    default: "Login",
                                    comment: "Login button text"
                                )
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                        .foregroundStyle(Color.white)
                        .tint(Color.white)
                        .fontWeight(.bold)
                        .animation(.default, value: viewModel.state)
                    }
                    .buttonStyle(.plain)
                    .disabled(username.isEmpty || password.isEmpty)
                }
                .padding()
            }
            .disabled(viewModel.state?.isLoading == true)
        }
        .navigationTitle("store_app_name".localize(default: "Store Overflow", comment: "Navigation title"))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.state) { _, newState in
            if let state = newState, state.getData() == true {
                NavController.shared
                    .navigateTo(
                        Destination.Main(),
                        popUpTo: Destination.Login.self,
                        inclusive: true
                    )
            }
        }
        .onLanguageChange()
    }
}

#if DEBUG

#Preview("With Data") {
    NavigationStack {
        LoginScreen(
            viewModel: LoginViewModel(
                forPreview: true,
                isLoading: false,
                isError: false
            )
        )
    }
}

#Preview("With Error") {
    NavigationStack {
        LoginScreen(
            viewModel: LoginViewModel(
                forPreview: true,
                isLoading: false,
                isError: true
            )
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        LoginScreen(
            viewModel: LoginViewModel(
                forPreview: true,
                isLoading: true,
                isError: false
            )
        )
    }
}

#endif

private struct BackgroundView: View {
    var body: some View {
        ZStack {
            // Background layer
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Mesh-like layer of radial gradients
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [.red.opacity(0.5), .clear]),
                    center: .topLeading,
                    startRadius: 10,
                    endRadius: 100
                )
                .blendMode(.screen)

                RadialGradient(
                    gradient: Gradient(colors: [.pink.opacity(0.5), .clear]),
                    center: .center,
                    startRadius: 10,
                    endRadius: 100
                )
                .blendMode(.screen)

                RadialGradient(
                    gradient: Gradient(colors: [.mint.opacity(0.5), .clear]),
                    center: .bottomTrailing,
                    startRadius: 10,
                    endRadius: 100
                )
                .blendMode(.screen)
            }
            .ignoresSafeArea()
        }
    }
}
