import SwiftMacros
import Foundation

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

// MARK: ----------------------------------------------------------------

/// Source: https://www.avanderlee.com/swift/macros/

print("The value \(result) was produced by the code \"\(code)\"")

let url: URL = #URL("https://imaginativeworld.org")

print("Url: \(url)")

// MARK: ----------------------------------------------------------------

/// Source: https://betterprogramming.pub/use-swift-macros-to-initialize-a-structure-516728c5fb49

@StructInit
struct Book {
    var id: Int
    var title: String
    var subtitle: String
    var description: String
    var author: String
}
