//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct LabelToggleScreen: View {
    @State var isOn = false

    var body: some View {
        VStack(spacing: 32) {
            Text("Native Toggle")
                .font(.headline)

            Toggle(isOn: $isOn) {}
                .fixedSize()

            Text("Custom Toggle")
                .font(.headline)

            LabelToggle(
                isOn: $isOn
            )
        }
        .padding()
        .navigationTitle("Label Toggle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LabelToggleScreen_Previews: PreviewProvider {
    static var previews: some View {
        LabelToggleScreen()
    }
}
