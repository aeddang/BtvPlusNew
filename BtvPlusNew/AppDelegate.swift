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
import AdSupport
import AppTrackingTransparency

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

    func handleApns(_ userInfo: [AnyHashable: Any], isMove:Bool = false){
        if let aps = userInfo[apnsKey] as? [String: Any] {
            PageLog.d("aps: \(aps)" , tag: self.tag)
            self.apns = userInfo
            let alram = NotificationReceiver.shareInstance().didReceiveRemoteNotification(userInfo: userInfo)
            alram?.isMove = isMove
            self.alram = alram
        }
        
        if let pageJson = userInfo[pageKey] as? [String: Any] {
            PageLog.d("pageJson : \(pageJson)" , tag: self.tag)
            self.page = WhereverYouCanGo.parseIwillGo(json: pageJson)
        }
    }
    
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
        PageLog.d("handleDynamicLink " + url.absoluteString)
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
                
                //iOS15 에서 푸시 팝업으로 인해 IDFA팝업이 미노출되는 현상땜에 푸시 팝업 닫은 후 뜨도록 변경
                self.initATT()
            }
        }
        
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        Self.appURLSession = URLSession(
            configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: queue)
        let launchedURL = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL
        
        //let launchedURL =  URL(string: "btvplus://menu?menus=BP_03_01/NM2000000262/NM2000000270/NM2000000272/NM2000003461")
        //let launchedURL =  URL(string: "http://m.btvplus.co.kr?menus=BP_03_01/NM2000000262/NM2000000270/NM2000000272/NM2000003461")
        
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
       
            AppDelegate.appObserver.handleApns(notification.request.content.userInfo, isMove: false)
            DispatchQueue.main.async {
                if let badgeNo = notification.request.content.badge as? Int {
                    UIApplication.shared.applicationIconBadgeNumber = badgeNo
                }
            }
            completionHandler([.badge, .sound])
           
    }
    
   
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
            AppDelegate.appObserver.handleApns(userInfo, isMove: true)
        }
        completionHandler()
    }
    
    
    func initATT(){
        
        // 사용자에게 Apple IDFA 수집 동의 대화상자 (AppTrackingTransparency)를 보입니다.
        // SDK가 IDFA를 수집하지 않도록 star() 전 호출되어야 합니다.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                if status == .authorized {
                    print("IDFA 승인")
                }
                
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

