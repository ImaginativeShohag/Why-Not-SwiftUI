//
//  Created by Md. Mahmudul Hasan Shohag on 19/09/2024.
//

import SwiftUI

// Reference: https://www.avanderlee.com/concurrency/asyncsequence/

public struct Counter: AsyncSequence, AsyncIteratorProtocol {
    public typealias Element = Int

    let limit: Int
    var current = 1

    public init(limit: Int) {
        self.limit = limit
    }

    public mutating func next() async -> Int? {
        guard !Task.isCancelled else {
            return nil
        }

        guard current <= limit else {
            return nil
        }

        let result = current
        current += 1
        return result
    }

    public func makeAsyncIterator() -> Counter {
        self
    }
}
