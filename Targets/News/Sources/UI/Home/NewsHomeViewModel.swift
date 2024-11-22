//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@Observable
class NewsHomeViewModel {
    var newsState: UIState<[News]> = .loading
    var typesState: UIState<[NewsType]> = .loading

    private var isPreview: Bool = false

    private let repository: NewsRepository

    init(repository: NewsRepository = NewsRepository()) {
        self.repository = repository
    }

    func loadData(forced: Bool = false) async {
        guard !isPreview, newsState.isLoading || forced else { return }

        newsState = .loading

        let result = await repository.getAllNews()

        switch result {
        case .success(let response):
            if response.success == true, let newsList = response.news {
                newsState = .data(data: newsList)
            } else {
                newsState = .error(message: response.message ?? "Unknown error")
            }

        case .failure(_, let errorMessage, _):
            newsState = .error(message: errorMessage)
        }
    }

    func loadTypes() async {
        guard !isPreview else { return }

        typesState = .loading

        let result = await repository.getNewsTypes()

        switch result {
        case .success(let response):
            if response.success == true, let newsList = response.data {
                typesState = .data(data: newsList)
            } else {
                typesState = .error(message: response.message ?? "Unknown error")
            }

        case .failure(_, let errorMessage, _):
            typesState = .error(message: errorMessage)
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
        hasNews: Bool = true,
        isNewsTypeError: Bool = false
    ) {
        self.init()

        isPreview = true

        if isLoading {
            newsState = .loading
        } else if isError {
            newsState = .error(message: "Something went wrong!")
        } else if !hasNews {
            newsState = .data(data: [])
        } else {
            let newsList: [News]

            if showFeatured {
                newsList = (1 ... 20)
                    .map { News.mockItem(id: $0, isFeatured: $0 % 2 == 0 ? true : false) }
            } else {
                newsList = (1 ... 20)
                    .map { News.mockItem(id: $0, isFeatured: false) }
            }

            newsState = .data(data: newsList)

            if isNewsTypeError {
                typesState = .error(message: "Something went wrong!")
            } else {
                typesState = .data(data: (1 ... 20).map {
                    NewsType.mockItem(
                        id: $0
                    )
                })
            }
        }
    }
}

#endif
