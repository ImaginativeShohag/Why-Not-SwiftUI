//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class ProfileViewModel {
    var state: UIState<StoreUser> = .loading

    private var isPreview: Bool = false
    private nonisolated let repository: StoreRepository

    init(repository: StoreRepository = StoreRepository()) {
        self.repository = repository
    }

    func getUserDetails() async {
        if let user = Preferences.user {
            state = .data(data: user)
        }
    }
}

#if DEBUG

extension ProfileViewModel {
    convenience init(
        forPreview: Bool,
        isLoading: Bool,
        isError: Bool
    ) {
        self.init()

        isPreview = true

        if isLoading {
            state = .loading
        } else if isError {
            state = .error(message: "Something went wrong! Try again.")
        } else {
            state = .data(data: StoreUser.mockItem())
        }
    }
}

#endif
