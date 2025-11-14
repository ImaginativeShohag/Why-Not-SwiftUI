//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CoreImage.CIFilterBuiltins
import UIKit
import AVFoundation

public extension UIImage {
    /// - Returns: The file size in KB.
    func fileSize() -> Int {
        guard let imageData = jpegData(compressionQuality: 1) else { return 0 }
        return imageData.count / 1000
    }
       
    func dominantColor() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
            
        let filter = CIFilter.areaAverage()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgRect: inputImage.extent), forKey: kCIInputExtentKey)
            
        guard let outputImage = filter.outputImage else { return nil }
            
        let context = CIContext(options: nil)
        var bitmap = [UInt8](repeating: 0, count: 4) // RGBA format
            
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1), // Render to 1x1 pixel
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
            
        let alpha = max(CGFloat(bitmap[3]) / 255.0, 1.0) // Prevent zero alpha
            
        return UIColor(
            red: CGFloat(bitmap[0]) / 255.0 / alpha,
            green: CGFloat(bitmap[1]) / 255.0 / alpha,
            blue: CGFloat(bitmap[2]) / 255.0 / alpha,
            alpha: alpha
        )
    }
    
    /// Resize image while keeping the aspect ratio. Original image is not modified. This will only resize if the image is bigger then the given size.
    ///
    /// - Parameters:
    ///   - width: A new width in pixels.
    ///   - height: A new height in pixels.
    /// - Returns: Resized image.
    ///
    /// - Tested: `UIImageExtensionResizeTests`
    func resizeIfNeeded(width: Int, height: Int) -> UIImage {
        guard CGFloat(width) < size.width || CGFloat(height) < size.height else { return self }

        return self.resize(width: width, height: height)
    }

    /// Resize image while keeping the aspect ratio. Original image is not modified.
    ///
    /// - Parameters:
    ///   - width: A new width in pixels.
    ///   - height: A new height in pixels.
    /// - Returns: Resized image.
    ///
    /// - Tested: `UIImageExtensionResizeTests`
    func resize(width: Int, height: Int) -> UIImage {
        // Keep aspect ratio
        let maxSize = CGSize(width: width, height: height)

        let availableRect = AVFoundation.AVMakeRect(
            aspectRatio: self.size,
            insideRect: .init(origin: .zero, size: maxSize)
        )
        let targetSize = availableRect.size

        // Set scale of renderer so that 1pt == 1px
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        // Resize the image
        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resized
    }
}
