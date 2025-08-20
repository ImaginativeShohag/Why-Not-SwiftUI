//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

// TODO: #1: Add a way to keep the debug background color for the drag controls

struct ShapeBlockView: View {
    @Binding var block: ShapeBlock
    let isSelected: Bool
    let contentSize: CGSize
    let onClick: () -> Void
    let onDuplicateClick: () -> Void
    let onRemoveClick: () -> Void

    @State private var dragOffset: CGSize = .zero // Track drag offset separately

    let minSize: CGSize = .init(width: 80, height: 80)

    var textBoxMaxSize: CGSize {
        return CGSize(width: contentSize.width - 32, height: contentSize.height - 32)
    }

    var body: some View {
        ZStack {
            Group {
                if block.type == .circle {
                    Circle()
                        .stroke(block.borderColor, lineWidth: block.borderSize)
                        .fill(block.backgroundColor)
                } else {
                    RoundedRectangle(cornerRadius: block.cornerRadius)
                        .stroke(block.borderColor, lineWidth: block.borderSize)
                        .fill(block.backgroundColor)
                }
            }
            .opacity(block.opacity)
            .disabled(!isSelected)
            .frame(width: block.size.width, height: block.size.height)
            .padding(5)
            // Note: This makes the content clickable even when the TextField is disabled.
            .contentShape(Rectangle())
            .overlay {
                if isSelected {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.systemBlue, lineWidth: 2)
                    }
                    .padding(-4)
                    .overlay {
                        GeometryReader { proxy in
                            // Horizontal control
                            HStack {
                                DragIndicatorView()
                                    // Note: Removing the corner tappable areas.
                                    .frame(height: proxy.size.height - 88)
                                    // Note: Recommended minimum tappable area is 44x44.
                                    .frame(width: 44)
                                    // .background(.red.opacity(0.25))
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newWidth = block.size.width - value.translation.width
                                                block.size.width = min(max(minSize.width, newWidth), textBoxMaxSize.width)
                                            }
                                    )

                                Spacer()

                                DragIndicatorView()
                                    // Note: Removing the corner tappable areas.
                                    .frame(height: proxy.size.height - 88)
                                    // Note: Recommended minimum tappable area is 44x44.
                                    .frame(width: 44)
                                    // .background(.red.opacity(0.25))
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newWidth = block.size.width + value.translation.width
                                                block.size.width = min(max(minSize.width, newWidth), textBoxMaxSize.width)
                                            }
                                    )
                            }
                            .frame(height: proxy.size.height)

                            // Vertical control
                            VStack {
                                DragIndicatorView()
                                    // Note: Removing the corner tappable areas.
                                    .frame(width: proxy.size.width - 88)
                                    // Note: Recommended minimum tappable area is 44x44.
                                    .frame(height: 44)
                                    // .background(.red.opacity(0.25))
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newHeight = block.size.height - value.translation.height
                                                block.size.height = min(max(minSize.height, newHeight), textBoxMaxSize.height)
                                            }
                                    )

                                Spacer()

                                DragIndicatorView()
                                    // Note: Removing the corner tappable areas.
                                    .frame(width: proxy.size.width - 88)
                                    // Note: Recommended minimum tappable area is 44x44.
                                    .frame(height: 44)
                                    // .background(.red.opacity(0.25))
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newHeight = block.size.height + value.translation.height
                                                block.size.height = min(max(minSize.height, newHeight), textBoxMaxSize.height)
                                            }
                                    )
                            }
                            .frame(width: proxy.size.width)

                            // Top-Corner control
                            HStack {
                                DragIndicatorView()
                                    // Note: Recommended minimum tappable area is 44x44.
                                    .frame(width: 44, height: 44)
                                    // .background(.green.opacity(0.25))
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newWidth = block.size.width - value.translation.width
                                                let newHeight = block.size.height - value.translation.height

                                                block.size = CGSize(
                                                    width: min(max(minSize.width, newWidth), textBoxMaxSize.width),
                                                    height: min(max(minSize.height, newHeight), textBoxMaxSize.height)
                                                )
                                            }
                                    )

                                Spacer()

                                DragIndicatorView()
                                    // Note: Recommended minimum tappable area is 44x44.
                                    .frame(width: 44, height: 44)
                                    // .background(.green.opacity(0.25))
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newWidth = block.size.width + value.translation.width
                                                let newHeight = block.size.height - value.translation.height

                                                block.size = CGSize(
                                                    width: min(max(minSize.width, newWidth), textBoxMaxSize.width),
                                                    height: min(max(minSize.height, newHeight), textBoxMaxSize.height)
                                                )
                                            }
                                    )
                            }
                            .frame(height: proxy.size.height, alignment: .top)

                            // Bottom-Corner control
                            HStack {
                                DragIndicatorView()
                                    // Note: Recommended minimum tappable area is 44x44.
                                    .frame(width: 44, height: 44)
                                    // .background(.green.opacity(0.25))
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newWidth = block.size.width - value.translation.width
                                                let newHeight = block.size.height + value.translation.height

                                                block.size = CGSize(
                                                    width: min(max(minSize.width, newWidth), textBoxMaxSize.width),
                                                    height: min(max(minSize.height, newHeight), textBoxMaxSize.height)
                                                )
                                            }
                                    )

                                Spacer()

                                DragIndicatorView()
                                    // Note: Recommended minimum tappable area is 44x44.
                                    .frame(width: 44, height: 44)
                                    // .background(.green.opacity(0.25))
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newWidth = block.size.width + value.translation.width
                                                let newHeight = block.size.height + value.translation.height

                                                block.size = CGSize(
                                                    width: min(max(minSize.width, newWidth), textBoxMaxSize.width),
                                                    height: min(max(minSize.height, newHeight), textBoxMaxSize.height)
                                                )
                                            }
                                    )
                            }
                            .frame(height: proxy.size.height, alignment: .bottom)
                        }
                        .padding(-26)
                    }
                } else if block.backgroundColor == .clear && block.borderColor == .clear {
                    // Note: This is need to give a outline for the shape when there is no background and border.
                    Rectangle()
                        .stroke(lineWidth: 1)
                }
            }
            .overlay {
                if isSelected {
                    GeometryReader { proxy in
                        BlockToolbarView(
                            block: $block,
                            onDuplicateClick: onDuplicateClick,
                            onRemoveClick: onRemoveClick
                        )
                        .position(x: proxy.size.width / 2, y: -44)
                    }
                }
            }
        }
        .position(block.position)
        .offset(dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let newX = block.position.x + value.translation.width
                    let newY = block.position.y + value.translation.height

                    // Clamp the position within allowed bounds
                    block.position.x = min(max(newX, 0), contentSize.width)
                    block.position.y = min(max(newY, 0), contentSize.height)

                    dragOffset = .zero
                }
        )
        .simultaneousGesture(
            TapGesture().onEnded {
                onClick()
            }
        )
    }
}

#Preview {
    @Previewable @State var shape1 = ShapeBlock(
        position: CGPoint(
            x: 200,
            y: 150
        )
    )
    @Previewable @State var shape2 = ShapeBlock(
        type: .circle,
        position: CGPoint(
            x: 200,
            y: 400
        )
    )

    ZStack {
        ShapeBlockView(
            block: $shape1,
            isSelected: true,
            contentSize: UIScreen.main.bounds.size,
            onClick: {},
            onDuplicateClick: {},
            onRemoveClick: {}
        )

        ShapeBlockView(
            block: $shape2,
            isSelected: true,
            contentSize: UIScreen.main.bounds.size,
            onClick: {},
            onDuplicateClick: {},
            onRemoveClick: {}
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}

private struct BlockToolbarView: View {
    @Binding var block: ShapeBlock
    let onDuplicateClick: () -> Void
    let onRemoveClick: () -> Void

    @State private var showBGOptionPopover: Bool = false
    @State private var showBorderOptionPopover: Bool = false
    @State private var showOpacityPopover: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            Button {
                showBGOptionPopover.toggle()
            } label: {
                Circle()
                    .fill(block.backgroundColor)
                    .frame(width: 24, height: 24)
                    .background {
                        if block.backgroundColor == .clear {
                            Circle()
                                .stroke(.gray.opacity(0.5), lineWidth: 1)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .popover(isPresented: $showBGOptionPopover, arrowEdge: .bottom) {
                        BackgroundOptionPopoverView(block: $block)
                            .presentationCompactAdaptation(.none)
                    }
            }

            Button {
                showBorderOptionPopover.toggle()
            } label: {
                ZStack {
                    if block.borderColor == .clear {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .stroke(.gray, lineWidth: 1)
                            .frame(width: 4, height: 24)
                            .rotationEffect(.degrees(45))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red)
                            .frame(width: 4, height: 24)
                            .rotationEffect(.degrees(-45))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(block.borderColor)
                            .frame(width: 4, height: 24)
                            .rotationEffect(.degrees(45))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                }
                .popover(isPresented: $showBorderOptionPopover, arrowEdge: .bottom) {
                    BorderOptionPopoverView(block: $block)
                        .presentationCompactAdaptation(.none)
                }
            }

            Button {
                showOpacityPopover.toggle()
            } label: {
                Image(systemName: "circle.dotted")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .popover(isPresented: $showOpacityPopover, arrowEdge: .bottom) {
                        OpacityPopoverView(block: $block)
                            .presentationCompactAdaptation(.none)
                    }
            }

            Divider()
                .frame(height: 20)

            Button {
                onDuplicateClick()
            } label: {
                Image(systemName: "plus.square.on.square")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }

            Button {
                onRemoveClick()
            } label: {
                Image(systemName: "trash")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .tint(.red)
        }
        .tint(.black)
        .padding(.horizontal, 0)
        .padding(.vertical, 0)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 50))
        .shadow(color: .black.opacity(0.2), radius: 8)
        .dynamicTypeSize(.large)
        .colorScheme(.light)
    }
}

private struct BackgroundOptionPopoverView: View {
    @Binding var block: ShapeBlock

    var body: some View {
        VStack {
            ColorSelectSection(
                selectedColor: $block.backgroundColor
            )

            HStack {
                Button {
                    block.backgroundColor = .clear
                } label: {
                    Text(NSLocalizedString("no_fill", bundle: .module, comment: ""))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.label)
                        .padding(.horizontal, 8)
                        .padding(.vertical, UIDevice.current.isPhone ? 3.8 : 3.9)
                        .background(Color.tertiarySystemFill)
                        .cornerRadius(8)
                }

                ColorPicker("", selection: $block.backgroundColor)
                    .labelsHidden()
            }
        }
        .padding(8)
        .animation(.default, value: block.backgroundColor)
    }
}

struct ColorSelectSection: View {
    @Binding var selectedColor: Color

    private let colorSection1: [Color] = [.white, .gray, .black, .mint, .pink, .purple]
    private let colorSection2: [Color] = [.red, .orange, .yellow, .green, .cyan, .indigo]

    var body: some View {
        HStack {
            ForEach(colorSection1, id: \.self) { color in
                if color != colorSection1.first {
                    Spacer()
                }

                Button {
                    selectedColor = color
                } label: {
                    Circle()
                        .fill(color)
                        .stroke(color == .white ? .gray : .clear, lineWidth: 1)
                        .frame(width: 32, height: 32)
                        .overlay {
                            if selectedColor == color {
                                Circle()
                                    .stroke(selectedColor == .white ? .black : .white, lineWidth: 2)
                                    .padding(4)
                            }
                        }
                }
            }
        }

        HStack {
            ForEach(colorSection2, id: \.self) { color in
                if color != colorSection2.first {
                    Spacer()
                }

                Button {
                    selectedColor = color
                } label: {
                    Circle()
                        .fill(color)
                        .frame(width: 32, height: 32)
                        .overlay {
                            if selectedColor == color {
                                Circle()
                                    .stroke(selectedColor == .white ? .black : .white, lineWidth: 2)
                                    .padding(4)
                            }
                        }
                }
            }
        }
    }
}

private struct BorderOptionPopoverView: View {
    @Binding var block: ShapeBlock

    private let colorSection1: [Color] = [.white, .gray, .black, .mint, .pink, .purple]
    private let colorSection2: [Color] = [.red, .orange, .yellow, .green, .cyan, .indigo]
    private let maxLineWidth: CGFloat = 30
    private let maxCornerRadius: CGFloat = 30

    var body: some View {
        VStack {
            ColorSelectSection(
                selectedColor: $block.borderColor
            )

            HStack {
                Button {
                    block.borderColor = .clear
                } label: {
                    Text(NSLocalizedString("no_stroke_button", bundle: .module, comment: ""))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.label)
                        .padding(.horizontal, 8)
                        .padding(.vertical, UIDevice.current.isPhone ? 3.8 : 3.9)
                        .background(Color.tertiarySystemFill)
                        .cornerRadius(8)
                }

                ColorPicker("", selection: $block.borderColor)
                    .labelsHidden()
            }

            if block.borderColor != .clear {
                HStack {
                    Image(systemName: "lineweight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color.label)

                    ControlGroup {
                        Button {
                            if block.borderSize > 1 {
                                block.borderSize -= 1
                            }
                        } label: {
                            Label(NSLocalizedString("decrease", bundle: .module, comment: ""), systemImage: "minus")
                        }

                        Button {
                            // Note: This button need to fix the UI issue with ControlGroup.
                        } label: {
                            Text("\(Int(block.borderSize)) pt")
                        }

                        Button {
                            if block.borderSize < maxLineWidth {
                                block.borderSize += 1
                            }
                        } label: {
                            Label(NSLocalizedString("increase", bundle: .module, comment: ""), systemImage: "plus")
                        }
                    }
                }
            }

            if block.cornerRadius != 0 {
                HStack {
                    Image(systemName: "capsule")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color.label)

                    ControlGroup {
                        Button {
                            if block.cornerRadius > 1 {
                                block.cornerRadius -= 1
                            }
                        } label: {
                            Label(NSLocalizedString("decrease", bundle: .module, comment: ""), systemImage: "minus")
                        }

                        Button {
                            // Note: This button need to fix the UI issue with ControlGroup.
                        } label: {
                            Text("\(Int(block.cornerRadius)) pt")
                        }

                        Button {
                            if block.cornerRadius < maxCornerRadius {
                                block.cornerRadius += 1
                            }
                        } label: {
                            Label(NSLocalizedString("increase", bundle: .module, comment: ""), systemImage: "plus")
                        }
                    }
                }
            }
        }
        .padding(8)
    }
}

private struct OpacityPopoverView: View {
    @Binding var block: ShapeBlock

    var body: some View {
        VStack {
            OpacitySlider(opacity: $block.opacity)
        }
        .frame(width: 200)
        .padding(8)
    }
}

struct DragIndicatorView: View {
    var body: some View {
        Circle()
            .fill(Color.blue)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .frame(width: 16, height: 16)
    }
}
