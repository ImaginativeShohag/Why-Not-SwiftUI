//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct MainScreen: View {
    @StateObject private var mainVM = MainViewModel()

    var body: some View {
        NavigationView {
            List {
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
