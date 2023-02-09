//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

/// Component Name: `NativeAlert`
/// Version: `1.1.09022023`

// MARK: - Extensions

extension UIAlertController {
    static func createAlert(
        title: String?,
        message: String?,
        primaryButtonText: String,
        primaryButtonTextColor: Color?,
        primaryButtonStyle: UIAlertAction.Style,
        primaryButtonHandler: @escaping ()->Void,
        secondaryButtonText: String?,
        secondaryButtonTextColor: Color?,
        secondaryButtonStyle: UIAlertAction.Style,
        secondaryButtonHandler: @escaping ()->Void,
        onDismiss: @escaping ()->Void
    )->UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // MARK: Secondary Button

        if let secondaryButtonText = secondaryButtonText {
            let secondaryAction = UIAlertAction(title: secondaryButtonText, style: secondaryButtonStyle, handler: { _ in
                onDismiss()
                secondaryButtonHandler()
            })
            if let secondaryButtonTextColor = secondaryButtonTextColor {
                secondaryAction.setValue(UIColor(secondaryButtonTextColor), forKey: "titleTextColor")
            }
            alert.addAction(secondaryAction)
        }

        // MARK: Primary Button

        /// We add the primary button in the second place, because it should be on the right of the `Alert`.
        /// The button placement could be changed based on the "style" parameter by the system.
        let primaryAction = UIAlertAction(title: primaryButtonText, style: primaryButtonStyle, handler: { _ in
            onDismiss()
            primaryButtonHandler()
        })
        if let primaryButtonTextColor = primaryButtonTextColor {
            primaryAction.setValue(UIColor(primaryButtonTextColor), forKey: "titleTextColor")
        }
        alert.addAction(primaryAction)

        return alert
    }
}

// MARK: - General Approach

private class NativeAlertController: UIViewController {
    var isPresented: Bool = false

    private let alert: UIAlertController
    private var onDismiss: ()->Void

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("") }

    init(
        title: String?,
        message: String?,
        primaryButtonText: String,
        primaryButtonTextColor: Color?,
        primaryButtonStyle: UIAlertAction.Style,
        primaryButtonHandler: @escaping ()->Void,
        secondaryButtonText: String?,
        secondaryButtonTextColor: Color?,
        secondaryButtonStyle: UIAlertAction.Style,
        secondaryButtonHandler: @escaping ()->Void,
        onDismiss: @escaping ()->Void
    ) {
        self.onDismiss = onDismiss

        self.alert = UIAlertController.createAlert(
            title: title,
            message: message,
            primaryButtonText: primaryButtonText,
            primaryButtonTextColor: primaryButtonTextColor,
            primaryButtonStyle: primaryButtonStyle,
            primaryButtonHandler: primaryButtonHandler,
            secondaryButtonText: secondaryButtonText,
            secondaryButtonTextColor: secondaryButtonTextColor,
            secondaryButtonStyle: secondaryButtonStyle,
            secondaryButtonHandler: secondaryButtonHandler,
            onDismiss: onDismiss
        )

        super.init(nibName: nil, bundle: nil)
    }

    func show() {
        DispatchQueue.main.async {
            if !self.alert.isBeingPresented, !self.alert.isBeingDismissed {
                self.present(self.alert, animated: true, completion: nil)
            }
        }
    }

    func hide() {
        DispatchQueue.main.async {
            self.alert.dismiss(animated: true) {
                self.onDismiss()
            }
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
    private let primaryButtonTextColor: Color?
    private let primaryButtonStyle: UIAlertAction.Style
    private let primaryButtonHandler: ()->Void
    private let secondaryButtonText: String?
    private let secondaryButtonTextColor: Color?
    private let secondaryButtonStyle: UIAlertAction.Style
    private let secondaryButtonHandler: ()->Void

    init(
        isPresented: Binding<Bool>,
        title: String?,
        message: String?,
        primaryButtonText: String,
        primaryButtonTextColor: Color?,
        primaryButtonStyle: UIAlertAction.Style,
        primaryButtonHandler: @escaping ()->Void,
        secondaryButtonText: String?,
        secondaryButtonTextColor: Color?,
        secondaryButtonStyle: UIAlertAction.Style,
        secondaryButtonHandler: @escaping ()->Void
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.primaryButtonText = primaryButtonText
        self.primaryButtonTextColor = primaryButtonTextColor
        self.primaryButtonStyle = primaryButtonStyle
        self.primaryButtonHandler = primaryButtonHandler
        self.secondaryButtonText = secondaryButtonText
        self.secondaryButtonTextColor = secondaryButtonTextColor
        self.secondaryButtonStyle = secondaryButtonStyle
        self.secondaryButtonHandler = secondaryButtonHandler
    }

    func makeUIViewController(context _: Context)->NativeAlertController {
        return NativeAlertController(
            title: title,
            message: message,
            primaryButtonText: primaryButtonText,
            primaryButtonTextColor: primaryButtonTextColor,
            primaryButtonStyle: primaryButtonStyle,
            primaryButtonHandler: primaryButtonHandler,
            secondaryButtonText: secondaryButtonText,
            secondaryButtonTextColor: secondaryButtonTextColor,
            secondaryButtonStyle: secondaryButtonStyle,
            secondaryButtonHandler: secondaryButtonHandler,
            onDismiss: onDismiss
        )
    }

    func updateUIViewController(_ uiViewController: NativeAlertController, context _: Context) {
        if uiViewController.isPresented == isPresented { return }

        uiViewController.isPresented = isPresented

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

private class NativeAlertModernController<Item: Identifiable>: UIViewController {
    var item: Item?

    private var alert: UIAlertController?
    private var onDismiss: ()->Void

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("") }

    init(onDismiss: @escaping ()->Void) {
        self.onDismiss = onDismiss

        super.init(nibName: nil, bundle: nil)
    }

    private func createAlert(_ data: NativeAlertData)->UIAlertController {
        alert?.dismiss(animated: true)

        alert = UIAlertController.createAlert(
            title: data.title,
            message: data.message,
            primaryButtonText: data.primaryButtonText,
            primaryButtonTextColor: data.primaryButtonTextColor,
            primaryButtonStyle: data.primaryButtonStyle,
            primaryButtonHandler: data.primaryButtonHandler,
            secondaryButtonText: data.secondaryButtonText,
            secondaryButtonTextColor: data.secondaryButtonTextColor,
            secondaryButtonStyle: data.secondaryButtonStyle,
            secondaryButtonHandler: data.secondaryButtonHandler,
            onDismiss: onDismiss
        )

        return alert!
    }

    func show(data: NativeAlertData) {
        DispatchQueue.main.async {
            if self.alert == nil || self.alert?.isBeingPresented == false {
                let alert = self.createAlert(data)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func hide() {
        DispatchQueue.main.async {
            self.alert?.dismiss(animated: true) {
                self.onDismiss()
            }
        }
    }

    override func viewWillDisappear(_: Bool) {
        hide()
    }
}

private struct NativeAlertModern: UIViewControllerRepresentable {
    @Binding private var data: NativeAlertData?

    init(data: Binding<NativeAlertData?>) {
        self._data = data
    }

    func makeUIViewController(context _: Context)->NativeAlertModernController<NativeAlertData> {
        return NativeAlertModernController(
            onDismiss: onDismiss
        )
    }

    func updateUIViewController(_ uiViewController: NativeAlertModernController<NativeAlertData>, context _: Context) {
        if uiViewController.item?.id == data?.id { return }

        uiViewController.item = data

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

// MARK: - Callback Approach

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

    func makeUIViewController(context _: Context)->NativeAlertModernController<Item> {
        return NativeAlertModernController<Item>(
            onDismiss: onDismiss
        )
    }

    func updateUIViewController(_ uiViewController: NativeAlertModernController<Item>, context _: Context) {
        if uiViewController.item?.id == item?.id { return }

        uiViewController.item = item

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
        primaryButtonTextColor: Color? = nil,
        primaryButtonStyle: UIAlertAction.Style = .default,
        primaryButtonHandler: @escaping ()->Void = {},
        secondaryButtonText: String? = nil,
        secondaryButtonTextColor: Color? = nil,
        secondaryButtonStyle: UIAlertAction.Style = .default,
        secondaryButtonHandler: @escaping ()->Void = {}
    )->some View {
        return AnyView(background(NativeAlert(
            isPresented: isPresented,
            title: title,
            message: message,
            primaryButtonText: primaryButtonText,
            primaryButtonTextColor: primaryButtonTextColor,
            primaryButtonStyle: primaryButtonStyle,
            primaryButtonHandler: primaryButtonHandler,
            secondaryButtonText: secondaryButtonText,
            secondaryButtonTextColor: secondaryButtonTextColor,
            secondaryButtonStyle: secondaryButtonStyle,
            secondaryButtonHandler: secondaryButtonHandler
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

struct NativeAlertData: Identifiable {
    let id = UUID()

    let title: String?
    let message: String?
    let primaryButtonText: String
    let primaryButtonTextColor: Color?
    let primaryButtonStyle: UIAlertAction.Style
    let primaryButtonHandler: ()->Void
    let secondaryButtonText: String?
    let secondaryButtonTextColor: Color?
    let secondaryButtonStyle: UIAlertAction.Style
    let secondaryButtonHandler: ()->Void

    init(
        title: String? = nil,
        message: String? = nil,
        primaryButtonText: String,
        primaryButtonTextColor: Color? = nil,
        primaryButtonStyle: UIAlertAction.Style = .default,
        primaryButtonHandler: @escaping ()->Void = {},
        secondaryButtonText: String? = nil,
        secondaryButtonTextColor: Color? = nil,
        secondaryButtonStyle: UIAlertAction.Style = .default,
        secondaryButtonHandler: @escaping ()->Void = {}
    ) {
        self.title = title
        self.message = message
        self.primaryButtonText = primaryButtonText
        self.primaryButtonTextColor = primaryButtonTextColor
        self.primaryButtonStyle = primaryButtonStyle
        self.primaryButtonHandler = primaryButtonHandler
        self.secondaryButtonText = secondaryButtonText
        self.secondaryButtonTextColor = secondaryButtonTextColor
        self.secondaryButtonStyle = secondaryButtonStyle
        self.secondaryButtonHandler = secondaryButtonHandler
    }
}
