//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

class NewsRepository {
    func getAllNews() async -> ApiResult<AllNewsResponse> {
        return await DataSource.News.request(
            AllNewsResponse.self,
            on: .allNews
        )
    }

    func getNewsTypes() async -> ApiResult<NewsTypesResponse> {
        return await DataSource.News.request(
            NewsTypesResponse.self,
            on: .newsTypes
        )
    }
}
