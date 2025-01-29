//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class StoreLogin: BaseDestination {
        override public func getScreen() -> any View {
            LoginScreen()
        }
    }
}

// MARK: - UI

struct LoginScreen: View {
    @State private var viewModel: LoginViewModel

    @State private var username: String = "johnd"
    @State private var password: String = "m38rmF$"

    init(viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Welcome to")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("Store Overflow")
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
                        Text("Username")
                            .font(.footnote)
                            .foregroundStyle(.gray)

                        TextField("Username", text: $username)
                    }
                    .padding()
                    .background(Color.tertiarySystemGroupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password")
                            .font(.footnote)
                            .foregroundStyle(.gray)

                        TextField("Password", text: $password)
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
                                Text("Login")
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
        .navigationTitle("Store Overflow")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.state) { _, newState in
            if let state = newState, state.getData() == true {
                NavController.shared
                    .navigateTo(
                        Destination.StoreHome(),
                        popUpTo: Destination.StoreLogin.self,
                        inclusive: true
                    )
            }
        }
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

struct BackgroundView: View {
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
