//: [Previous](@previous)

import Combine
import Foundation
import Observation
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

//: ----------------------------------------------------------------

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
    @Published var roles: [String] = []
    var somethingElse: Int = 10
}

struct ObservableObjectContentView: View {
    @StateObject var viewModel = ObservableObjectViewModel()
    @State var cancellable: AnyCancellable? = nil

    var body: some View {
        VStack {
            Text("`ObservableObject` example")

            KeyValueSectionView(key: "Username", value: viewModel.username)

            KeyValueSectionView(key: "Password", value: viewModel.password)
            
            KeyValueSectionView(key: "Roles", value: viewModel.roles.joined(separator: ", "))

            ButtonSectionView(label: "Change username") {
                viewModel.username = "ImaginativeShohag \(Int.random(in: 1...10))"
            }

            ButtonSectionView(label: "Change password") {
                viewModel.password = "AwesomePassword \(Int.random(in: 1...10))"
            }
            
            ButtonSectionView(label: "Add role") {
                viewModel.roles.append("Role \(Int.random(in: 1...10))")
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
        .frame(width: 300, height: 700)
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

//: ----------------------------------------------------------------

/*:
 ## `@Observable` macro
 
 This is not a part of `Combine` framework, but a part of `Observation` framework.
 `Observation` framework is a Swift-specific implementation of the observer design pattern.
 
 ### Benefits:
 
 - Tracking optionals and collections of objects, which isn’t possible when using `ObservableObject`.
 - Using existing data flow primitives like `State` and `Environment` instead of object-based equivalents such as `StateObject` and `EnvironmentObject`.
 - Updating views based on changes to the observable properties that a view’s body reads instead of any property changes that occur to an observable object, which can help improve your app’s performance 🔥.
 */

print("\n* Demonstrating @Observable")

struct User {
    var username: String = ""
    var password: String = ""
    var roles: [String] = []
}

@Observable
class ObservableMacroViewModel {
    var isSubmitAllowed: Bool = false
    var user: User = .init()
    @ObservationIgnored var somethingElse: Int = 10
}

struct ObservableMacroContentView: View {
    @State var viewModel = ObservableMacroViewModel()

    var body: some View {
        VStack {
            Text("`@Observable` macro example")

            KeyValueSectionView(key: "Username", value: viewModel.user.username)

            KeyValueSectionView(key: "Password", value: viewModel.user.password)

            KeyValueSectionView(key: "Roles", value: viewModel.user.roles.joined(separator: ", "))

            ButtonSectionView(label: "Change username") {
                viewModel.user.username = "ImaginativeShohag \(Int.random(in: 1...10))"
            }

            ButtonSectionView(label: "Change password") {
                viewModel.user.password = "AwesomePassword \(Int.random(in: 1...10))"
            }

            ButtonSectionView(label: "Add role") {
                viewModel.user.roles.append("Role \(Int.random(in: 1...10))")
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
        .frame(width: 300, height: 700)
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
