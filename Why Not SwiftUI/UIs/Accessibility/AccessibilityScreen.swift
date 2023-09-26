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

                NavigationLink("Rotor") {
                    AXRotorScreen()
                }

                NavigationLink("Dynamic Types") {
                    DynamicTypeScreen()
                }

                NavigationLink("Custom Actions") {
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
