//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class Accessibility: BaseDestination {
        override public func getScreen() -> any View {
            AccessibilityScreen()
        }
    }
}

// MARK: - UI

public struct AccessibilityScreen: View {
    public init() {}

    public var body: some View {
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
                    AccessibilityPreferencesScreen()
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
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.inline)
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
