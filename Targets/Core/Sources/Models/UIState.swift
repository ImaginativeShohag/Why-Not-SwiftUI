//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// A generic UI state representation that models different states of a UI component.
///
/// - `loading`: Represents a loading state.
/// - `error(message: String)`: Represents an error state with an associated error message.
/// - `data(data: T)`: Represents a success state containing a value of type `T`.
///
/// The enum includes computed properties and methods to check the state and retrieve associated values.
public enum UIState<T: Any> {
    /// Indicates that the UI is in a loading state.
    case loading

    /// Indicates that an error has occurred, with an associated error message.
    ///
    /// - Parameter message: A string describing the error.
    case error(message: String)

    /// Indicates that data is available.
    ///
    /// - Parameter data: The associated data of type `T`.
    case data(data: T)

    /// Checks whether the state contains data.
    ///
    /// - Returns: `true` if the state is `.data`, otherwise `false`.
    public var hasData: Bool {
        if case .data = self {
            return true
        } else {
            return false
        }
    }

    /// Checks whether the state is currently loading.
    ///
    /// - Returns: `true` if the state is `.loading`, otherwise `false`.
    public var isLoading: Bool {
        if case .loading = self {
            return true
        } else {
            return false
        }
    }

    /// Checks whether the state represents an error.
    ///
    /// - Returns: `true` if the state is `.error`, otherwise `false`.
    public var isError: Bool {
        if case .error = self {
            return true
        } else {
            return false
        }
    }

    /// Retrieves the associated data if available.
    ///
    /// - Returns: The associated data of type `T` if the state is `.data`, otherwise `nil`.
    public func getData() -> T? {
        if case .data(let data) = self {
            return data
        }
        return nil
    }

    /// Retrieves the error message if the state is `.error`.
    ///
    /// - Returns: The associated error message if the state is `.error`, otherwise `nil`.
    public func getErrorMessage() -> String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}

/// Extends `UIState` to conform to `Equatable`, enabling equality comparison.
///
/// This conformance is available only when `T` itself conforms to `Equatable`.
/// Swift automatically synthesizes the `==` implementation, allowing instances of `UIState<T>`
/// to be compared if `T` is an `Equatable` type (e.g., `Bool`, `Int`, `Float`, `String`).
///
/// ## Example Usage
/// ```swift
/// let state1: UIState<Int> = .data(data: 42)
/// let state2: UIState<Int> = .data(data: 42)
/// let state3: UIState<Int> = .error(message: "Something went wrong")
///
/// print(state1 == state2) // true
/// print(state1 == state3) // false
/// ```
extension UIState: Equatable where T: Equatable {}
