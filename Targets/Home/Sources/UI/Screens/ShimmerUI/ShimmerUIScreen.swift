//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class ShimmerUI: BaseDestination {
        override public func getScreen() -> any View {
            ShimmerUIScreen()
        }
    }
}

// MARK: - UI

public struct ShimmerUIScreen: View {
    public init() {}

    public var body: some View {
        VStack {
            NavigationLink {
                ShimmerUIDemo0()
            } label: {
                Text(NSLocalizedString("components", bundle: .module, comment: ""))
            }

            NavigationLink {
                ShimmerUIDemo1()
            } label: {
                Text(NSLocalizedString("shimmer_ui_demo_1_button_label", bundle: .module, comment: ""))
            }

            NavigationLink {
                ShimmerUIDemo2()
            } label: {
                Text(NSLocalizedString("demo_2_button_label", bundle: .module, comment: ""))
            }

            NavigationLink {
                ShimmerUIDemo3()
            } label: {
                Text(NSLocalizedString("demo_3_button_label", bundle: .module, comment: ""))
            }
        }
        .buttonStyle(.borderedProminent)
        .navigationTitle(NSLocalizedString("shimmer_ui_screen_title", bundle: .module, comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ShimmerUIScreen()
    }
}
