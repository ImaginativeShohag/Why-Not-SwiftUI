//
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import Foundation
import MetricKit

class MetricKitViewModel: ObservableObject {
    @Published var items = [String]()
    @Published var time: String = ""

    func loadCrashes() {
        guard let items = DiagnosticDataSaver.shared.crashData,
              let time = DiagnosticDataSaver.shared.savedTime, time != 0 else { return }

        self.items = items
        self.time = Date(timeIntervalSince1970: TimeInterval(time)).formatted()

        print("items: \(items.count)")
        print("time: \(self.time)")
    }
}
