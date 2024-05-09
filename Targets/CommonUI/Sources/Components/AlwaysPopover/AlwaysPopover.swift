//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

// MARK: - Extension

public extension View {
    func alwaysPopover<Content>(
        isPresented: Binding<Bool>,
        permittedArrowDirections: UIPopoverArrowDirection = [.up],
        onDismiss: (() -> Void)? = nil,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        self.modifier(AlwaysPopoverViewModifier(
            isPresented: isPresented,
            permittedArrowDirections: permittedArrowDirections,
            onDismiss: onDismiss,
            content: content
        ))
    }
}

// MARK: - Modifier

struct AlwaysPopoverViewModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    @Binding var isPresented: Bool
    let permittedArrowDirections: UIPopoverArrowDirection
    let onDismiss: (() -> Void)?
    let content: () -> PopoverContent

    init(
        isPresented: Binding<Bool>,
        permittedArrowDirections: UIPopoverArrowDirection,
        onDismiss: (() -> Void)? = nil,
        content: @escaping () -> PopoverContent
    ) {
        self._isPresented = isPresented
        self.permittedArrowDirections = permittedArrowDirections
        self.onDismiss = onDismiss
        self.content = content
    }

    func body(content: Content) -> some View {
        content
            .background(
                AlwaysPopover(
                    isPresented: self.$isPresented,
                    permittedArrowDirections: self.permittedArrowDirections,
                    onDismiss: self.onDismiss,
                    content: self.content
                )
            )
    }
}

// MARK: - UIViewController

struct AlwaysPopover<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let permittedArrowDirections: UIPopoverArrowDirection
    let onDismiss: (() -> Void)?
    @ViewBuilder let content: () -> Content

    init(
        isPresented: Binding<Bool>,
        permittedArrowDirections: UIPopoverArrowDirection,
        onDismiss: (() -> Void)?,
        content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.permittedArrowDirections = permittedArrowDirections
        self.onDismiss = onDismiss
        self.content = content
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, content: self.content())
    }

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.host.rootView = self.content()

        guard context.coordinator.lastIsPresentedValue != self.isPresented else { return }

        context.coordinator.lastIsPresentedValue = self.isPresented

        if self.isPresented {
            let host = context.coordinator.host

            if context.coordinator.viewSize == .zero {
                context.coordinator.viewSize = host.sizeThatFits(in: UIView.layoutFittingExpandedSize)
            }

            host.preferredContentSize = context.coordinator.viewSize
            host.modalPresentationStyle = .popover

            host.popoverPresentationController?.delegate = context.coordinator
            host.popoverPresentationController?.sourceView = uiViewController.view
            host.popoverPresentationController?.sourceRect = uiViewController.view.bounds
            host.popoverPresentationController?.permittedArrowDirections = self.permittedArrowDirections

            if let presentedVC = uiViewController.presentedViewController {
                presentedVC.dismiss(animated: true) {
                    uiViewController.present(host, animated: true, completion: nil)
                }
            } else {
                uiViewController.present(host, animated: true, completion: nil)
            }
        }
    }

    class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
        let host: UIHostingController<Content>
        private let parent: AlwaysPopover

        var lastIsPresentedValue: Bool = false

        /// Content view size.
        var viewSize: CGSize = .zero

        init(parent: AlwaysPopover, content: Content) {
            self.parent = parent
            self.host = AlwaysPopoverUIHostingController(
                rootView: content,
                isPresented: self.parent.$isPresented,
                onDismiss: self.parent.onDismiss
            )
        }

        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            self.parent.isPresented = false

            if let onDismiss = self.parent.onDismiss {
                onDismiss()
            }
        }

        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none
        }
    }
}

// MARK: - UIHostingController

class AlwaysPopoverUIHostingController<Content: View>: UIHostingController<Content> {
    @Binding private var isPresented: Bool
    private let onDismiss: (() -> Void)?

    init(rootView: Content, isPresented: Binding<Bool>, onDismiss: (() -> Void)?) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        super.init(rootView: rootView)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.isPresented = false

        if let onDismiss = self.onDismiss {
            onDismiss()
        }
    }
}
