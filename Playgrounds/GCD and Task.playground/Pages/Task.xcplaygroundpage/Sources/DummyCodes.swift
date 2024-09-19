import Foundation

public func someAsyncFunction() async {
    try? await Task.sleep(for: .seconds(1))
    print("(someAsyncFunction) 1 second later (\(Thread.current))")
}

public func performAsyncOperation() async {
    try? await Task.sleep(for: .seconds(1))
    print("(performAsyncOperation) 1 second later (\(Thread.current))")
}

public func highPriorityWork() async {
    try? await Task.sleep(for: .seconds(1))
    print("(highPriorityWork) 1 second later")
}

public func performTask() async {
    try? await Task.sleep(for: .seconds(1))
    print("(performTask) 1 second later")
}

public func fetchData() async -> String {
    try? await Task.sleep(for: .seconds(1))
    print("(fetchData) 1 second later")
    return "(fetchData) Awesome!"
}

public func performTask1() async -> String {
    try? await Task.sleep(for: .seconds(1))
    print("(performTask1) 1 second later")
    return "(performTask1) Awesome!"
}

public func performTask2() async -> String {
    try? await Task.sleep(for: .seconds(1))
    print("(performTask2) 1 second later")
    return "(performTask2) Awesome!"
}
