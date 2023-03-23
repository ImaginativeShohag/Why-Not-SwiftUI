//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PhotosUI
import SwiftUI

// TODO: #1 Add icon to the image for showing source/type
// TODO: #2 Add remove button
// TODO: #3 Add overlay loading

struct MediaSelectScreen: View {
    @ObservedObject var viewModel = MediaSelectViewModel()

    @State private var showAttachmentAddDialog: Bool = false
    @State private var showImageCapturer: Bool = false
    @State private var showVideoCapturer: Bool = false
    @State private var showPhotoLibrary: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                            ForEach(viewModel.attachmentItems) { item in
                                GeometryReader { geometry in
                                    Image(uiImage: item.image ?? UIImage(named: "jean-philippe-delberghe-75xPHEQBmvA-unsplash")!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: geometry.size.width)
                                }
                                .clipped()
                                .aspectRatio(1, contentMode: .fit)
                                .background(Color.systemGroupedBackground)
                                .cornerRadius(16)
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
                .shadow(radius: 5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .onChange(of: viewModel.selectedItems, perform: { _ in
                viewModel.addAttachments()
            })
        }
        .navigationViewStyle(.stack)
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
