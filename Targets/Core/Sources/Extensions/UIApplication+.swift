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

    /// Capture the app's active key window as it appears on screen.
    ///
    /// - Returns: The screenshot as `UIImage` or `nil` if no foreground-active scene or key window is found.
    func screenshot() -> UIImage? {
        let scenes = self.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        let windows = scenes
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            ?? scenes.flatMap { $0.windows }

        guard let window = windows.first(where: { $0.isKeyWindow }) else { return nil }

        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        return renderer.image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
    }
}
