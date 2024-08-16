//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct ObjectDetailsScreen: View {
    let icon: String
    let name: String
    let color: Color

    var body: some View {
        VStack {
            Text(icon)
                .fontStyle(size: 128)

            Text(name)
                .fontStyle(size: 48, weight: .bold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Rectangle().fill(color.gradient.opacity(0.25))
        }
        .ignoresSafeArea()
    }
}

#Preview("Details Screen") {
    ObjectDetailsScreen(
        icon: "🥭",
        name: "Mango",
        color: Color.red
    )
}
