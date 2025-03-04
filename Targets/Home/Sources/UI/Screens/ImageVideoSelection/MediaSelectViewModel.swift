//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PhotosUI
import SwiftUI

@MainActor
@Observable
public final class MediaSelectViewModel {
    var attachmentItems: [UIAttachment] = []
    var selectedItems: [PhotosPickerItem] = []

    var showLoading: Bool = false

    public nonisolated init() {}

    func addAttachment(image: UIImage, videoUrl: URL? = nil) {
        #if DEBUG

        print("debug: image -> dimension: \(image.size.width)x\(image.size.height) | size: \(image.fileSize()) KB")
        print("debug: video -> size: \(videoUrl?.fileSize() ?? 0) KB")

        #endif

        attachmentItems.append(UIAttachment(
            id: UUID().hashValue,
            type: videoUrl == nil ? .capturedPhoto : .recordedVideo,
            image: image,
            videoUrl: videoUrl?.absoluteString
        ))
    }

    func addAttachments() {
        guard !selectedItems.isEmpty else { return }

        showLoading = true

        Task.detached(priority: .userInitiated) { [selectedItems] in
            for item in selectedItems {
                do {
                    let data = try await item.loadTransferable(type: Data.self)

                    if let data = data, let image = UIImage(data: data) {
                        await MainActor.run {
                            self.attachmentItems.append(UIAttachment(
                                id: UUID().hashValue,
                                type: .selectedPhoto,
                                image: image,
                                videoUrl: nil
                            ))
                        }
                    }
                } catch {
                    print("Debug: \(error)")
                }
            }

            await MainActor.run {
                self.selectedItems.removeAll()

                self.showLoading = false
            }
        }
    }

    func removeAttachment(item: UIAttachment) {
        attachmentItems.removeAll(where: { $0.id == item.id })
    }
}

#if DEBUG

extension MediaSelectViewModel {
    convenience init(
        forPreview: Bool = true,
        attachments: [UIAttachment]
    ) {
        self.init()

        self.attachmentItems = attachments
    }
}

#endif
