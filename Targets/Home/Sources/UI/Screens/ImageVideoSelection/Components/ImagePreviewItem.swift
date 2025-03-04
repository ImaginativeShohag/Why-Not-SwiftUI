//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import UIKit
import QuickLook

class ImagePreviewItem: NSObject, QLPreviewItem {
    let previewItemURL: URL?
    let previewItemTitle: String?
    
    init(image: UIImage, title: String = "Preview Image") {
        // Save UIImage to a temporary file
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("\(UUID().uuidString).png")
        if let imageData = image.pngData() {
            try? imageData.write(to: fileURL)
        }
        self.previewItemURL = fileURL
        self.previewItemTitle = title
    }
}
