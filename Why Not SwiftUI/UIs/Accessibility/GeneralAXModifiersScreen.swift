//
//  GeneralAXModifiers.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 26/09/2023.
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

/// # Resources:
/// - Checkout all the blogs under "Accessibility" project from here: https://www.hackingwithswift.com/books/ios-swiftui
/// - https://www.hackingwithswift.com/books/ios-swiftui/supporting-specific-accessibility-needs-with-swiftui

/// **Note:**
/// - `AX` = Accessibility
/// - `VO` = Voice Over

struct GeneralAXModifiersScreen: View {
    /// If this is true, UI should not convey information using color alone
    /// and instead should use shapes or glyphs to convey information.
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    /// If this property's value is true, UI should avoid large animations,
    /// especially those that simulate the third dimension.
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// If this property's value is true, UI (mainly window) backgrounds should
    /// not be semi-transparent; they should be opaque.
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    // MARK: -

    @State private var scale = 1.0

    @State private var isSelected = false

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

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Group {
                    Text("First, comment out all the '`accessibility*`' modifiers, then navigate the screen using **VoiceOver**. Then uncomment the modifiers and again navigate this screen using VoiceOver. So you will understand the difference.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)

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
                        /// Set custom label for AX tools.
                        .accessibilityLabel("Image")
                        /// Set custom value for AX tools.
                        .accessibilityValue(labels[selectedPicture])
                        /// Set custom hint for AX tools.
                        .accessibilityHint("Double tap to change the image.")
                        /// Set the element type for accessibility. So AX tools will think this is a "Button".
                        .accessibilityAddTraits(.isButton)
                        /// Remove the default view type for accessibility. So AX tools will to think this is a "Image".
                        .accessibilityRemoveTraits(.isImage)

                    Divider()
                }

                // MARK: -

                Group {
                    Text("Custom Traits Example")
                        .font(.title)

                    Text("isButton Trait")
                        /// The accessibility element is a button.
                        .accessibilityAddTraits(.isButton)

                    Text("isHeader Trait")
                        /// The accessibility element is a header that divides content into
                        /// sections, like the title of a navigation bar.
                        .accessibilityAddTraits(.isHeader)

                    Text("isSelected Trait")
                        /// The accessibility element is currently selected.
                        .accessibilityAddTraits(.isSelected)

                    Text("isLink Trait")
                        /// The accessibility element is a link.
                        .accessibilityAddTraits(.isLink)

                    Text("isSearchField Trait")
                        /// The accessibility element is a search field.
                        .accessibilityAddTraits(.isSearchField)

                    Text("isImage Trait")
                        /// The accessibility element is an image.
                        .accessibilityAddTraits(.isImage)

                    Text("playsSound Trait")
                        /// The accessibility element plays its own sound when activated.
                        .accessibilityAddTraits(.playsSound)

                    Text("isKeyboardKey Trait")
                        /// The accessibility element behaves as a keyboard key.
                        .accessibilityAddTraits(.isKeyboardKey)

                    Text("isStaticText Trait")
                        /// The accessibility element is a static text that cannot be
                        /// modified by the user.
                        .accessibilityAddTraits(.isStaticText)

                    Text("isSummaryElement Trait")
                        /// The accessibility element provides summary information when the
                        /// application starts.
                        ///
                        /// Use this trait to characterize an accessibility element that provides
                        /// a summary of current conditions, settings, or state, like the
                        /// temperature in the Weather app.
                        .accessibilityAddTraits(.isSummaryElement)

                    Text("updatesFrequently Trait")
                        /// The accessibility element frequently updates its label or value.
                        ///
                        /// Use this trait when you want an assistive technology to poll for
                        /// changes when it needs updated information. For example, you might use
                        /// this trait to characterize the readout of a stopwatch.
                        .accessibilityAddTraits(.updatesFrequently)

                    Text("startsMediaSession Trait")
                        /// The accessibility element starts a media session when it is activated.
                        ///
                        /// Use this trait to silence the audio output of an assistive technology,
                        /// such as VoiceOver, during a media session that should not be interrupted.
                        /// For example, you might use this trait to silence VoiceOver speech while
                        /// the user is recording audio.
                        .accessibilityAddTraits(.startsMediaSession)

                    Text("allowsDirectInteraction Trait")
                        /// The accessibility element allows direct touch interaction for
                        /// VoiceOver users.
                        .accessibilityAddTraits(.allowsDirectInteraction)

                    Text("causesPageTurn Trait")
                        /// The accessibility element causes an automatic page turn when VoiceOver
                        /// finishes reading the text within it.
                        .accessibilityAddTraits(.causesPageTurn)

                    /// This code is commented intentionally. VO will think this component is a modal, and block the focus.
                    // Text("isModal Trait")
                    //     /// The accessibility element is modal.
                    //     ///
                    //     /// Use this trait to restrict which accessibility elements an assistive
                    //     /// technology can navigate. When a modal accessibility element is visible,
                    //     /// sibling accessibility elements that are not modal are ignored.
                    //     .accessibilityAddTraits(.isModal)

                    #warning("iOS 17")
                    // Text("isToggle Trait")
                    //     /// The accessibility element is a toggle.
                    //     .accessibilityAddTraits(.isToggle)

                    Divider()
                }

                // MARK: -

                Group {
                    Text("Ignored Image Example")
                        .font(.title)

                    /// If we use `Image(decorative:)` AX tools will ignore it.
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
                        /// This element will be hidden to AX tools. So it will be ignored by AX tools.
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
                    /// This will merge all the components. So AX tools will think the whole `VStack` is a single view.
                    /// Without this modifier, AX tools will select the `Text` components separately.
                    .accessibilityElement(children: .combine)

                    Divider()
                }

                // MARK: -

                Group {
                    Text("Custom Label for Complex Elements Example")
                        .font(.title)

                    VStack {
                        Text("Your result is")
                        Text("1K")
                            .font(.title)
                    }
                    /// Ignore all the elements inside the `VStack`.
                    .accessibilityElement(children: .ignore) // Or: accessibilityElement()
                    /// Set a custom label for the component. As above modifier ignore all the elements, we must need to set custom label for it.
                    .accessibilityLabel("Your score is 1000")

                    Divider()
                }

                // MARK: -

                Group {
                    Text("Accessibility Differentiate Without Color Example")
                        .font(.title)

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
                        Text("Accessibility Reduce Motion Example")
                            .font(.title)

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
                    }

                    // MARK: -

                    Group {
                        Text("Accessibility Reduce Transparency Example")
                            .font(.title)

                        Text("Hello, World!")
                            .padding()
                            /// Remove the transparency if "Reduce Transparency" is enabled.
                            .background(reduceTransparency ? Color(.systemBlack) : Color(.systemBlack).opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }

                    Divider()

                    // MARK: -

                    Group {
                        Text("Custom Component Example")
                            .font(.title)

                        LongPressCheckmark(
                            isSelected: $isSelected
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Accessibility Modifiers")
    }
}

struct GeneralAXModifiersScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GeneralAXModifiersScreen()
        }
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

// MARK: - Components

struct LongPressCheckmark: View {
    @Binding var isSelected: Bool

    var body: some View {
        Image(systemName: isSelected ? "checkmark.square" : "square")
            /// Long press gesture, which is not accessible by VO.
            .onLongPressGesture { isSelected.toggle() }
            /// Remove the default `Image` trait from this view.
            .accessibilityRemoveTraits(.isImage)
            /// Set this component as `Button`.
            .accessibilityAddTraits(.isButton)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            /// Set custom label for AX tools.
            .accessibilityLabel(Text("Checkmark"))
            /// Set custom hint for AX tools.
            .accessibilityHint("You can toggle the checkmark")
            /// This element is using `onLongPressGesture`, so VO cannot access it directly.
            /// So, for VO users we added specify the action here.
            .accessibilityAction { isSelected.toggle() }
    }
}
