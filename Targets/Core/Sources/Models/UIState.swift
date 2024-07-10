//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//


import Foundation

public enum UIState<T: Any> {
    case error(message: String)
    case loading
    case data(data: T)
}
