//
//  AppDelegate.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/01.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class AppObserver: ObservableObject, PageProtocol {
    @Published fileprivate(set) var page:IwillGo? = nil
    @Published fileprivate(set) var apnsToken:String? = nil
    @Published fileprivate(set) var pushToken:String? = nil
    @Published private(set) var alram:AlramData? = nil
    func resetToken(){
        pushToken = nil
    }
    
    private(set) var apns:[AnyHashable: Any]? = nil
    func reset(){
        page = nil
    }
    func resetApns(){
        alram = nil
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
            self.apns = userInfo
            self.alram = NotificationCoreData().addNotice(userInfo)
        }
        
        if let pageJson = userInfo[pageKey] as? [String: Any] {
            PageLog.d("pageJson : \(pageJson)" , tag: self.tag)
            self.page = WhereverYouCanGo.parseIwillGo(json: pageJson)
        }
    }
    
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
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PageProtocol {
    static var orientationLock = UIInterfaceOrientationMask.all
    static let appObserver = AppObserver()
    static private(set) var appURLSession:URLSession? = nil
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        DynamicLinks.performDiagnostics(completion: nil)
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
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        Self.appURLSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: queue)
        let launchedURL = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL
        return AppDelegate.appObserver.handleDynamicLink(launchedURL)
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
        return AppDelegate.appObserver.handleUniversalLink(userActivity.webpageURL)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        PageLog.d("Deeplink start", tag: self.tag)
        return AppDelegate.appObserver.handleDynamicLink(url)
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
        PageLog.d("APNs token retrieved: \(deviceToken.base64EncodedString())", tag: self.tag)
        AppDelegate.appObserver.apnsToken = deviceToken.base64EncodedString()
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
          if let error = error {
            PageLog.e("Error fetching FCM registration token: \(error)", tag: self.tag)
          } else if let token = token {
            PageLog.d("Firebase registration token: \(token)", tag: self.tag)
            AppDelegate.appObserver.pushToken = token
          }
        }
    }
}

extension AppDelegate : URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, urlCredential)
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
