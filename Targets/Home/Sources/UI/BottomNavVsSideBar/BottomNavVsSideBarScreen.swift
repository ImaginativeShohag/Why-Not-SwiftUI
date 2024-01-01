//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

public struct BottomNavVsSideBarScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    BottomNavIOSScreen() {
                        dismiss()
                    }
                } else {
                    SideBarIPadScreen() {
                        dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden()
    }
}

struct BottomNavVsSideBarScreen_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavVsSideBarScreen()
            .previewDevice("iPhone 14 Pro Max")

        BottomNavVsSideBarScreen()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
