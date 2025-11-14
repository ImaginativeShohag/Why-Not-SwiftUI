//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct ToggleButtonStyle: ToggleStyle {
    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        let highlightColor: Color = colorScheme == .light ? .white : Color(uiColor: UIColor.tertiaryLabel)
        let foregroundColor = Color(UIColor.label)

        configuration.label
            .symbolRenderingMode(.monochrome)
            .labelStyle(.iconOnly)
            .foregroundStyle(foregroundColor)
            .frame(width: 36, height: 28)
            .contentShape(Rectangle())
            .onTapGesture {
                configuration.isOn.toggle()
            }
            .background(configuration.isOn ? highlightColor : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .shadow(color: configuration.isOn ? Color.black.opacity(0.15) : Color.clear,
                    radius: configuration.isOn ? 4 : 0,
                    x: 0, y: 2)
    }
}

struct ControlGroupNoneSeparatorStyle: ControlGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        let bgColor = Color(uiColor: UIColor.tertiarySystemFill)

        HStack(spacing: 0) {
            configuration.content
                .toggleStyle(ToggleButtonStyle())
                .padding(2)
        }
        .frame(maxWidth: .infinity)
        .background(bgColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
