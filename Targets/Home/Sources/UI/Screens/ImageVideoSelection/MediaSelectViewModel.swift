//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PhotosUI
import SwiftUI

// TODO: #1: Refactor codes.

@MainActor
@Observable
public final class MediaSelectViewModel {
    var attachmentItems: [UIAttachment] = []
    var selectedItems: [PhotosPickerItem] = []
    var selectedItem: PhotosPickerItem?

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
            videoUrl: videoUrl
        ))

        // Reset selected items
        selectedItem = nil
    }

    func addAttachments() {
        guard !selectedItems.isEmpty else { return }

        showLoading = true

        Task.detached(priority: .userInitiated) { [selectedItems] in
            for item in selectedItems {
                await self.processAndAppendAttachment(item)
            }

            await MainActor.run {
                self.selectedItems.removeAll()

                self.showLoading = false
            }
        }
    }

    func addAttachment() {
        guard let selectedItem else { return }

        showLoading = true

        Task.detached(priority: .userInitiated) { [selectedItem] in
            await self.processAndAppendAttachment(selectedItem)

            await MainActor.run {
                self.selectedItem = nil

                self.showLoading = false
            }
        }
    }

    private func processAndAppendAttachment(_ item: PhotosPickerItem) async {
        do {
            if item.supportedContentTypes.contains(where: { $0.conforms(to: .image) }) {
                if let data = try await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data)
                {
                    await MainActor.run {
                        self.attachmentItems.append(UIAttachment(
                            id: UUID().hashValue,
                            type: .selectedPhoto,
                            image: image,
                            videoUrl: nil
                        ))
                    }
                }
            } else if item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
                if let movie = try await item.loadTransferable(type: Movie.self) {
                    let videoURL = movie.url

                    // Generate thumbnail using async API (fixes error #4)
                    let thumbnail = try await generateThumbnail(for: videoURL)

                    await MainActor.run {
                        self.attachmentItems.append(UIAttachment(
                            id: UUID().hashValue,
                            type: .recordedVideo,
                            image: thumbnail,
                            videoUrl: videoURL
                        ))
                    }
                }
            } else {
                print("Unsupported media type")
            }
        } catch {
            print("Debug: \(error)")
        }
    }

    func removeAttachment(item: UIAttachment) {
        attachmentItems.removeAll(where: { $0.id == item.id })
    }
}

extension PhotosPickerItem {
    func toUIImage() async throws -> UIImage? {
        let data = try await loadTransferable(type: Data.self)

        if let data = data, let image = UIImage(data: data) {
            return image
        } else {
            return nil
        }
    }
}

// Helper struct to load video URL using Transferable
struct Movie: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .movie) { receivedFile in
            // Create a temp URL to copy the video file
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = UUID().uuidString + ".mov"
            let tempURL = tempDirectory.appendingPathComponent(fileName)

            // receivedFile is of type ReceivedTransferredFile, which has a .file property (URL)
            try FileManager.default.copyItem(at: receivedFile.file, to: tempURL)

            // Return the Movie instance correctly initialized
            return Movie(url: tempURL)
        }
    }
}

// Helper function to generate a thumbnail image from video URL
private func generateThumbnail(for url: URL) async throws -> UIImage? {
    let asset = AVURLAsset(url: url) // Use AVURLAsset (fixes error #3)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true

    return try await withCheckedThrowingContinuation { continuation in
        generator.generateCGImageAsynchronously(for: .zero) { cgImage, _, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else if let cgImage = cgImage {
                continuation.resume(returning: UIImage(cgImage: cgImage))
            } else {
                continuation.resume(returning: nil)
            }
        }
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
