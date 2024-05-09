//
//  AXRotorScreen.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 26/09/2023.
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

/// Resources
/// - Accessibility rotors in SwiftUI: https://swiftwithmajid.com/2021/09/14/accessibility-rotors-in-swiftui/

struct AXRotorScreen: View {
    let flowers = [
        Flower(name: "Rose", color: .red),
        Flower(name: "Sunflower", color: .yellow),
        Flower(name: "Carnation", color: .red),
        Flower(name: "Poinsettia", color: .red),
        Flower(name: "Marigold", color: .yellow),
        Flower(name: "Amaryllis", color: .red),
        Flower(name: "Poppy", color: .red),
        Flower(name: "Bluebell", color: .blue),
        Flower(name: "Buttercup", color: .yellow),
        Flower(name: "Tulip", color: .yellow),
        Flower(name: "Iris", color: .blue),
        Flower(name: "Hyacinth", color: .blue),
        Flower(name: "Daffodil", color: .yellow),
        Flower(name: "Jonquil", color: .yellow)
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Use **VoiceOver** to check the custom Rotors.")
                .font(.footnote)
                .multilineTextAlignment(.center)
            
            List {
                ForEach(flowers, id: \.id) { flower in
                    HStack {
                        Text("✿")
                            .font(.title)
                            .foregroundStyle(flower.color)
                            .accessibilityHidden(true)
                        Text(flower.name)
                            .frame(maxWidth: .infinity)
                    }
                    .accessibilityElement()
                    .accessibilityLabel(flower.name)
                }
            }
            /// Adding custom rotor shortcut to access `Red` flowers using rotor gesture.
            .accessibilityRotor("Red flowers") {
                ForEach(flowers, id: \.id) { flower in
                    if flower.color == .red {
                        AccessibilityRotorEntry(flower.name, id: flower.id)
                    }
                }
            }
            /// Adding custom rotor shortcut to access `Yellow` flowers using rotor gesture.
            .accessibilityRotor("Yellow flowers") {
                ForEach(flowers, id: \.id) { flower in
                    if flower.color == .yellow {
                        AccessibilityRotorEntry(flower.name, id: flower.id)
                    }
                }
            }
            /// Adding custom rotor shortcut to access `Blue` flowers using rotor gesture.
            .accessibilityRotor("Blue flowers") {
                ForEach(flowers, id: \.id) { flower in
                    if flower.color == .blue {
                        AccessibilityRotorEntry(flower.name, id: flower.id)
                    }
                }
            }
        }
        .navigationTitle("Rotor Example")
    }
}

#Preview("AXRotorScreen") {
    NavigationStack {
        AXRotorScreen()
    }
}

struct Flower: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}
