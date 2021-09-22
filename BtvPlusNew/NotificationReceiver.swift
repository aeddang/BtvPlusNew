//
//  NotificationReceiver.swift
//  BtvPlus
//
//  Created by jtpark on 2017. 6. 2..
//  Copyright © 2017년 skb. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationReceiver{
    private static let notiReceiver = NotificationReceiver()
    static func shareInstance() -> NotificationReceiver {
        return notiReceiver
    }
    /*
    func didReceiveLocalNotification(_ application: UIApplication, notification: UILocalNotification) {
        
        if Global.sharedInstance.isAgreementInfoPush == false {
            Tool.removeNotification(notification: true)
        } else {
           
            if let userInfo = notification.userInfo as? [String: Any] {
                guard PushUtil.getPushModel(userInfo: userInfo) != nil else { return }
                if fromDidReceiveUserNotification {
                    fromDidReceiveUserNotification = false
                } else {
                    PushUtil.action(userInfo: userInfo)
                }
            }
        }
    }*/
    @discardableResult 
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any]) -> AlramData? {
        guard let info = userInfo as? [String: Any] else { return nil }
        let num = NotificationCoreData().getAllNotices().filter{!$0.isRead}.count
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = num
        }
        var title:String = ""
        var body:String = ""
        var isSave:Bool = true
        if let aps = info["aps"] as? [String: Any] {
            if let mutableContent = aps["mutable-content"] as? String {
                if mutableContent == "1" { isSave = false }
            } else if let mutableContent = aps["mutable-content"] as? Int {
                if mutableContent == 1 { isSave = false }
            }
            if let alert = aps["alert"] as? [String: Any] {
                if let value = alert["title"] as? String { title = value }
                if let value = alert["body"] as? String { body = value }
            } else {
                if let value = aps["alert"] as? String { body = value }
            }
        }
        let alram = AlramData().setData(title: title, text: body, userData: info)
        if isSave { NotificationCoreData().addNotice(info) }
        return alram
    }
    
    /*
    func isLimitTime(userInfo: [AnyHashable: Any]) -> Bool {
        guard let info = userInfo as? [String: Any] else {
            return false
        }
        if let model = PushUtil.getPushModel(userInfo: info) {
            let limit = model.lmitTime
            Tool.debugLog("limit: \(limit)")
            if !limit.isEmpty {
                let hour = limit.split(separator: "-")
                if hour.count == 2 {
                    if let start = hour.first, let end = hour.last {
                        let startH = String(start).int
                        let endH = String(end).int
                        let nowH = Tool.getTime(fromDate: Date(), format: "HH").int
                        if startH > nowH || nowH >= endH {
                            Tool.debugLog("limited: \(nowH)")
                            return true
                        }
                    }
                    
                }
            }
        }
        return false
    }*/
    
}
