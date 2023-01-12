//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

private class NativeAlertController: UIViewController {
    private var isPresented: Bool
    private var onDismiss: ()->Void

    private let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("") }

    init(
        isPresented: Bool,
        title: String?,
        message: String?,
        primaryButtonText: String,
        primaryButtonTextColor: Color,
        primaryHandler: @escaping ()->Void,
        secondaryButtonText: String?,
        secondaryButtonTextColor: Color,
        secondaryHandler: @escaping ()->Void,
        onDismiss: @escaping ()->Void
    ) {
        self.isPresented = isPresented
        self.onDismiss = onDismiss

        if let title = title {
            alert.title = title
        }

        if let message = message {
            alert.message = message
        }

        let primaryAction = UIAlertAction(title: primaryButtonText, style: .default, handler: { _ in
            onDismiss()
            primaryHandler()
        })
        primaryAction.setValue(UIColor(primaryButtonTextColor), forKey: "titleTextColor")
        alert.addAction(primaryAction)

        if let secondaryButtonText = secondaryButtonText {
            let secondaryAction = UIAlertAction(title: secondaryButtonText, style: .default, handler: { _ in
                onDismiss()
                secondaryHandler()
            })
            secondaryAction.setValue(UIColor(secondaryButtonTextColor), forKey: "titleTextColor")
            alert.addAction(secondaryAction)
        }

        super.init(nibName: nil, bundle: nil)
    }

    func show() {
        if !alert.isBeingPresented {
            present(alert, animated: true, completion: nil)
        }
    }

    func hide() {
        alert.dismiss(animated: true) {
            self.onDismiss()
        }
    }

    override func viewWillDisappear(_: Bool) {
        hide()
    }
}

private struct NativeAlert: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let title: String?
    let message: String?
    let primaryButtonText: String
    let primaryButtonTextColor: Color
    let primaryHandler: ()->Void
    let secondaryButtonText: String?
    let secondaryButtonTextColor: Color
    let secondaryHandler: ()->Void

    init(
        isPresented: Binding<Bool>,
        title: String?,
        message: String?,
        primaryButtonText: String,
        primaryButtonTextColor: Color,
        primaryHandler: @escaping ()->Void,
        secondaryButtonText: String?,
        secondaryButtonTextColor: Color,
        secondaryHandler: @escaping ()->Void
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.primaryButtonText = primaryButtonText
        self.primaryButtonTextColor = primaryButtonTextColor
        self.primaryHandler = primaryHandler
        self.secondaryButtonText = secondaryButtonText
        self.secondaryButtonTextColor = secondaryButtonTextColor
        self.secondaryHandler = secondaryHandler
    }

    func makeUIViewController(context _: Context)->NativeAlertController {
        return NativeAlertController(
            isPresented: isPresented,
            title: title,
            message: message,
            primaryButtonText: primaryButtonText,
            primaryButtonTextColor: primaryButtonTextColor,
            primaryHandler: primaryHandler,
            secondaryButtonText: secondaryButtonText,
            secondaryButtonTextColor: secondaryButtonTextColor,
            secondaryHandler: secondaryHandler,
            onDismiss: onDismiss
        )
    }

    func updateUIViewController(_ uiViewController: NativeAlertController, context _: Context) {
        if isPresented {
            uiViewController.show()
        } else {
            uiViewController.hide()
        }
    }

    private func onDismiss() {
        DispatchQueue.main.async {
            isPresented = false
        }
    }
}

extension View {
    func alert(
        isPresented: Binding<Bool>,
        title: String?,
        message: String?,
        primaryButtonText: String,
        primaryButtonTextColor: Color = Color(.systemBlue),
        primaryHandler: @escaping ()->Void = {},
        secondaryButtonText: String?,
        secondaryButtonTextColor: Color = Color(.systemBlue),
        secondaryHandler: @escaping ()->Void = {}
    )->some View {
        return AnyView(background(NativeAlert(
            isPresented: isPresented,
            title: title,
            message: message,
            primaryButtonText: primaryButtonText,
            primaryButtonTextColor: primaryButtonTextColor,
            primaryHandler: primaryHandler,
            secondaryButtonText: secondaryButtonText,
            secondaryButtonTextColor: secondaryButtonTextColor,
            secondaryHandler: secondaryHandler
        )))
    }
}

// MARK: - Previews

struct NativeAlert_Previews: PreviewProvider {
    static var showAlert = false

    static var previews: some View {
        ZStack {
            Text("Native Alert")
        }
        .alert(
            isPresented: .constant(true),
            title: "Awesome title",
            message: "Awesome message",
            primaryButtonText: "Ok",
            primaryButtonTextColor: Color(.systemGreen),
            primaryHandler: {
                //
            },
            secondaryButtonText: "Cool",
            secondaryButtonTextColor: Color(.systemRed),
            secondaryHandler: {
                //
            }
        )
    }
}
