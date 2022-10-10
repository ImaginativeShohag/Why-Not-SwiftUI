//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

// MARK: - Example#001: `KeyPath`

// Help:
// - https://www.hackingwithswift.com/example-code/language/what-are-keypaths
// - https://www.swiftbysundell.com/articles/the-power-of-key-paths-in-swift/
// - https://sarunw.com/posts/what-is-keypath-in-swift/

struct KeyPathExampleScreen: View {
    let allFruits = Fruit.items
    let justFruitNames: [String] = Fruit.items.map(\.name)
    let justFavoriteFruits = Fruit.items.filter(\.isFavorite)
    let sortedFruits = Fruit.items.sorted(by: \.count)

    var body: some View {
        List(allFruits, id: \.id) { item in
            // Text("\(item.name) (\(item.count))")
            Text("\(item[keyPath: \.name]) (\(item.count))")
        }
    }
}

struct KeyPathExampleScreen_Previews: PreviewProvider {
    static var previews: some View {
        KeyPathExampleScreen()
    }
}

// MARK: - Models

struct KeyPathDummyModel {
    let A: Int
    let B: Int
    let C: Int

    static let items = [
        KeyPathDummyModel(A: 1, B: 2, C: 3),
        KeyPathDummyModel(A: 4, B: 5, C: 6),
        KeyPathDummyModel(A: 7, B: 8, C: 9),
    ]

    func process(path: KeyPath<KeyPathDummyModel, Int>) -> [Int] {
        switch path {
            case \.A:
                return KeyPathDummyModel.items.map(\.A)
            case \.B:
                return KeyPathDummyModel.items.map(\.B)
            case \.C:
                return KeyPathDummyModel.items.map(\.C)
            default:
                return []
        }
    }
}

// MARK: - Extensions

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}
