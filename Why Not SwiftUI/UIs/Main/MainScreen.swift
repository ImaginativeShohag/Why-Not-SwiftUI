//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct MainScreen: View {
    @State private var showSplash = false

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
            .previewDevice("iPhone 14 Pro Max")
        
        MainScreen()
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
    }
}
