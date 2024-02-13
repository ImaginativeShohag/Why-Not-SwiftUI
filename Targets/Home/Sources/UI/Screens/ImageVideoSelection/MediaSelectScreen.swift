//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CommonUI
import Core
import PhotosUI
import SwiftUI

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
    @ObservedObject var viewModel = MediaSelectViewModel()

    @State private var showAttachmentAddDialog: Bool = false
    @State private var showImageCapturer: Bool = false
    @State private var showVideoCapturer: Bool = false
    @State private var showPhotoLibrary: Bool = false

    public init(viewModel: MediaSelectViewModel = MediaSelectViewModel()) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
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
                showPhotoLibrary = true
            } label: {
                Text("Choose Photo")
                    .foregroundColor(Color.label)
            }

            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showImageCapturer) {
            ImageVideoCapturer(defaultCaptureMode: .photo) { image, videoUrl in
                viewModel.addAttachment(image: image, videoUrl: videoUrl)
            }
        }
        .fullScreenCover(isPresented: $showVideoCapturer) {
            ImageVideoCapturer(defaultCaptureMode: .video) { image, videoUrl in
                viewModel.addAttachment(image: image, videoUrl: videoUrl)
            }
        }
        .photosPicker(
            isPresented: $showPhotoLibrary,
            selection: $viewModel.selectedItems,
            matching: .any(of: [.images, .videos])
        )
        .onChange(of: viewModel.selectedItems) {
            viewModel.addAttachments()
        }
        .navigationTitle("Media Capture & Select")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG

struct MediaSelectScreen_Previews: PreviewProvider {
    static var previews: some View {
        MediaSelectScreen(
            viewModel: MediaSelectViewModel(forPreview: true)
        )
    }
}

#endif

// MARK: - Components

private struct ImageItemView: View {
    let item: UIAttachment
    let onDeleteClicked: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: item.image ?? UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!)
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
}
