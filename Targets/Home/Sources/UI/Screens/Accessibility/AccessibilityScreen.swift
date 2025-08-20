//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class Accessibility: BaseDestination, @unchecked Sendable {
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
                Text(NSLocalizedString("accessibility_screen_title", bundle: .module, comment: ""))
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
                        label: NSLocalizedString("dynamic_type_menu_item", bundle: .module, comment: "")
                    )
                }

                NavigationLink {
                    CustomAXActionsScreen()
                } label: {
                    MenuItem(
                        icon: "4.circle",
                        label: NSLocalizedString("custom_accessibility_actions_menu_item", bundle: .module, comment: "")
                    )
                }

                NavigationLink {
                    AccessibilityPreferencesScreen()
                } label: {
                    MenuItem(
                        icon: "5.circle",
                        label: NSLocalizedString("accessibility_preferences", bundle: .module, comment: "")
                    )
                }
            }
            .padding()
            .multilineTextAlignment(.center)
            .buttonStyle(.bordered)
        }
        .navigationTitle(NSLocalizedString("accessibility_screen_title", bundle: .module, comment: ""))
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
