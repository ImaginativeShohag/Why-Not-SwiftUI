//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@Observable
class NewsHomeViewModel {
    var news: UIState<[News]> = .loading

    private let repository: NewsRepository

    init(repository: NewsRepository = NewsRepository()) {
        self.repository = repository
    }

    func loadData() async {
        news = .loading

        let result = await repository.getAllNews()

        switch result {
        case .success(let response):
            if response.success == true, let newsList = response.news {
                news = .data(data: newsList)
            } else {
                news = .error(message: response.message ?? "Unknown error")
            }

        case .failure(let error, let errorMessage, let statusCode):
            news = .error(message: errorMessage)
        }
    }
}
