//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct TextFieldValidationScreen: View {
    @StateObject private var viewModel = TextFieldValidationViewModel()

    var body: some View {
        ScrollView {
            VStack {
                CustomTextFieldView(
                    value: $viewModel.fullName,
                    placeHolder: "Full Name",
                    isError: viewModel.fullName.count < 1
                )

                CustomTextFieldView(
                    value: $viewModel.email,
                    placeHolder: "Email",
                    keyboardType: .emailAddress,
                    isError: viewModel.email.count < 1 || viewModel.showEmailError
                )
                .autocapitalization(.none)
                .autocorrectionDisabled()

                if viewModel.showEmailError {
                    Text("Enter a valid email!")
                        .fontStyle(size: 12)
                        .frame(maxWidth: .infinity)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                CustomTextFieldView(
                    value: $viewModel.phoneNumber,
                    placeHolder: "Phone Number",
                    keyboardType: .phonePad,
                    isError: viewModel.phoneNumber.count < 9
                )
                .onChange(of: viewModel.phoneNumber) {
                    viewModel.phoneNumber = String(viewModel.phoneNumber.prefix(9))
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
        .animation(.easeInOut, value: [viewModel.canSubmit, viewModel.showEmailError])
        .navigationTitle("TextField Validation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TextFieldValidationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TextFieldValidationScreen()
        }
    }
}
