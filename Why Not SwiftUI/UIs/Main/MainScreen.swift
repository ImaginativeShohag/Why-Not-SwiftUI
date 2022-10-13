//
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import SwiftUI

struct MainScreen: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
            } else {
                HomeScreen()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSplash = false
            }
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
