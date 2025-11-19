//
//  DynamicTypeScreen.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 23/09/2023.
//

import SwiftUI

/// # Resources:
/// - Typography: Specifications:  https://developer.apple.com/design/human-interface-guidelines/typography#Specifications
/// - How to specify the Dynamic Type sizes a view supports: https://www.hackingwithswift.com/quick-start/swiftui/how-to-specify-the-dynamic-type-sizes-a-view-supports
/// - Improving Dynamic Type Support: https://pspdfkit.com/blog/2018/improving-dynamic-type-support/
/// - Dynamic Type: Adaptable Layouts: https://www.blog.kevin-hirsch.com/dynamic-type-adaptable-layouts/
/// - Designing for scalable Dynamic Type in iOS for accessibility: https://uxdesign.cc/designing-for-scalable-dynamic-type-in-ios-5d3e2ae554eb
/// - What is the @ScaledMetric property wrapper?: https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-scaledmetric-property-wrapper

struct DynamicTypeScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Group {
                    Text("Use ")
                        +
                        Text(NSLocalizedString("dynamic_type_from_text", bundle: .module, comment: ""))
                        +
                        Text(Image(systemName: "switch.2"))
                        +
                        Text(NSLocalizedString("canvas_device_settings_effects_text", bundle: .module, comment: ""))
                }
                .multilineTextAlignment(.center)
                .font(.footnote)
                .padding(.horizontal)

                Divider()

                // MARK: -

                FontStyles()

                Divider()

                // MARK: -

                Text(NSLocalizedString("set_limit_dynamic_type_size", bundle: .module, comment: ""))
                    .font(.title)
                    .multilineTextAlignment(.center)

                Text(NSLocalizedString("dynamic_type_no_change_text", bundle: .module, comment: ""))
                    /// This will be stay same for all dynamic type settings.
                    /// It is not recommended to use specified font size. Use the dedicated font styles.
                    .font(.system(size: 16))

                Text(NSLocalizedString("dynamic_type_stay_small_text", bundle: .module, comment: ""))
                    /// This will limit the size to `.small`. So it will not gets affected by dynamic type change.
                    .dynamicTypeSize(.small)

                Text(NSLocalizedString("dynamic_type_limit_large_text", bundle: .module, comment: ""))
                    /// This will limit font scaling from `.xSmall` up to `.large`.
                    /// After `.large` dynamic type the text will not grow more.
                    .dynamicTypeSize(...DynamicTypeSize.large)

                Text(NSLocalizedString("dynamic_type_scale_range_text", bundle: .module, comment: ""))
                    /// This will only scale up or down between `large` and `.xxxlarge`.
                    .dynamicTypeSize(DynamicTypeSize.large ... DynamicTypeSize.xxxLarge)

                Divider()

                // MARK: -

                DynamicLayout()

                // MARK: -

                Divider()

                DynamicLayoutWithScaleMetric()
            }
        }
        .navigationTitle(NSLocalizedString("dynamic_type_menu_item", bundle: .module, comment: ""))
    }
}

struct DynamicTypeScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DynamicTypeScreen()
        }
        .previewDisplayName(NSLocalizedString("dynamic_type_menu_item", bundle: .module, comment: ""))

        NavigationStack {
            DynamicTypeScreen()
        }
        .previewDisplayName("Dynamic Type (Medium)")
        .environment(\.sizeCategory, .medium)

        NavigationStack {
            DynamicTypeScreen()
        }
        .previewDisplayName("Dynamic Type (AX1)")
        .environment(\.sizeCategory, .accessibilityMedium)
    }
}

// MARK: -

struct FontStyles: View {
    var body: some View {
        Text(NSLocalizedString("font_styles_screen_title", bundle: .module, comment: ""))
            .font(.title)
            .multilineTextAlignment(.center)

        /// Examples of all the possible font size styles.
        /// If no styles is selected, the `.body` will be applied.
        /// Don't use hard-coded font size, which will note change with the system font size change.

        Group {
            Text(Image(systemName: "doc.richtext"))
                + Text(NSLocalizedString("font_style_large_title", bundle: .module, comment: ""))
        }.font(.largeTitle)

        Group {
            Text(Image(systemName: "doc.richtext"))
                + Text(NSLocalizedString("font_style_title_1", bundle: .module, comment: ""))
        }.font(.title)

        Group {
            Text(Image(systemName: "doc.richtext"))
                + Text(NSLocalizedString("font_style_title_2", bundle: .module, comment: ""))
        }.font(.title2)

        Group {
            Text(Image(systemName: "doc.richtext"))
                + Text(NSLocalizedString("font_style_title_3", bundle: .module, comment: ""))
        }.font(.title3)

        Group {
            Text(Image(systemName: "doc.richtext"))
                + Text("Headline")
        }.font(.headline)

        Group {
            Text(Image(systemName: "doc.richtext"))
                + Text(NSLocalizedString("font_styles_title", bundle: .module, comment: ""))
        }.font(.body) // Default

        Group {
            Text(Image(systemName: "doc.richtext"))
                + Text("Callout")
        }.font(.callout)

        Group {
            Text(Image(systemName: "doc.richtext"))
                + Text("Sub-Headline")
        }.font(.subheadline)

        Group {
            Text(Image(systemName: "doc.richtext"))
                + Text("Footnote")
        }.font(.footnote)

        Group {
            Text(Image(systemName: "doc.richtext"))
                + Text(NSLocalizedString("font_styles_caption_1", bundle: .module, comment: ""))
        }.font(.caption)

        Group {
            Text(Image(systemName: "doc.richtext"))
                + Text(NSLocalizedString("font_styles_caption_2", bundle: .module, comment: ""))
        }.font(.caption2)
    }
}

// MARK: - Dynamic Layout Example

/// Layout will be changed based on the Dynamic Type size.
struct DynamicLayout: View {
    /// `.dynamicTypeSize` will gives the current Dynamic Type size.
    ///
    /// This value changes as the user's chosen Dynamic Type size changes. The
    /// default value is device-dependent.
    ///
    /// When limiting the Dynamic Type size, consider if adding a
    /// large content view with ``View/accessibilityShowsLargeContentViewer()``
    /// would be appropriate.
    ///
    /// On macOS, this value cannot be changed by users and does not affect the
    /// text size.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        /// Layout will be `VStack` if current dynamic type is greater then `XXX Large`.
        /// Means, for `AX1, AX2, AX3, AX4, AX5`, the layout will be `VStack`.
        /// Otherwise it will be `HStack`.
        let layout = dynamicTypeSize > .xxxLarge ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())

        VStack(alignment: .center, spacing: 16) {
            Text(NSLocalizedString("dynamic_layout_title", bundle: .module, comment: ""))
                .font(.title)
                .multilineTextAlignment(.center)

            Text(NSLocalizedString("dynamic_type_layout_explanation", bundle: .module, comment: ""))
                .multilineTextAlignment(.center)

            layout {
                SampleItem(icon: "laptopcomputer", name: "Mac Book")
                SampleItem(icon: "iphone.gen3", name: "iPhone")
            }

            layout {
                SampleItem(icon: "ipad", name: "iPad")
                SampleItem(icon: "airpods", name: "AirPods")
            }
        }
        .padding()
    }
}

// MARK: - Dynamic Layout and `@ScaleMetric` Example

/// Layout will be changed based on the Dynamic Type size.
/// This example also demonstrate how we can use `@ScaledMetric` to scale any value based on the Dynamic Type.
struct DynamicLayoutWithScaleMetric: View {
    /// `.dynamicTypeSize` will gives the current Dynamic Type size.
    ///
    /// This value changes as the user's chosen Dynamic Type size changes. The
    /// default value is device-dependent.
    ///
    /// When limiting the Dynamic Type size, consider if adding a
    /// large content view with ``View/accessibilityShowsLargeContentViewer()``
    /// would be appropriate.
    ///
    /// On macOS, this value cannot be changed by users and does not affect the
    /// text size.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// `@ScaledMetric` will scale the value based on the dynamic type.
    /// By default `relativeTo` is `.body`.
    @ScaledMetric var scaleSizeForImage = 48

    /// We can also specify a font style type, the scaling will be `relativeTo` the given font text style.
    @ScaledMetric(relativeTo: .footnote) var scaleSize = 1
    @ScaledMetric(relativeTo: .footnote) var scaleSizeForSpacing = 16

    var body: some View {
        /// Layout will be `VStack` if current dynamic type is greater then `XXX Large`.
        /// Means, for `AX1, AX2, AX3, AX4, AX5`, the layout will be `VStack`.
        /// Otherwise it will be `HStack`.
        let layout = dynamicTypeSize > .xxxLarge ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())

        VStack(alignment: .center, spacing: 16) {
            Text(NSLocalizedString("scaled_metric_example_title", bundle: .module, comment: ""))
                .font(.title)
                .multilineTextAlignment(.center)

            Text(NSLocalizedString("dynamic_type_description", bundle: .module, comment: ""))
                .multilineTextAlignment(.center)

            VStack(spacing: scaleSizeForSpacing) {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                    .font(.footnote)

                layout {
                    Image("anastasiya-leskova-3p0nSfa5gi8-unsplash")
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: scaleSize * 72,
                            height: scaleSize * 72
                        )
                        .clipped()
                        .cornerRadius(scaleSize * 16)

                    Image("anastasiya-leskova-3p0nSfa5gi8-unsplash")
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: scaleSize * 72,
                            height: scaleSize * 72
                        )
                        .clipped()
                        .cornerRadius(scaleSize * 16)

                    Image("anastasiya-leskova-3p0nSfa5gi8-unsplash")
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: scaleSize * 72,
                            height: scaleSize * 72
                        )
                        .clipped()
                        .cornerRadius(scaleSize * 16)
                }

                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                    .font(.footnote)
            }
            .padding(scaleSizeForSpacing)
        }
        .padding()
    }
}

// MARK: - Components

private struct SampleItem: View {
    let icon: String
    let name: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            Text(name)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
