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
    @Published fileprivate(set) var deepLinkUrl:URL? = nil
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
    func resetDeeplink(){
        deepLinkUrl = nil
    }
    func resetApns(){
        alram = nil
        apns = nil
    }
    let gcmMessageIDKey = "gcm.message_id"
    let pageKey = "page"
    let apnsKey = "aps"

    func handleApns(_ userInfo: [AnyHashable: Any]){
        if let aps = userInfo[apnsKey] as? [String: Any] {
            PageLog.d("aps: \(aps)" , tag: self.tag)
            self.apns = userInfo
            self.alram = NotificationReceiver.shareInstance().didReceiveRemoteNotification(userInfo: userInfo)
        }
        
        if let pageJson = userInfo[pageKey] as? [String: Any] {
            PageLog.d("pageJson : \(pageJson)" , tag: self.tag)
            self.page = WhereverYouCanGo.parseIwillGo(json: pageJson)
        }
    }
    /*
    @discardableResult
    func addNotice(_ userInfo: [AnyHashable: Any])->AlramData?{
        var title:String = ""
        var body:String = ""
        //var needSave:Bool = true
        if let aps = userInfo["aps"] as? [String: Any] {
            if let mutableContent = aps["mutable-content"] as? String {
                if mutableContent == "1" { return nil}
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
        let alram = AlramData().setData(title: title, text: body, userData: userInfo as? [String: Any])
        NotificationCoreData().addNotice(userInfo)
        
        return alram
        
    }
    */
    @discardableResult
    func handleUniversalLink(_ deepLink: URL?)-> Bool{
        guard let url =  deepLink else { return false }
        self.deepLinkUrl = url
        
        return DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamiclink, error) in
            self.deepLinkUrl = dynamiclink?.url
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
        PageLog.t("handleDynamicLink " + url.absoluteString)
        if let dynamiclink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            if let query = dynamiclink.url?.query{
                PageLog.d("Deeplink dynamiclink : \(query)", tag: self.tag)
                self.page = WhereverYouCanGo.parseIwillGo(qurryString: query)
            }else{
                PageLog.d("Deeplink dynamiclink : no query", tag: self.tag)
            }
            return true
        }else{
            self.deepLinkUrl = url
            return false
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, PageProtocol {
    static var orientationLock = UIInterfaceOrientationMask.all
    static let appObserver = AppObserver()
    static private(set) var appURLSession:URLSession? = nil
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        DynamicLinks.performDiagnostics(completion: nil)
        
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions){ _ , error in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        Self.appURLSession = URLSession(
            configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: queue)
        let launchedURL = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL
        return AppDelegate.appObserver.handleDynamicLink(launchedURL)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //application.applicationIconBadgeNumber = 0
    }
    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        //[DL]
        PageLog.t("Deeplink start open url", tag: self.tag)
        let dynamicLink = application(app, open: url,
                     sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                     annotation: "")
        return dynamicLink
    }
    
    // [Deeplink]
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        PageLog.t("Deeplink start handleUniversalLink", tag: self.tag)
        return AppDelegate.appObserver.handleUniversalLink(userActivity.webpageURL)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        PageLog.t("Deeplink start handleDynamicLink", tag: self.tag)
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
        AppDelegate.appObserver.apnsToken = deviceToken.toHexString()
        /*FB
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                PageLog.e("Error fetching FCM registration token: \(error)", tag: self.tag)
            } else if let token = token {
                PageLog.d("Firebase registration token: \(token)", tag: self.tag)
                AppDelegate.appObserver.pushToken = token
            }
        }*/
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
                AppDelegate.appObserver.handleApns(notification.request.content.userInfo)
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
            AppDelegate.appObserver.handleApns(userInfo)
        }
        completionHandler()
    }
    
}

extension AppDelegate : URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, urlCredential)
    }
}

