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
        self.pagePresenter.bodyColor = Color.brand.bg
        
        let appSceneObserver = AppSceneObserver()
        let dataProvider = DataProvider()
        let pairing = Pairing()
        let audioMirroring = AudioMirroring(pairing: pairing)
        let networkObserver = NetworkObserver()
        let setup = Setup()
        let vsManager: VSManager = VSManager(
            pairing:pairing,
            dataProvider: dataProvider,
            appSceneObserver: appSceneObserver
        )
    
        let res = Repository(
            vsManager: vsManager,
            dataProvider:dataProvider,
            pairing:pairing,
            audioMirroring:audioMirroring,
            networkObserver:networkObserver,
            pagePresenter: self.pagePresenter,
            appSceneObserver:appSceneObserver,
            setup:setup
        )
        self.repository = res
        let naviLogManager = NaviLogManager(
            pagePresenter: self.pagePresenter,
            repository: res
        )
        pairing.naviLogManager = naviLogManager
        
        let keyboardObserver = KeyboardObserver()
        let locationObserver = LocationObserver()
       
        let environmentView = view
            .environmentObject(AppDelegate.appObserver)
            .environmentObject(vsManager)
            .environmentObject(res)
            .environmentObject(dataProvider)
            .environmentObject(pairing)
            .environmentObject(audioMirroring)
            .environmentObject(networkObserver)
            .environmentObject(appSceneObserver)
            .environmentObject(keyboardObserver)
            .environmentObject(locationObserver)
            .environmentObject(setup) 
            .environmentObject(naviLogManager)
            .background(Color.brand.bg)
        return AnyView(environmentView)
    }
    
    override func willChangeAblePage(_ page:PageObject?)->Bool{
       
        guard let willPage = page else { return false }
         
        if PageType.getType(willPage.pageGroupID) == .kids
            && PageType.getType(self.repository?.pagePresenter?.currentPage?.pageGroupID) == .btv
            && !willPage.isPopup
        {
            
            self.repository?.appSceneObserver?.finalBtvPage = self.pagePresenter.currentPage
            if page?.pageID != .kidsIntro && !SystemEnvironment.isInitKidsPage {
                self.pagePresenter.changePage(
                    PageKidsProvider.getPageObject(.kidsIntro)
                        .addParam(key: .data, value: page)
                )
                return false
            }
        }
        
        if PageSceneModel.needPairing(willPage) && self.repository?.pairing.status != .pairing {
            self.repository?.appSceneObserver?.alert = .needPairing(move:willPage)
            return false
        }
        
        switch willPage.pageID {
        case .cashCharge:
            if SystemEnvironment.isTablet {
                self.repository?.appSceneObserver?.alert = .alert(nil, String.alert.cashChargeDisable)
                return false
            }
            
            if self.repository?.userSetup.isFirstCashCharge == true {
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
            let watchLv = watchLv
        {
            if SystemEnvironment.watchLv != 0 && SystemEnvironment.watchLv <= watchLv {
                if SystemEnvironment.currentPageType == .btv {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.confirmNumber)
                            .addParam(key: .data, value: page)
                            .addParam(key: .type, value: ScsNetwork.ConfirmType.adult)
                    )
                } else {
                    self.pagePresenter.openPopup(
                        PageKidsProvider.getPageObject(.kidsConfirmNumber)
                            .addParam(key: .data, value: page)
                            .addParam(key: .type, value: PageKidsConfirmType.watchLv)
                    )
                }
                return false
            }
        }
        if self.repository?.appSceneObserver?.pairingCompletedMovePage?.pageID == willPage.pageID {
            self.repository?.appSceneObserver?.pairingCompletedMovePage = nil
        }
        
        if let layerPlayer = self.repository?.appSceneObserver?.currentPlayer  {
            if willPage.pageGroupID == PageType.kids.rawValue {
                self.repository?.pagePresenter?.closePopup(layerPlayer.pageObject?.id)
            } else {
            
                if willPage.pageID == .synopsis {
                    let synopData = layerPlayer.getSynopData(obj: willPage)
                    layerPlayer.changeVod(synopsisData: synopData, isHistoryBack: true)
                    layerPlayer.activePlayer()
                    return false
                } else {
                    layerPlayer.passivePlayer()
                }
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
        //PageLog.t("Deeplink openURLContexts", tag: self.tag)
        guard let url = URLContexts.first?.url else { return }
        //PageLog.t("Deeplink openURLContexts " + url.absoluteString, tag: self.tag)
        //[DL]
        AppDelegate.appObserver.handleDynamicLink(url)
                        
    }
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let url = connectionOptions.urlContexts.first?.url
        let link = connectionOptions.userActivities.first?.webpageURL
        //PageLog.t("Deeplink willConnectTo url " + (url?.absoluteString ?? ""))
        //PageLog.t("Deeplink willConnectTo link " + (link?.absoluteString ?? ""))
        AppDelegate.appObserver.handleDynamicLink(url)
        AppDelegate.appObserver.handleUniversalLink(link)
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        PageLog.d("Deeplink continue userActivity", tag: self.tag)
        //AppDelegate.appObserver.handleUniversalLink(userActivity.webpageURL)
    }
    
    
    func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        PageLog.d("Deeplink didUpdate userActivity", tag: self.tag)
        //AppDelegate.appObserver.handleUniversalLink(userActivity.webpageURL)
    }
    
    override func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
}
