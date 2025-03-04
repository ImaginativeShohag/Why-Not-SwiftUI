//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PencilKit
import SwiftUI

struct CanvasViewWrapper: View {
    let image: UIImage
    let canvasView: PKCanvasView
    let toolPicker: PKToolPicker

    var body: some View {
        ZoomableScrollView {
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = width * (image.size.height / image.size.width)

                ZStack(alignment: .center) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: width, height: height)

                    CanvasView(canvasView: canvasView, toolPicker: toolPicker)
                        .frame(width: width, height: height)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CanvasViewWrapper(
        image: UIImage(named: "boliviainteligente-llyebZWmLM0-unsplash")!,
        canvasView: PKCanvasView(),
        toolPicker: PKToolPicker()
    )
}

struct CanvasView: UIViewRepresentable {
    let canvasView: PKCanvasView
    let toolPicker: PKToolPicker

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.tool = PKInkingTool(.pen, color: .red, width: 2)

        canvasView.delegate = context.coordinator

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        showToolPicker()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView

        init(_ parent: CanvasView) {
            self.parent = parent
        }
    }
}

extension CanvasView {
    func showToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
}
