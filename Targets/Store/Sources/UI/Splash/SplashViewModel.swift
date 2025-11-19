//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class SplashViewModel {
    var nextAction: SplashNextAction?

    private var isPreview: Bool = false

    init() {}

    func checkNextAction() async {
        guard !isPreview else { return }

        try? await Task.sleep(for: .seconds(1))

        if Preferences.user != nil {
            nextAction = .home
        } else {
            nextAction = .auth
        }
    }
}

enum SplashNextAction {
    case auth
    case home
}

#if DEBUG

extension SplashViewModel {
    convenience init(
        forPreview: Bool
    ) {
        self.init()

        isPreview = true
    }
}

#endif
