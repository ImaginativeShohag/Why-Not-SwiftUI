//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CoreImage.CIFilterBuiltins
import UIKit

public extension UIImage {
    /// - Returns: The file size in KB.
    func fileSize() -> Int {
        guard let imageData = jpegData(compressionQuality: 1) else { return 0 }
        return imageData.count / 1000
    }
    
    // Shared instance to improve performance
    private static let ciContext = CIContext()
       
    func dominantColor() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
           
        let filter = CIFilter.areaAverage()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgRect: inputImage.extent), forKey: kCIInputExtentKey)
           
        guard let outputImage = filter.outputImage else { return nil }
           
        var bitmap = [UInt8](repeating: 0, count: 4) // RGBA format
        let ciContext = CIContext()
        ciContext.render(
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
}
