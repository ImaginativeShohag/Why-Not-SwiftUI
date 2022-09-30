//
//  MainViewModel.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 8/8/22.
//

import Combine
import CombineMoya
import Foundation

class MainViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    func getPosts() {
        print("1111111")
        
        goRestProvider.requestPublisher(.posts, callbackQueue: DispatchQueue.main)
            .print("6666666")
            .sink(receiveCompletion: { completion in
                guard case let .failure(error) = completion else { return }
                
                print("22222: \(error)")
            }, receiveValue: { response in
                let data = response.data
                let statusCode = response.statusCode
                // do something with the response data or statusCode
                
                let str = String(decoding: data, as: UTF8.self)
                
                print("333333: \(str)")
            })
            .store(in: &cancellables)
    }
}
