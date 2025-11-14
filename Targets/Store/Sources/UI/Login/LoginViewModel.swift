//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class LoginViewModel {
    var state: UIState<Bool>?

    private var isPreview: Bool = false
    private nonisolated let repository: StoreRepository

    init(repository: StoreRepository = StoreRepository()) {
        self.repository = repository
    }

    func login(username: String, password: String) async {
        guard !isPreview else { return }

        state = .loading

        let result = await repository.login(
            username: username,
            password: password
        )

        switch result {
        case .success(let response):
            if response.token.isEmpty {
                state = .error(message: "Invalid credentials")
                return
            }

            await getUserDetails()

        case .failure(_, let errorMessage, _):
            state = .error(message: errorMessage)
        }
    }

    private func getUserDetails() async {
        state = .loading

        let result = await repository.getUserDetails(
            userId: Constant.userId
        )

        switch result {
        case .success(let user):
            // Store initial information about logged in person.
            Preferences.user = user
            Preferences.name = user.name.getFullName()
            Preferences.phoneNumber = user.phone
            Preferences.address = user.address?.getAddress() ?? ""

            // Update state.
            state = .data(data: true)

        case .failure(_, let errorMessage, _):
            state = .error(message: errorMessage)
        }
    }
}

#if DEBUG

extension LoginViewModel {
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
            state = .data(data: true)
        }
    }
}

#endif
