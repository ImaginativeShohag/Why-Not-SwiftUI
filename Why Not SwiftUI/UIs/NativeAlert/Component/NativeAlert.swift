//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - General Approach

private class NativeAlertController: UIViewController {
    private var onDismiss: ()->Void

    private let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("") }

    init(
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
    @Binding private var isPresented: Bool
    private let title: String?
    private let message: String?
    private let primaryButtonText: String
    private let primaryButtonTextColor: Color
    private let primaryHandler: ()->Void
    private let secondaryButtonText: String?
    private let secondaryButtonTextColor: Color
    private let secondaryHandler: ()->Void

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

// MARK: - Modern Approach

private class ModernNativeAlertController: UIViewController {
    private var onDismiss: ()->Void

    private var alert: UIAlertController?

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("") }

    init(
        onDismiss: @escaping ()->Void
    ) {
        self.onDismiss = onDismiss

        super.init(nibName: nil, bundle: nil)
    }

    private func initAlert(_ data: NativeAlertData)->UIAlertController? {
        alert?.dismiss(animated: true)

        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        guard let alert = alert else { return nil }

        if let title = data.title {
            alert.title = title
        }

        if let message = data.message {
            alert.message = message
        }

        let primaryAction = UIAlertAction(title: data.primaryButtonText, style: .default, handler: { _ in
            self.onDismiss()
            data.primaryHandler()
        })
        primaryAction.setValue(UIColor(data.primaryButtonTextColor), forKey: "titleTextColor")
        alert.addAction(primaryAction)

        if let secondaryButtonText = data.secondaryButtonText {
            let secondaryAction = UIAlertAction(title: secondaryButtonText, style: .default, handler: { _ in
                self.onDismiss()
                data.secondaryHandler()
            })
            secondaryAction.setValue(UIColor(data.secondaryButtonTextColor), forKey: "titleTextColor")
            alert.addAction(secondaryAction)
        }

        return alert
    }

    func show(data: NativeAlertData) {
        if alert == nil || alert?.isBeingPresented == false {
            if let alert = initAlert(data) {
                present(alert, animated: true, completion: nil)
            }
        }
    }

    func hide() {
        alert?.dismiss(animated: true) {
            self.onDismiss()
        }
    }

    override func viewWillDisappear(_: Bool) {
        hide()
    }
}

private struct NativeAlertModern: UIViewControllerRepresentable {
    @Binding private var data: NativeAlertData?

    init(
        data: Binding<NativeAlertData?>
    ) {
        self._data = data
    }

    func makeUIViewController(context _: Context)->ModernNativeAlertController {
        return ModernNativeAlertController(
            onDismiss: onDismiss
        )
    }

    func updateUIViewController(_ uiViewController: ModernNativeAlertController, context _: Context) {
        if let data = data {
            uiViewController.show(data: data)
        } else {
            uiViewController.hide()
        }
    }

    private func onDismiss() {
        DispatchQueue.main.async {
            data = nil
        }
    }
}

private struct NativeAlertCallback<Item: Identifiable>: UIViewControllerRepresentable {
    @Binding private var item: Item?
    private let content: (Item)->NativeAlertData

    init(
        item: Binding<Item?>,
        content: @escaping (Item)->NativeAlertData
    ) {
        self._item = item
        self.content = content
    }

    func makeUIViewController(context _: Context)->ModernNativeAlertController {
        return ModernNativeAlertController(
            onDismiss: onDismiss
        )
    }

    func updateUIViewController(_ uiViewController: ModernNativeAlertController, context _: Context) {
        if let item = item {
            uiViewController.show(data: content(item))
        } else {
            uiViewController.hide()
        }
    }

    private func onDismiss() {
        DispatchQueue.main.async {
            item = nil
        }
    }
}

// MARK: - Extensions

extension View {
    func alert(
        isPresented: Binding<Bool>,
        title: String? = nil,
        message: String? = nil,
        primaryButtonText: String,
        primaryButtonTextColor: Color = Color(.systemBlue),
        primaryHandler: @escaping ()->Void = {},
        secondaryButtonText: String? = nil,
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

    func alert(
        data: Binding<NativeAlertData?>
    )->some View {
        return AnyView(background(NativeAlertModern(
            data: data
        )))
    }

    func alert<Item: Identifiable>(
        data: Binding<Item?>,
        content: @escaping (Item)->NativeAlertData
    ) ->some View {
        return AnyView(background(NativeAlertCallback(
            item: data,
            content: content
        )))
    }
}

// MARK: - Models

struct NativeAlertData {
    let title: String?
    let message: String?
    let primaryButtonText: String
    let primaryButtonTextColor: Color
    let primaryHandler: ()->Void
    let secondaryButtonText: String?
    let secondaryButtonTextColor: Color
    let secondaryHandler: ()->Void

    init(
        title: String? = nil,
        message: String? = nil,
        primaryButtonText: String,
        primaryButtonTextColor: Color = Color(.systemBlue),
        primaryHandler: @escaping ()->Void = {},
        secondaryButtonText: String? = nil,
        secondaryButtonTextColor: Color = Color(.systemBlue),
        secondaryHandler: @escaping ()->Void = {}
    ) {
        self.title = title
        self.message = message
        self.primaryButtonText = primaryButtonText
        self.primaryButtonTextColor = primaryButtonTextColor
        self.primaryHandler = primaryHandler
        self.secondaryButtonText = secondaryButtonText
        self.secondaryButtonTextColor = secondaryButtonTextColor
        self.secondaryHandler = secondaryHandler
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
