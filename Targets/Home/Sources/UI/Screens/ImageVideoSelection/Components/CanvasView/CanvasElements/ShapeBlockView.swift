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

    @FocusState private var isFocused: Bool
    @State private var dragOffset: CGSize = .zero // Track drag offset separately

    let minSize: CGSize = .init(width: 80, height: 80)

    var textBoxMaxSize: CGSize {
        return CGSize(width: contentSize.width - 32, height: contentSize.height - 32)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: block.cornerRadius)
                .stroke(block.borderColor, lineWidth: block.borderSize)
                .fill(block.backgroundColor)
                .focused($isFocused)
                .disabled(!isSelected)
                .padding(5)
                .frame(width: block.size.width, height: block.size.height)
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
                                        .background(.red.opacity(0.25))
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    let newWidth = block.size.width - value.translation.width
                                                    block.size.width = min(max(minSize.width, newWidth), textBoxMaxSize.width)

                                                    isFocused = false
                                                }
                                        )

                                    Spacer()

                                    DragIndicatorView()
                                        // Note: Removing the corner tappable areas.
                                        .frame(height: proxy.size.height - 88)
                                        // Note: Recommended minimum tappable area is 44x44.
                                        .frame(width: 44)
                                        .background(.red.opacity(0.25))
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    let newWidth = block.size.width + value.translation.width
                                                    block.size.width = min(max(minSize.width, newWidth), textBoxMaxSize.width)

                                                    isFocused = false
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
                                        .background(.red.opacity(0.25))
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    let newHeight = block.size.height - value.translation.height
                                                    block.size.height = min(max(minSize.height, newHeight), textBoxMaxSize.height)

                                                    isFocused = false
                                                }
                                        )

                                    Spacer()

                                    DragIndicatorView()
                                        // Note: Removing the corner tappable areas.
                                        .frame(width: proxy.size.width - 88)
                                        // Note: Recommended minimum tappable area is 44x44.
                                        .frame(height: 44)
                                        .background(.red.opacity(0.25))
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    let newHeight = block.size.height + value.translation.height
                                                    block.size.height = min(max(minSize.height, newHeight), textBoxMaxSize.height)

                                                    isFocused = false
                                                }
                                        )
                                }
                                .frame(width: proxy.size.width)

                                // Top-Corner control
                                HStack {
                                    DragIndicatorView()
                                        // Note: Recommended minimum tappable area is 44x44.
                                        .frame(width: 44, height: 44)
                                        .background(.green.opacity(0.25))
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

                                                    isFocused = false
                                                }
                                        )

                                    Spacer()

                                    DragIndicatorView()
                                        // Note: Recommended minimum tappable area is 44x44.
                                        .frame(width: 44, height: 44)
                                        .background(.green.opacity(0.25))
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

                                                    isFocused = false
                                                }
                                        )
                                }
                                .frame(height: proxy.size.height, alignment: .top)

                                // Bottom-Corner control
                                HStack {
                                    DragIndicatorView()
                                        // Note: Recommended minimum tappable area is 44x44.
                                        .frame(width: 44, height: 44)
                                        .background(.green.opacity(0.25))
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

                                                    isFocused = false
                                                }
                                        )

                                    Spacer()

                                    DragIndicatorView()
                                        // Note: Recommended minimum tappable area is 44x44.
                                        .frame(width: 44, height: 44)
                                        .background(.green.opacity(0.25))
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

                                                    isFocused = false
                                                }
                                        )
                                }
                                .frame(height: proxy.size.height, alignment: .bottom)
                            }
                            .padding(-26)
                        }
                    }
                }
            // .overlay {
            //    if isSelected {
            //        GeometryReader { proxy in
            //            TextBoxToolbar(
            //                box: $box,
            //                onDuplicateClick: onDuplicateClick,
            //                onRemoveClick: onRemoveClick
            //            )
            //            .position(x: proxy.size.width / 2, y: -32)
            //        }
            //    }
            // }
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

//    private func calculateTextWidth() {
//        var traits: UIFontDescriptor.SymbolicTraits = []
//
//        if block.isBold {
//            traits.insert(.traitBold)
//        }
//
//        if block.isItalic {
//            traits.insert(.traitItalic)
//        }
//
//        let baseFont = UIFont.systemFont(ofSize: block.fontSize)
//        var fontDescriptor = baseFont.fontDescriptor
//
//        if !traits.isEmpty, let descriptorWithTraits = fontDescriptor.withSymbolicTraits(traits) {
//            fontDescriptor = descriptorWithTraits
//        }
//
//        let font = UIFont(descriptor: fontDescriptor, size: block.fontSize)
//
//        // Underline and Strikethrough styles
//        let underlineStyle: NSUnderlineStyle = block.isUnderline ? .single : []
//        let strikethroughStyle: NSUnderlineStyle = block.isStrikethrough ? .single : []
//
//        // Paragraph style with text alignment
//        let paragraphStyle = NSMutableParagraphStyle()
//
//        switch block.alignment {
//        case .leading:
//            paragraphStyle.alignment = .left
//        case .center:
//            paragraphStyle.alignment = .center
//        case .trailing:
//            paragraphStyle.alignment = .right
//        }
//
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: font,
//            .foregroundColor: UIColor(block.textColor),
//            .underlineStyle: underlineStyle.rawValue,
//            .strikethroughStyle: strikethroughStyle.rawValue,
//            .paragraphStyle: paragraphStyle
//        ]
//        let size = (block.text as NSString).size(withAttributes: attributes)
//
//        // Update the width
//        withAnimation {
//            block.width = min(max(size.width + 32, minSize.), textBoxMaxWidth)
//            textBoxHeight = size.height + 32
//            print("debug3: calculateTextWidth: size: \(size)")
//        }
//    }
}

#Preview {
    @Previewable @State var shape = ShapeBlock(
        position: CGPoint(
            x: UIScreen.main.bounds.size.width / 2,
            y: UIScreen.main.bounds.size.height / 2
        )
    )

    ZStack {
        ShapeBlockView(
            block: $shape,
            isSelected: true,
            contentSize: UIScreen.main.bounds.size,
            onClick: {},
            onDuplicateClick: {},
            onRemoveClick: {}
        )
    }
}

// struct TextBoxToolbar: View {
//    @Binding var box: TextBox
//    let onDuplicateClick: () -> Void
//    let onRemoveClick: () -> Void
//
//    @State private var showTextFormatPopover: Bool = false
//
//    var body: some View {
//        HStack(spacing: 0) {
//            Button {
//                showTextFormatPopover.toggle()
//            } label: {
//                Image(systemName: "textformat")
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 8)
//            }
//            .popover(isPresented: $showTextFormatPopover, arrowEdge: .bottom) {
//                TextFormatPopoverView(box: $box)
//                    .presentationCompactAdaptation(.none)
//            }
//
//            Divider()
//                .frame(height: 20)
//
//            Button {
//                onDuplicateClick()
//            } label: {
//                Image(systemName: "plus.square.on.square")
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 8)
//            }
//
//            Button {
//                onRemoveClick()
//            } label: {
//                Image(systemName: "trash")
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 8)
//            }
//            .tint(.red)
//        }
//        .tint(.black)
//        .padding(.horizontal, 0)
//        .padding(.vertical, 0)
//        .background(.regularMaterial)
//        .clipShape(RoundedRectangle(cornerRadius: 50))
//        .shadow(color: .black.opacity(0.2), radius: 8)
//        .colorScheme(.light)
//    }
// }
//
// struct TextFormatPopoverView: View {
//    @Binding var box: TextBox
//
//    private let fontSizes: [Int] = [10, 12, 14, 18, 24, 36, 48, 64, 72, 96, 144]
//
//    var body: some View {
//        VStack {
//            HStack {
//                ControlGroup {
//                    Toggle(isOn: $block.isBold) {
//                        Label("Bold", systemImage: "bold")
//                    }
//                    Toggle(isOn: $block.isItalic) {
//                        Label("Italic", systemImage: "italic")
//                    }
//                    Toggle(isOn: $block.isUnderline) {
//                        Label("Underline", systemImage: "underline")
//                    }
//                    Toggle(isOn: $block.isStrikethrough) {
//                        Label("Strikethrough", systemImage: "strikethrough")
//                    }
//                }
//                .controlGroupStyle(ControlGroupNoneSeparatorStyle())
//
//                ColorPicker("", selection: $block.textColor)
//                    .labelsHidden()
//            }
//
//            HStack {
//                SwiftUI.Menu {
//                    ForEach(fontSizes, id: \.self) { size in
//                        Button("\(size) pt") {
//                            block.fontSize = CGFloat(size)
//                        }
//                    }
//                } label: {
//                    Text("\(Int(block.fontSize)) pt")
//                        .foregroundColor(.label)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, UIDevice.current.isPhone ? 3.8 : 3.9)
//                        .background(Color.tertiarySystemFill)
//                        .cornerRadius(8)
//                }
//
//                ControlGroup {
//                    Button(action: {
//                        block.fontSize -= 1
//                    }) {
//                        Label("Decrease", systemImage: "minus")
//                    }
//
//                    Button(action: {
//                        block.fontSize += 1
//                    }) {
//                        Label("Increase", systemImage: "plus")
//                    }
//                }
//            }
//
//            Picker("", selection: $block.alignment) {
//                Image(systemName: "text.alignleft").tag(TextAlignment.leading)
//                Image(systemName: "text.aligncenter").tag(TextAlignment.center)
//                Image(systemName: "text.alignright").tag(TextAlignment.trailing)
//            }
//            .pickerStyle(.segmented)
//        }
//        .padding(8)
//    }
// }

struct DragIndicatorView: View {
    var body: some View {
        Circle()
            .fill(Color.blue)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .frame(width: 16, height: 16)
    }
}
