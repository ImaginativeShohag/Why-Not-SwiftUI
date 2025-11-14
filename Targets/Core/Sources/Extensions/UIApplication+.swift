//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import UIKit

public extension UIApplication {
    /// Returns the active / visible `UIWindow`.
    ///
    /// Source: https://stackoverflow.com/a/58031897/2263329
    var activeWindow: UIWindow? {
        return UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .last
    }

    /// Returns  `rootViewController`.
    var rootViewController: UIViewController? {
        let scene = self.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene

        return scene?.keyWindow?.rootViewController
    }

    /// Hide the software keyboard.
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
