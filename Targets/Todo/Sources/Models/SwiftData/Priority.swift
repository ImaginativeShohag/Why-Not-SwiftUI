//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

enum Priority: Codable {
    case none, low, medium, high
}

// MARK: - Extensions

extension Priority {
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

    static func fromUIModel(_ priority: UITodo.Priority) -> Priority {
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
