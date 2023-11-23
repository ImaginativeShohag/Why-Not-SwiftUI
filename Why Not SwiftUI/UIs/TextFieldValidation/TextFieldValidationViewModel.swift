//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

@MainActor
class TextFieldValidationViewModel: ObservableObject {
    @Published var fullName: String = "" {
        didSet {
            validate()
        }
    }

    @Published var email: String = "" {
        didSet {
            validate()
        }
    }

    @Published var phoneNumber: String = "" {
        didSet {
            validate()
        }
    }

    @Published var canSubmit = false
    @Published var showEmailError = false

    func validate() {
        showEmailError = !email.isEmpty && !email.isValidEmail()

        canSubmit = !fullName.isEmpty &&
            email.isValidEmail() &&
            !phoneNumber.isEmpty && phoneNumber.count >= 9
    }

    func submit() {
        // no-op
    }
}
