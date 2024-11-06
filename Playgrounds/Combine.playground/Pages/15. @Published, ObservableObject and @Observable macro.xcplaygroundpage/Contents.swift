//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport
import SwiftUI
import UIKit

/*:
 # `@Published` properties

 A [Property Wrapper](https://www.avanderlee.com/swift/property-wrappers/) that adds a `Publisher` to any property.

 _Note: Xcode Playgrounds don't support running this Playground page with the @Published property unfortunately._
 */

final class FormViewModel {
    @Published var isSubmitAllowed: Bool = true
}

final class FormViewController: UIViewController {
    var viewModel = FormViewModel()
    let submitButton = UIButton()

    var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        // subscribe to a @Published property using the $ wrapped accessor
        cancellable = viewModel.$isSubmitAllowed
            .print()
            .assign(to: \.isEnabled, on: submitButton)
    }
}

print("* Demonstrating @Published")

let formViewController = FormViewController(nibName: nil, bundle: nil)
PlaygroundPage.current.setLiveView(formViewController)

print("Button enabled is \(formViewController.submitButton.isEnabled)")
formViewController.viewModel.isSubmitAllowed = false
print("Button enabled is \(formViewController.submitButton.isEnabled)")

/*:
 ## `ObservableObject`

 - a class inheriting from `ObservableObject` automagically synthesizes an observable
 - ... which fires whenever any of the `@Published` properties of the class change
 */

print("\n* Demonstrating ObservableObject")

class ObservableObjectViewModel: ObservableObject {
    @Published var isSubmitAllowed: Bool = true
    @Published var username: String = ""
    @Published var password: String = ""
    var somethingElse: Int = 10

//    init(isSubmitAllowed: Bool, username: String, password: String, somethingElse: Int) {
//        self.isSubmitAllowed = isSubmitAllowed
//        self.username = username
//        self.password = password
//        self.somethingElse = somethingElse
//
//        objectWillChange.sink { _ in
//            print("Value changed: \(isSubmitAllowed) \"\(username)\" \"\(password)\"")
//        }
//    }
}

// var form = ObservableObjectViewModel()
//
// let formSubscription = form.objectWillChange.sink { _ in
//    print("Form changed: \(form.isSubmitAllowed) \"\(form.username)\" \"\(form.password)\"")
// }
//
// form.isSubmitAllowed = false
// form.username = "ImaginativeShohag"
// form.password = "AwesomePassword"
// form.somethingElse = 0 // note that this doesn't output anything

struct ObservableObjectContentView: View {
    @StateObject var viewModel = ObservableObjectViewModel()
    @State var cancellable: AnyCancellable? = nil

    var body: some View {
        VStack {
            Text("`ObservableObject` example")

            KeyValueSectionView(key: "Username", value: viewModel.username)

            KeyValueSectionView(key: "Password", value: viewModel.password)

            ButtonSectionView(label: "Change username") {
                viewModel.username = "ImaginativeShohag \(Int.random(in: 1...10))"
            }

            ButtonSectionView(label: "Change password") {
                viewModel.password = "AwesomePassword \(Int.random(in: 1...10))"
            }

            ButtonSectionView(label: "Change isSubmitAllowed") {
                viewModel.isSubmitAllowed.toggle()
            }

            ButtonSectionView(label: "Change somethingElse") {
                viewModel.somethingElse = 0
            }

            ButtonSectionView(label: "Submit") {
                // no-op
            }
            .disabled(!viewModel.isSubmitAllowed)
        }
        .frame(width: 300, height: 500)
        .onAppear {
            // `objectWillChange` is a publisher, that emits before the object (here viewModel) has changed.
            cancellable = viewModel.objectWillChange.sink { _ in
                print("Value changed: \(viewModel.isSubmitAllowed) \"\(viewModel.username)\" \"\(viewModel.password)\"")
            }
        }
    }
}

let contentView1 = ObservableObjectContentView()
PlaygroundPage.current.setLiveView(contentView1)

//: ## `@Observable` macro

print("\n* Demonstrating @Observable")

@Observable
class ObservableMacroViewModel {
    var isSubmitAllowed: Bool = false
    var username: String = ""
    var password: String = ""
    @ObservationIgnored var somethingElse: Int = 10
}

// 🔴 does it deep observe
// 🔴 did the array use diff

struct ObservableMacroContentView: View {
    @State var viewModel = ObservableMacroViewModel()

    var body: some View {
        VStack {
            Text("`@Observable` macro example")

            KeyValueSectionView(key: "Username", value: viewModel.username)

            KeyValueSectionView(key: "Password", value: viewModel.password)

            ButtonSectionView(label: "Change username") {
                viewModel.username = "ImaginativeShohag \(Int.random(in: 1...10))"
            }

            ButtonSectionView(label: "Change password") {
                viewModel.password = "AwesomePassword \(Int.random(in: 1...10))"
            }

            ButtonSectionView(label: "Change isSubmitAllowed") {
                viewModel.isSubmitAllowed.toggle()
            }

            ButtonSectionView(label: "Change somethingElse") {
                viewModel.somethingElse = 0
            }

            ButtonSectionView(label: "Submit") {
                // no-op
            }
            .disabled(!viewModel.isSubmitAllowed)
        }
        .frame(width: 300, height: 500)
    }
}

let contentView2 = ObservableMacroContentView()
PlaygroundPage.current.setLiveView(contentView2)

/*:
 # Further reading

 - [Observation proposal](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0395-observability.md)
 - [Migrating from the Observable Object protocol to the Observable macro](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
 */

//: [Next](@next)
