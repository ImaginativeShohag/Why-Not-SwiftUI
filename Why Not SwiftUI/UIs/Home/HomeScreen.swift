//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            List {
                // MARK: Custom Menu
                HStack {
                    Text(NSLocalizedString("jailbroken-status", comment: "Jailbroken Status"))
                    Spacer()
                    Text(viewModel.isJailBroken ? "Broken" : "Not Broken")
                        .foregroundColor(viewModel.isJailBroken ? Color.red : Color.green)
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
                    NavigationLink {
                        screen.destination
                            .if(screen.showTitle, transform: { view in
                                view.navigationTitle(screen.name)
                            })
                    } label: {
                        Text(screen.name)
                    }
                }
            }
            .navigationTitle("Why Not SwiftUI!")
        }
        .navigationViewStyle(.stack)
        .onAppear {
            //viewModel.getPosts()
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
            .previewDevice("iPhone 14 Pro Max")

        MainScreen()
            .previewDevice("iPad Pro (11-inch) (3rd generation)")
    }
}
