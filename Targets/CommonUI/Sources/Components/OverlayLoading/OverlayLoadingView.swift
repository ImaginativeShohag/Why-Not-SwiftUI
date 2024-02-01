//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

public struct OverlayLoadingView: View {
    let isPresented: Bool

    public init(isPresented: Bool) {
        self.isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            if isPresented {
                ZStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
            }
        }
        .animation(.default, value: isPresented)
    }
}

struct OverlayLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(1 ..< 5) { _ in
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            OverlayLoadingView(isPresented: true)
        }
    }
}
