//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PhotosUI
import SwiftUI

@MainActor
class MediaSelectViewModel: ObservableObject {
    @Published var attachmentItems: [UIAttachment] = []
    @Published var selectedItems: [PhotosPickerItem] = []

    func addAttachment(image: UIImage, videoUrl: URL? = nil) {
        #if DEBUG

        print("debug: image -> dimension: \(image.size.width)x\(image.size.height) | size: \(image.fileSize()) KB")
        print("debug: video -> size: \(videoUrl?.fileSize() ?? 0) KB")

        #endif

        attachmentItems.append(UIAttachment(
            id: UUID().hashValue,
            image: image,
            videoUrl: videoUrl?.absoluteString
        ))
    }

    func addAttachments() {
        guard !selectedItems.isEmpty else { return }

        Task {
            for item in self.selectedItems {
                do {
                    let data = try await item.loadTransferable(type: Data.self)

                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.attachmentItems.append(UIAttachment(
                                id: UUID().hashValue,
                                image: image,
                                videoUrl: nil
                            ))
                        }
                    }
                } catch {
                    print("Debug: \(error)")
                }
            }

            DispatchQueue.main.async {
                self.selectedItems.removeAll()
            }
        }
    }

    func removeAttachment(item: UIAttachment) {
        attachmentItems.removeAll(where: { $0.id == item.id })
    }
}

#if DEBUG

extension MediaSelectViewModel {
    convenience init(forPreview: Bool = true) {
        self.init()

        self.attachmentItems = [
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil),
            UIAttachment(id: UUID().hashValue, image: UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!, videoUrl: nil)
        ]
    }
}

#endif
