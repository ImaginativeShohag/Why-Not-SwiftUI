//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

/// Component Name: `CoolToast`
/// Version: `1.2.230216`

private struct ModernCoolToast: ViewModifier {
    @Binding var data: CoolToastData?
    let padding: CGFloat

    @State private var isPresented: Bool
    @State var dismissDispatchWorkItem: DispatchWorkItem? = nil

    @State var lastData: CoolToastData = .init()

    init(data: Binding<CoolToastData?>, padding: CGFloat) {
        self._data = data
        self.padding = padding

        if let data = data.wrappedValue {
            self.lastData = data
        }

        if data.wrappedValue == .none {
            self.isPresented = false
        } else {
            self.isPresented = true
        }
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            CoolToastContainer(
                isPresented: $isPresented,
                icon: data?.icon ?? lastData.icon,
                iconColor: data?.iconColor ?? lastData.iconColor,
                message: data?.message ?? lastData.message,
                anchor: data?.anchor ?? lastData.anchor,
                animation: data?.animation ?? lastData.animation,
                padding: padding,
                dismiss: dismiss
            )
        }
        .onChange(of: data) { newValue in
            if newValue == .none {
                isPresented = false

                dismissDispatchWorkItem?.cancel()
            } else {
                isPresented = true

                startDismissCountdown()

                if let data = data {
                    self.lastData = data
                }
            }
        }
    }

    private func dismiss() {
        dismissDispatchWorkItem?.cancel()

        isPresented = false

        data = nil
    }

    private func startDismissCountdown() {
        dismissDispatchWorkItem?.cancel()

        dismissDispatchWorkItem = DispatchWorkItem {
            dismiss()
        }

        if let workItem = dismissDispatchWorkItem {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + (data?.duration ?? 0),
                execute: workItem
            )
        }
    }
}

private struct CoolToast: ViewModifier {
    @Binding var isPresented: Bool
    let data: CoolToastData
    let padding: CGFloat

    @State var dismissDispatchWorkItem: DispatchWorkItem? = nil

    func body(content: Content) -> some View {
        ZStack {
            content

            CoolToastContainer(
                isPresented: $isPresented,
                icon: data.icon,
                iconColor: data.iconColor,
                message: data.message,
                anchor: data.anchor,
                animation: data.animation,
                padding: padding,
                dismiss: dismiss
            )
        }
        .onChange(of: isPresented) { newValue in
            if newValue {
                startDismissCountdown()
            } else {
                dismissDispatchWorkItem?.cancel()
            }
        }
    }

    private func dismiss() {
        dismissDispatchWorkItem?.cancel()

        isPresented = false
    }

    private func startDismissCountdown() {
        dismissDispatchWorkItem?.cancel()

        dismissDispatchWorkItem = DispatchWorkItem {
            dismiss()
        }

        if let workItem = dismissDispatchWorkItem {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + data.duration,
                execute: workItem
            )
        }
    }
}

struct CoolToastContainer: View {
    @Binding var isPresented: Bool
    let icon: String
    let iconColor: Color
    let message: String
    let anchor: CoolToastAnchor
    let animation: Animation
    let padding: CGFloat
    let dismiss: () -> Void

    var body: some View {
        VStack {
            if case .bottom = anchor {
                Spacer()
            }

            if isPresented {
                CoolToastView(
                    icon: icon,
                    iconColor: iconColor,
                    message: message
                )
                .padding(anchor.getEdge(), padding)
                .padding(.horizontal)
                .onTapGesture {
                    dismiss()
                }
            } else {
                EmptyView()
            }

            if case .top = anchor {
                Spacer()
            }
        }
        .animation(animation, value: isPresented)
        .transition(.opacity)
    }
}

private struct CoolToastView: View {
    let icon: String
    let iconColor: Color
    let message: String

    var body: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: 12)

            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)

            Spacer().frame(width: 8)

            Text(message)
                .font(.system(size: 14, weight: .medium))

            Spacer().frame(width: 16)
        }
        .frame(height: 46)
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(23)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Extensions

extension View {
    func coolToast(
        isPresented: Binding<Bool>,
        icon: String,
        iconColor: Color = .accentColor,
        message: String,
        anchor: CoolToastAnchor = .bottom,
        duration: TimeInterval = 3.0,
        animation: Animation = .linear(duration: 0.3),
        padding: CGFloat = 16
    ) -> some View {
        modifier(
            CoolToast(
                isPresented: isPresented,
                data: CoolToastData(
                    icon: icon,
                    iconColor: iconColor,
                    message: message,
                    anchor: anchor,
                    duration: duration,
                    animation: animation
                ),
                padding: padding
            )
        )
    }

    func coolToast(
        isPresented: Binding<Bool>,
        data: CoolToastData,
        padding: CGFloat = 16
    ) -> some View {
        modifier(
            CoolToast(
                isPresented: isPresented,
                data: data,
                padding: padding
            )
        )
    }

    func coolToast(
        data: Binding<CoolToastData?>,
        padding: CGFloat = 16
    ) -> some View {
        modifier(
            ModernCoolToast(
                data: data,
                padding: padding
            )
        )
    }
}

// MARK: - Models

enum CoolToastAnchor {
    case top
    case bottom

    func getEdge() -> Edge.Set {
        switch self {
        case .top:
            return Edge.Set.top
        case .bottom:
            return Edge.Set.bottom
        }
    }
}

struct CoolToastData: Equatable {
    let icon: String
    let iconColor: Color
    let message: String
    let anchor: CoolToastAnchor
    let duration: TimeInterval
    let animation: Animation

    init(
        icon: String = "",
        iconColor: Color = .accentColor,
        message: String = "",
        anchor: CoolToastAnchor = .bottom,
        duration: TimeInterval = 3.0,
        animation: Animation = .linear(duration: 0.3)
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.message = message
        self.anchor = anchor
        self.duration = duration
        self.animation = animation
    }
}

// MARK: - Previews

struct CoolToast_Previews: PreviewProvider {
    static var previews: some View {
        CoolToastView(
            icon: "checkmark.circle.fill",
            iconColor: .systemGreen,
            message: "Answer Saved"
        )
        // Variation 1
        .coolToast(
            isPresented: .constant(true),
            icon: "light.beacon.max.fill",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam. Please Be Warn!",
            anchor: .top,
            duration: .infinity,
            padding: 32
        )
        .coolToast(
            isPresented: .constant(true),
            icon: "light.beacon.max.fill",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam. Please Be Warn!",
            anchor: .bottom,
            duration: .infinity,
            padding: 32
        )
        // Variation 2
        .coolToast(
            isPresented: .constant(true),
            data: CoolToastData(
                icon: "atom",
                iconColor: .systemCyan,
                message: "Awesome!",
                anchor: .top,
                duration: .infinity
            ),
            padding: 120
        )
        .coolToast(
            isPresented: .constant(true),
            data: CoolToastData(
                icon: "atom",
                iconColor: .systemCyan,
                message: "Awesome!",
                anchor: .bottom,
                duration: .infinity
            ),
            padding: 120
        )
        // Variation 3
        .coolToast(
            data: .constant(CoolToastData(
                icon: "flame",
                iconColor: .systemRed,
                message: "Impressive!",
                anchor: .top,
                duration: .infinity
            )),
            padding: 200
        )
        .coolToast(
            data: .constant(CoolToastData(
                icon: "flame",
                iconColor: .systemRed,
                message: "Impressive!",
                anchor: .bottom,
                duration: .infinity
            )),
            padding: 200
        )
    }
}

// MARK: - Example Screen

struct CoolToastExampleScreen: View {
    @State private var showToast1 = false
    @State private var showToast2 = false
    @State private var showToast3: CoolToastData? = nil

    var body: some View {
        VStack {
            Spacer()

            Text("Cool Toast Example")

            Button {
                showToast1.toggle()
            } label: {
                Text("Show Toast 1")
            }

            Button {
                showToast2.toggle()
            } label: {
                Text("Show Toast 2")
            }

            Button {
                if showToast3 == nil {
                    showToast3 = CoolToastData(
                        icon: "flame",
                        iconColor: .systemRed,
                        message: "Impressive!",
                        anchor: .top,
                        duration: 3
                    )
                } else {
                    showToast3 = nil
                }
            } label: {
                Text("Show Toast 3.1")
            }
            
            Button {
                if showToast3 == nil {
                    showToast3 = CoolToastData(
                        icon: "flame.fill",
                        iconColor: .systemPink,
                        message: "Super Impressive!",
                        anchor: .bottom,
                        duration: 3
                    )
                } else {
                    showToast3 = nil
                }
            } label: {
                Text("Show Toast 3.2")
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.systemGroupedBackground)
        .buttonStyle(.bordered)
        .coolToast(
            isPresented: $showToast1,
            icon: "light.beacon.max.fill",
            message: "Please Be Warn!",
            anchor: .top,
            duration: 3,
            padding: 32
        )
        .coolToast(
            isPresented: $showToast2,
            data: CoolToastData(
                icon: "atom",
                iconColor: .systemCyan,
                message: "Awesome!",
                anchor: .top,
                duration: .infinity
            ),
            padding: 120
        )
        .coolToast(
            data: $showToast3,
            padding: 200
        )
    }
}

struct CoolToastExampleScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoolToastExampleScreen()
    }
}
