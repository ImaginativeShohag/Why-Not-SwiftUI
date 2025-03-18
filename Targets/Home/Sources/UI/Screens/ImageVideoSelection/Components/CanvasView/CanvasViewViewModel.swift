//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

@MainActor
@Observable
class CanvasViewViewModel {
    var selectedTextBoxId: String? {
        didSet {
            print("debug2: didSet selectedTextBox")
        }
    }
    var selectedShapeId: String? {
        didSet {
            print("debug2: didSet selectedTextBox")
        }
    }

    init() {
        print("debug2: init CanvasViewViewModel")
    }
}
