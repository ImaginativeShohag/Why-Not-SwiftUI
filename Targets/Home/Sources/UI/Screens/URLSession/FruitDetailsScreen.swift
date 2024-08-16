//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct FruitDetailsScreen: View {
    let icon: String
    let name: String
    let color: Color

    var body: some View {
        VStack {
            Text(icon)
                .fontStyle(size: 150)

            Text(name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Rectangle().fill(color.gradient.opacity(0.25))
        }
        .ignoresSafeArea()
    }
}

#Preview("Fruit Details Screen") {
    FruitDetailsScreen(
        icon: "🥭",
        name: "Mango",
        color: Color.red
    )
}
