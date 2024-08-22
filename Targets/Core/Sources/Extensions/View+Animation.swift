//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

// Inspired from:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-start-an-animation-immediately-after-a-view-appears

public extension View {
    /// Create an immediate animation.
    func animate(
        using animation: Animation = .easeInOut(duration: 1),
        _ action: @escaping () -> Void
    ) -> some View {
        onAppear {
            withAnimation(animation) {
                action()
            }
        }
    }

    /// Create an immediate, looping animation
    func animateForever(
        using animation: Animation = .easeInOut(duration: 1),
        autoreverses: Bool = false,
        _ action: @escaping () -> Void
    ) -> some View {
        let repeated = animation.repeatForever(autoreverses: autoreverses)

        return onAppear {
            withAnimation(repeated) {
                action()
            }
        }
    }
}
