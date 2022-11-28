//
//  Why_Not_SwiftUIApp.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 8/8/22.
//

import SwiftUI

@main
struct Why_Not_SwiftUIApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    private let trackingService = TrackingService.shared

    var body: some Scene {
        WindowGroup {
            MainScreen()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    print("App State: Background (using NotificationCenter)")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    print("App State: Foreground (using NotificationCenter)")
                }
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
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
