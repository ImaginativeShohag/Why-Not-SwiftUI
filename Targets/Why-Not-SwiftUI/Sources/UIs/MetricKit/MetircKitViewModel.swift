//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import MetricKit

//atos -arch arm64 -o /Users/shohag/Downloads/crash-reports/dSYMs/Why\ Not\ SwiftUI\!.app.dSYM/Contents/Resources/DWARF/Why\ Not\ SwiftUI\! -l 0x1 0x15961

// https://developer.apple.com/forums/thread/681967

class MetricKitViewModel: ObservableObject {
    @Published var items = [String]()
    @Published var time: String = ""

    func loadCrashes() {
        guard let filename = getDocumentsDirectory() else { return }
        
        let newPath = filename.appendingPathComponent("crash-reports")
        
        if !FileManager.default.fileExists(atPath: newPath.path) {
            do {
                try FileManager.default.createDirectory(at: newPath, withIntermediateDirectories: true)
            } catch {
                print(error.localizedDescription)
            }
        }

        let fullPath = newPath
            .appendingPathComponent("crash.json")
        
        do {
            try "Test".write(to: fullPath, atomically: true, encoding: .utf8)
            let input = try String(contentsOf: fullPath)
            print(input)
        } catch {
            print("Error writing crash log: \(error)")
        }

        guard let items = DiagnosticDataSaver.shared.crashData,
              let time = DiagnosticDataSaver.shared.savedTime, time != 0 else { return }

        self.items = items
        self.time = Date(timeIntervalSince1970: TimeInterval(time)).formatted()

        print("items: \(items.count)")
        print("time: \(self.time)")
    }

    func getDocumentsDirectory() -> URL? {
        let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return path
    }
}
