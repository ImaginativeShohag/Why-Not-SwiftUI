//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport
import UIKit

// This is necessary for the Playgrounds app. This enables indefinite execution, which is necessary for this page.
PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 # Foundation and Combine

 Foundation adds Combine publishers for many types, like:
 */

/*:
 ## A URLSessionTask publisher and a JSON Decoding operator
 */

let requestCancellable = URLSession.shared.dataTaskPublisher(for: URL(string: "https://httpbin.org/get")!)
    .map { $0.data }
    .decode(type: HttpBinGetResponse.self, decoder: JSONDecoder())
    .sink(
        receiveCompletion: { print("Received completion: \($0).") },
        receiveValue: { print("Received data: \($0)") }
    )

/*:
 ## A Publisher for notifications
 */
let notificationCenter = NotificationCenter.default

notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification)
    .sink { _ in
        print("App became active.")
    }

notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)

/*:
 ## KeyPath binding to NSObject instances
 */

let ageLabel = UILabel()
Just(28)
    .map { "Age is \($0)" }
    .assign(to: \.text, on: ageLabel)

print("Age label text: \(ageLabel.text!)")

/*:
 ## A Timer publisher exposing Cocoa's `Timer`

 - this one is a bit special as it is a `Connectable`
 - ... use `autoconnect` to automatically start it when a subscriber subscribes
 */

let publisher = Timer
    .publish(every: 1.0, on: .main, in: .common)
    .autoconnect()

var cancellable: AnyCancellable?

// Subscribe to the Timer publisher
cancellable = publisher.sink { currentTime in
    print("Timer fired at: \(currentTime)")
}

//: [Next](@next)
