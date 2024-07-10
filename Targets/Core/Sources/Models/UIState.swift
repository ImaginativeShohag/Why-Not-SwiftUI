//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//


import Foundation

public enum UIState<T: Any> {
    case loading
    case error(message: String)
    case data(data: T)

    public var hasData: Bool {
        if case .data = self {
            return true
        } else {
            return false
        }
    }

    public var isLoading: Bool {
        if case .loading = self {
            return true
        } else {
            return false
        }
    }

    public var isError: Bool {
        if case .error = self {
            return true
        } else {
            return false
        }
    }

    public func getData() -> T? {
        if case .data(let data) = self {
            return data
        }
        return nil
    }

    public func getErrorMessage() -> String {
        if case .error(let message) = self {
            return message
        }
        return ""
    }
}
