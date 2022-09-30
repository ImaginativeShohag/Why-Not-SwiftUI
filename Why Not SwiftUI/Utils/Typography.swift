//
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import SwiftUI

struct Typography: ViewModifier {
    private let fontName: String = "SF Pro Rounded"

    var size: CGFloat
    var weight: Font.Weight

    func body(content: Content) -> some View {
        content
            .font(
                .custom(fontName, size: size)
                    .weight(weight)
            )
    }
}

extension View {
    /// Sets the default font `size` and font `weight` for text in this view. This will automatically set default custom font.
    func fontStyle(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        modifier(Typography(size: size, weight: weight))
    }
}
