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
    override func onInitPage() {}
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
        let naviLogManager = NaviLogManager(
            pagePresenter: self.pagePresenter,
            repository: res
        )
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
            .environmentObject(naviLogManager)
        return AnyView(environmentView)
    }
    
    override func willChangeAblePage(_ page:PageObject?)->Bool{
        guard let willPage = page else { return false }
        
        if let layerPlayer = self.repository?.appSceneObserver?.currentPlayer  {
            if willPage.pageGroupID == PageType.kids.rawValue {
                self.repository?.pagePresenter?.closePopup(layerPlayer.pageObject?.id)
            } else {
            
                if willPage.pageID == .synopsis {
                    let synopData = layerPlayer.getSynopData(obj: willPage)
                    layerPlayer.changeVod(synopsisData: synopData)
                    layerPlayer.activePlayer()
                    return false
                } else {
                    layerPlayer.passivePlayer()
                }
            }
        
        }
        
        if PageType.getType(willPage.pageGroupID) == .kids && SystemEnvironment.currentPageType != .kids {
            if page?.pageID != .kidsIntro && !SystemEnvironment.isInitKidsPage {
                self.pagePresenter.changePage(
                    PageKidsProvider.getPageObject(.kidsIntro)
                        .addParam(key: .data, value: page)
                )
                return false
            }
        }
        
        if PageSceneModel.needPairing(willPage) && self.repository?.pairing.status != .pairing {
            self.repository?.appSceneObserver?.alert = .needPairing()
            return false
        }
        
        switch willPage.pageID {
        case .cashCharge:
            if self.repository?.storage.isFirstCashCharge == true {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.cashChargeGuide)
                )
                return false
            }
        default: break
        }
        
        
        if willPage.getParamValue(key: .needAdult) as? Bool == true {
            willPage.addParam(key: .watchLv, value: Setup.WatchLv.lv4.rawValue )
        }
        let watchLv = willPage.getParamValue(key: .watchLv) as? Int
        if (watchLv ?? 0) >= 19 {
            if self.repository?.pairing.status != .pairing {
                self.repository?.appSceneObserver?.alert = .needPairing()
                return false
            }
            if !SystemEnvironment.isAdultAuth {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.adultCertification)
                        .addParam(key: .data, value: page)
                )
                return false
            }
        }
        
        //시청연령제한
        if !SystemEnvironment.isAdultAuth ||
            ( !SystemEnvironment.isWatchAuth && SystemEnvironment.watchLv != 0 ),
            let watchLv = watchLv {
                if SystemEnvironment.watchLv != 0 && SystemEnvironment.watchLv <= watchLv {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.confirmNumber)
                            .addParam(key: .data, value: page)
                            .addParam(key: .type, value: ScsNetwork.ConfirmType.adult)
                    )
                    return false
                }
            }
        return true
    }
    
    override func getPageContentProtocol(_ page: PageObject) -> PageViewProtocol {
        switch PageType.getType(page.pageGroupID) {
        case .btv: return PageFactory.getPage(page)
        case .kids: return PageKidsFactory.getPage(page)
        }
        
        
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
