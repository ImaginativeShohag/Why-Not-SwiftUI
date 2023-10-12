//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct AccessibilityScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Accessibility")
                    .font(.title)

                NavigationLink {
                    GeneralAXModifiersScreen()
                } label: {
                    MenuItem(
                        icon: "1.circle",
                        label: "General Accessibility Modifiers"
                    )
                }

                NavigationLink {
                    AXRotorScreen()
                } label: {
                    MenuItem(
                        icon: "2.circle",
                        label: "Custom Rotor Example"
                    )
                }

                NavigationLink {
                    DynamicTypeScreen()
                } label: {
                    MenuItem(
                        icon: "3.circle",
                        label: "Dynamic Type"
                    )
                }

                NavigationLink {
                    CustomAXActionsScreen()
                } label: {
                    MenuItem(
                        icon: "4.circle",
                        label: "Custom Accessibility Actions"
                    )
                }

                NavigationLink {
                    AccessibilityPreferences()
                } label: {
                    MenuItem(
                        icon: "5.circle",
                        label: "Accessibility Preferences"
                    )
                }
            }
            .padding()
            .multilineTextAlignment(.center)
            .buttonStyle(.bordered)
        }
    }
}

struct AccessibilityScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccessibilityScreen()
        }
    }
}

struct MenuItem: View {
    let icon: String
    let label: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(label)
            Spacer()
        }
    }
}
