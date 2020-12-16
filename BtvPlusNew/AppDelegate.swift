//
//  AppDelegate.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/01.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import UIKit
import CoreData
//import Firebase


class AppObserver: ObservableObject, PageProtocol {
    @Published fileprivate(set) var page:IwillGo? = nil
    @Published fileprivate(set) var pushToken:String? = nil
    func resetToken(){
        pushToken = nil
    }
    
    private(set) var apns:[String: Any]? = nil
    func reset(){
        page = nil
        apns = nil
    }
    
    let gcmMessageIDKey = "gcm.message_id"
    let pageKey = "page"
    let apnsKey = "aps"
    
    
    
    func handleApns(_ userInfo: [AnyHashable: Any]){
        if let messageID = userInfo[gcmMessageIDKey] {
             PageLog.d("Message ID: \(messageID)", tag: self.tag)
        }
        if let aps = userInfo[apnsKey] as? [String: Any] {
            PageLog.d("aps: \(aps)" , tag: self.tag)
            self.apns = aps
        }
        if let pageJson = userInfo[pageKey] as? [String: Any] {
            PageLog.d("pageJson : \(pageJson)" , tag: self.tag)
            self.page = WhereverYouCanGo.parseIwillGo(json: pageJson)
        }
    }
    /*
    @discardableResult
    func handleUniversalLink(_ deepLink: URL?)-> Bool{
        guard let url =  deepLink else { return false }
        return DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamiclink, error) in
            if let query = dynamiclink?.url?.query{
                PageLog.d("Deeplink dynamiclink : \(query)", tag: self.tag)
                self.page = WhereverYouCanGo.parseIwillGo(qurryString: query)
            }else{
                PageLog.d("Deeplink dynamiclink : no query", tag: self.tag)
            }
        }
    }
    
    @discardableResult
    func handleDynamicLink(_ deepLink: URL?)-> Bool{
        guard let url =  deepLink else { return false }
        if let dynamiclink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            if let query = dynamiclink.url?.query{
                PageLog.d("Deeplink dynamiclink : \(query)", tag: self.tag)
                self.page = WhereverYouCanGo.parseIwillGo(qurryString: query)
            }else{
                PageLog.d("Deeplink dynamiclink : no query", tag: self.tag)
            }
             return true
        }else{
            return false
        }
    }
    */
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PageProtocol {
    static var orientationLock = UIInterfaceOrientationMask.all
    static let appObserver = AppObserver()

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //FirebaseApp.configure()
        //DynamicLinks.performDiagnostics(completion: nil)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    
        //let launchedURL = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL
        return true//AppDelegate.appObserver.handleDynamicLink(launchedURL)
        
        
    }
    
    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        //[DL]
        let dynamicLink = application(app, open: url,
                     sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                     annotation: "")
        return dynamicLink
        
    }
    
    // [Deeplink]
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        PageLog.d("Deeplink start", tag: self.tag)
        return false//AppDelegate.appObserver.handleUniversalLink(userActivity.webpageURL)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        PageLog.d("Deeplink start", tag: self.tag)
        return false//AppDelegate.appObserver.handleDynamicLink(url)
    }
    
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    
    
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        AppDelegate.appObserver.handleApns(userInfo)
        PageLog.d("didReceiveRemoteNotification", tag: self.tag)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppDelegate.appObserver.handleApns(userInfo)
        PageLog.d("didReceiveRemoteNotification fetchCompletionHandler", tag: self.tag)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PageLog.d("Unable to register for remote notifications: \(error.localizedDescription)", tag: self.tag)
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PageLog.d("APNs token retrieved: \(deviceToken)", tag: self.tag)
        AppDelegate.appObserver.pushToken = deviceToken.base64EncodedString()
    }

}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        AppDelegate.appObserver.handleApns(userInfo)
        PageLog.d("userNotificationCenter []", tag: self.tag)
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        AppDelegate.appObserver.handleApns(userInfo)
        PageLog.d("userNotificationCenter {}", tag: self.tag)
        completionHandler()
    }
}

/*
// [END ios_10_message_handling]
extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        PageLog.d("Firebase registration token: \(fcmToken)", tag: self.tag)
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
         PageLog.d("Received data message: \(remoteMessage.appData)", tag: self.tag)
    }
    // [END ios_10_data_message]
}

*/
