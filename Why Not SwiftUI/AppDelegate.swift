//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    override init() {
        super.init()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        self.registerForPushNotifications()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Typically, this method is called only after you call the registerForRemoteNotifications() method of UIApplication, but UIKit might call it in other rare circumstances. For example, UIKit calls the method when the user launches an app after having restored a device from data that is not the device’s backup data. In this exceptional case, the app won’t know the new device’s token until the user launches it.

        let deviceToken = deviceToken.reduce("") { $0 + String(format: "%02X", $1) }
        // Call API and send the deviceToken from here.
    }

    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

//    private func getNotificationSettings() {
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//
//            guard settings.authorizationStatus == .authorized else { return }
//
//            DispatchQueue.main.async {
//                UIApplication.shared.registerForRemoteNotifications()
//            }
//        }
//    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let actionType = userInfo["action_type"] as? String, var actionData = userInfo["action_data"] as? String {
            actionData = actionData.lowercased()

            var notificationId = ""

            if let id = userInfo["id"] as? String {
                notificationId = id
            }
            switch actionType.uppercased() {
            case "URL":
                // TODO: Go to web application with the url
                NotificationCenter.default.post(name: .linkNavigation, object: "\(actionData)")

            case "SCREEN":
                switch actionData {
                case "events":
                    NotificationCenter.default.post(name: .screenNavigation, object: NotificationAction(name: .event, value: notificationId))
                case "jobs":
                    NotificationCenter.default.post(name: .screenNavigation, object: NotificationAction(name: .job, value: nil))
                case "posts":
                    NotificationCenter.default.post(name: .screenNavigation, object: NotificationAction(name: .post, value: notificationId))
                default:
                    break
                }
            default:
                break
            }
        }

        completionHandler()
    }
}

public extension Notification.Name {
    static let linkNavigation = Notification.Name(rawValue: "link_navigation")
    static let screenNavigation = Notification.Name(rawValue: "screen_navigation")
}

struct NotificationAction {
    let name: NotificationType
    let value: String?

    func getName() -> NotificationType {
        return self.name
    }

    func getValue() -> String {
        return self.value == nil ? "" : self.value!
    }
}

enum NotificationType {
    case post // = "post"
    case event // = "event"
    case job // = "job"
}
