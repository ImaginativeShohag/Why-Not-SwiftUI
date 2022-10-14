//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct SideBarIPadScreen: View {
    @State var selection = 0

    var body: some View {
        NavigationView {
            // List
            List {
                NavigationLink {
                    ColorScreen(color: .red)
                        .edgesIgnoringSafeArea(.top)
                } label: {
                    Label("Red", systemImage: "house.fill")
                }

                NavigationLink {
                    ColorScreen(color: .green)
                        .edgesIgnoringSafeArea(.top)
                } label: {
                    Label("Green", systemImage: "calendar")
                }

                NavigationLink {
                    ColorScreen(color: .blue)
                        .edgesIgnoringSafeArea(.top)
                } label: {
                    Label("Blue", systemImage: "magnifyingglass")
                }

                NavigationLink {
                    ColorScreen(color: .purple)
                        .edgesIgnoringSafeArea(.top)
                } label: {
                    Label("Purple", systemImage: "bell.fill")
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Awesome")

            // Details
            ColorScreen(color: .red)
                .edgesIgnoringSafeArea(.top)
        }
    }
}



struct SideBarIPadScreen_Previews: PreviewProvider {
    static var previews: some View {
        SideBarIPadScreen()
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")

        SideBarIPadScreen()
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
    }
}
