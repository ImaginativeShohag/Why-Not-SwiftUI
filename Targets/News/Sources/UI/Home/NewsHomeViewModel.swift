//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@Observable
class NewsHomeViewModel {
    var news: UIState<[News]> = .loading
    var types: UIState<[NewsType]> = .loading

    private var isPreview: Bool = false

    private let repository: NewsRepository

    init(repository: NewsRepository = NewsRepository()) {
        self.repository = repository
    }

    func loadData(forced: Bool = false) async {
        guard !isPreview, news.isLoading || forced else { return }

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

    func loadTypes() async {
        guard !isPreview else { return }

        types = .loading

        let result = await repository.getNewsTypes()

        switch result {
        case .success(let response):
            if response.success == true, let newsList = response.data {
                types = .data(data: newsList)
            } else {
                types = .error(message: response.message ?? "Unknown error")
            }

        case .failure(_, let errorMessage, _):
            types = .error(message: errorMessage)
        }
    }
}

#if DEBUG

extension NewsHomeViewModel {
    convenience init(
        forPreview: Bool,
        isLoading: Bool = false,
        isError: Bool = false,
        showFeatured: Bool = true,
        hasNews: Bool = true
    ) {
        self.init()

        isPreview = true

        if isLoading {
            news = .loading
        } else if isError {
            news = .error(message: "Something went wrong!")
        } else if !hasNews {
            news = .data(data: [])
        } else {
            let newsList: [News]

            if showFeatured {
                newsList = (1 ... 20)
                    .map { News.mockItem(id: $0, isFeatured: $0 % 2 == 0 ? true : false) }
            } else {
                newsList = (1 ... 20)
                    .map { News.mockItem(id: $0, isFeatured: false) }
            }

            news = .data(data: newsList)
            types = .data(data: (1 ... 20).map {
                NewsType.mockItem(
                    id: $0
                )
            })
        }
    }
}

#endif
