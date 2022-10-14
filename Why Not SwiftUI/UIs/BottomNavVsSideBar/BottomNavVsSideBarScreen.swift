//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct BottomNavVsSideBarScreen: View {
    var body: some View {
        NavigationView {
            ZStack {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    BottomNavIOSScreen()
                } else {
                    SideBarIPadScreen()
                }
            }
            .navigationTitle("")
            .statusBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}

struct BottomNavVsSideBarScreen_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavVsSideBarScreen()
            .previewDevice("iPhone 14 Pro Max")

        BottomNavVsSideBarScreen()
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
    }
}
