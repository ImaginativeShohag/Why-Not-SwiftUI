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
// TODO: #15: Text format toolbar: end menu

struct CanvasViewWrapper: View {
    let image: UIImage
    @Binding var textBoxes: [TextBox]
    @Binding var shapes: [ShapeBlock]
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
                        onAddShapeClick: {
                            addNewShapeBox()
                        },
                        onDrawingDidChange: {
                            viewModel.selectedTextBoxId = nil
                            viewModel.selectedShapeId = nil
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

                        ForEach($shapes) { $shape in
                            ShapeBlockView(
                                block: $shape,
                                isSelected: shape.id == viewModel.selectedShapeId,
                                contentSize: contentSize,
                                onClick: {
                                     viewModel.selectedShapeId = shape.id
                                },
                                onDuplicateClick: {
                                    addDuplicateShape(shape: shape)
                                },
                                onRemoveClick: {
                                    shapes.remove(at: shapes.firstIndex(of: $shape.wrappedValue)!)
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
                    viewModel.selectedShapeId = nil
                }

            },
            including: .gesture
        )
        .toolbarVisibility(keyboardObserver.isKeyboardVisible ? .hidden : .visible, for: .automatic)
    }

    private func addNewTextBox() {
        let newBox = TextBox(
            position: CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
        )
        textBoxes.append(newBox)

        viewModel.selectedTextBoxId = newBox.id
        viewModel.selectedShapeId = nil
    }

    private func addDuplicateTextBox(box: TextBox) {
        let newBox = box.copy(
            position: CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
        )
        textBoxes.append(newBox)

        viewModel.selectedTextBoxId = newBox.id
        viewModel.selectedShapeId = nil
    }
    
    private func addNewShapeBox() {
        let newBlock = ShapeBlock(
            position: CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
        )
        shapes.append(newBlock)

        viewModel.selectedTextBoxId = nil
        viewModel.selectedShapeId = newBlock.id
    }
    
    private func addDuplicateShape(shape: ShapeBlock) {
        let newShape = shape.copy(
            position: CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
        )
        shapes.append(newShape)

        viewModel.selectedTextBoxId = nil
        viewModel.selectedShapeId = newShape.id
    }
}

#Preview {
    @Previewable @State var textBoxes: [TextBox] = [
        TextBox(text: "Text", width: 100, position: CGPoint(x: 100, y: 100)),
        TextBox(text: "A\nMultiline\nText", textColor: .white, position: CGPoint(x: 300, y: 200))
    ]
    @Previewable @State var shapes: [ShapeBlock] = [
        ShapeBlock(size: CGSize(width: 100, height: 100), position: CGPoint(x: 200, y: 100))
    ]

    CanvasViewWrapper(
        image: UIImage(named: "boliviainteligente-llyebZWmLM0-unsplash")!,
        textBoxes: $textBoxes,
        shapes: $shapes,
        canvasView: PKCanvasView(),
        toolPicker: PKToolPicker()
    )
}

struct CanvasView: UIViewRepresentable {
    let canvasView: PKCanvasView
    let toolPicker: PKToolPicker
    let onAddTextClick: () -> Void
    let onAddShapeClick: () -> Void
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
        let addShapeAction = UIAction(
            title: "Add Shape",
            image: UIImage(systemName: "square.on.circle")
        ) { _ in
            onAddShapeClick()
        }
        let menu = UIMenu(children: [addShapeAction, addTextAction])
        toolPicker.accessoryItem = UIBarButtonItem(systemItem: .add, menu: menu)

        // Bind with canvas
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
}

struct ShapeBlock: Identifiable, Equatable {
    var id = UUID().uuidString
    var backgroundColor: Color = .gray
    var borderSize: CGFloat = 5
    var borderColor: Color = .red
    var cornerRadius: CGFloat = 10
    var opacity: Double = 1

    var size: CGSize = CGSize(width: 100, height: 100)
    var position: CGPoint = .zero
}

extension ShapeBlock {
    func copy(
        id: String? = UUID().uuidString,
        backgroundColor: Color? = nil,
        borderSize: CGFloat? = nil,
        borderColor: Color? = nil,
        cornerRadius: CGFloat? = nil,
        opacity: Double? = nil,
        size: CGSize? = nil,
        position: CGPoint? = nil
    ) -> ShapeBlock {
        ShapeBlock(
            id: id ?? self.id,
            backgroundColor: backgroundColor ?? self.backgroundColor,
            borderSize: borderSize ?? self.borderSize,
            borderColor: borderColor ?? self.borderColor,
            cornerRadius: cornerRadius ?? self.cornerRadius,
            opacity: opacity ?? self.opacity,
            size: size ?? self.size,
            position: position ?? self.position
        )
    }
}
