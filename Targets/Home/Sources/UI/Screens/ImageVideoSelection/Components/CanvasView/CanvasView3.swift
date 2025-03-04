//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PencilKit
import SwiftUI

// programatically add cgpoints: https://stackoverflow.com/questions/70274330/how-do-i-create-a-pkdrawing-programmatically-from-cgpoints/70274331#70274331

//        ZStack {
//            GeometryReader { proxy in
//                CanvasView3(canvasView: canvasView, size: proxy.size)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//        }

struct CanvasView3: UIViewRepresentable {
    let canvasView: PKCanvasView
    let size: CGSize

    let toolPicker = PKToolPicker()

    @State var imageView: UIImageView? = nil
    @State var scale = 1.0

    let imageName: String = "boliviainteligente-llyebZWmLM0-unsplash"

    func makeUIView(context: Context) -> UIScrollView {
        canvasView.drawingPolicy = .anyInput
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.tool = PKInkingTool(.pen, color: .red, width: 2)
        // canvasView.translatesAutoresizingMaskIntoConstraints = false

        // Set a background image
        let uiImage = UIImage(named: imageName)!
        let imageView = UIImageView(image: uiImage)
        imageView.contentMode = .scaleAspectFit
        //        Task { @MainActor in
        //            self.imageView = imageView
        //            imageView.frame = canvasView.bounds
        //            print("frame: \(canvasView.bounds)")
        //        }
        imageView.translatesAutoresizingMaskIntoConstraints = false

        canvasView.addSubview(imageView)
        canvasView.sendSubviewToBack(imageView)

        // Zoom
        canvasView.minimumZoomScale = 1.0
        canvasView.maximumZoomScale = 5.0
        canvasView.zoomScale = 1
        //        canvasView.frame.size = canvasView.contentSize
        canvasView.contentMode = .center
        canvasView.scrollsToTop = false
        canvasView.bouncesZoom = true

        // Inset
        // canvasView.contentInset = UIEdgeInsets(top: 500, left: 500, bottom: 500, right: 500)

        canvasView.delegate = context.coordinator

        Task { @MainActor in
            let imageWidth = uiImage.size.width
            let imageHeight = uiImage.size.height
            let containerWidth = canvasView.frame.width
            let targetImageHeight = containerWidth * (imageHeight / imageWidth)

            print("imageWidth: \(imageWidth)")
            print("imageHeight: \(imageHeight)")
            print("containerWidth: \(containerWidth)")
            print("targetImageHeight: \(targetImageHeight)")

            NSLayoutConstraint.activate([
                // imageView.centerXAnchor.constraint(equalTo: canvasView.centerXAnchor),
                // imageView.centerYAnchor.constraint(equalTo: canvasView.centerYAnchor),

                imageView.leadingAnchor.constraint(equalTo: canvasView.frameLayoutGuide.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: canvasView.frameLayoutGuide.trailingAnchor),
                imageView.topAnchor.constraint(equalTo: canvasView.frameLayoutGuide.topAnchor),
//                        imageView.bottomAnchor.constraint(equalTo: canvasView.frameLayoutGuide.bottomAnchor),

                //                imageView.widthAnchor.constraint(equalTo: canvasView.widthAnchor),
                // imageView.heightAnchor.constraint(equalTo: canvasView.heightAnchor)
                //                imageView.widthAnchor.constraint(equalToConstant: containerWidth),
                //                imageView.heightAnchor.constraint(equalToConstant: targetImageHeight)

                //                imageView.topAnchor.constraint(equalTo: canvasView.contentLayoutGuide.topAnchor),
                //                imageView.leadingAnchor.constraint(equalTo: canvasView.contentLayoutGuide.leadingAnchor),
                //                imageView.trailingAnchor.constraint(equalTo: canvasView.contentLayoutGuide.trailingAnchor),
                //                imageView.bottomAnchor.constraint(equalTo: canvasView.contentLayoutGuide.bottomAnchor),
                //
                //                imageView.widthAnchor.constraint(equalTo: canvasView.frameLayoutGuide.widthAnchor),
                //                imageView.heightAnchor.constraint(greaterThanOrEqualTo: canvasView.frameLayoutGuide.heightAnchor),

                imageView.widthAnchor.constraint(equalToConstant: containerWidth),
                imageView.heightAnchor.constraint(equalToConstant: targetImageHeight),

//                imageView.centerXAnchor.constraint(equalTo: canvasView.centerXAnchor),
//                imageView.centerYAnchor.constraint(equalTo: canvasView.centerYAnchor),
                //                imageView.widthAnchor.constraint(equalToConstant: size.width),
                //                imageView.heightAnchor.constraint(equalToConstant: size.height)
            ])
        }

        return canvasView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
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

    class Coordinator: NSObject, PKCanvasViewDelegate, UIScrollViewDelegate {
        var parent: CanvasView3

        init(_ parent: CanvasView3) {
            self.parent = parent
        }

//        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//            return scrollView.subviews.first // The container with the image & canvas
//        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let imageView = scrollView.subviews.first else { return }

            let scrollViewSize = scrollView.bounds.size
            let contentSize = scrollView.contentSize
            let contentOffset = scrollView.contentOffset

            let offsetX = max((scrollViewSize.width - contentSize.width) / 2, 0)
            let offsetY = max((scrollViewSize.height - contentSize.height) / 2, 0)
            
            print("contentOffset \(contentOffset)")
            print("offsetX \(offsetX)")
            print("offsetY \(offsetY)")

            // Adjust the position of the moving view based on the zoomed content and scroll position
            imageView.frame.origin = CGPoint(
                x: contentOffset.x + offsetX,
                y: contentOffset.y + offsetY
            )
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let imageView = scrollView.subviews.first else { return }

            // print("first view: \(imageView)")

            // Center the imageView when zooming
//            let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
//            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
//
//            imageView.center = CGPoint(
//                x: scrollView.contentSize.width * 0.5 + offsetX,
//                y: scrollView.contentSize.height * 0.5 + offsetY
//            )

            let scale = scrollView.zoomScale
            imageView.transform = CGAffineTransform(scaleX: scale, y: scale)

            // ----
        }
    }
}

extension CanvasView3 {
    func showToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
}
