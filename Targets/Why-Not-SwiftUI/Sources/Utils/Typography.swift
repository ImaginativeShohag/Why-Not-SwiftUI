//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct Typography: ViewModifier {
    var fontFamily: FontFamily
    var size: CGFloat
    var weight: Font.Weight

    func body(content: Content) -> some View {
        content
            .font(
                .custom(fontFamily.rawValue, size: size)
                    .weight(weight)
            )
    }
}

extension View {
    /// Sets the default font `size` and font `weight` for text in this view. This will automatically set default custom font.
    func fontStyle(
        fontFamily: FontFamily = .sFProRounded,
        size: CGFloat,
        weight: Font.Weight = .regular
    ) -> some View {
        modifier(Typography(fontFamily: fontFamily, size: size, weight: weight))
    }
}

extension Text {
    /// Sets the default font `size` and font `weight` for text in this view. This will automatically set default custom font.
    func fontStyle(
        fontFamily: FontFamily = .sFProRounded,
        size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Text {
        font(
            .custom(fontFamily.rawValue, size: size)
                .weight(weight)
        )
    }
}

// MARK: - Enums

enum FontFamily: String {
    case sFProRounded = "SF Pro Rounded"
    case robotoSlab = "Roboto Slab"
}
