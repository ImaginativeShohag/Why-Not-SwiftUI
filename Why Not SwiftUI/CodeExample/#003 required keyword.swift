//
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import Foundation

// MARK: - Example#003: `some` vs `any`

class E3_A {
    var num: Int

    required init(num: Int) {
        self.num = num
    }
}

class E3_B: E3_A {
    /// This does not need any initialization, because of `Automatic Initializer Inheritance`.
    /// Source: https://docs.swift.org/swift-book/LanguageGuide/Initialization.html (Automatic Initializer Inheritance)
    ///
    /// Automatic Initializer Inheritance:
    ///  - **Rule 1**
    ///    If your subclass doesn’t define any designated initializers, it automatically inherits all of its superclass designated initializers.
    ///
    ///  - **Rule 2**
    ///    If your subclass provides an implementation of all of its superclass designated initializers—either by inheriting them as per rule 1, or by providing a custom implementation as part of its definition—then it automatically inherits all of the superclass convenience initializers.

    func test() {
        print("hello.")
    }
}

class E3_C: E3_A {
    init() {
        print("Initialize.")

        // 'super.init' isn't called on all paths before returning from initializer
        super.init(num: 0)
    }

    // 'required' initializer 'init(num:)' must be provided by subclass of 'E3_A'
    required init(num: Int) {
        print("required initializer.")

        // 'super.init' isn't called on all paths before returning from initializer
        super.init(num: num)
    }
}
