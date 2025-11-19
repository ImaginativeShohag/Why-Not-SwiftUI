//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Combine
import Observation
import SwiftUI

@MainActor
@Observable
class KeyboardObserver {
    var isKeyboardVisible: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        let willShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }
            
        let willHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in false }
            
        Publishers.Merge(willShow, willHide)
            .receive(on: RunLoop.main)
            .sink { [weak self] isVisible in
                self?.isKeyboardVisible = isVisible
            }
            .store(in: &cancellables)
    }
}
