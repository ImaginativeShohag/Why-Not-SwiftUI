//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

/// Resources:
/// - Checkout all the blogs under "Accessibility" project from here: https://www.hackingwithswift.com/books/ios-swiftui
/// - https://www.hackingwithswift.com/books/ios-swiftui/supporting-specific-accessibility-needs-with-swiftui

// TODO: #1: Add example for: .accessibilityAddTraits(isSelected ? .isSelected : [])
// https://swiftwithmajid.com/2021/09/01/the-power-of-accessibility-representation-view-modifier-in-swiftui/

struct AccessibilityScreen: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    // MARK: -

    @State private var scale = 1.0

    // MARK: -

    let pictures = [
        "anastasiya-leskova-3p0nSfa5gi8-unsplash",
        "leon-rohrwild-XqJyl5FD_90-unsplash",
        "jean-philippe-delberghe-75xPHEQBmvA-unsplash",
        "shubham-dhage-_PmYFVygfak-unsplash"
    ]

    let labels = [
        "Food",
        "Colored lines",
        "Gray lines",
        "Pink glass"
    ]

    @State private var selectedPicture = Int.random(in: 0...3)

    // MARK: -

    @State private var countValue: Int = 0
    private let countMaxValue = 10
    private let countMinValue = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Group {
                    Text("First, comment out all the 'accessibility*' modifiers, then navigate the screen using VoiceOver. Then uncomment the modifiers and again navigate this screen using VoiceOver. So you will understand the difference.")

                    Divider()
                }

                Group {
                    Text("Custom Label Example")
                        .font(.title)

                    Image(pictures[selectedPicture])
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, minHeight: 250, maxHeight: 250)
                        .onTapGesture {
                            selectedPicture = Int.random(in: 0...3)
                        }
                        .accessibilityLabel("Image")
                        .accessibilityValue(labels[selectedPicture])
                        .accessibilityHint("Double tap to change the image.")
                        .accessibilityAddTraits(.isButton)
                        .accessibilityRemoveTraits(.isImage)

                    Divider()
                }

                // MARK: -

                Group {
                    Text("Ignored Image Example")
                        .font(.title)

                    Image(decorative: "anastasiya-leskova-3p0nSfa5gi8-unsplash")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, minHeight: 250, maxHeight: 250)
                        .clipped()

                    Divider()
                }

                // MARK: -

                Group {
                    Text("Ignored Element Example")
                        .font(.title)

                    Text("Ignored Element")
                        .accessibilityHidden(true)

                    Divider()
                }

                // MARK: -

                Group {
                    Text("Combine Complex Elements Example")
                        .font(.title)

                    VStack {
                        Text("Your score is")
                        Text("1000")
                            .font(.title)
                    }
                    .accessibilityElement(children: .combine)

                    Divider()
                }

                // MARK: -

                Group {
                    Text("Custom Label for Complex Elements Example")
                        .font(.title)

                    VStack {
                        Text("Your score is")
                        Text("1000")
                            .font(.title)
                    }
                    .accessibilityElement(children: .ignore) // Or: accessibilityElement()
                    .accessibilityLabel("Your score is 1000")

                    Divider()
                }

                // MARK: -

                Group {
                    Text("Custom Action Example")
                        .font(.title)

                    VStack {
                        Text("Item: \(countValue) piece\(countValue <= 1 ? "" : "s")")

                        Button("Increment") {
                            countValue += 1
                        }

                        Button("Decrement") {
                            countValue -= 1
                        }
                    }
                    .accessibilityElement()
                    .accessibilityLabel("Value")
                    .accessibilityValue("\(countValue) piece\(countValue <= 1 ? "" : "s")")
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment:
                            if countValue < countMaxValue {
                                countValue += 1
                            }
                        case .decrement:
                            if countValue > countMinValue {
                                countValue -= 1
                            }
                        default:
                            return
                        }
                    }

                    Divider()
                }

                // MARK: -

                Group {
                    Text("Accessibility Differentiate Without Color Example")
                        .font(.title)

                    HStack {
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

                    Text("Accessibility Reduce Motion Example")
                        .font(.title)

                    Text("Hello, World!")
                        .scaleEffect(scale)
                        .onTapGesture {
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

                    Divider()

                    // MARK: -

                    Text("Accessibility Reduce Transparency Example")
                        .font(.title)

                    Text("Hello, World!")
                        .padding()
                        .background(reduceTransparency ? .black : .black.opacity(0.5))
                        .foregroundColor(.white)
                        .clipShape(Capsule())

                    Divider()
                }
            }
            .padding()
            .multilineTextAlignment(.center)
        }
    }
}

struct AccessibilityScreen_Previews: PreviewProvider {
    static var previews: some View {
        AccessibilityScreen()
    }
}

// MARK: - Global methods

func withOptionalAnimation<Result>(_ animation: Animation? = .default, _ body: () throws -> Result) rethrows -> Result {
    if UIAccessibility.isReduceMotionEnabled {
        return try body()
    } else {
        return try withAnimation(animation, body)
    }
}
