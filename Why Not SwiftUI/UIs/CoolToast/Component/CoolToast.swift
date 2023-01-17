//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

private struct ModernCoolToast: ViewModifier {
    @Binding var data: CoolToastData
    let paddingBottom: CGFloat

    @State private var isPresented: Bool
    @State var dismissDispatchWorkItem: DispatchWorkItem? = nil

    init(data: Binding<CoolToastData>, paddingBottom: CGFloat) {
        self._data = data
        self.paddingBottom = paddingBottom

        if data.wrappedValue == .emptyInstance() {
            self.isPresented = false
        } else {
            self.isPresented = true
        }
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            VStack {
                Spacer()

                if isPresented {
                    CoolToastView(
                        icon: data.icon,
                        iconColor: data.iconColor,
                        message: data.message,
                        paddingBottom: paddingBottom
                    )
                    .padding(.bottom, paddingBottom)
                    .onTapGesture {
                        dismiss()
                    }
                }
            }
            .animation(data.animation, value: isPresented)
            .transition(.opacity)
        }
        .onChange(of: data) { newValue in
            if newValue == CoolToastData.emptyInstance() {
                isPresented = false

                dismissDispatchWorkItem?.cancel()
            } else {
                isPresented = true

                startDismissCountdown()
            }
        }
    }

    private func dismiss() {
        dismissDispatchWorkItem?.cancel()

        isPresented = false

        data = .emptyInstance()
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

private struct CoolToast: ViewModifier {
    @Binding var isPresented: Bool
    let icon: String
    let iconColor: Color
    let message: String
    let duration: TimeInterval
    let animation: Animation
    let paddingBottom: CGFloat

    @State var dismissDispatchWorkItem: DispatchWorkItem? = nil

    func body(content: Content) -> some View {
        ZStack {
            content

            VStack {
                Spacer()

                if isPresented {
                    CoolToastView(
                        icon: icon,
                        iconColor: iconColor,
                        message: message,
                        paddingBottom: paddingBottom
                    )
                    .padding(.bottom, paddingBottom)
                    .onTapGesture {
                        dismiss()
                    }
                }
            }
            .animation(animation, value: isPresented)
            .transition(.opacity)
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
                deadline: .now() + duration,
                execute: workItem
            )
        }
    }
}

private struct CoolToastView: View {
    let icon: String
    let iconColor: Color
    let message: String
    let paddingBottom: CGFloat

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
        .background(Color(.systemBackground))
        .cornerRadius(23)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Extensions

extension View {
    func coolToast(
        isPresented: Binding<Bool>,
        icon: String,
        iconColor: Color = Color(.systemGreen),
        message: String,
        duration: TimeInterval = 3.0,
        animation: Animation = .linear(duration: 0.3),
        paddingBottom: CGFloat = 16
    ) -> some View {
        modifier(
            CoolToast(
                isPresented: isPresented,
                icon: icon,
                iconColor: iconColor,
                message: message,
                duration: duration,
                animation: animation,
                paddingBottom: paddingBottom
            )
        )
    }

    func coolToast(
        isPresented: Binding<Bool>,
        data: CoolToastData,
        paddingBottom: CGFloat = 16
    ) -> some View {
        modifier(
            CoolToast(
                isPresented: isPresented,
                icon: data.icon,
                iconColor: data.iconColor,
                message: data.message,
                duration: data.duration,
                animation: data.animation,
                paddingBottom: paddingBottom
            )
        )
    }

    func coolToast(
        data: Binding<CoolToastData>,
        paddingBottom: CGFloat = 16
    ) -> some View {
        modifier(
            ModernCoolToast(
                data: data,
                paddingBottom: paddingBottom
            )
        )
    }
}

// MARK: - Models

struct CoolToastData: Equatable {
    let icon: String
    let iconColor: Color
    let message: String
    let duration: TimeInterval
    let animation: Animation

    init(
        icon: String = "",
        iconColor: Color = Color(.systemGreen),
        message: String = "",
        duration: TimeInterval = 3.0,
        animation: Animation = .linear(duration: 0.3)
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.message = message
        self.duration = duration
        self.animation = animation
    }

    static func emptyInstance() -> CoolToastData {
        return CoolToastData(
            icon: "",
            message: "",
            duration: 0.0,
            animation: .default
        )
    }
}

// MARK: - Previews

struct CoolToast_Previews: PreviewProvider {
    static var previews: some View {
        CoolToastView(
            icon: "checkmark.circle.fill",
            iconColor: Color(.systemGreen),
            message: "Answer Saved",
            paddingBottom: 16
        )
        .coolToast(
            isPresented: .constant(true),
            icon: "light.beacon.max.fill",
            message: "Please Be Warn!",
            duration: .infinity,
            paddingBottom: 32
        )
        .coolToast(
            data: .constant(CoolToastData(
                icon: "flame",
                iconColor: Color(.systemRed),
                message: "Impressive!",
                duration: .infinity
            )),
            paddingBottom: 120
        )
    }
}
