//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import SwiftUI
import Observation

@Observable
class URLSessionViewModel {
    var state: UIState<[Fruit]> = .loading

    private var isPreview: Bool = false

    func getFruits() async {
        guard !isPreview else { return }

        state = .loading

        do {
            let apiEndpoint = URL(string: "https://raw.githubusercontent.com/ImaginativeShohag/Why-Not-SwiftUI/dev/raw/fruits.json")!
            let (data, _) = try await URLSession.shared.data(from: apiEndpoint)

            if let fruitsResponse = try? JSONDecoder().decode(
                FruitsResponse.self,
                from: data
            ) {
                if fruitsResponse.success == true, let fruitList = fruitsResponse.data {
                    state = .data(data: fruitList)
                } else {
                    state = .error(message: "Cannot Load Data!")
                }
            } else {
                state = .error(message: "Wrong response. Please try again.")
            }
        } catch {
            state = .error(message: error.localizedDescription)
        }
    }
}

#if DEBUG

extension URLSessionViewModel {
    convenience init(
        forPreview: Bool,
        isLoading: Bool = false,
        isError: Bool = false,
        hasData: Bool = true
    ) {
        self.init()

        isPreview = true

        if isLoading {
            state = .loading
        } else if isError {
            state = .error(message: "Something went wrong!")
        } else if !hasData {
            state = .data(data: [])
        } else {
            state = .data(data: Fruit.mockItems())
        }
    }
}

#endif
