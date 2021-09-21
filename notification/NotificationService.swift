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
            // Modify the notification content here...
             if isPushOn() {
                let num = NotificationCoreData().getAllNotices().filter{!$0.isRead}.count
                content.badge = NSNumber(value: num )
            } else {
                content.badge = NSNumber(value: 0)
                content.sound = nil
            }
            NotificationCoreData().addNotice(content.userInfo)
            //content.badge = NSNumber(value: 10 )
            //contentHandler(content)
            
            contentHandler(content)
        }
        /*
                    content.subtitle = "iam modify"
                    
                    if isPushOn() {
                        let num = NotificationCoreData().getAllNotices().filter{!$0.isRead}.count
                        content.badge = NSNumber(value: num )
                    } else {
                        content.badge = NSNumber(value: 0)
                        content.sound = nil
                    }
                    NotificationCoreData().addNotice(content.userInfo)
                    content.badge = NSNumber(value: 10 )
                    contentHandler(content)
        
        */
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    
    func isPushOn() -> Bool {
        return LocalStorage().isPush
    }

}
