//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Text("Why Not SwiftUI!")
                .fontStyle(size: 24, weight: .bold)
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
