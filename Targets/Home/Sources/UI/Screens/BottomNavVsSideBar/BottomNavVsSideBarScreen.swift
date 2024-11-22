//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class BottomNavAndSideBar: BaseDestination {
        override public func getScreen() -> any View {
            BottomNavVsSideBarScreen()
        }
    }
}

// MARK: - UI

public struct BottomNavVsSideBarScreen: View {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        ZStack {
            if UIDevice.current.userInterfaceIdiom == .phone {
                BottomNavIOSScreen {
                    dismiss()
                }
            } else {
                SideBarIPadScreen {
                    dismiss()
                }
            }
        }
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
