//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PencilKit
import SwiftUI

// TODO: #2: Finalize CanvasViewWrapper code.
// TODO: #3: Fix on dismiss reset photos library selection
// TODO: #4: process to scale down the image (also add parameter  maxImageSize: CGSize? = nil,)

public struct ImageMarkupScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.undoManager) private var undoManager: UndoManager!

    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var canUndo = false
    @State private var canRedo = false
    @State private var isProcessing = false

    @State var textBoxes: [TextBox] = []

    private var image: UIImage
    private var onSuccess: @Sendable (UIImage) -> Void

    public init(
        image: UIImage,
        onSuccess: @escaping @Sendable (UIImage) -> Void
    ) {
        self.image = image
        self.onSuccess = onSuccess

        print("debug1: init: imagesize: \(image.size)")
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                CanvasViewWrapper(
                    image: image,
                    textBoxes: $textBoxes,
                    canvasView: canvasView,
                    toolPicker: toolPicker
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Note: This will fix keyboard focus jumping.
                .ignoresSafeArea(.all)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Markup")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if isProcessing {
                    ZStack {
                        ProgressView {
                            Text("Processing...")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.regularMaterial)
                    .allowsHitTesting(true)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }

                        if UIDevice.current.isPhone {
                            Button("Undo", systemImage: "arrow.uturn.backward.circle") {
                                undoManager?.undo()
                            }
                            .disabled(!canUndo)

                            Button("Redo", systemImage: "arrow.uturn.forward.circle") {
                                undoManager?.redo()
                            }
                            .disabled(!canRedo)
                        }
                    }
                    .disabled(isProcessing)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        Button("Clear", systemImage: "trash") {
                            clearDrawing()
                        }

                        Button("Done") {
                            processAndDismiss()
                        }
                        .fontWeight(.medium)
                    }
                    .disabled(isProcessing)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSUndoManagerDidCloseUndoGroup)) { _ in
                updateUndoRedoControls()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSUndoManagerDidUndoChange)) { _ in
                updateUndoRedoControls()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSUndoManagerDidRedoChange)) { _ in
                updateUndoRedoControls()
            }
        }
        // Note: This fix the top app bar transparent issue.
        .background(Color.systemBackground)
    }

    func updateUndoRedoControls() {
        canUndo = undoManager.canUndo
        canRedo = undoManager.canRedo
    }

    func clearDrawing() {
        // Without undoing using UndoManager, the buttons are not working correctly.

        // Manually undo all drawings.
        for _ in 0 ..< undoManager.undoCount {
            undoManager.undo()
        }

        // Finally reset all actions.
        undoManager.removeAllActions()
    }

    func processAndDismiss() {
        Task.detached(priority: .userInitiated) {
            await MainActor.run {
                toolPicker.setVisible(false, forFirstResponder: canvasView)

                isProcessing = true
            }

            let finalImage = await canvasView.renderedImage(onto: image, textBoxes: textBoxes)

            onSuccess(finalImage)

            await dismiss()
        }
    }
}

extension PKCanvasView {
    /// Combines the current PKCanvasView drawing with a given UIImage and returns the resulting UIImage.
    /// - Parameter image: The UIImage you want to combine with the current drawing.
    /// - Returns: A new UIImage that includes the original image and the canvas drawing.
    func renderedImage(onto image: UIImage, textBoxes: [TextBox]) -> UIImage {
        let imageSize = image.size

        // Render the combined image
        let renderer = UIGraphicsImageRenderer(size: imageSize)

        let combinedImage = renderer.image { context in
            // Draw the original UIImage first
            image.draw(in: CGRect(origin: .zero, size: imageSize))

            // Scale the drawing from canvasView to fit the original image size
            let scaleX = imageSize.width / bounds.width
            let scaleY = imageSize.height / bounds.height
            context.cgContext.scaleBy(x: scaleX, y: scaleY)

            // Text blocks
//            let swiftUIView = ZStack {
//                ForEach(textBoxes) { box in
//                    Text(box.text)
//                        .font(.system(size: 35, weight: box.isBold ? .bold : .regular))
//                        .fontWeight(box.isBold ? .bold : .none)
//                        .foregroundColor(box.textColor)
//                        .offset(box.offset)
//                }
//            }
//            let controller = UIHostingController(rootView: swiftUIView).view!
//            controller.frame = CGRect(origin: .zero, size: bounds.size)
//            controller.backgroundColor = .clear
//            controller.drawHierarchy(in: bounds, afterScreenUpdates: true)

            // do benchmark for speed and memory usage
            for box in textBoxes {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 35, weight: box.isBold ? .bold : .regular),
                    .foregroundColor: UIColor(box.textColor)
                ]

                let attributedText = NSAttributedString(string: box.text, attributes: attributes)

                // Calculate text size
                let textSize = attributedText.boundingRect(
                    with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                ).size

                // Convert center-relative offset to top-left coordinate system
                let centerX = bounds.width / 2
                let centerY = bounds.height / 2

                let adjustedX = centerX + box.position.x - (textSize.width / 2)
                let adjustedY = centerY + box.position.y - (textSize.height / 2)

                let textRect = CGRect(
                    origin: CGPoint(x: adjustedX, y: adjustedY),
                    size: textSize
                )

                attributedText.draw(in: textRect)
            }

            // Render the canvasView drawing
            // drawHierarchy(in: bounds, afterScreenUpdates: true) // do benchmark

            drawing.image(from: bounds, scale: UIScreen.main.scale)
                .draw(in: bounds)
        }

        print("debug1: imagesize: \(combinedImage.size)")

        return combinedImage
    }
}

#Preview {
    NavigationStack {
        ZStack {}
            .navigationTitle("Demo Screen")
            .fullScreenCover(isPresented: .constant(true)) {
                ImageMarkupScreen(
                    image: UIImage(named: "boliviainteligente-llyebZWmLM0-unsplash")!,
                    onSuccess: { _ in
                        //
                    }
                )
            }
    }
}

// MARK: - Text Box

struct TextBox: Identifiable, Equatable {
    var id = UUID().uuidString
    var text: String = "Text\nAnother\nLine"

    var isBold: Bool = false
    var isItalic: Bool = false
    var isUnderline: Bool = false
    var isStrikethrough: Bool = false
    var alignment: TextAlignment = .center

    var fontSize: CGFloat = 24
    var textColor: Color = .black

    var width: CGFloat = 100
    var position: CGPoint = .zero
}
