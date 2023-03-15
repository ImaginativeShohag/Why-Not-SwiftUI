//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct TextFieldValidationScreen: View {
    @StateObject private var viewModel = TextFieldValidationViewModel()

    var body: some View {
        VStack {
            CustomTextFieldView(
                value: $viewModel.email,
                placeHolder: "Email"
            )
            if !viewModel.email.isEmpty && !viewModel.isValidEmail {
                Text("Enter a valid email!")
                    .fontStyle(size: 12)
            }

            CustomTextFieldView(
                value: $viewModel.phoneNumber,
                placeHolder: "Phone Number"
            )
            .onChange(of: viewModel.phoneNumber) { newValue in
                viewModel.phoneNumber = String(newValue.prefix(9))
                    .filter("0123456789".contains)
            }
            
            Button {
                viewModel.submit()
            } label: {
                Text("Submit")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSubmit)
        }
        .padding()
    }

    func validate(name: String) -> Bool {
        return true
    }
}

struct TextFieldValidationScreen_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldValidationScreen()
    }
}
