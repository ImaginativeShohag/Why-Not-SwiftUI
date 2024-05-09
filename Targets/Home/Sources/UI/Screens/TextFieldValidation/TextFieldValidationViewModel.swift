//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

@MainActor
@Observable
class TextFieldValidationViewModel {
    var fullName: String = "" {
        didSet {
            validate()
        }
    }

    var email: String = "" {
        didSet {
            validate()
        }
    }

    var phoneNumber: String = "" {
        didSet {
            validate()
        }
    }

    var canSubmit = false
    var showEmailError = false
    var showSuccessAlert = false

    nonisolated init() {}

    func validate() {
        showEmailError = !email.isEmpty && !email.isValidEmail()

        canSubmit = !fullName.isEmpty &&
            email.isValidEmail() &&
            !phoneNumber.isEmpty && phoneNumber.count >= 9
    }

    func submit() {
        // ...
        
        showSuccessAlert = true
    }
}
