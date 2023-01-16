//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - General Approach

private class NativeAlertController: UIViewController {
    var isPresented: Bool = false

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
        primaryButtonHandler: @escaping ()->Void,
        secondaryButtonText: String?,
        secondaryButtonTextColor: Color,
        secondaryButtonHandler: @escaping ()->Void,
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
            primaryButtonHandler()
        })
        primaryAction.setValue(UIColor(primaryButtonTextColor), forKey: "titleTextColor")
        alert.addAction(primaryAction)

        if let secondaryButtonText = secondaryButtonText {
            let secondaryAction = UIAlertAction(title: secondaryButtonText, style: .default, handler: { _ in
                onDismiss()
                secondaryButtonHandler()
            })
            secondaryAction.setValue(UIColor(secondaryButtonTextColor), forKey: "titleTextColor")
            alert.addAction(secondaryAction)
        }

        super.init(nibName: nil, bundle: nil)
    }

    func show() {
        if !alert.isBeingPresented, !alert.isBeingDismissed {
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
    private let primaryButtonHandler: ()->Void
    private let secondaryButtonText: String?
    private let secondaryButtonTextColor: Color
    private let secondaryButtonHandler: ()->Void

    init(
        isPresented: Binding<Bool>,
        title: String?,
        message: String?,
        primaryButtonText: String,
        primaryButtonTextColor: Color,
        primaryButtonHandler: @escaping ()->Void,
        secondaryButtonText: String?,
        secondaryButtonTextColor: Color,
        secondaryButtonHandler: @escaping ()->Void
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.primaryButtonText = primaryButtonText
        self.primaryButtonTextColor = primaryButtonTextColor
        self.primaryButtonHandler = primaryButtonHandler
        self.secondaryButtonText = secondaryButtonText
        self.secondaryButtonTextColor = secondaryButtonTextColor
        self.secondaryButtonHandler = secondaryButtonHandler
    }

    func makeUIViewController(context _: Context)->NativeAlertController {
        return NativeAlertController(
            isPresented: isPresented,
            title: title,
            message: message,
            primaryButtonText: primaryButtonText,
            primaryButtonTextColor: primaryButtonTextColor,
            primaryButtonHandler: primaryButtonHandler,
            secondaryButtonText: secondaryButtonText,
            secondaryButtonTextColor: secondaryButtonTextColor,
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

private class NativeAlertModernController: UIViewController {
    private var onDismiss: ()->Void

    var data: NativeAlertData?

    private var alert: UIAlertController?

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("") }

    init(
        data _: NativeAlertData?,
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
            data.primaryButtonHandler()
        })
        primaryAction.setValue(UIColor(data.primaryButtonTextColor), forKey: "titleTextColor")
        alert.addAction(primaryAction)

        if let secondaryButtonText = data.secondaryButtonText {
            let secondaryAction = UIAlertAction(title: secondaryButtonText, style: .default, handler: { _ in
                self.onDismiss()
                data.secondaryButtonHandler()
            })
            secondaryAction.setValue(UIColor(data.secondaryButtonTextColor), forKey: "titleTextColor")
            alert.addAction(secondaryAction)
        }

        return alert
    }

    func show(data: NativeAlertData) {
        if alert == nil || alert?.isBeingPresented == false {
            if let alert = initAlert(data) {
                rootController().present(alert, animated: true, completion: nil)
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

    private func rootController()->UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
}

private struct NativeAlertModern: UIViewControllerRepresentable {
    @Binding private var data: NativeAlertData?

    init(
        data: Binding<NativeAlertData?>
    ) {
        self._data = data
    }

    func makeUIViewController(context _: Context)->NativeAlertModernController {
        return NativeAlertModernController(
            data: data,
            onDismiss: onDismiss
        )
    }

    func updateUIViewController(_ uiViewController: NativeAlertModernController, context _: Context) {
        if uiViewController.data?.id == data?.id { return }
        uiViewController.data = data

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

private class NativeAlertCallbackController<Item: Identifiable>: UIViewController {
    private var onDismiss: ()->Void

    var item: Item?

    private var alert: UIAlertController?

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("") }

    init(
        item: Item?,
        onDismiss: @escaping ()->Void
    ) {
        self.item = item
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
            data.primaryButtonHandler()
        })
        primaryAction.setValue(UIColor(data.primaryButtonTextColor), forKey: "titleTextColor")
        alert.addAction(primaryAction)

        if let secondaryButtonText = data.secondaryButtonText {
            let secondaryAction = UIAlertAction(title: secondaryButtonText, style: .default, handler: { _ in
                self.onDismiss()
                data.secondaryButtonHandler()
            })
            secondaryAction.setValue(UIColor(data.secondaryButtonTextColor), forKey: "titleTextColor")
            alert.addAction(secondaryAction)
        }

        return alert
    }

    func show(data: NativeAlertData) {
        if alert == nil || alert?.isBeingPresented == false {
            if let alert = initAlert(data) {
                rootController().present(alert, animated: true, completion: nil)
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

    private func rootController()->UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
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

    func makeUIViewController(context _: Context)->NativeAlertCallbackController<Item> {
        return NativeAlertCallbackController<Item>(
            item: item,
            onDismiss: onDismiss
        )
    }

    func updateUIViewController(_ uiViewController: NativeAlertCallbackController<Item>, context _: Context) {
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
        primaryButtonTextColor: Color = Color.accentColor,
        primaryButtonHandler: @escaping ()->Void = {},
        secondaryButtonText: String? = nil,
        secondaryButtonTextColor: Color = Color.accentColor,
        secondaryButtonHandler: @escaping ()->Void = {}
    )->some View {
        return AnyView(background(NativeAlert(
            isPresented: isPresented,
            title: title,
            message: message,
            primaryButtonText: primaryButtonText,
            primaryButtonTextColor: primaryButtonTextColor,
            primaryButtonHandler: primaryButtonHandler,
            secondaryButtonText: secondaryButtonText,
            secondaryButtonTextColor: secondaryButtonTextColor,
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
    let primaryButtonTextColor: Color
    let primaryButtonHandler: ()->Void
    let secondaryButtonText: String?
    let secondaryButtonTextColor: Color
    let secondaryButtonHandler: ()->Void

    init(
        title: String? = nil,
        message: String? = nil,
        primaryButtonText: String,
        primaryButtonTextColor: Color = Color.accentColor,
        primaryButtonHandler: @escaping ()->Void = {},
        secondaryButtonText: String? = nil,
        secondaryButtonTextColor: Color = Color.accentColor,
        secondaryButtonHandler: @escaping ()->Void = {}
    ) {
        self.title = title
        self.message = message
        self.primaryButtonText = primaryButtonText
        self.primaryButtonTextColor = primaryButtonTextColor
        self.primaryButtonHandler = primaryButtonHandler
        self.secondaryButtonText = secondaryButtonText
        self.secondaryButtonTextColor = secondaryButtonTextColor
        self.secondaryButtonHandler = secondaryButtonHandler
    }
}
