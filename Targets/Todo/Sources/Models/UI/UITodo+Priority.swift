//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

extension UITodo {
    enum Priority: Codable, CaseIterable {
        case none, low, medium, high

        var description: String {
            switch self {
            case .none: return "None"
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
    }
}
