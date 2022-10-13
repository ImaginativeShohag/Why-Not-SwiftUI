//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct MainScreen: View {
    @StateObject private var mainVM = MainViewModel()

    var body: some View {
        NavigationView {
            List {
                HStack {
                    Text("Jailbroken Status")
                    Spacer()
                    Text(mainVM.isJailBroken ? "Broken" : "Not Broken")
                        .foregroundColor(mainVM.isJailBroken ? Color.red : Color.green)
                }

                ForEach(Screen.screens) { screen in
                    NavigationLink {
                        screen.destination
                            .navigationTitle(screen.name)
                    } label: {
                        Text(screen.name)
                    }
                }
            }
            .navigationTitle("Why Not SwiftUI!")
        }
        .onAppear {
            mainVM.getPosts()
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
