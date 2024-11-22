//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Home
import SwiftUI

@MainActor
struct MainContainerScreen: View {
    @Bindable private var navController = NavController.shared

    var body: some View {
        NavigationStack(path: $navController.navStack) {
            HomeScreen()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationDestination(for: BaseDestination.self) { destination in
                    AnyView(destination.getScreen())
                }
                .onChange(of: navController.navStack) {
                    SuperLog.v("navStack: \(navController.navStack)")
                }
        }
    }
}

#Preview {
    MainContainerScreen()
}
