//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import SwiftUI

/// # Resources:
/// - Supporting specific accessibility needs with SwiftUI: https://www.hackingwithswift.com/books/ios-swiftui/supporting-specific-accessibility-needs-with-swiftui
/// - Accessibility Smart Invert: https://useyourloaf.com/blog/accessibility-smart-invert/

struct AccessibilityPreferencesScreen: View {
    /// If this is true, UI should not convey information using color alone
    /// and instead should use shapes or glyphs to convey information.
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    /// If this property's value is true, UI should avoid large animations,
    /// especially those that simulate the third dimension.
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// If this property's value is true, UI (mainly window) backgrounds should
    /// not be semi-transparent; they should be opaque.
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    /// Whether the system preference for Invert Colors is enabled.
    ///
    /// If this property's value is true then the display will be inverted.
    /// In these cases it may be needed for UI drawing to be adjusted to in
    /// order to display optimally when inverted.
    @Environment(\.accessibilityInvertColors) var invertColors

    // MARK: -

    @State private var scale = 1.0

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Accessibility Differentiate Without Color Example")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack {
                    /// We will show an check icon to make it easy to understand the meaning of the button without color.
                    if differentiateWithoutColor {
                        Image(systemName: "checkmark.circle")
                    }

                    Text("Success")
                }
                .padding()
                .background(differentiateWithoutColor ? .black : .green)
                .foregroundColor(.white)
                .clipShape(Capsule())

                Divider()

                // MARK: -

                Group {
                    Text("Accessibility Reduce Transparency Example")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("Hello, World!")
                        .padding()
                        /// Remove the transparency if "Reduce Transparency" is enabled.
                        .background(reduceTransparency ? Color.systemBlack : Color.systemBlack.opacity(0.5))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }

                Divider()

                // MARK: -

                Text("Accessibility Reduce Motion Example")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("Hello, World!")
                    .scaleEffect(scale)
                    .onTapGesture {
                        /// We are using custom method to stop animation.
                        withOptionalAnimation {
                            scale *= 1.5
                        }

                        // Or,
                        //
                        // if reduceMotion {
                        //     scale *= 1.5
                        // } else {
                        //     withAnimation {
                        //         scale *= 1.5
                        //     }
                        // }
                    }
                    /// Set the element type for accessibility. So AX tools will think this is a "Button".
                    .accessibilityAddTraits(.isButton)
                    /// Set custom hint for AX tools.
                    .accessibilityHint("Double tap to increase the text size.")

                Divider()

                // MARK: -

                Text("Accessibility Reduce Motion Example")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                /// This image will be inverted if **Smart Invert** enabled.
                Image("anastasiya-leskova-3p0nSfa5gi8-unsplash")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .contentShape(Rectangle())

                Image("anastasiya-leskova-3p0nSfa5gi8-unsplash")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .contentShape(Rectangle())
                    /// Now **Smart Invert** will not invert this image.
                    .accessibilityIgnoresInvertColors()
            }
        }
        .navigationTitle("Accessibility Preferences")
    }
}

#Preview("Accessibility Preferences") {
    NavigationStack {
        AccessibilityPreferencesScreen()
    }
}

// MARK: - Global methods

/// Only animate if "Reduce Motion" is disabled.
func withOptionalAnimation<Result>(_ animation: Animation? = .default, _ body: () throws -> Result) rethrows -> Result {
    if UIAccessibility.isReduceMotionEnabled {
        return try body()
    } else {
        return try withAnimation(animation, body)
    }
}
