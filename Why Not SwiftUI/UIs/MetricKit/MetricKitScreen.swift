//
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import SwiftUI

struct MetricKitScreen: View {
    @StateObject private var viewModel = MetricKitViewModel()

    var body: some View {
        VStack {
            if viewModel.items.isEmpty {
                Text("No crash report found!")
            } else {
                Text("Last crashed: \(viewModel.time)")
                List {
                    ForEach(viewModel.items, id: \.self) { item in
                        Text("Report Size: \(item.count)")
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadCrashes()
        }
        .navigationTitle("MetricKit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MetricKitScreen_Previews: PreviewProvider {
    static var previews: some View {
        MetricKitScreen()
    }
}
