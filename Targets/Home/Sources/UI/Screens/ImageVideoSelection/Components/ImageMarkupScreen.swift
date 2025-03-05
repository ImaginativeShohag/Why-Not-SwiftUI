//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PencilKit
import SwiftUI

// TODO: #2: Finalize CanvasViewWrapper code.
// TODO: #3: Fix on dismiss reset photos library selection

public struct ImageMarkupScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.undoManager) private var undoManager: UndoManager!

    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var canUndo = false
    @State private var canRedo = false
    @State private var isProcessing = false
    @State private var canDraw = false

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
                if canDraw {
                    CanvasViewWrapper(
                        image: image,
                        canvasView: canvasView,
                        toolPicker: toolPicker
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(canDraw ? "Markup" : "Preview")
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
                if canDraw {
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
                                clearDrawing()
                            }

                            Button("Done") {
                                processAndDismiss()
                            }
                            .fontWeight(.medium)
                        }
                        .disabled(isProcessing)
                    }
                } else {
                    ToolbarItem(placement: .bottomBar) {
                        HStack(spacing: 8) {
                            Button {
                                dismiss()
                            } label: {
                                Text("Cancel")
                            }

                            Spacer()
                            Button {
                                canDraw.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: "pencil.tip.crop.circle")
                                    Text("Markup")
                                }
                            }

                            Spacer()

                            Button {
                                onSuccess(image)

                                dismiss()
                            } label: {
                                Text("Add")
                                    .fontWeight(.medium)
                            }
                        }
                    }
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
            .task {
                try? await Task.sleep(for: .seconds(0.1))

                toolPicker.setVisible(false, forFirstResponder: canvasView)
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

            let finalImage = await canvasView.renderedImage(onto: image)

            onSuccess(finalImage)

            await dismiss()
        }
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
