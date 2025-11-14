//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PencilKit
import SwiftUI

// programatically add cgpoints: https://stackoverflow.com/questions/70274330/how-do-i-create-a-pkdrawing-programmatically-from-cgpoints/70274331#70274331

struct CanvasView1: UIViewRepresentable {
    let canvasView: PKCanvasView
    let toolPicker = PKToolPicker()

    let imageName: String = "boliviainteligente-llyebZWmLM0-unsplash"

    func makeUIView(context: Context) -> UIScrollView {
//        canvasView.drawingPolicy = .anyInput
//        canvasView.isOpaque = false
//        canvasView.backgroundColor = .clear
//        canvasView.tool = PKInkingTool(.pen, color: .red, width: 2)
//
//        // Set a background image
//        var uiImage = UIImage(named: "boliviainteligente-llyebZWmLM0-unsplash")!
        ////        // uiImage = uiImage?.withTintColor(.blue)
        ////        // uiImage = uiImage?.resized(to: CGSize(width: 500, height: 500))
//        let imageView = UIImageView(image: uiImage)
//        imageView.contentMode = .scaleAspectFit
//        Task { @MainActor in
//            imageView.frame = canvasView.bounds
//            print("frame: \(canvasView.bounds)")
//        }
//
//
//        // canvasView.contentSize = imageView.frame.size
//        // canvasView.frame = imageView.frame
        ////        canvasView.addSubview(imageView)
//        canvasView.insertSubview(imageView, at: 0)
//        canvasView.sendSubviewToBack(imageView)
//
//        // canvasView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
//
//        // Zoom
//        canvasView.minimumZoomScale = 1.0
//        canvasView.maximumZoomScale = 5.0
        ////        canvasView.frame.size = canvasView.contentSize
//        canvasView.contentMode = .center
        ////        canvasView.scrollsToTop = false
//
//        // Inset
//        // canvasView.contentInset = UIEdgeInsets(top: 500, left: 500, bottom: 500, right: 500)
//
//        canvasView.delegate = context.coordinator
//
        ////        DispatchQueue.main.async {
        ////            if let screenSize = canvasView.window?.bounds.size {
        ////                let scaleWidth = screenSize.width / uiImage.size.width
        ////                let scaleHeight = screenSize.height / uiImage.size.height
        ////                let initialScale = min(scaleWidth, scaleHeight)
        ////
        ////                canvasView.minimumZoomScale = initialScale
        ////                canvasView.zoomScale = initialScale
        ////
        ////                // **Center the content initially**
        ////                let offsetX = max((screenSize.width - uiImage.size.width * initialScale) / 2, 0)
        ////                let offsetY = max((screenSize.height - uiImage.size.height * initialScale) / 2, 0)
        ////                canvasView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        ////            }
        ////        }
//
//        return canvasView

        // try 2 ----------------------------------------------------------------

//        let scrollView = UIScrollView()
//        scrollView.minimumZoomScale = 1.0
//        scrollView.maximumZoomScale = 5.0
//        scrollView.delegate = context.coordinator
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.bounces = false
//        scrollView.bouncesZoom = false
//        scrollView.alwaysBounceVertical = false
//        scrollView.alwaysBounceHorizontal = false
//        scrollView.backgroundColor = .black
//
//        // Load image
//        guard let image = UIImage(named: imageName) else { return scrollView }
//        let imageSize = image.size
//
//        // **Container for image & canvas**
//        let containerView = UIView(frame: CGRect(origin: .zero, size: imageSize))
//        containerView.backgroundColor = .clear
//
//        // **Background Image**
//        let backgroundImageView = UIImageView(image: image)
//        backgroundImageView.frame = containerView.bounds
//        backgroundImageView.contentMode = .scaleAspectFit
//
//        // **PKCanvasView setup**
//        canvasView.frame = containerView.bounds
//        canvasView.backgroundColor = .clear
//        canvasView.isOpaque = false
//        canvasView.drawingPolicy = .anyInput
//        canvasView.isUserInteractionEnabled = true
//
//        // **Add background & canvas**
//        containerView.addSubview(backgroundImageView)
//        containerView.addSubview(canvasView)
//
//        // **Set container as scroll view content**
//        scrollView.addSubview(containerView)
//        scrollView.contentSize = imageSize
//
//        // **Ensure Image & Canvas Stay Centered**
//        DispatchQueue.main.async {
//            if let screenSize = scrollView.window?.bounds.size {
//                let scaleWidth = screenSize.width / imageSize.width
//                let scaleHeight = screenSize.height / imageSize.height
//                let initialScale = min(scaleWidth, scaleHeight)
//
//                scrollView.minimumZoomScale = initialScale
//                scrollView.zoomScale = initialScale
//
//                // **Center the content initially**
//                let offsetX = max((screenSize.width - imageSize.width * initialScale) / 2, 0)
//                let offsetY = max((screenSize.height - imageSize.height * initialScale) / 2, 0)
//                scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
//            }
//        }
//
//        return scrollView

        // try 3 ---------------------------------------------------------------

        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = context.coordinator

        // Container view to hold the background and canvas
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Background Image
        let image = UIImage(named: imageName)!
        let backgroundImageView = UIImageView(image: image)
        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        // PKCanvasView setup
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.translatesAutoresizingMaskIntoConstraints = false

        // Add subviews
        containerView.addSubview(backgroundImageView)
        containerView.addSubview(canvasView)
        scrollView.addSubview(containerView)

        // Constraints to ensure the background and canvas match sizes
        Task { @MainActor in
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            let containerWidth = scrollView.frame.width

            print("imageWidth: \(imageWidth)")
            print("imageHeight: \(imageHeight)")
            print("containerWidth: \(containerWidth)")
            print("scrollView.safeAreaInsets.bottom: \(scrollView.safeAreaInsets.bottom)")

            NSLayoutConstraint.activate([
                //            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                //            containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

                containerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
                containerView.widthAnchor.constraint(equalToConstant: containerWidth), // Set desired width
                containerView.heightAnchor.constraint(equalToConstant: containerWidth * (imageHeight / imageWidth)), // Set desired height,

                // scrollView.widthAnchor.constraint(equalToConstant: containerWidth), // Set desired width
                // scrollView.heightAnchor.constraint(equalToConstant: containerWidth * (imageHeight / imageWidth)), // Set desired height

                backgroundImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                backgroundImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                backgroundImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
                backgroundImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

                canvasView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                canvasView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                canvasView.topAnchor.constraint(equalTo: containerView.topAnchor),
                canvasView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

                //            canvasView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                //            canvasView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                //            canvasView.widthAnchor.constraint(equalToConstant: 200), // Set desired width
                //            canvasView.heightAnchor.constraint(equalToConstant: 300) // Set desired height
            ])
        }

        // scrollView.contentSize = containerView.frame.size

//        print("im here out")
//        if let widthConstraint = containerView.constraints.first(where: { $0.firstAttribute == .width }),
//           let heightConstraint = containerView.constraints.first(where: { $0.firstAttribute == .height })
//        {
//            print("im here")
//            widthConstraint.constant = image.size.width
//            heightConstraint.constant = image.size.height
//        }

        return scrollView
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
        var parent: CanvasView1

        init(_ parent: CanvasView1) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first // The container with the image & canvas
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension CanvasView1 {
    func showToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
}
