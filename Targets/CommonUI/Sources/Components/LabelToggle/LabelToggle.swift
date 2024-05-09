//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

/// Component Name: `LabelToggle`
/// Version: `1.0.230317`

public struct LabelToggle: View {
    @Binding private var isOn: Bool
    private let onLabel: String
    private let offLabel: String

    public init(
        isOn: Binding<Bool>,
        onLabel: String = "On",
        offLabel: String = "Off"
    ) {
        self._isOn = isOn
        self.onLabel = onLabel
        self.offLabel = offLabel
    }

    public var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Text(onLabel)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 6)

                Circle()
                    .fill(Color.clear)
            }
            .opacity(isOn ? 1 : 0)

            HStack(spacing: 0) {
                Circle()
                    .fill(Color.clear)

                Text(offLabel)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.systemGray)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 6)
            }
            .opacity(isOn ? 0 : 1)

            HStack(spacing: 0) {
                if isOn {
                    Spacer()
                }

                Circle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, y: 1)

                if !isOn {
                    Spacer()
                }
            }
        }
        .padding(2)
        .frame(height: 32)
        .fixedSize()
        .background(isOn ? Color.systemGreen : Color.systemFill)
        .clipShape(Capsule())
        .cornerRadius(16)
        .animation(.default, value: isOn)
        .onTapGesture {
            isOn.toggle()
        }
        .accessibilityElement()
        .accessibilityLabel("Switch Button")
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityHint("Double tap to toggle setting.")
        .accessibilityAddTraits(.isButton)
    }
}

struct LabelToggle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            Toggle(isOn: .constant(true)) {}
                .fixedSize()

            LabelToggle(
                isOn: .constant(true)
            )

            Toggle(isOn: .constant(false)) {}
                .fixedSize()

            LabelToggle(
                isOn: .constant(false)
            )
        }
        .padding()
    }
}
