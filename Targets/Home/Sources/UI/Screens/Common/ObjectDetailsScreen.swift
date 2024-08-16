//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct ObjectDetailsScreen: View {
    @Namespace private var animation
    let icon: String
    let name: String
    let color: Color

    var body: some View {
        VStack {
            Text(icon)
                .fontStyle(size: 128)
                .multilineTextAlignment(.center)

            Text(name)
                .fontStyle(size: 48, weight: .bold)
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
                .shadow(
                    color: Color.black.opacity(0.75),
                    radius: 1,
                    x: 1,
                    y: 1
                )
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Rectangle().fill(color.gradient.opacity(0.25))
        }
        .ignoresSafeArea()
    }
}

#Preview("Details Screen 1") {
    ObjectDetailsScreen(
        icon: "🥭",
        name: "Mango Mango Mango Mango Mango",
        color: Color.red
    )
}


#Preview("Details Screen 2") {
    ObjectDetailsScreen(
        icon: "🥭",
        name: "Mango Mango Mango Mango Mango",
        color: Color.yellow
    )
}
