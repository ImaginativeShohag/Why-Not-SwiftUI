//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI
import Home
import SwiftMacros

@main
struct Why_Not_SwiftUIApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    private let trackingService = TrackingService.shared
    
    /// Just testing custom `Macro`. Nothing else. Ignore.
    let url = #URL("https://imaginativeworld.org")

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
