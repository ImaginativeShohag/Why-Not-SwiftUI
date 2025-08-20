//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class MetricKit: BaseDestination {
        override public func getScreen() -> any View {
            MetricKitScreen()
        }
    }
}

// MARK: - UI

public struct MetricKitScreen: View {
    @StateObject private var viewModel = MetricKitViewModel()

    public init() {}

    public var body: some View {
        VStack {
            if viewModel.items.isEmpty {
                Text(NSLocalizedString("no_crash_report_found", bundle: .module, comment: ""))
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
        .navigationTitle(NSLocalizedString("metric_kit_screen_title", bundle: .module, comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MetricKitScreen_Previews: PreviewProvider {
    static var previews: some View {
        MetricKitScreen()
    }
}
