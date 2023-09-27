//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct AccessibilityScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Accessibility")
                    .font(.title)

                NavigationLink("General Accessibility Modifiers") {
                    GeneralAXModifiersScreen()
                }

                NavigationLink("Custom Rotor Example") {
                    AXRotorScreen()
                }

                NavigationLink("Dynamic Type") {
                    DynamicTypeScreen()
                }

                NavigationLink("Custom Accessibility Actions") {
                    CustomAXActionsScreen()
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
