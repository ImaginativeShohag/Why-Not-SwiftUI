//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct AccessibilityScreen: View {
    let pictures = [
        "anastasiya-leskova-3p0nSfa5gi8-unsplash",
        "assetsthatslap-4HZQGoFbI1Y-unsplash",
        "jean-philippe-delberghe-75xPHEQBmvA-unsplash",
        "shubham-dhage-_PmYFVygfak-unsplash"
    ]

    let labels = [
        "Food",
        "Colored lines",
        "Gray lines",
        "Pink glass"
    ]

    @State private var selectedPicture = Int.random(in: 0...3)

    var body: some View {
        Image(pictures[selectedPicture])
            .resizable()
            .scaledToFit()
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .onTapGesture {
                selectedPicture = Int.random(in: 0...3)
            }
            .accessibilityLabel(labels[selectedPicture])
            .accessibilityAddTraits(.isButton)
            .accessibilityRemoveTraits(.isImage)
    }
}

struct AccessibilityScreen_Previews: PreviewProvider {
    static var previews: some View {
        AccessibilityScreen()
    }
}
