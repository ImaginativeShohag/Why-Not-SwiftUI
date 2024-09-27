//
//  Created by Md. Mahmudul Hasan Shohag on 20/09/2024.
//

import SwiftUI

public func someAsyncFunction() async {
    try? await Task.sleep(for: .seconds(1))
    print("(someAsyncFunction) 1 second later (\(Thread.current))")
}

public func performTask() async {
    try? await Task.sleep(for: .seconds(1))
    print("(performTask) 1 second later (\(Thread.current))")
}

public func fetchData() async -> String {
    try? await Task.sleep(for: .seconds(1))
    print("(fetchData) 1 second later")
    return "(fetchData) Awesome!"
}
