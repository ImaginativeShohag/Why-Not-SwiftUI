//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

class TextFieldValidationViewModel: ObservableObject {
    @Published var email: String = "" {
        didSet {
            validate()

            isValidEmail = email.isValidEmail()
        }
    }

    @Published var phoneNumber: String = "" {
        didSet {
            validate()
        }
    }

    @Published var canSubmit = false
    @Published var isValidEmail = false

    func validate() {
        canSubmit = email.isValidEmail() && !phoneNumber.isEmpty
    }

    func submit() {
        // no-op
    }
}
