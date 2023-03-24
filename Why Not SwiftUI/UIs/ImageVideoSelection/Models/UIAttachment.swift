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

enum UIAttachmentType {
    case capturedPhoto
    case recordedVideo
    case selectedPhoto
}
