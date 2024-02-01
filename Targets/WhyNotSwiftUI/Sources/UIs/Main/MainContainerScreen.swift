//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Home
import SwiftUI

struct MainContainerScreen: View {
    @ObservedObject private var navController = NavController.shared

    var body: some View {
        NavigationStack(path: $navController.navStack) {
            HomeScreen()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationDestination(for: Destination.self) { destination in
                    DestinationMapper.getScreen(destination: destination)
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
