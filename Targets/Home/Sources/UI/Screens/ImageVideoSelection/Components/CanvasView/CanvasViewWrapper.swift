//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import PencilKit
import SwiftUI
import UIKit

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
                        onAddShapeClick: { shape in
                            addNewShapeBox(of: shape)
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

    private func addNewShapeBox(of type: ShapeBlockType) {
        let newBlock: ShapeBlock
        
        switch type {
            
        case .square:
            newBlock = ShapeBlock(
                type: type,
                borderSize: 0,
                borderColor: .clear,
                cornerRadius: 0,
                position: CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
            )
        case .roundedSquare:
            newBlock = ShapeBlock(
                type: type,
                borderSize: 5,
                cornerRadius: 16,
                position: CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
            )
        case .circle:
            newBlock = ShapeBlock(
                type: type,
                position: CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
            )
        }
        
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
    let onAddShapeClick: (ShapeBlockType) -> Void
    let onDrawingDidChange: () -> Void
    
    private let popoverPresenterDelegate = PopoverPresenter()

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
    
    private class PopoverPresenter: NSObject, UIPopoverPresentationControllerDelegate {
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none // Forces popover style even on iPhone
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
        ) { action in
            if let button = action.sender as? UIBarButtonItem {
                presentShapePickerPopover(from: button)
            }
        }

        let menu = UIMenu(children: [addShapeAction, addTextAction])
        toolPicker.accessoryItem = UIBarButtonItem(systemItem: .add, menu: menu)

        // Bind with canvas
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }

    private func presentShapePickerPopover(from barButtonItem: UIBarButtonItem) {
        guard let topVC = UIApplication.shared.rootViewController else {
            return
        }

        let view = ShapePickerView { shape in
            onAddShapeClick(shape)
        }

        let hostingController = UIHostingController(rootView: view)
        hostingController.modalPresentationStyle = .popover
        hostingController.preferredContentSize = CGSize(width: 224, height: 80)

        if let popover = hostingController.popoverPresentationController {
            popover.barButtonItem = barButtonItem
            popover.permittedArrowDirections = .down
            popover.delegate = popoverPresenterDelegate
        }

        topVC.present(hostingController, animated: true)
    }
}

enum ShapeBlockType: String, CaseIterable {
    case square = "squareshape.fill"
    case roundedSquare = "square.fill"
    case circle = "circle.fill"
}

struct ShapePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDetent: PresentationDetent = .medium

    let onClick: (ShapeBlockType) -> Void

    let items = ShapeBlockType.allCases

    var body: some View {
        VStack {
            let spacing: CGFloat = 8
            let columns = 3

            VStack(alignment: .leading, spacing: spacing) {
                ForEach(0..<rowsCount(), id: \.self) { rowIndex in
                    HStack(spacing: spacing) {
                        ForEach(0..<columns, id: \.self) { columnIndex in
                            let itemIndex = rowIndex * columns + columnIndex
                            let item = items[itemIndex]

                            if itemIndex < items.count {
                                Button {
                                    onClick(item)
                                    dismiss()
                                }label: {
                                    Image(systemName: item.rawValue)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .padding(16)
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundStyle(Color.gray)
                                        .cornerRadius(12)
                                }
                            } else {
                                Spacer()
                                    .frame(width: 32, height: 32)
                            }
                        }
                    }
                }
            }
            .padding(8) // Set height as needed to avoid scroll behavior
        }
    }

    private func rowsCount() -> Int {
        let items = items.count
        return (items + 2) / 3 // Integer division to cover all items
    }
}

#Preview {
    Text("")
        .popover(isPresented: .constant(true)) {
            ShapePickerView(onClick: { _ in })
                .presentationCompactAdaptation(.none)
        }
}

struct ShapeBlock: Identifiable, Equatable {
    var id = UUID().uuidString
    var type: ShapeBlockType = .square
    var backgroundColor: Color = .gray
    var borderSize: CGFloat = 5
    var borderColor: Color = .clear
    var cornerRadius: CGFloat = 16
    var opacity: Double = 1

    var size: CGSize = .init(width: 100, height: 100)
    var position: CGPoint = .zero
}

extension ShapeBlock {
    func copy(
        id: String? = UUID().uuidString,
        backgroundColor: Color? = nil,
        type: ShapeBlockType? = nil,
        borderSize: CGFloat? = nil,
        borderColor: Color? = nil,
        cornerRadius: CGFloat? = nil,
        opacity: Double? = nil,
        size: CGSize? = nil,
        position: CGPoint? = nil
    ) -> ShapeBlock {
        ShapeBlock(
            id: id ?? self.id,
            type: type ?? self.type,
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
