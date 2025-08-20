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

/// **Note:**
/// - `AX` = Accessibility
/// - `VO` = Voice Over

struct GeneralAXModifiersScreen: View {
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
                    Text(NSLocalizedString("accessibility_modifiers_explanation_text", bundle: .module, comment: ""))
                        .font(.footnote)
                        .multilineTextAlignment(.center)

                    Divider()
                }

                Group {
                    Text(NSLocalizedString("custom_label_example_title", bundle: .module, comment: ""))
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
                        .accessibilityHint(NSLocalizedString("double_tap_to_change_image_hint", bundle: .module, comment: ""))
                        /// Set the element type for accessibility. So AX tools will think this is a "Button".
                        .accessibilityAddTraits(.isButton)
                        /// Remove the default view type for accessibility. So AX tools will to think this is a "Image".
                        .accessibilityRemoveTraits(.isImage)

                    Divider()
                }

                // MARK: -

                Group {
                    Text(NSLocalizedString("custom_traits_example_title", bundle: .module, comment: ""))
                        .font(.title)

                    Text(NSLocalizedString("is_button_trait", bundle: .module, comment: ""))
                        /// The accessibility element is a button.
                        .accessibilityAddTraits(.isButton)

                    Text(NSLocalizedString("is_header_trait", bundle: .module, comment: ""))
                        /// The accessibility element is a header that divides content into
                        /// sections, like the title of a navigation bar.
                        .accessibilityAddTraits(.isHeader)

                    Text(NSLocalizedString("is_selected_trait_label", bundle: .module, comment: ""))
                        /// The accessibility element is currently selected.
                        .accessibilityAddTraits(.isSelected)

                    Text(NSLocalizedString("is_link_trait", bundle: .module, comment: ""))
                        /// The accessibility element is a link.
                        .accessibilityAddTraits(.isLink)

                    Text(NSLocalizedString("is_search_field_trait", bundle: .module, comment: ""))
                        /// The accessibility element is a search field.
                        .accessibilityAddTraits(.isSearchField)

                    Text(NSLocalizedString("is_image_trait_label", bundle: .module, comment: ""))
                        /// The accessibility element is an image.
                        .accessibilityAddTraits(.isImage)

                    Text(NSLocalizedString("plays_sound_trait_label", bundle: .module, comment: ""))
                        /// The accessibility element plays its own sound when activated.
                        .accessibilityAddTraits(.playsSound)

                    Text(NSLocalizedString("is_keyboard_key_trait", bundle: .module, comment: ""))
                        /// The accessibility element behaves as a keyboard key.
                        .accessibilityAddTraits(.isKeyboardKey)

                    Text(NSLocalizedString("is_static_text_trait", bundle: .module, comment: ""))
                        /// The accessibility element is a static text that cannot be
                        /// modified by the user.
                        .accessibilityAddTraits(.isStaticText)

                    Text(NSLocalizedString("is_summary_element_trait", bundle: .module, comment: ""))
                        /// The accessibility element provides summary information when the
                        /// application starts.
                        ///
                        /// Use this trait to characterize an accessibility element that provides
                        /// a summary of current conditions, settings, or state, like the
                        /// temperature in the Weather app.
                        .accessibilityAddTraits(.isSummaryElement)

                    Text(NSLocalizedString("updates_frequently_trait", bundle: .module, comment: ""))
                        /// The accessibility element frequently updates its label or value.
                        ///
                        /// Use this trait when you want an assistive technology to poll for
                        /// changes when it needs updated information. For example, you might use
                        /// this trait to characterize the readout of a stopwatch.
                        .accessibilityAddTraits(.updatesFrequently)

                    Text(NSLocalizedString("starts_media_session_trait", bundle: .module, comment: ""))
                        /// The accessibility element starts a media session when it is activated.
                        ///
                        /// Use this trait to silence the audio output of an assistive technology,
                        /// such as VoiceOver, during a media session that should not be interrupted.
                        /// For example, you might use this trait to silence VoiceOver speech while
                        /// the user is recording audio.
                        .accessibilityAddTraits(.startsMediaSession)

                    Text(NSLocalizedString("allows_direct_interaction_trait_label", bundle: .module, comment: ""))
                        /// The accessibility element allows direct touch interaction for
                        /// VoiceOver users.
                        .accessibilityAddTraits(.allowsDirectInteraction)

                    Text(NSLocalizedString("causes_page_turn_trait_label", bundle: .module, comment: ""))
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

                    Text(NSLocalizedString("is_toggle_trait", bundle: .module, comment: ""))
                        /// The accessibility element is a toggle.
                        .accessibilityAddTraits(.isToggle)

                    Divider()
                }

                // MARK: -

                Group {
                    Text(NSLocalizedString("ignored_image_example_title", bundle: .module, comment: ""))
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
                    Text(NSLocalizedString("accessibility_ignored_element_explanation", bundle: .module, comment: ""))
                        .font(.title)

                    Text(NSLocalizedString("ignored_element_label", bundle: .module, comment: ""))
                        /// This element will be hidden to AX tools. So it will be ignored by AX tools.
                        .accessibilityHidden(true)

                    Divider()
                }

                // MARK: -

                Group {
                    Text("Combine Complex Elements Example")
                        .font(.title)

                    VStack {
                        Text(NSLocalizedString("your_score_is_label", bundle: .module, comment: ""))
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
                    Text(NSLocalizedString("custom_label_for_complex_elements_example_title", bundle: .module, comment: ""))
                        .font(.title)

                    VStack {
                        Text(NSLocalizedString("general_ax_modifiers_intro_text", bundle: .module, comment: ""))
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
                    Text(NSLocalizedString("general_accessibility_screen_title", bundle: .module, comment: ""))
                        .font(.title)

                    LongPressCheckmark(
                        isSelected: $isSelected
                    )
                }
            }
            .padding()
        }
        .navigationTitle(NSLocalizedString("accessibility_modifiers_screen_title", bundle: .module, comment: ""))
    }
}

struct GeneralAXModifiersScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GeneralAXModifiersScreen()
        }
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
            .accessibilityLabel(Text(NSLocalizedString("checkmark_label", bundle: .module, comment: "")))
            /// Set custom hint for AX tools.
            .accessibilityHint(NSLocalizedString("toggle_checkmark_hint", bundle: .module, comment: ""))
            /// This element is using `onLongPressGesture`, so VO cannot access it directly.
            /// So, for VO users we added specify the action here.
            .accessibilityAction { isSelected.toggle() }
    }
}
