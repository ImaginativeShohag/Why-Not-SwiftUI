//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import PencilKit
import SwiftUI

// TODO: #8: Add text to the undo manager
// TODO: #9: Auto width change on text input; only if user didn't change the width
// TODO: #11: BUG: if the popover too top, its height not looks ok
// TODO: #13: BUG: image jump issue on load
// TODO: #14: BUG: first time width change jumping issue

struct CanvasViewWrapper: View {
    let image: UIImage
    @Binding var textBoxes: [TextBox]
    let canvasView: PKCanvasView
    let toolPicker: PKToolPicker

    @State private var viewModel = CanvasViewViewModel()
    @State private var keyboardObserver = KeyboardObserver()
    @State private var contentSize: CGSize = .zero

    var body: some View {
        ZoomableScrollView {
            GeometryReader { proxy in
                ZStack(alignment: .center) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: contentSize.width, height: contentSize.height)

                    CanvasView(
                        canvasView: canvasView,
                        toolPicker: toolPicker,
                        onAddTextClick: {
                            addNewTextBox()
                        },
                        onDrawingDidChange: {
                            viewModel.selectedTextBoxId = nil
                        }
                    )
                    .frame(width: contentSize.width, height: contentSize.height)
                    .disabled(keyboardObserver.isKeyboardVisible)

                    ZStack(alignment: .center) {
                        ForEach($textBoxes) { $box in
                            TextBoxView(
                                box: $box,
                                isSelected: box.id == viewModel.selectedTextBoxId,
                                contentSize: contentSize,
                                onClick: {
                                    viewModel.selectedTextBoxId = box.id
                                },
                                onDuplicateClick: {
                                    addDuplicateTextBox(box: box)
                                },
                                onRemoveClick: {
                                    textBoxes.remove(at: textBoxes.firstIndex(of: $box.wrappedValue)!)
                                }
                            )
                        }
                    }
                    .frame(width: contentSize.width, height: contentSize.height)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .onAppear {
                    let containerSize = proxy.size
                    let imageAspectRatio = image.size.width / image.size.height
                    let containerAspectRatio = containerSize.width / containerSize.height

                    // Calculate the appropriate width and height to fit the image entirely inside the container
                    var width: CGFloat {
                        if containerAspectRatio > imageAspectRatio {
                            // Container is wider than the image's aspect ratio, limit by height
                            height * imageAspectRatio
                        } else {
                            // Container is narrower, limit by width
                            containerSize.width
                        }
                    }

                    var height: CGFloat {
                        if containerAspectRatio > imageAspectRatio {
                            // Container is wider than the image's aspect ratio, limit by height
                            containerSize.height
                        } else {
                            // Container is narrower, limit by width
                            width / imageAspectRatio
                        }
                    }

                    self.contentSize = CGSize(width: width, height: height)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: keyboardObserver.isKeyboardVisible) { _, isKeyboardVisible in
            print("debug2: keyboardVisible: \(isKeyboardVisible)")
            Task { @MainActor in
                if !isKeyboardVisible {
                    toolPicker.setVisible(true, forFirstResponder: canvasView)
                    canvasView.becomeFirstResponder()
                }
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                print("debug2: tap on canvas: \(keyboardObserver.isKeyboardVisible) | toolPicker.isVisible: \(toolPicker.isVisible)")

                if keyboardObserver.isKeyboardVisible {
                    UIApplication.shared.hideKeyboard()
                } else {
                    viewModel.selectedTextBoxId = nil
                }

            },
            including: .gesture
        )
        .toolbarVisibility(keyboardObserver.isKeyboardVisible ? .hidden : .visible, for: .automatic)
    }

    @MainActor
    private func addNewTextBox() {
        let newBox = TextBox(
            position: CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
        )
        textBoxes.append(newBox)

        viewModel.selectedTextBoxId = newBox.id
    }

    @MainActor
    private func addDuplicateTextBox(box: TextBox) {
        let newBox = box.copy(
            position: CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
        )
        textBoxes.append(newBox)

        viewModel.selectedTextBoxId = newBox.id
    }
}

struct TextBoxView: View {
    @Binding var box: TextBox
    let isSelected: Bool
    let contentSize: CGSize
    let onClick: () -> Void
    let onDuplicateClick: () -> Void
    let onRemoveClick: () -> Void

    @FocusState private var isFocused: Bool
    @State private var dragOffset: CGSize = .zero // Track drag offset separately

    var textBoxMaxWidth: CGFloat {
        return contentSize.width - 32
    }

    var body: some View {
        ZStack {
            TextField("Enter text", text: $box.text, axis: .vertical)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .disabled(!isSelected)
                .multilineTextAlignment(box.alignment)
                .submitLabel(.return)
                .font(.system(size: box.fontSize))
                .bold(box.isBold)
                .italic(box.isItalic)
                .underline(box.isUnderline, color: box.textColor)
                .strikethrough(box.isStrikethrough, color: box.textColor)
                .foregroundColor(box.textColor)
                // .onChange(of: box.text) { _, _ in
                //    calculateTextWidth()
                // }
                .padding(5)
                .frame(width: box.width)
                // Note: This makes the content clickable even when the TextField is disabled.
                .contentShape(Rectangle())
                .overlay {
                    if isSelected {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.systemBlue, lineWidth: 2)
                        }
                        // .animation(.default, value: box.width)
                        .padding(.horizontal, -4)
                        .overlay {
                            GeometryReader { proxy in
                                HStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .frame(width: 16, height: 16)
                                        .frame(height: proxy.size.height)
                                        // Note: Recommended minimum tappable area is 44x44.
                                        .frame(width: 44)
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    let newWidth = box.width - value.translation.width
                                                    box.width = min(max(100, newWidth), textBoxMaxWidth)

                                                    isFocused = false
                                                }
                                        )
                                        .padding(.trailing, 4)

                                    Spacer()

                                    Circle()
                                        .fill(Color.blue)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .frame(width: 16, height: 16)
                                        .frame(height: proxy.size.height)
                                        // Note: Recommended minimum tappable area is 44x44.
                                        .frame(width: 44)
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    let newWidth = box.width + value.translation.width
                                                    box.width = min(max(100, newWidth), textBoxMaxWidth)

                                                    isFocused = false
                                                }
                                        )
                                        .padding(.leading, 4)
                                }
                                .frame(height: proxy.size.height)
                            }
                            .padding(.horizontal, -26)
                            // .animation(.default, value: box.width)
                        }
                    }
                }
                .overlay {
                    if isSelected {
                        GeometryReader { proxy in
                            TextBoxToolbar(
                                box: $box,
                                onDuplicateClick: onDuplicateClick,
                                onRemoveClick: onRemoveClick
                            )
                            .position(x: proxy.size.width / 2, y: -32)
                        }
                    }
                }
        }
        // .animation(.default, value: box.width)
        .position(box.position)
        .offset(dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let newX = box.position.x + value.translation.width
                    let newY = box.position.y + value.translation.height

                    // Clamp the position within allowed bounds
                    box.position.x = min(max(newX, 0), contentSize.width)
                    box.position.y = min(max(newY, 0), contentSize.height)

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
//        if box.isBold {
//            traits.insert(.traitBold)
//        }
//
//        if box.isItalic {
//            traits.insert(.traitItalic)
//        }
//
//        let baseFont = UIFont.systemFont(ofSize: box.fontSize)
//        var fontDescriptor = baseFont.fontDescriptor
//
//        if !traits.isEmpty, let descriptorWithTraits = fontDescriptor.withSymbolicTraits(traits) {
//            fontDescriptor = descriptorWithTraits
//        }
//
//        let font = UIFont(descriptor: fontDescriptor, size: box.fontSize)
//
//        // Underline and Strikethrough styles
//        let underlineStyle: NSUnderlineStyle = box.isUnderline ? .single : []
//        let strikethroughStyle: NSUnderlineStyle = box.isStrikethrough ? .single : []
//
//        // Paragraph style with text alignment
//        let paragraphStyle = NSMutableParagraphStyle()
//
//        switch box.alignment {
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
//            .foregroundColor: UIColor(box.textColor),
//            .underlineStyle: underlineStyle.rawValue,
//            .strikethroughStyle: strikethroughStyle.rawValue,
//            .paragraphStyle: paragraphStyle
//        ]
//        let size = (box.text as NSString).size(withAttributes: attributes)
//
//        // Update the width
//        withAnimation {
//            box.width = min(max(size.width + 32, 100), textBoxMaxWidth)
//            textBoxHeight = size.height + 32
//            print("debug3: calculateTextWidth: size: \(size)")
//        }
//    }
}

#Preview {
    @Previewable @State var textBoxes: [TextBox] = [
        TextBox(text: "Text", width: 100, position: CGPoint(x: 100, y: 100)),
        TextBox(text: "A\nMultiline\nText", position: CGPoint(x: 200, y: 200))
    ]

    CanvasViewWrapper(
        image: UIImage(named: "boliviainteligente-llyebZWmLM0-unsplash")!,
        textBoxes: $textBoxes,
        canvasView: PKCanvasView(),
        toolPicker: PKToolPicker()
    )
}

struct TextBoxToolbar: View {
    @Binding var box: TextBox
    let onDuplicateClick: () -> Void
    let onRemoveClick: () -> Void

    @State private var showTextFormatPopover: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            Button {
                showTextFormatPopover.toggle()
            } label: {
                Image(systemName: "textformat")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .popover(isPresented: $showTextFormatPopover, arrowEdge: .bottom) {
                TextFormatPopoverView(box: $box)
                    .presentationCompactAdaptation(.none)
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
        .colorScheme(.light)
    }
}

struct TextFormatPopoverView: View {
    @Binding var box: TextBox

    private let fontSizes: [Int] = [10, 12, 14, 18, 24, 36, 48, 64, 72, 96, 144]

    var body: some View {
        VStack {
            HStack {
                ControlGroup {
                    Toggle(isOn: $box.isBold) {
                        Label("Bold", systemImage: "bold")
                    }
                    Toggle(isOn: $box.isItalic) {
                        Label("Italic", systemImage: "italic")
                    }
                    Toggle(isOn: $box.isUnderline) {
                        Label("Underline", systemImage: "underline")
                    }
                    Toggle(isOn: $box.isStrikethrough) {
                        Label("Strikethrough", systemImage: "strikethrough")
                    }
                }
                .controlGroupStyle(ControlGroupNoneSeparatorStyle())

                ColorPicker("", selection: $box.textColor)
                    .labelsHidden()
            }

            HStack {
                SwiftUI.Menu {
                    ForEach(fontSizes, id: \.self) { size in
                        Button("\(size) pt") {
                            box.fontSize = CGFloat(size)
                        }
                    }
                } label: {
                    Text("\(Int(box.fontSize)) pt")
                        .foregroundColor(.label)
                        .padding(.horizontal, 8)
                        .padding(.vertical, UIDevice.current.isPhone ? 3.8 : 3.9)
                        .background(Color.tertiarySystemFill)
                        .cornerRadius(8)
                }

                ControlGroup {
                    Button(action: {
                        box.fontSize -= 1
                    }) {
                        Label("Decrease", systemImage: "minus")
                    }

                    Button(action: {
                        box.fontSize += 1
                    }) {
                        Label("Increase", systemImage: "plus")
                    }
                }
            }

            Picker("", selection: $box.alignment) {
                Image(systemName: "text.alignleft").tag(TextAlignment.leading)
                Image(systemName: "text.aligncenter").tag(TextAlignment.center)
                Image(systemName: "text.alignright").tag(TextAlignment.trailing)
            }
            .pickerStyle(.segmented)
        }
        .padding(8)
    }
}

struct CanvasView: UIViewRepresentable {
    let canvasView: PKCanvasView
    let toolPicker: PKToolPicker
    let onAddTextClick: () -> Void
    let onDrawingDidChange: () -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.tool = PKInkingTool(.pen, color: .red, width: 2)

        canvasView.delegate = context.coordinator

        initToolPicker()

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView

        init(_ parent: CanvasView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.onDrawingDidChange()
        }
    }
}

extension CanvasView {
    func initToolPicker() {
        // Init menu
        let addTextAction = UIAction(
            title: "Add Text",
            image: UIImage(systemName: "character.textbox")
        ) { _ in
            onAddTextClick()
        }
        let menu = UIMenu(children: [addTextAction])
        toolPicker.accessoryItem = UIBarButtonItem(systemItem: .add, menu: menu)

        // Bind with canvas
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
}

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
