//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import AVFoundation
import Core
import Foundation
import MobileCoreServices
import SuperLog
import SwiftUI
import UniformTypeIdentifiers

#warning("Add support for .video. Restrict limited capture mode.")
#warning("Add max duration as parameter")

public struct ImageVideoCapturer: UIViewControllerRepresentable {
    private let defaultCaptureMode: UIImagePickerController.CameraCaptureMode // .movie or .photo
    private let allowedMediaType: [String]
    private let maxImageSize: CGSize?
    private let onSuccess: (UIImage, URL?) -> Void
    
    public init(
        defaultCaptureMode: UIImagePickerController.CameraCaptureMode,
        allowedMediaType: [UTType] = [UTType.movie, UTType.image],
        maxImageSize: CGSize? = nil,
        onSuccess: @escaping (UIImage, URL?) -> Void
    ) {
        self.defaultCaptureMode = defaultCaptureMode
        self.allowedMediaType = allowedMediaType.map { $0.identifier }
        self.maxImageSize = maxImageSize
        self.onSuccess = onSuccess
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = allowedMediaType
        picker.cameraCaptureMode = defaultCaptureMode
        // picker.videoMaximumDuration = 60 * 10 // Seconds
        
        SuperLog.v("picker.videoMaximumDuration: \(picker.videoMaximumDuration) seconds")
        SuperLog.v("picker.videoQuality: \(picker.videoQuality)")
        
        picker.delegate = context.coordinator
        
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // no-op
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: ImageVideoCapturer
        
        init(_ parent: ImageVideoCapturer) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            // Check for the media type
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! String
            
            switch mediaType {
            case UTType.image.identifier:
                // Handle image selection result
                print("Selected media is image")
                    
                if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    if let maxImageSize = parent.maxImageSize {
                        let resizedImage = editedImage.resizeIfNeeded(
                            width: Int(maxImageSize.width),
                            height: Int(maxImageSize.height)
                        )
                        
                        parent.onSuccess(resizedImage, nil)
                    } else {
                        parent.onSuccess(editedImage, nil)
                    }
                } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    if let maxImageSize = parent.maxImageSize {
                        let resizedImage = originalImage.resizeIfNeeded(
                            width: Int(maxImageSize.width),
                            height: Int(maxImageSize.height)
                        )
                        
                        parent.onSuccess(resizedImage, nil)
                    } else {
                        parent.onSuccess(originalImage, nil)
                    }
                }

            case UTType.movie.identifier:
                // Handle video selection result
                print("Selected media is video")
                    
                let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as! URL
                    
                // Help: https://www.swiftdevcenter.com/get-thumbnail-from-video-url-in-background-swift/
                Task.detached(priority: .userInitiated) {
                    let asset = AVURLAsset(url: videoUrl)
                    let assetImageGenerator = AVAssetImageGenerator(asset: asset)
                    assetImageGenerator.appliesPreferredTrackTransform = true
                    
                    let thumbnailTime = CMTimeMake(value: 2, timescale: 1)
                    assetImageGenerator.generateCGImageAsynchronously(for: thumbnailTime) { cgImage, _, _ in
                        if let cgImage = cgImage {
                            let thumbnailImage = UIImage(cgImage: cgImage)
                                    
                            if let maxImageSize = self.parent.maxImageSize {
                                let resizedImage = thumbnailImage.resizeIfNeeded(
                                    width: Int(maxImageSize.width),
                                    height: Int(maxImageSize.height)
                                )
                                
                                Task { @MainActor in
                                    self.parent.onSuccess(resizedImage, videoUrl)
                                }
                            } else {
                                Task { @MainActor in
                                    self.parent.onSuccess(thumbnailImage, videoUrl)
                                }
                            }
                        }
                    }
                }
              
            default:
                print("Mismatched type: \(mediaType)")
            }

            picker.dismiss(animated: true, completion: nil)
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
