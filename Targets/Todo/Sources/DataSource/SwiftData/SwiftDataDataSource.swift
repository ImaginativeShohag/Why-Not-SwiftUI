//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftData

final actor SwiftDataDataSource {
    static let shared = SwiftDataDataSource()

    let container: ModelContainer = {
        do {
            return try ModelContainer(for: SDTodo.self)
        } catch {
            fatalError("Failed to initialize ModelContainer for SwiftData: \(error)")
        }
    }()

    private init() {}
}
