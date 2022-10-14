//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct ImageVideoCapturerExampleScreen: View {
    @State var showPicker: Bool = false
    
    @State var image: UIImage = .init()
    @State var videoUrl: URL? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 250)
                    .background(Color.gray)
                
                Spacer()
                
                Button {
                    showPicker.toggle()
                } label: {
                    Text("Open Picker")
                }
                
                Spacer()
            }
            .fullScreenCover(isPresented: $showPicker) {
                ImageVideoCapturer(defaultCaptureMode: .video) { image, videoUrl in
                    self.image = image
                    self.videoUrl = videoUrl
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct ImageVideoCapturerExampleScreen_Previews: PreviewProvider {
    static var previews: some View {
        ImageVideoCapturerExampleScreen()
    }
}
