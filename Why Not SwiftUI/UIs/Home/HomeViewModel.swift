//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Combine
import CombineMoya
import Foundation
import UIKit

class HomeViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    let isJailBroken = UIDevice.current.isJailBroken
    
    func getPosts() {
        goRestProvider.requestPublisher(.posts, callbackQueue: DispatchQueue.main)
            .print("network calling...")
            .sink(receiveCompletion: { completion in
                guard case let .failure(error) = completion else { return }
                
                print("error: \(error)")
            }, receiveValue: { response in
                let data = response.data
                let statusCode = response.statusCode
                // do something with the response data or statusCode
                
                let str = String(decoding: data, as: UTF8.self)
                
                print("result: \(str)")
            })
            .store(in: &cancellables)
    }
}
