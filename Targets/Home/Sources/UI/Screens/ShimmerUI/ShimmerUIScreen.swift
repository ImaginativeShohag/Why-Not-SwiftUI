//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
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
                Text("Components")
            }

            NavigationLink {
                ShimmerUIDemo1()
            } label: {
                Text("Demo 1")
            }

            NavigationLink {
                ShimmerUIDemo2()
            } label: {
                Text("Demo 2")
            }

            NavigationLink {
                ShimmerUIDemo3()
            } label: {
                Text("Demo 3")
            }
        }
        .buttonStyle(.borderedProminent)
        .navigationTitle("ShimmerUI")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ShimmerUIScreen()
    }
}
