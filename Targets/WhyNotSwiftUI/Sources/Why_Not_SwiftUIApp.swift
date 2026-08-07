//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Home
import LocalizeKit
import SwiftMacros
import SwiftUI

@main
struct Why_Not_SwiftUIApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    // Observe LocalizationManager for layout direction changes
    @State private var localizationManager = LocalizationManager.shared

    private let trackingService = TrackingService.shared

    /// Just testing custom `Macro`. Nothing else. Ignore.
    let url = #URL("https://imaginativeworld.org")

    init() {
        configureLocalization()
    }

    private func configureLocalization() {
        LocalizationManager.shared.configure(
            pluralRules: [
                "en": englishPluralRule,
                "bn": bengaliPluralRule,
                "ar": arabicPluralRule,
                "ru": russianPluralRule
            ]
        )
    }

    // MARK: - Plural Rules

    private var englishPluralRule: PluralRule {
        { choice, _ in
            if choice == 0 { return 0 } // zero
            if choice == 1 { return 1 } // one
            return 5 // other
        }
    }

    private var bengaliPluralRule: PluralRule {
        { choice, _ in
            if choice == 0 { return 0 } // zero
            if choice == 1 { return 1 } // one
            return 5 // other
        }
    }

    private var arabicPluralRule: PluralRule {
        { choice, _ in
            if choice == 0 { return 0 } // zero
            if choice == 1 { return 1 } // one
            if choice == 2 { return 2 } // two
            if choice % 100 >= 3 && choice % 100 <= 10 { return 3 } // few
            if choice % 100 >= 11 { return 4 } // many
            return 5 // other
        }
    }

    private var russianPluralRule: PluralRule {
        { choice, _ in
            if choice == 0 { return 4 } // many

            let teen = choice > 10 && choice < 20
            let endsWithOne = choice % 10 == 1

            if !teen && endsWithOne { return 1 } // one
            if !teen && choice % 10 >= 2 && choice % 10 <= 4 { return 3 } // few

            return 4 // many
        }
    }

    var body: some Scene {
        WindowGroup {
            MainScreen()
                .onLanguageChange()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    print("App State: Background (using NotificationCenter)")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    print("App State: Foreground (using NotificationCenter)")
                }
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
                case .background:
                    print("App State: Background")
                case .inactive:
                    print("App State: Inactive")
                case .active:
                    print("App State: Active")
                @unknown default:
                    print("App State: Unknown")
            }
        }
    }
}

/// Just testing custom `Macro`. Nothing else. Ignore.
@StructInit
struct DummyStruct {
    let variable1: String
    let variable2: Int
}
