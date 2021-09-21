//
//  NotificationReceiver.swift
//  BtvPlus
//
//  Created by jtpark on 2017. 6. 2..
//  Copyright © 2017년 skb. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationReceiver: NSObject, UNUserNotificationCenterDelegate {
    private static let notiReceiver = NotificationReceiver()

    private var isShownRemoteNoti = false
    private var isShownReservation = false
    //옥수수는 idReceiveUserNotification 에서 로컬노티 추가하면 반응없는데
    //얘는 추가하면 receiveLocalNoti 가 호출되서 플래그 설정.
    private var fromDidReceiveUserNotification = false
    
    class func shareInstance() -> NotificationReceiver {
        return notiReceiver
    }
    

    override init() {
        super.init()
        
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //if Global.sharedInstance.isAgreementInfoPush {
            // 수신 제한 시간인지 체크
            //if !isLimitTime(userInfo: notification.request.content.userInfo) {
                // 키즈 모드 진입 상태이면서 수신 가능한 PUSH가 아니면 처리 안함
                /*
                if isKidsModeEnabled
                    && !PushUtil.isKidsAvailablePush(userInfo: notification.request.content.userInfo) {
                    return
                }*/
                self.didReceiveRemoteNotification(userInfo: notification.request.content.userInfo)
                DispatchQueue.main.async {
                    if let badgeNo = notification.request.content.badge as? Int {
                        UIApplication.shared.applicationIconBadgeNumber = badgeNo
                    }
                }
            completionHandler([.badge, .sound])
            //}
        //}
    }
    
   
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
            NotificationCoreData().addNotice(userInfo)
        }
        completionHandler()
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
        if let aps = info["aps"] as? [String: Any] {
            if let mutableContent = aps["mutable-content"] as? String {
                if mutableContent == "1" { return nil }
            } else if let mutableContent = aps["mutable-content"] as? Int {
                if mutableContent == 1 { return nil}
            }
            if let alert = aps["alert"] as? [String: Any] {
                if let value = alert["title"] as? String { title = value }
                if let value = alert["body"] as? String { body = value }
            } else {
                if let value = aps["alert"] as? String { body = value }
            }
        }
        let alram = AlramData().setData(title: title, text: body, userData: info)
        NotificationCoreData().addNotice(info)
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
