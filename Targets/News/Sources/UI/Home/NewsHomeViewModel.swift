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

    func loadData(forced: Bool = false) async {
        guard news.isLoading || forced else { return }

        news = .loading

        let result = await repository.getAllNews()

        switch result {
        case .success(let response):
            if response.success == true, let newsList = response.news {
                news = .data(data: newsList)
            } else {
                news = .error(message: response.message ?? "Unknown error")
            }

        case .failure(_, let errorMessage, _):
            news = .error(message: errorMessage)
        }
    }
}

#if DEBUG

extension NewsHomeViewModel {
    convenience init(forPreview: Bool) {
        self.init()

        news =
            .data(
                data: (1 ... 10)
                    .map {
                        News.mockItem(
                            id: $0,
                            isFeatured: $0 % 2 == 0 ? true : false
                        )
                    }
            )
    }
}

#endif
