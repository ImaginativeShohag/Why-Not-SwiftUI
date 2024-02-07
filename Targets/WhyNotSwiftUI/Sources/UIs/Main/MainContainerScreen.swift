//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Home
import SwiftUI

struct MainContainerScreen: View {
    @ObservedObject private var navController = NavController.shared
    
    @State public var navStack = [BaseDestination]()

    var body: some View {
        NavigationStack(path: $navStack) {
            HomeScreen()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationDestination(for: BaseDestination.self) { destination in
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
