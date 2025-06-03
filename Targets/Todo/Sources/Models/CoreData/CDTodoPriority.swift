//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

enum CDTodoPriority: Int16 {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
}

extension CDTodoPriority {
    func toUIModel() -> UITodo.Priority {
        switch self {
        case .none:
            return .none
        case .low:
            return .low
        case .medium:
            return .medium
        case .high:
            return .high
        }
    }
    
    static func fromUIModel(_ priority: UITodo.Priority) -> CDTodoPriority {
        switch priority {
        case .none:
            return .none
        case .low:
            return .low
        case .medium:
            return .medium
        case .high:
            return .high
        }
    }
}
