//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import SwiftUI

// MARK: - Destination

public extension Destination {
    class AlwaysPopover: BaseDestination {
        override public func getScreen() -> any View {
            AlwaysPopoverScreen()
        }
    }
}

// MARK: - UI

public struct AlwaysPopoverScreen: View {
    @State private var showInfo1: Bool = false
    @State private var showInfo2: Bool = false

    public init() {}

    public var body: some View {
        VStack {
            Button {
                showInfo1 = true
            } label: {
                Text("UIKit Popover")
                Image(systemName: "info")
            }
            .buttonStyle(.borderedProminent)
            .alwaysPopover(isPresented: $showInfo1) {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? (UIScreen.main.bounds.size.width - 16 * 2) : 350)
                    .foregroundColor(Color.white)
                    .background(Color(.systemGray))
            }

            Button {
                showInfo2 = true
            } label: {
                Text("SwiftUI Popover")
                Image(systemName: "info")
            }
            .buttonStyle(.borderedProminent)
            .popover(isPresented: $showInfo2) {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? (UIScreen.main.bounds.size.width - 16 * 2) : 350)
                    .foregroundColor(Color.white)
                    .background(Color(.systemGray))
                    /// From iOS 16.4, we can use following modifier to force `.popover()` to show as "popover" in iOS, same is iPad.
                    /// Before iOS 16.4, default `.popover()` was shown as "sheet" in iOS, but as "popover" in iPad.
                    .presentationCompactAdaptation(.popover)
            }
        }
        .navigationTitle("Always Popover")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AlwaysPopoverScreen()
}
