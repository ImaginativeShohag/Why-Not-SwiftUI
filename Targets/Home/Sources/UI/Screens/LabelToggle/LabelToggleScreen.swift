//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CommonUI
import Core
import SwiftUI

// MARK: - Destination

public extension Destination {
    class LabelToggle: BaseDestination {
        override public func getScreen() -> any View {
            LabelToggleScreen()
        }
    }
}

// MARK: - UI

public struct LabelToggleScreen: View {
    @State var isOn = false

    public init() {}

    public var body: some View {
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
