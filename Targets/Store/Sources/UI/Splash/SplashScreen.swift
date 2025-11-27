//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import LocalizeKit
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class StoreSplash: BaseDestination {
        override public func getScreen() -> any View {
            SplashScreen()
        }
    }
}

// MARK: - UI

struct SplashScreen: View {
    @State private var viewModel: SplashViewModel

    init(viewModel: SplashViewModel = SplashViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Text.localized(
                    "store_welcome_to",
                    default: "Welcome to",
                    comment: "Splash screen welcome text"
                )
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

                Text.localized(
                    "store_app_name",
                    default: "Store Overflow",
                    comment: "Application name"
                )
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .background {
            BackgroundView()
        }
        .onChange(of: viewModel.nextAction) { _, nextAction in
            if let nextAction {
                switch nextAction {
                case .auth:
                    NavController.shared
                        .navigateTo(
                            Destination.Login(),
                            popUpTo: Destination.StoreSplash.self,
                            inclusive: true
                        )

                case .home:
                    NavController.shared
                        .navigateTo(
                            Destination.Main(),
                            popUpTo: Destination.StoreSplash.self,
                            inclusive: true
                        )
                }
            }
        }
        .task {
            await viewModel.checkNextAction()
        }
        .onLanguageChange()
    }
}

#if DEBUG

#Preview("Splash") {
    NavigationStack {
        SplashScreen(
            viewModel: SplashViewModel(
                forPreview: true
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
                    startRadius: 25,
                    endRadius: 200
                )
                .blendMode(.screen)

                RadialGradient(
                    gradient: Gradient(colors: [.pink.opacity(0.5), .clear]),
                    center: .center,
                    startRadius: 25,
                    endRadius: 200
                )
                .blendMode(.screen)

                RadialGradient(
                    gradient: Gradient(colors: [.mint.opacity(0.5), .clear]),
                    center: .bottomTrailing,
                    startRadius: 25,
                    endRadius: 200
                )
                .blendMode(.screen)
            }
            .ignoresSafeArea()
        }
    }
}
