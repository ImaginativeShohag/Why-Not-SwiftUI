//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct CustomSideBarScreen: View {
    @State private var showSideBar = true

    var body: some View {
        NavigationView {
            ZStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)

                SideBar(
                    isPresented: $showSideBar,
                    menuList: .constant(Menu.menuList)
                ) { _ in
                    //
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSideBar.toggle()
                    } label: {
                        Image(systemName: "sidebar.left")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct CustomSideBarScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomSideBarScreen()
            .previewDevice("iPad Pro (11-inch) (3rd generation)")
    }
}
