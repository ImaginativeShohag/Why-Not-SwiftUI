//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import AVFoundation

extension URL {
    /// - Returns: The file size in KB.
    func fileSize() -> Int {
        var fileSize = 0.0
        var fileSizeValue = 0.0
        try? fileSizeValue = (self.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
        if fileSizeValue > 0.0 {
            fileSize = (Double(fileSizeValue) / 1000)
        }
        return Int(fileSize)
    }
    
    /// - Returns: Video dimension.
    func localVideoDimension() async -> CGSize? {
        guard let track = try? await AVURLAsset(url: self)
            .loadTracks(withMediaType: AVMediaType.video)
            .first else { return nil }

        guard let size = try? await track.load(.naturalSize)
            .applying(track.load(.preferredTransform)) else { return nil }

        return CGSize(width: abs(size.width), height: abs(size.height))
    }

    /// - Returns: `True` if the `URL` is a QuickTime local video.
    ///
    /// Tested: `IsLocalQuickTimeVideoURLTest`
    func isLocalQuickTimeVideoURL() -> Bool {
        return scheme == "file" && host == nil && absoluteString.fileExtension() == "mov"
    }
}
