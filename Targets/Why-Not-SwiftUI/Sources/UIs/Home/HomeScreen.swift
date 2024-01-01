//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import SwiftUI

struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        List {
            // MARK: Custom Menu

            HStack {
                Text(NSLocalizedString("jailbroken-status", comment: "Jailbroken Status"))

                Spacer()

                Text(viewModel.isJailBroken ? "Broken" : "Not Broken")
                    .foregroundColor(viewModel.isJailBroken ? Color(.systemRed) : Color(.systemGreen))
            }

            // MARK: Custom Menu

            Button {
                fatalError("Hello, Crashed!")
            } label: {
                Text("Crash App 💥")
            }
            .foregroundColor(Color.theme.black)

            // MARK: Custom Menu

            Button {
                UNUserNotificationCenter.current().sendDummyNotification()
            } label: {
                Text("Push Notification 🔔")
            }
            .foregroundColor(Color.theme.black)

            // MARK: Screens

            ForEach(Screen.screens) { screen in
                NavigationLink(value: screen.destination) {
                    Text(screen.name)
                }
            }
        }
        .fontStyle(size: 16)
        .navigationTitle("Why Not SwiftUI!")
        .onAppear {
            // viewModel.getPosts()
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
            .previewDevice("iPhone 14 Pro Max")

        MainScreen()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
