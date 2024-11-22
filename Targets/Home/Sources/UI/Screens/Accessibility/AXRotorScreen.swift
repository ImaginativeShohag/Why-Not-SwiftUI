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
        FlowerModel(name: "Rose", color: .red),
        FlowerModel(name: "Sunflower", color: .yellow),
        FlowerModel(name: "Carnation", color: .red),
        FlowerModel(name: "Poinsettia", color: .red),
        FlowerModel(name: "Marigold", color: .yellow),
        FlowerModel(name: "Amaryllis", color: .red),
        FlowerModel(name: "Poppy", color: .red),
        FlowerModel(name: "Bluebell", color: .blue),
        FlowerModel(name: "Buttercup", color: .yellow),
        FlowerModel(name: "Tulip", color: .yellow),
        FlowerModel(name: "Iris", color: .blue),
        FlowerModel(name: "Hyacinth", color: .blue),
        FlowerModel(name: "Daffodil", color: .yellow),
        FlowerModel(name: "Jonquil", color: .yellow)
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

struct FlowerModel: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}
