//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import Core
import SwiftUI

@Observable
class AlamofireViewModel {
    var state: UIState<[Flower]> = .loading

    private var isPreview: Bool = false

    func getFlowers() async {
        guard !isPreview else { return }

        state = .loading

        let apiEndpoint = URL(string: "https://raw.githubusercontent.com/ImaginativeShohag/Why-Not-SwiftUI/dev/raw/flowers.json")!

        let result = await AF.request(apiEndpoint)
            .serializingDecodable(FlowersResponse.self)
            .result

        switch result {
        case .success(let fruitsResponse):
            if fruitsResponse.success == true, let fruitList = fruitsResponse.data {
                state = .data(data: fruitList)
            } else {
                state = .error(message: "Cannot Load Data!")
            }

        case .failure(let error):
            state = .error(message: error.localizedDescription)
        }
    }
}

#if DEBUG

extension AlamofireViewModel {
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
            state = .data(data: Flower.mockItems())
        }
    }
}

#endif
