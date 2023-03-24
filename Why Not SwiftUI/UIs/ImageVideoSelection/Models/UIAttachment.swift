//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct UIAttachment: Identifiable {
    let id: Int
    let type: UIAttachmentType
    let image: UIImage?
    let videoUrl: String?
}

// MARK: - Enums

enum UIAttachmentType {
    case capturedPhoto
    case recordedVideo
    case selectedPhoto
}

// MARK: - Extensions

extension UIAttachment {
    static let examples = [
        UIAttachment(id: UUID().hashValue, type: .capturedPhoto, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .selectedPhoto, image: UIImage(named: "anastasiya-leskova-3p0nSfa5gi8-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .recordedVideo, image: UIImage(named: "boliviainteligente-llyebZWmLM0-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .capturedPhoto, image: UIImage(named: "shubham-dhage-_PmYFVygfak-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .selectedPhoto, image: UIImage(named: "anita-austvika-tRMaCsI7RZw-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .recordedVideo, image: UIImage(named: "leon-rohrwild-XqJyl5FD_90-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .recordedVideo, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .recordedVideo, image: UIImage(named: "anastasiya-leskova-3p0nSfa5gi8-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .capturedPhoto, image: UIImage(named: "boliviainteligente-llyebZWmLM0-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .selectedPhoto, image: UIImage(named: "shubham-dhage-_PmYFVygfak-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .recordedVideo, image: UIImage(named: "anita-austvika-tRMaCsI7RZw-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .selectedPhoto, image: UIImage(named: "leon-rohrwild-XqJyl5FD_90-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .capturedPhoto, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .recordedVideo, image: UIImage(named: "anastasiya-leskova-3p0nSfa5gi8-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .capturedPhoto, image: UIImage(named: "boliviainteligente-llyebZWmLM0-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .capturedPhoto, image: UIImage(named: "shubham-dhage-_PmYFVygfak-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .selectedPhoto, image: UIImage(named: "anita-austvika-tRMaCsI7RZw-unsplash")!, videoUrl: nil),
        UIAttachment(id: UUID().hashValue, type: .selectedPhoto, image: UIImage(named: "leon-rohrwild-XqJyl5FD_90-unsplash")!, videoUrl: nil)
    ]
}
