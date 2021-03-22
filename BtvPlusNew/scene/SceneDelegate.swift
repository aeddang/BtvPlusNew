//
//  SceneDelegate.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/01.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import UIKit
import SwiftUI
//import Firebase

class SceneDelegate: PageSceneDelegate {
    var repository:Repository? = nil
    override func onInitController(controller: PageContentController) {
        controller.pageControllerObservable.overlayView = AppLayout()
    }
    override func onInitPage() {
        
    }
    override func getPageModel() -> PageModel { return PageSceneModel()}
    override func adjustEnvironmentObjects<T>(_ view: T) -> AnyView where T : View
    {
        
        let sceneObserver = AppSceneObserver()
        let dataProvider = DataProvider()
        let pairing = Pairing()
        let networkObserver = NetworkObserver()
        
        let setup = Setup()
        self.pagePresenter.bodyColor = Color.brand.bg
        let res = Repository(
            dataProvider:dataProvider,
            pairing:pairing,
            networkObserver:networkObserver,
            pagePresenter: self.pagePresenter,
            sceneObserver:sceneObserver,
            setup:setup
        )
        self.repository = res
        
        let keyboardObserver = KeyboardObserver()
        let locationObserver = LocationObserver()
       
        let environmentView = view
            .environmentObject(AppDelegate.appObserver)
            .environmentObject(res)
            .environmentObject(dataProvider)
            .environmentObject(pairing)
            .environmentObject(networkObserver)
            .environmentObject(sceneObserver)
            .environmentObject(keyboardObserver)
            .environmentObject(locationObserver)
            .environmentObject(setup)
            
        return AnyView(environmentView)
    }
    
    override func willChangeAblePage(_ page:PageObject?)->Bool{
        //guard let page = page else { return false }
        //guard let repo = self.repository else { return false }
        //Analytic.viewPage(id: page.pageID, value: page.isPopup.description)
        if page?.pageID == PageID.synopsis {
            requestDeviceOrientation(.portrait)
        }
        return true
    }
    
    override func getPageContentProtocol(_ page: PageObject) -> PageViewProtocol {
        return PageFactory.getPage(page)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        PageLog.d("Deeplink openURLContexts", tag: self.tag)
        //guard let url = URLContexts.first?.url else { return }
        
        //[DL]
        //AppDelegate.appObserver.handleDynamicLink(url)
                        
    }
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        PageLog.d("Deeplink willConnectTo", tag: self.tag)
        //AppDelegate.appObserver.handleDynamicLink(connectionOptions.urlContexts.first?.url)
        //AppDelegate.appObserver.handleUniversalLink(connectionOptions.userActivities.first?.webpageURL)
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    /*
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        PageLog.d("Deeplink continue userActivity", tag: self.tag)
        AppDelegate.appObserver.handleUniversalLink(userActivity.webpageURL)
    }
    */
    
    func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        PageLog.d("Deeplink didUpdate userActivity", tag: self.tag)
        //AppDelegate.appObserver.handleUniversalLink(userActivity.webpageURL)
    }
    
    override func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
}
