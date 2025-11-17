//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NavigationKit
import SwiftUI

public struct HomeScreen: View {
    @State private var viewModel = HomeViewModel()

    public init() {}

    public var body: some View {
        List {
            // MARK: Custom Menu

            HStack {
                Text(NSLocalizedString("jailbroken_status_label", bundle: .module, comment: ""))

                Spacer()

                Text(viewModel.isJailBroken ? NSLocalizedString("jailbroken_status_broken", bundle: .module, comment: "") : NSLocalizedString("jailbroken_status_not_broken", bundle: .module, comment: ""))
                    .foregroundColor(viewModel.isJailBroken ? Color(.systemRed) : Color(.systemGreen))
            }

            // MARK: Custom Menu

            Button {
                fatalError("Hello, Crashed!")
            } label: {
                Text(NSLocalizedString("crash_app_button_title", bundle: .module, comment: ""))
            }
            .foregroundColor(Color.theme.black)

            // MARK: Custom Menu

            Button {
                UNUserNotificationCenter.current().sendDummyNotification()
            } label: {
                Text(NSLocalizedString("push_notification_button_label", bundle: .module, comment: ""))
            }
            .foregroundColor(Color.theme.black)

            // MARK: Screens

            ForEach(Screen.screens) { screen in
                NavigationLink(value: screen.destination) {
                    Text(screen.name.toMarkdown())
                }
                .accessibilityIdentifier(screen.name)
            }
        }
        .fontStyle(size: 16)
        .navigationTitle(NSLocalizedString("home_screen_navigation_title", bundle: .module, comment: ""))
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeScreen()
        }
        .previewDevice("iPhone 14 Pro Max")

        NavigationStack {
            HomeScreen()
        }
        .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
