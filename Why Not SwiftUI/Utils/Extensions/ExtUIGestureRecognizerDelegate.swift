//
//  ExtUIGestureRecognizerDelegate.swift
//  RDDM (iOS)
//
//  Created by iOS Developer on 9/19/22.
//

import Foundation
import SwiftUI

/// Magic code for enabling swipe back to dismiss a screen, when default back button set hidden (`navigationBarBackButtonHidden(true)`) on navigation.
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }

    // To make it works also with ScrollView
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
