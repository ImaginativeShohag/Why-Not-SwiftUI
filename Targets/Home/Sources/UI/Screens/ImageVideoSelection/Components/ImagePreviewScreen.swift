//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import QuickLook
import SwiftUI

// TODO: #1: Add video url support

struct ImagePreviewScreen: View {
    let image: UIImage
    
    @State private var previewItem: ImagePreviewItem?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Preparing preview...")
            } else if let previewItem = previewItem {
                QuickLookController(previewItem: previewItem)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Failed to load preview.")
            }
        }
        .onAppear {
            preparePreview()
        }
    }
    
    private func preparePreview() {
        DispatchQueue.global(qos: .userInitiated).async {
            let item = ImagePreviewItem(image: image)
            
            Task { @MainActor in
                self.previewItem = item
                self.isLoading = false
            }
        }
    }
}

struct QuickLookController: UIViewControllerRepresentable {
    let previewItem: QLPreviewItem
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.title = previewItem.previewItemTitle ?? ""
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(previewItem: previewItem)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let previewItem: QLPreviewItem
        
        init(previewItem: QLPreviewItem) {
            self.previewItem = previewItem
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            previewItem
        }
    }
}
