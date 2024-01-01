//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import NotificationCenter

public extension UNUserNotificationCenter {
    func sendDummyNotification() {
        sendNotification(
            identifier: "dummy-notification",
            title: "Dummy title",
            subtitle: "Dummy subtitle",
            body: "Dummy body",
            extraContent: { content in
                content.userInfo["image"] = "https://picsum.photos/300/300"
            }
        )
    }

    func sendNotification(identifier: String, title: String, subtitle: String?, body: String?, badge: Int = 0, extraContent: (UNMutableNotificationContent) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle ?? ""
        content.body = body ?? ""
        content.badge = NSNumber(value: badge)

        extraContent(content)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

        add(request) { error in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}
