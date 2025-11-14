//
//  CanvasView22.swift
//  WhyNotSwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 26/02/2025.
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PencilKit
import SwiftUI

// programatically add cgpoints: https://stackoverflow.com/questions/70274330/how-do-i-create-a-pkdrawing-programmatically-from-cgpoints/70274331#70274331

struct CanvasView2: UIViewRepresentable {
    let canvasView: PKCanvasView
    let toolPicker = PKToolPicker()

    let imageName: String = "boliviainteligente-llyebZWmLM0-unsplash"

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.tool = PKInkingTool(.pen, color: .red, width: 2)

        // Set a background image
//        var uiImage = UIImage(named: imageName)!
//        //        // uiImage = uiImage?.withTintColor(.blue)
//        //        // uiImage = uiImage?.resized(to: CGSize(width: 500, height: 500))
//        let imageView = UIImageView(image: uiImage)
//        imageView.contentMode = .scaleAspectFit
//        Task { @MainActor in
//            imageView.frame = canvasView.bounds
//            print("frame: \(canvasView.bounds)")
//        }

//        // canvasView.contentSize = imageView.frame.size
//        // canvasView.frame = imageView.frame
//        canvasView.insertSubview(imageView, at: 0)
//        canvasView.sendSubviewToBack(imageView)

        // canvasView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)

        // Zoom
        //canvasView.minimumZoomScale = 1.0
        //canvasView.maximumZoomScale = 5.0
        //        canvasView.frame.size = canvasView.contentSize
        //canvasView.contentMode = .center
        //        canvasView.scrollsToTop = false

        // Inset
        // canvasView.contentInset = UIEdgeInsets(top: 500, left: 500, bottom: 500, right: 500)

        canvasView.delegate = context.coordinator

        //        DispatchQueue.main.async {
        //            if let screenSize = canvasView.window?.bounds.size {
        //                let scaleWidth = screenSize.width / uiImage.size.width
        //                let scaleHeight = screenSize.height / uiImage.size.height
        //                let initialScale = min(scaleWidth, scaleHeight)
        //
        //                canvasView.minimumZoomScale = initialScale
        //                canvasView.zoomScale = initialScale
        //
        //                // **Center the content initially**
        //                let offsetX = max((screenSize.width - uiImage.size.width * initialScale) / 2, 0)
        //                let offsetY = max((screenSize.height - uiImage.size.height * initialScale) / 2, 0)
        //                canvasView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        //            }
        //        }

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        showToolPicker()

        if let containerView = uiView.subviews.first {
            if let imageView = containerView.subviews.first as? UIImageView {
                imageView.image = UIImage(named: imageName)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView2

        init(_ parent: CanvasView2) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first // The container with the image & canvas
        }
    }
}

extension CanvasView2 {
    func showToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
}
