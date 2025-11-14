//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

class DataSourceController {
    nonisolated(unsafe) static let shared = DataSourceController()
    
    private init() {}
    
    private(set) var source: DataSourceType = .swiftData
    
    func setSource(_ source: DataSourceType) {
        self.source = source
    }
}
 
enum DataSourceType: String, CaseIterable, Identifiable {
    case swiftData = "SwiftData"
    case coreData = "CoreData"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .swiftData: return "Modern, streamlined storage"
        case .coreData: return "Robust, established storage"
        }
    }
}
