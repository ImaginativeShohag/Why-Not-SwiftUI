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

struct DynamicTypeScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Group {
                    Text("Use ")
                        +
                        Text(" **Dynamic Type** from ")
                        +
                        Text(Image(systemName: "switch.2"))
                        +
                        Text(" **Canvas Device Settings** to quickly understand the effects.")
                }
                .multilineTextAlignment(.center)
                .font(.footnote)
                .padding(.horizontal)
                
                Divider()
                
                // MARK: -
                
                Text("Font styles")
                    .font(.title)
                
                /// Examples of all the possible font size styles.
                /// If no styles is selected, the `.body` will be applied.
                /// Don't use hard-coded font size, which will note change with the system font size change.
                Group {
                    Text("Large Title")
                        .font(.largeTitle)
                   
                    Text("Title 1")
                        .font(.title)
                   
                    Text("Title 2")
                        .font(.title2)
                   
                    Text("Title 3")
                        .font(.title3)
                   
                    Text("Headline")
                        .font(.headline)
                   
                    Text("Body")
                        .font(.body) // Default
                   
                    Text("Callout")
                        .font(.callout)
                   
                    Text("Sub-Headline")
                        .font(.subheadline)
                   
                    Text("Footnote")
                        .font(.footnote)
                   
                    Text("Caption 1")
                        .font(.caption)
                   
                    Text("Caption 2")
                        .font(.caption2)
                }
                
                Divider()
                
                // MARK: -
                
                Text("Set/Limit Dynamic Type Size")
                    .font(.title)
                
                Text("This will not change with Dynamic Type")
                    /// This will be stay same for all dynamic type settings.
                    /// It is not recommended to use specified font size. Use the dedicated font styles.
                    .font(.system(size: 16))
                
                Text("This will stay small")
                    /// This will limit the size to `.small`. So it will not gets affected by dynamic type change.
                    .dynamicTypeSize(.small)
                
                Text("This won't go above large")
                    /// This will limit font scaling from `.xSmall` up to `.large`.
                    /// After `.large` dynamic type the text will not grow more.
                    .dynamicTypeSize(...DynamicTypeSize.large)
                
                Text("This will scale within a range")
                    /// This will only scale up or down between `large` and `.xxxlarge`.
                    .dynamicTypeSize(DynamicTypeSize.large ... DynamicTypeSize.xxxLarge)
                
                Divider()
                
                // MARK: -
                
                DynamicLayout()
            }
        }
        .navigationTitle("Dynamic Type")
    }
}

struct DynamicTypeScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DynamicTypeScreen()
        }
        .previewDisplayName("Dynamic Type")
        
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

/// Layout will be changed based on the Dynamic Type size.
struct DynamicLayout: View {
    /// The current Dynamic Type size.
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
            Text("Dynamic layout")
                .font(.title)

            Text("The layout will be changed based on the `Dynamic Type`.")
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
