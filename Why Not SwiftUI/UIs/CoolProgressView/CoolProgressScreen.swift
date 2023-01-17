//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct CoolProgressScreen: View {
    var body: some View {
        VStack(spacing: 32) {
            VStack {
                ProgressView(value: 0, total: 1.0)
                CoolProgressView(value: 0, total: 1.0)
            }

            VStack {
                ProgressView(value: 0.25, total: 1.0)
                CoolProgressView(value: 0.25, total: 1.0)
            }

            VStack {
                ProgressView(value: 0.5, total: 1.0)
                    .accentColor(Color(.systemRed))
                CoolProgressView(value: 0.5, total: 1.0)
                    .accentColor(Color(.systemRed))
            }

            VStack {
                ProgressView(value: 0.75, total: 1.0)
                CoolProgressView(value: 0.75, total: 1.0)
            }

            VStack {
                ProgressView(value: 100, total: 100)
                CoolProgressView(value: 100, total: 100)
            }

            CoolProgressView(value: 50, total: 100, height: 16)
                .cornerRadius(8)
                .padding(.horizontal)
        }
        .accentColor(Color(.systemMint))
    }
}

struct CoolProgressScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoolProgressScreen()
    }
}
