//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftData

final actor SwiftDataDataSource {
    static let shared = SwiftDataDataSource()

    let container: ModelContainer = try! ModelContainer(for: SDTodo.self)

    private init() {}
}
