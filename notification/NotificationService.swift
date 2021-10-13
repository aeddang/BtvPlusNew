//
//  NotificationService.swift
//  notification
//
//  Created by JeongCheol Kim on 2021/09/17.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let content = bestAttemptContent {
            var isInform = false
            if let userData = content.userInfo["user_data"] as? [String: Any] {
                if let value = userData ["msgType"] as? String {
                    isInform =  value == "inform"
                }
            }
            //content.title = "modify " + isPushOn().description
            //content.subtitle = "modify " + NotificationCoreData().getAllNotices().filter{!$0.isRead}.count.description
            //content.badge = NSNumber(value: 10 )
            if isPushOn() || isInform {
                let num = NotificationCoreData().getAllNotices().filter{!$0.isRead}.count
                content.badge = NSNumber(value: (num + 1))
                NotificationCoreData().addNotice(content.userInfo)
            } else {
                content.badge = NSNumber(value: 0)
                //content.sound = nil
            }
            contentHandler(content)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    
    func isPushOn() -> Bool {
        return GroupStorage().isPush
    }

}
