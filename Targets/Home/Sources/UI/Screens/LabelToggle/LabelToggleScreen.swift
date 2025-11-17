//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CommonUI
import Core
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class LabelToggle: BaseDestination {
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
            Text(NSLocalizedString("native_toggle", bundle: .module, comment: ""))
                .font(.headline)

            Toggle(isOn: $isOn) {}
                .fixedSize()

            Text(NSLocalizedString("custom_toggle", bundle: .module, comment: ""))
                .font(.headline)

            LabelToggle(
                isOn: $isOn
            )
        }
        .padding()
        .navigationTitle(NSLocalizedString("label_toggle", bundle: .module, comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LabelToggleScreen_Previews: PreviewProvider {
    static var previews: some View {
        LabelToggleScreen()
    }
}
