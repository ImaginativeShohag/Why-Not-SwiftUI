//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CommonUI
import Core
import NavigationKit
import PhotosUI
import SwiftUI

// TODO: #1: Add preview (https://nilcoalescing.com/blog/PreviewFilesWithQuickLookInSwiftUI/)
// TODO: #2: Fix error image in items

// MARK: - Destination

public extension Destination {
    final class MediaCaptureAndSelect: BaseDestination {
        override public func getScreen() -> any View {
            MediaSelectScreen()
        }
    }
}

// MARK: - UI

public struct MediaSelectScreen: View {
    @State private var viewModel: MediaSelectViewModel

    @State private var showAttachmentAddDialog: Bool = false
    @State private var showImageCapturer: Bool = false
    @State private var showVideoCapturer: Bool = false
    @State private var showPhotoLibraryForSingle: Bool = false
    @State private var showPhotoLibraryForMultiple: Bool = false
    @State private var selectedImageForMarkup: IdentifiableImage? = nil

    public init(viewModel: MediaSelectViewModel = MediaSelectViewModel()) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            if viewModel.attachmentItems.isEmpty {
                ContentUnavailableView("No attachment yet.", systemImage: "photo.on.rectangle.angled")
            } else {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                            ForEach(viewModel.attachmentItems) { item in
                                ImageItemView(
                                    item: item,
                                    onDeleteClicked: {
                                        viewModel.removeAttachment(item: item)
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                }
            }

            VStack {
                Button {
                    showAttachmentAddDialog = true
                } label: {
                    Text("Add Attachment")
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color.systemBackground)
            .shadow(color: Color.black.opacity(0.1), radius: 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Media Capture & Select")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            OverlayLoadingView(isPresented: viewModel.showLoading)
        }
        .confirmationDialog(
            "Add Attachment",
            isPresented: $showAttachmentAddDialog
        ) {
            Button {
                showImageCapturer = true
            } label: {
                Text("Take New Photo")
                    .foregroundColor(Color.label)
            }

            Button {
                showVideoCapturer = true
            } label: {
                Text("Take New Video")
                    .foregroundColor(Color.label)
            }

            Button {
                showPhotoLibraryForSingle = true
            } label: {
                Text("Choose from Library (Single)")
                    .foregroundColor(Color.label)
            }

            Button {
                showPhotoLibraryForMultiple = true
            } label: {
                Text("Choose from Library (Multiple)")
                    .foregroundColor(Color.label)
            }

            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showImageCapturer) {
            ImageVideoCapturer(
                defaultCaptureMode: .photo,
                maxImageSize: CGSize(width: 1024, height: 1024)
            ) { image, videoUrl in
                if videoUrl == nil {
                    Task { @MainActor in
                        showImageCapturer = false

                        selectedImageForMarkup = image.toIdentifiable()
                    }
                } else {
                    viewModel.addAttachment(image: image, videoUrl: videoUrl)
                }
            }
        }
        .fullScreenCover(isPresented: $showVideoCapturer) {
            ImageVideoCapturer(
                defaultCaptureMode: .video,
                maxImageSize: CGSize(width: 1024, height: 1024)
            ) { image, videoUrl in
                if videoUrl == nil {
                    Task { @MainActor in
                        showImageCapturer = false

                        selectedImageForMarkup = image.toIdentifiable()
                    }
                } else {
                    viewModel.addAttachment(image: image, videoUrl: videoUrl)
                }
            }
        }
        .fullScreenCover(item: $selectedImageForMarkup) { image in
            ImageMarkupScreen(
                image: image.image
            ) { image in
                Task { @MainActor in
                    selectedImageForMarkup = nil

                    viewModel.addAttachment(image: image, videoUrl: nil)
                }
            }
        }
        .photosPicker(
            isPresented: $showPhotoLibraryForMultiple,
            selection: $viewModel.selectedItems,
            matching: .any(of: [.images, .videos])
        )
        .onChange(of: viewModel.selectedItems) {
            viewModel.addAttachments()
        }
        .photosPicker(
            isPresented: $showPhotoLibraryForSingle,
            selection: $viewModel.selectedItem,
            matching: .any(of: [.images, .videos])
        )
        .onChange(of: viewModel.selectedItem) {
            if viewModel.selectedItem?.supportedContentTypes.contains(where: { $0.conforms(to: .image) }) == true {
                Task {
                    let image = try? await viewModel.selectedItem?.toUIImage()

                    await MainActor.run {
                        selectedImageForMarkup = image?.toIdentifiable()
                    }
                }
            } else {
                viewModel.addAttachment()
            }
        }
        .onAppear {
            print("count: \(viewModel.attachmentItems.count)")
        }
    }
}

#if DEBUG

#Preview("Empty view") {
    MediaSelectScreen(
        viewModel: MediaSelectViewModel(
            forPreview: true,
            attachments: []
        )
    )
}

#Preview("With Items") {
    MediaSelectScreen(
        viewModel: MediaSelectViewModel(
            forPreview: true,
            attachments: UIAttachment.examples
        )
    )
}

#endif

// MARK: - Components

private struct ImageItemView: View {
    let item: UIAttachment
    let onDeleteClicked: () -> Void

    @State private var showPreview = false

    private var image: UIImage {
        item.image ?? UIImage(systemName: "exclamationmark.triangle.fill")!
    }

    var body: some View {
        Button {
            showPreview.toggle()
        } label: {
            GeometryReader { geometry in
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: geometry.size.width)
                }
            }
            .clipped()
            .aspectRatio(1, contentMode: .fit)
            .background(Color.systemGroupedBackground)
            .cornerRadius(16)
            .overlay {
                ZStack {
                    Button {
                        onDeleteClicked()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.systemRed)
                    }
                    .background(Color.white)
                    .cornerRadius(24)
                    .padding(4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            .overlay {
                ZStack {
                    if item.type == .capturedPhoto {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                            .padding(8)
                    } else if item.type == .recordedVideo {
                        Image(systemName: "video.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                            .padding(8)
                    } else {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                            .padding(8)
                    }
                }
                .shadow(radius: 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .fullScreenCover(isPresented: $showPreview) {
            ImagePreviewScreen(image: image)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
