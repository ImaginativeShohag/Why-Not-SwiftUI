//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PencilKit
import SwiftUI

// TODO: #1: Pass image through parameter and finalize the flow from image select/capture to markup and add to the main view.
// TODO: #2: Finalize CanvasViewWrapper code.

public struct ImageMarkupScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.undoManager) private var undoManager: UndoManager!

    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var canUndo = false
    @State private var canRedo = false
    @State private var isProcessing = false

    private var image: UIImage
    private var onSuccess: @Sendable (UIImage) -> Void

    public init(
        image: UIImage,
        onSuccess: @escaping @Sendable (UIImage) -> Void
    ) {
        self.image = image
        self.onSuccess = onSuccess
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                CanvasViewWrapper(
                    image: image,
                    canvasView: canvasView,
                    toolPicker: toolPicker
                )

                if isProcessing {
                    ZStack {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(true)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Markup")
            .navigationBarTitleDisplayMode(.inline)
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
                        Button("Clear") {
                            // Without undoing using UndoManager, the buttons are not working correctly.

                            // Manually undo all drawings.
                            for _ in 0 ..< undoManager.undoCount {
                                undoManager.undo()
                            }

                            // Finally reset all actions.
                            undoManager.removeAllActions()
                        }

                        Button("Done") {
                            Task.detached(priority: .userInitiated) {
                                await MainActor.run {
                                    isProcessing = true
                                }

                                let finalImage = await canvasView.renderedImage(onto: image)

                                onSuccess(finalImage)

                                await dismiss()
                            }
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
    }

    func updateUndoRedoControls() {
        canUndo = undoManager.canUndo
        canRedo = undoManager.canRedo
    }
}

extension PKCanvasView {
    /// Combines the current PKCanvasView drawing with a given UIImage and returns the resulting UIImage.
    /// - Parameter image: The UIImage you want to combine with the current drawing.
    /// - Returns: A new UIImage that includes the original image and the canvas drawing.
    func renderedImage(onto image: UIImage) -> UIImage {
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

            // Render the canvasView drawing
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }

        return combinedImage
    }
}

#Preview {
    ZStack {}
        .fullScreenCover(isPresented: .constant(true)) {
            ImageMarkupScreen(
                image: UIImage(named: "boliviainteligente-llyebZWmLM0-unsplash")!,
                onSuccess: { _ in
                    //
                }
            )
        }
}
