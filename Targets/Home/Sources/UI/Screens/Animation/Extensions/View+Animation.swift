//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

// MARK: - Animatable custom font

// A modifier that animates a font through various sizes.
struct AnimatableCustomFontModifier: ViewModifier, Animatable {
    var name: String
    var size: Double

    var animatableData: Double {
        get { size }
        set { size = newValue }
    }

    func body(content: Content) -> some View {
        content
            .font(.custom(name, size: size))
    }
}

// To make that easier to use, I recommend wrapping
// it in a `View` extension, like this:
extension View {
    func animatableFont(name: String, size: Double) -> some View {
        modifier(AnimatableCustomFontModifier(name: name, size: size))
    }
}

// MARK: - Animatable system font

struct AnimatableSystemFontModifier: ViewModifier, Animatable {
    var size: Double
    var weight: Font.Weight
    var design: Font.Design

    var animatableData: Double {
        get { size }
        set { size = newValue }
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight, design: design))
    }
}

extension View {
    func animatableSystemFont(size: Double, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        modifier(AnimatableSystemFontModifier(size: size, weight: weight, design: design))
    }
}
