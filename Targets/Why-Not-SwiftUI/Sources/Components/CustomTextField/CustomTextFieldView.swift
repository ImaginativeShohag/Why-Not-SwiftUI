//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

/// Component Name: `CustomTextFieldView`
/// Version: `1.0.230327`

struct CustomTextFieldView: View {
    @Binding var value: String
    var placeHolder: String
    var keyboardType: UIKeyboardType = .default
    var isError: Bool = false

    @FocusState private var isFocused: Bool
    @State private var showValueField = false

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme

    private var borderColor: Color {
        if isError {
            .red
        } else {
            Color.systemGray4
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(
                "",
                text: $value
            )
            .font(.system(size: 16))
            .focused($isFocused)
            .onSubmit {
                if value == "" {
                    hideValue()
                }
            }
            .keyboardType(keyboardType)
            .onChange(of: isFocused) { focused in
                if focused {
                    showValue()
                } else {
                    if value == "" {
                        hideValue()
                    }
                }
            }
            .onChange(of: value) { newValue in
                if !newValue.isEmpty {
                    showValue()
                } else if !isFocused {
                    hideValue()
                }
            }
            .padding(.top, showValueField ? 17 : 0)
            .background(
                Text(placeHolder)
                    .font(.system(size: showValueField ? 14 : 16))
                    .foregroundColor(colorScheme == .light ? Color.label.opacity(0.55) : Color.label.opacity(0.75))
                    .offset(
                        y: showValueField ? -11 : 0
                    ),
                alignment: .leading
            )
            .padding(EdgeInsets(
                top: 0,
                leading: 13,
                bottom: 0,
                trailing: 0
            ))
        }
        .onAppear(perform: {
            if value != "" {
                showValueField = true
            }
        })
        .frame(height: 51)
        .background(isEnabled ? Color.secondarySystemGroupedBackground : Color.systemGray5)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    private func showValue() {
        withAnimation(.easeIn(duration: 0.15)) {
            showValueField = true
        }
    }

    private func hideValue() {
        withAnimation(.easeOut(duration: 0.15)) {
            showValueField = false
        }
    }
}

struct CustomTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomTextFieldView(
                value: .constant(""),
                placeHolder: "Full Name",
                keyboardType: .default
            )

            CustomTextFieldView(
                value: .constant(""),
                placeHolder: "Full Name",
                keyboardType: .default,
                isError: true
            )

            CustomTextFieldView(
                value: .constant(""),
                placeHolder: "Full Name",
                keyboardType: .default
            )
            .disabled(true)

            CustomTextFieldView(
                value: .constant(""),
                placeHolder: "Full Name",
                keyboardType: .default,
                isError: true
            )
            .disabled(true)

            CustomTextFieldView(
                value: .constant("Mahmudul Hasan Shohag"),
                placeHolder: "Full Name",
                keyboardType: .namePhonePad
            )

            CustomTextFieldView(
                value: .constant("Mahmudul Hasan Shohag"),
                placeHolder: "Full Name",
                keyboardType: .namePhonePad,
                isError: true
            )

            CustomTextFieldView(
                value: .constant("Mahmudul Hasan Shohag"),
                placeHolder: "Full Name",
                keyboardType: .namePhonePad
            )
            .disabled(true)

            CustomTextFieldView(
                value: .constant("   "),
                placeHolder: "Full Name"
            )

            CustomTextFieldView(
                value: .constant("   "),
                placeHolder: "Full Name",
                isError: true
            )
        }
        .padding()
    }
}
