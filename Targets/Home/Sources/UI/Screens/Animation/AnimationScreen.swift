//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import NavigationKit
import SwiftUI

// For iOS 18:
// - https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-zoom-animations-between-views
// - https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-custom-text-effects-and-animations

// MARK: - Destination

public extension Destination {
    final class Animation: BaseDestination {
        override public func getScreen() -> any View {
            AnimationScreen()
        }
    }
}

// MARK: - UI

struct AnimationScreen: View {
    @State private var scale = 1.0
    @State private var isLeft = true

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AnimationTypesContainer()

                EffectModifiersContainer()

                BindingValueAnimationContainer()

                ExplicitAnimationContainer()

                OnAppearAnimationContainer()

                ApplyMultipleAnimationContainer()

                MatchedGeometryEffectAnimationContainer()

                AddRemoveViewsAnimationContainer()

                CustomTransitionAnimationContainer()

                TestSizeAnimationContainer()

                OverrideAnimationContainer()

                CompletionCallbackForAnimationContainer()

                PhaseAnimationContainer()
            }
            .padding()
        }
        .navigationTitle(NSLocalizedString("animation_example_navigation_title", bundle: .module, comment: ""))
    }
}

#Preview {
    NavigationStack {
        AnimationScreen()
    }
}

// MARK: - Animation types

// Reference:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-basic-animations

struct AnimationTypesContainer: View {
    @State private var isLeft = true

    var body: some View {
        CardContainer(title: "Builtin Animation Types") {
            VStack {
                InfoBox(text: "Press the button and compare the animation types.")

                BoxItem(name: "`.linear`", isLeft: $isLeft)
                    .animation(.linear(duration: 1), value: isLeft)

                BoxItem(name: "`.easeIn`", isLeft: $isLeft)
                    .animation(.easeIn(duration: 1), value: isLeft)

                BoxItem(name: "`.easeOut`", isLeft: $isLeft)
                    .animation(.easeOut(duration: 1), value: isLeft)

                BoxItem(name: "`.easeInOut`", isLeft: $isLeft)
                    .animation(.easeInOut(duration: 1), value: isLeft)

                BoxItem(name: "`.smooth`", isLeft: $isLeft)
                    .animation(.smooth(duration: 1), value: isLeft)

                BoxItem(name: "`.snappy`", isLeft: $isLeft)
                    .animation(.snappy(duration: 1), value: isLeft)

                BoxItem(name: "`.bouncy`", isLeft: $isLeft)
                    .animation(.bouncy(duration: 1), value: isLeft)

                BoxItem(name: "`.spring`", isLeft: $isLeft)
                    .animation(.spring(duration: 1), value: isLeft)

                BoxItem(name: "`.spring(...)`", isLeft: $isLeft)
                    .animation(.spring(duration: 1, bounce: 0.75), value: isLeft)

                BoxItem(name: "`.interpolatingSpring`", isLeft: $isLeft)
                    .animation(.interpolatingSpring(mass: 1, stiffness: 1, damping: 0.5, initialVelocity: 5), value: isLeft)

                Button(NSLocalizedString("press_here_button_title", bundle: .module, comment: "")) {
                    isLeft.toggle()
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

private struct BoxItem: View {
    let name: String
    @Binding var isLeft: Bool

    var body: some View {
        ZStack {
            Color.red
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .frame(maxWidth: .infinity, alignment: isLeft ? .leading : .trailing)

            Text(name.toMarkdown())
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("AnimationTypesContainer") {
    ScrollView {
        AnimationTypesContainer()
            .padding()
    }
}

// MARK: - Scale Effects

// References:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-basic-animations
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-spring-animation
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-delay-an-animation

struct EffectModifiersContainer: View {
    @State private var scale = 1.0

    @State private var angle = 0.0
    @State private var borderThickness = 1.0

    @State private var angle2 = 0.0

    @State private var scale2 = 1.0

    @State private var rotation = 0.0

    var body: some View {
        CardContainer(title: "Animation Effect Modifiers") {
            VStack(spacing: 16) {
                InfoBox(text: "Press on the shapes to activate the animations.")

                Text("`.scaleEffect()`")

                Button {
                    if scale >= 5 {
                        scale = 1
                    } else {
                        scale += 1
                    }
                } label: {
                    Color.red
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .scaleEffect(scale) // <-- 👀
                        .animation(.easeIn, value: scale) // <-- 👀
                }

                Text("`.rotationEffect()`")

                Button {
                    angle += 45

                    if borderThickness > 10 {
                        borderThickness = 1
                    } else {
                        borderThickness += 2
                    }
                } label: {
                    Color.clear
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red, lineWidth: borderThickness)
                        }
                        .rotationEffect(.degrees(angle)) // <-- 👀
                        .animation(.spring, value: angle) // <-- 👀
                }

                Text("`.rotationEffect()`")

                Button {
                    angle2 += 45
                } label: {
                    Color.red
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .rotationEffect(.degrees(angle2)) // <-- 👀
                        .animation( // <-- 👀
                            .interpolatingSpring(mass: 1, stiffness: 1, damping: 0.5, initialVelocity: 10),
                            value: angle2
                        )
                }

                Text("`.scaleEffect()`")

                Button {
                    if scale2 >= 5 {
                        scale2 = 1
                    } else {
                        scale2 += 1
                    }
                } label: {
                    Color.red
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .scaleEffect(scale2) // <-- 👀
                        .animation(.spring(duration: 1, bounce: 0.75), value: scale2) // <-- 👀
                }

                Text(NSLocalizedString("with_delay_modifier", bundle: .module, comment: ""))

                Button {
                    rotation += 360
                } label: {
                    Color.red
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .rotationEffect(.degrees(rotation)) // <-- 👀
                        .animation(.easeInOut(duration: 3).delay(1), value: rotation) // <-- 👀
                }
            }
        }
    }
}

#Preview("EffectModifiersContainer") {
    ScrollView {
        EffectModifiersContainer()
            .padding()
    }
}

// MARK: - Animate changes in binding values

// Reference:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-animate-changes-in-binding-values

struct BindingValueAnimationContainer: View {
    @State private var showingWelcome1 = false
    @State private var showingWelcome2 = false

    var body: some View {
        CardContainer(title: "Animate changes in binding values") {
            VStack {
                InfoBox(text: "Press the toggle to activate the animations.")
                    .padding(.bottom)

                Toggle(
                    NSLocalizedString("toggle_label_default_animation", bundle: .module, comment: ""),
                    isOn: $showingWelcome1.animation() // <-- 👀
                )

                if showingWelcome1 {
                    Text(NSLocalizedString("hello_world_greeting", bundle: .module, comment: ""))
                }

                Toggle(
                    NSLocalizedString("toggle_label_custom_animation", bundle: .module, comment: ""),
                    isOn: $showingWelcome2.animation(.spring(duration: 1, bounce: 0.75)) // <-- 👀
                )

                if showingWelcome2 {
                    Text(NSLocalizedString("hello_world_greeting", bundle: .module, comment: ""))
                }
            }
        }
    }
}

#Preview("BindingValueAnimationContainer") {
    ScrollView {
        BindingValueAnimationContainer()
            .padding()
    }
}

// MARK: - Create an explicit animation

// Reference:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-an-explicit-animation

struct ExplicitAnimationContainer: View {
    @State private var opacity = 1.0
    @State private var isRed = true

    var body: some View {
        CardContainer(title: "Create an explicit animation using `withAnimation`") {
            VStack {
                InfoBox(text: "Press on the shapes to activate the animations.")
                    .padding(.bottom)

                Button {
                    withAnimation { // <-- 👀
                        if opacity <= 0.0 {
                            opacity = 1
                        } else {
                            opacity -= 0.3
                        }
                    }
                } label: {
                    Color.red
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .opacity(opacity) // <-- 👀
                }

                Button {
                    withAnimation(.spring) { // <-- 👀
                        isRed.toggle()
                    }
                } label: {
                    Color.clear
                        .frame(width: 50, height: 50)
                        .overlay { // <-- 👀
                            if isRed {
                                Color.red
                            } else {
                                Color.blue
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

#Preview("ExplicitAnimationContainer") {
    ScrollView {
        ExplicitAnimationContainer()
            .padding()
    }
}

// MARK: - Start an animation immediately after a view appears

// Reference:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-start-an-animation-immediately-after-a-view-appears

struct OnAppearAnimationContainer: View {
    @State private var scale1 = 1.0
    @State private var scale2 = 1.0

    var body: some View {
        CardContainer(title: "Start an animation immediately after a view appears") {
            VStack {
                Circle()
                    .fill(Color.pink)
                    .frame(width: 50, height: 50)
                    .scaleEffect(scale1) // <-- 👀
                    .onAppear { // <-- 👀
                        let baseAnimation = Animation.easeInOut(duration: 1)
                        let repeated = baseAnimation.repeatForever(autoreverses: true)

                        withAnimation(repeated) {
                            scale1 = 0.5
                        }
                    }

                Circle()
                    .fill(Color.mint)
                    .frame(width: 50, height: 50)
                    .scaleEffect(scale2) // <-- 👀
                    .animateForever( // <-- 👀
                        using: .spring,
                        autoreverses: true
                    ) { scale2 = 0.5 }
            }
        }
    }
}

#Preview("OnAppearAnimationContainer") {
    ScrollView {
        OnAppearAnimationContainer()
            .padding()
    }
}

// MARK: - Apply multiple animations to a view

// Reference:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-apply-multiple-animations-to-a-view

struct ApplyMultipleAnimationContainer: View {
    @State private var isEnabled1 = false
    @State private var isEnabled2 = false

    var body: some View {
        CardContainer(title: "Apply multiple animations to a view") {
            VStack {
                InfoBox(text: "Color and shape animation.")
                    .padding(.bottom)

                Button(NSLocalizedString("press_me_button_text", bundle: .module, comment: "")) {
                    isEnabled1.toggle()
                }
                .foregroundStyle(.white)
                .frame(width: 100, height: 100)
                .animation(.easeInOut(duration: 1)) { content in // <-- 👀
                    content
                        .background(isEnabled1 ? .green : .red)
                }
                .animation(.easeInOut(duration: 2)) { content in // <-- 👀
                    content
                        .clipShape(.rect(cornerRadius: isEnabled1 ? 100 : 0))
                }

                InfoBox(text: "Only shape animation.")
                    .padding()

                Button(NSLocalizedString("press_me_button_text", bundle: .module, comment: "")) {
                    isEnabled2.toggle()
                }
                .foregroundStyle(.white)
                .frame(width: 100, height: 100)
                .background(isEnabled2 ? .green : .red)
                .animation(nil, value: isEnabled2) // <-- 👀
                .clipShape(RoundedRectangle(cornerRadius: isEnabled2 ? 100 : 0))
                .animation(.default, value: isEnabled2) // <-- 👀
            }
        }
    }
}

#Preview("ApplyMultipleAnimationContainer") {
    ScrollView {
        ApplyMultipleAnimationContainer()
            .padding()
    }
}

// MARK: - Synchronize animations from one view to another with `matchedGeometryEffect()`

// Reference:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-synchronize-animations-from-one-view-to-another-with-matchedgeometryeffect

struct MatchedGeometryEffectAnimationContainer: View {
    @Namespace private var animation
    @State private var isFlipped = false

    @State private var isZoomed = false

    private var frame: Double {
        isZoomed ? 300 : 44
    }

    var body: some View {
        CardContainer(title: "Synchronize animations from one view to another with `matchedGeometryEffect()`") {
            VStack {
                InfoBox(text: "Press on the cards to activate the animations.")
                    .padding(.bottom)

                VStack {
                    if isFlipped {
                        Circle()
                            .fill(.red)
                            .frame(width: 44, height: 44)
                            .matchedGeometryEffect(id: "Shape", in: animation)
                        Text(NSLocalizedString("do_what_you_enjoy", bundle: .module, comment: ""))
                            .matchedGeometryEffect(id: "Title", in: animation)
                            .font(.headline)
                    } else {
                        Text(NSLocalizedString("enjoy_what_you_do", bundle: .module, comment: ""))
                            .matchedGeometryEffect(id: "Title", in: animation)
                            .font(.headline)
                        Circle()
                            .fill(.blue)
                            .frame(width: 44, height: 44)
                            .matchedGeometryEffect(id: "Shape", in: animation)
                    }
                }
                .padding()
                .background(Color.secondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onTapGesture {
                    withAnimation {
                        isFlipped.toggle()
                    }
                }

                Spacer()
                    .frame(height: 16)

                VStack {
                    HStack {
                        RoundedRectangle(cornerRadius: isZoomed ? 10 : 150)
                            .fill(isZoomed ? .blue : .red)
                            .frame(width: frame, height: frame)

                        if isZoomed == false {
                            Text(NSLocalizedString("do_what_you_enjoy", bundle: .module, comment: ""))
                                .matchedGeometryEffect(id: "AlbumTitle", in: animation)
                                .font(.headline)
                            Spacer()
                        }
                    }

                    if isZoomed == true {
                        Text(NSLocalizedString("enjoy_what_you_do", bundle: .module, comment: ""))
                            .matchedGeometryEffect(id: "AlbumTitle", in: animation)
                            .font(.headline)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.secondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onTapGesture {
                    withAnimation(.spring()) {
                        isZoomed.toggle()
                    }
                }
            }
        }
    }
}

#Preview("MatchedGeometryEffectAnimationContainer") {
    ScrollView {
        MatchedGeometryEffectAnimationContainer()
            .padding()
    }
}

// MARK: - Add and remove views with a transition

// Reference:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-and-remove-views-with-a-transition
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-combine-transitions
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-asymmetric-transitions

struct AddRemoveViewsAnimationContainer: View {
    @State private var showDetails1 = false
    @State private var showDetails2 = false
    @State private var showDetails3 = false
    @State private var showDetails4 = false
    @State private var showDetails5 = false

    var body: some View {
        CardContainer(title: "Add and remove views with a transition") {
            VStack(spacing: 16) {
                Button(NSLocalizedString("example_one", bundle: .module, comment: "")) {
                    withAnimation {
                        showDetails1.toggle()
                    }
                }

                if showDetails1 {
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                }

                // ----------------------------------------------------------------

                Button(NSLocalizedString("example_two", bundle: .module, comment: "")) {
                    withAnimation {
                        showDetails2.toggle()
                    }
                }

                if showDetails2 {
                    // Moves in from the bottom
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                        .transition(.move(edge: .bottom))

                    // Moves in from leading out, out to trailing edge.
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                        .transition(.slide)

                    // Starts small and grows to full size.
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                        .transition(.scale)
                }

                // ----------------------------------------------------------------

                InfoBox(text: "Example for how to combine transitions.")

                Button(NSLocalizedString("example_three", bundle: .module, comment: "")) {
                    withAnimation {
                        showDetails3.toggle()
                    }
                }

                if showDetails3 {
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                        .transition(AnyTransition.opacity.combined(with: .slide))
                }

                // ----------------------------------------------------------------

                Button(NSLocalizedString("example_four", bundle: .module, comment: "")) {
                    withAnimation {
                        showDetails4.toggle()
                    }
                }

                if showDetails4 {
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                        .transition(.moveAndScale)
                }

                // ----------------------------------------------------------------

                InfoBox(text: "Example for create asymmetric transitions.")

                Button(NSLocalizedString("example_five", bundle: .module, comment: "")) {
                    withAnimation {
                        showDetails5.toggle()
                    }
                }

                if showDetails5 {
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .bottom)))
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview("AddRemoveViewsAnimationContainer") {
    ScrollView {
        AddRemoveViewsAnimationContainer()
            .padding()
    }
}

// MARK: - Create a custom transition

// Reference:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-custom-transition

struct CustomTransitionAnimationContainer: View {
    @State private var isShowingRed = true

    var body: some View {
        CardContainer(title: "Create a custom transition") {
            VStack {
                InfoBox(text: "Press on the shape to activate the animation.")

                ZStack {
                    Color.blue
                        .frame(width: 200, height: 200)

                    if isShowingRed {
                        Color.red
                            .frame(width: 200, height: 200)
                            .transition(.iris) // <-- 👀
                            .zIndex(1)
                    }
                }
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding()
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        isShowingRed.toggle()
                    }
                }
            }
        }
    }
}

#Preview("CustomTransitionAnimationContainer") {
    ScrollView {
        CustomTransitionAnimationContainer()
            .padding()
    }
}

// MARK: - Animate the size of text

// Reference:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-animate-the-size-of-text

struct TestSizeAnimationContainer: View {
    @State private var fontSize = 32.0

    var body: some View {
        CardContainer(title: "Animate the size of text") {
            VStack {
                InfoBox(text: "Press on the texts to activate the animations.")
                    .padding(.bottom)

                Text(NSLocalizedString("sidebar_main_content_greeting", bundle: .module, comment: ""))
                    .font(.custom("Georgia", size: fontSize)) // <-- 👀
                    .onTapGesture { // <-- 👀
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                            action()
                        }
                    }

                Text(NSLocalizedString("sidebar_main_content_greeting", bundle: .module, comment: ""))
                    .animatableFont(name: "Georgia", size: fontSize) // <-- 👀
                    .onTapGesture { // <-- 👀
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                            action()
                        }
                    }

                Text(NSLocalizedString("sidebar_main_content_greeting", bundle: .module, comment: ""))
                    .animatableSystemFont(size: fontSize) // <-- 👀
                    .onTapGesture { // <-- 👀
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                            action()
                        }
                    }
            }
        }
    }

    private func action() {
        if fontSize == 32 {
            fontSize = 72
        } else {
            fontSize = 32
        }
    }
}

#Preview("TestSizeAnimationContainer") {
    ScrollView {
        TestSizeAnimationContainer()
            .padding()
    }
}

// MARK: - Override animations with transactions

// Reference:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-override-animations-with-transactions

struct OverrideAnimationContainer: View {
    @State private var isZoomed1 = false
    @State private var isZoomed2 = false
    @State private var isZoomed3 = false

    var body: some View {
        CardContainer(title: "Override animations with transactions") {
            VStack(spacing: 16) {
                InfoBox(text: "This code toggles some text between small and large sizes, animating all the way because it has an implicit animation attached.")

                Button(NSLocalizedString("toggle_zoom_button", bundle: .module, comment: "")) {
                    isZoomed1.toggle() // <-- 👀
                }

                Spacer()
                    .frame(height: 16)

                Text(NSLocalizedString("zoom_text", bundle: .module, comment: ""))
                    .font(.title)
                    .scaleEffect(isZoomed1 ? 3 : 1) // <-- 👀
                    .animation(.easeInOut(duration: 2), value: isZoomed1) // <-- 👀

                // ----------------------------------------------------------------

                Divider()

                InfoBox(text: "Here’s our same text scaling example code except using a transaction to insert a custom animation that overrides the implicit one.")

                Button(NSLocalizedString("toggle_zoom_button", bundle: .module, comment: "")) {
                    var transaction = Transaction(animation: .linear) // <-- 👀
                    transaction.disablesAnimations = true // <-- 👀

                    withTransaction(transaction) { // <-- 👀
                        isZoomed2.toggle()
                    }
                }

                Spacer()
                    .frame(height: 16)

                Text(NSLocalizedString("zoom_text", bundle: .module, comment: ""))
                    .font(.title)
                    .scaleEffect(isZoomed2 ? 3 : 1) // <-- 👀
                    .animation(.easeInOut(duration: 2), value: isZoomed2) // <-- Will be ignored

                // ----------------------------------------------------------------

                Divider()

                InfoBox(text: "Use the `transaction()` modifier on the second text view so we disable any transactions on that one view – we’re overriding the override.")

                Button(NSLocalizedString("toggle_zoom_button", bundle: .module, comment: "")) {
                    var transaction = Transaction(animation: .linear) // <-- 👀
                    transaction.disablesAnimations = true // <-- 👀

                    withTransaction(transaction) { // <-- 👀
                        isZoomed3.toggle()
                    }
                }

                Spacer()
                    .frame(height: 16)

                Text(NSLocalizedString("zoom_text_1", bundle: .module, comment: ""))
                    .font(.title)
                    .scaleEffect(isZoomed3 ? 3 : 1) // <-- 👀

                Spacer()
                    .frame(height: 16)

                Text(NSLocalizedString("zoom_text_2", bundle: .module, comment: ""))
                    .font(.title)
                    .scaleEffect(isZoomed3 ? 3 : 1) // <-- 👀
                    .transaction { transection in // <-- 👀
                        transection.animation = .none
                    }
            }
            .buttonStyle(.bordered)
            .multilineTextAlignment(.center)
        }
    }
}

#Preview("OverrideAnimationContainer") {
    ScrollView {
        OverrideAnimationContainer()
            .padding()
    }
}

// MARK: - Run a completion callback when an animation finishes

// Reference:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-run-a-completion-callback-when-an-animation-finishes

struct CompletionCallbackForAnimationContainer: View {
    @State private var scaleUp1 = false
    @State private var fadeOut1 = false

    @State private var scaleUp2 = false
    @State private var fadeOut2 = false

    var body: some View {
        CardContainer(title: "Run a completion callback when an animation finishes") {
            VStack(spacing: 16) {
                InfoBox(text: "Press on the shapes to activate the animations.")

                Color.red
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .scaleEffect(scaleUp1 ? 3 : 1) // <-- 👀
                    .opacity(fadeOut1 ? 0 : 1) // <-- 👀
                    .onTapGesture { // <-- 👀
                        withAnimation {
                            scaleUp1 = true
                        } completion: {
                            withAnimation {
                                fadeOut1 = true
                            }
                        }
                    }

                InfoBox(text: "The default behavior of `withAnimation()` is to consider the animation complete even with that long tail of tiny movement still happening, but if you wanted it to be 100% finished you can override the default like this.")

                Color.mint
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .scaleEffect(scaleUp2 ? 3 : 1) // <-- 👀
                    .opacity(fadeOut2 ? 0 : 1) // <-- 👀
                    .onTapGesture { // <-- 👀
                        withAnimation(.bouncy, completionCriteria: .removed) {
                            scaleUp2 = true
                        } completion: {
                            withAnimation {
                                fadeOut2 = true
                            }
                        }
                    }

                Button(NSLocalizedString("reset_button_title", bundle: .module, comment: "")) {
                    scaleUp1 = false
                    fadeOut1 = false
                    scaleUp2 = false
                    fadeOut2 = false
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview("CompletionCallbackForAnimationContainer") {
    ScrollView {
        CompletionCallbackForAnimationContainer()
            .padding()
    }
}

// MARK: - Create multi-step animations using phase animators

// Reference:
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-multi-step-animations-using-phase-animators

struct PhaseAnimationContainer: View {
    @State private var scaleUp = false
    @State private var fadeOut = false

    var body: some View {
        CardContainer(title: "Create multi-step animations using phase animators") {
            VStack(spacing: 16) {
                Text(NSLocalizedString("hello_world_text", bundle: .module, comment: ""))
                    .font(.largeTitle)
                    .phaseAnimator([0, 1, 2]) { view, phase in // <-- 👀
                        view
                            .scaleEffect(phase)
                            .opacity(phase == 1 ? 1 : 0)
                    }

                PhaseAnimator([0, 1, 2]) { value in // <-- 👀
                    Text(NSLocalizedString("hello_world_text", bundle: .module, comment: ""))
                        .font(.title)
                        .scaleEffect(value) // <-- 👀
                        .opacity(value == 1 ? 1 : 0) // <-- 👀

                    Text(NSLocalizedString("goodbye_world_text", bundle: .module, comment: ""))
                        .font(.title)
                        .scaleEffect(3 - value) // <-- 👀
                        .opacity(value == 1 ? 1 : 0) // <-- 👀
                }

                Text(NSLocalizedString("hello_world_text", bundle: .module, comment: ""))
                    .font(.title)
                    .phaseAnimator(AnimationPhase.allCases) { view, phase in // <-- 👀
                        view
                            .scaleEffect(phase.rawValue) // <-- 👀
                            .opacity(phase.rawValue == 1 ? 1 : 0) // <-- 👀
                    }
            }
        }
    }
}

private enum AnimationPhase: Double, CaseIterable {
    case fadingIn = 0
    case middle = 1
    case zoomingOut = 2
}

#Preview("PhaseAnimationContainer") {
    ScrollView {
        PhaseAnimationContainer()
            .padding()
    }
}

// MARK: - Card Container

struct CardContainer<Content: View>: View {
    let title: String
    @ViewBuilder
    let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Text(title.toMarkdown())
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()

            Divider()

            ZStack {
                content()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.25), lineWidth: 2)
        }
    }
}

#Preview("CardContainer") {
    ScrollView {
        VStack {
            CardContainer(title: "Hello World!") {
                Text("Hello World!\nHello World!\nHello World!")
            }

            CardContainer(title: "Lorem Ipsum `Dolor Lorem` Ipsum **Dolor** Lorem Ipsum Dolor") {
                Text("Hello World!\nHello World!\nHello World!")
            }

            CardContainer(title: "Lorem Ipsum") {
                Text("Hello World!\nHello World!\nHello World!")
            }

            CardContainer(title: "Lorem Ipsum") {
                VStack {
                    InfoBox(text: "Hello World!\nHello World!\nHello World!")

                    InfoBox(text: "Lorem Ipsum `Dolor Lorem` Ipsum **Dolor** Lorem Ipsum Dolor")

                    Text("Hello World!\nHello World!\nHello World!")
                }
            }
        }
        .padding()
    }
}

// MARK: - Information Box

private struct InfoBox: View {
    let text: String

    var body: some View {
        HStack {
            Image(systemName: "info.square.fill")
                .foregroundStyle(Color.yellow)

            Text(text.toMarkdown())
                .font(.footnote)
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.yellow.opacity(0.25))
                .strokeBorder(Color.yellow, lineWidth: 1)
        }
    }
}
