//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Foundation
import SwiftUI
import Combine
struct AppLayout: PageComponent{
    @EnvironmentObject var vsManager:VSManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    var body: some View {
        ZStack{
            SceneTab()
                .accessibility(hidden: self.pageType != .btv)
            SceneKidsTab()
                .accessibility(hidden: self.pageType != .kids)
            if self.pageType == .btv && !self.hasPopup, let datas = self.floatBannerDatas {
                FloatingBanner(datas:datas){ today in
                    if today {self.floatingBannerToDayUnvisible()}
                    withAnimation(.easeOut(duration: 0.0)){
                        floatBannerDatas = nil
                    }
                }
            }
            if self.isInit && self.isPairingHitchShowing && self.pageType == .btv {
                PairingHitch()
            }
            if self.useLogCollector {
                SceneLogCollector()
            }
            
            Group {
                SceneRadioController()
                SceneSelectController()
                ScenePickerController()
                SceneDatePickerController()
                SceneAlertController()
            }
            if self.isLoading == true {
                Spacer().modifier(MatchParent()).background(Color.transparent.black70)
                if let loadingInfo = self.loadingInfo  {
                    SceneLoading(loadingInfo:loadingInfo)
                }
                CircularSpinner(resorce: Asset.ani.loading)
            }
            
        }
        .toast(isShowing: self.$isToastShowing , text: self.toastMsg)
        
        .onReceive(self.pagePresenter.$isLoading){ loading in
            DispatchQueue.main.async {
                withAnimation{
                    self.isLoading = loading
                }
            }
        }
        .onReceive(self.appSceneObserver.$loadingInfo){ loadingInfo in
            self.loadingInfo = loadingInfo
            withAnimation{
                self.isLoading = loadingInfo == nil ? false : true
            }
        }
        .onReceive(self.appSceneObserver.$useLogCollector){ logCollector in
            self.useLogCollector = logCollector
        }
        .onReceive(self.appSceneObserver.$event){ evt in
            guard let evt = evt else { return }
            switch evt  {
            case .initate: self.onPageInit()
            case .pairingHitchClose:
                withAnimation{
                    self.isPairingHitchShowing = false
                }
            case .toast(let msg):
                self.toastMsg = msg
                withAnimation{
                    self.isToastShowing = true
                }
            case .debug(let msg):
                #if DEBUG
                    self.toastMsg = msg
                    withAnimation{
                        self.isToastShowing = true
                    }
                #endif
                break
            case .floatingBanner(let datas): self.onFloatingBannerView(datas: datas)
            default: break
            }
        }
        .onReceive (self.appSceneObserver.$useTopFix) { use in
            guard let use = use else {return}
            self.appSceneObserver.useTop = use
        }
        .onReceive(self.pagePresenter.$currentTopPage){ page in
            guard let cPage = page else { return }
            PageLog.d("currentTopPage " + cPage.pageID.debugDescription, tag:self.tag)
            PageLog.d("current useTopFix " + (self.appSceneObserver.useTopFix?.description ?? "nil"), tag:self.tag)
            SystemEnvironment.currentPageType = PageType.getType(cPage.pageGroupID)
            withAnimation{
                self.pageType = SystemEnvironment.currentPageType
                self.hasPopup = self.pagePresenter.hasPopup
            }
            PageLog.d("currentPageType " + self.pageType.rawValue, tag:self.tag)
            switch self.pageType {
            case .btv :
                self.pagePresenter.bodyColor = Color.brand.bg
            case .kids :
                self.pagePresenter.bodyColor = Color.kids.bg
            }
            if self.appSceneObserver.useTopFix != false, let useTop = PageSceneModel.needTopTab(cPage){
                
                self.appSceneObserver.useTop = useTop
            }
            
            if !PageSceneModel.maintainBottomTab(cPage, sceneOrientation: self.sceneObserver.sceneOrientation) {
                let useBottom = PageSceneModel.needBottomTab( cPage, sceneOrientation: self.sceneObserver.sceneOrientation)
                self.appSceneObserver.useBottom = useBottom
            }
            
                
            AppUtil.hideKeyboard()
            if PageSceneModel.needKeyboard(cPage) {
                self.keyboardObserver.start()
            }else{
                self.keyboardObserver.cancel()
            }
            //self.pagePresenter.syncOrientation()
            self.syncOrientation()
        }
        .onReceive(self.pairing.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .pairingCompleted :
                if let movePage = self.appSceneObserver.pairingCompletedMovePage {
                    if movePage.isPopup {
                        self.pagePresenter.openPopup(movePage)
                    } else {
                        self.pagePresenter.changePage(movePage)
                    }
                }
            default : break
            }
        }
        .onReceive(self.repository.apiManager.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .needUpdate(let flag, let msg) :
                self.onUpdateAlram(flag: flag, msg: msg)
            default : break
            }
        }
        .onReceive (self.appObserver.$page) { iwg in
            if !self.isInit { return }
            self.appObserverMove(iwg)
        }
        .onReceive (self.appObserver.$deepLinkUrl) { url in
            if !self.isInit { return }
            self.deepLinkMove(url)
        }
        .onReceive (self.appObserver.$alram) { alram in
            guard let alram = alram else {return}
            self.repository.recivePush(alram.messageId, data:alram)
            if !self.isInit { return }
            if alram.isMove {
                self.moveAlram(alram)
            } else {
                self.repository.alram.updatedNotification()
            }
        }
        .onReceive (self.appObserver.$apnsToken) { token in
            guard let token = token else { return }
            self.repository.pushManager.initRegisterPushToken(token)
        }
        
        .onReceive(self.repository.$status){ status in
            switch status {
            case .reset: self.isInit = false
            case .ready: self.onStoreInit()
            case .error(let err): self.onPageError(err)
            default: break
            }
        }
        .onReceive(self.appSceneObserver.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .appReset :
                self.repository.reset(isReleaseMode: SystemEnvironment.isReleaseMode)
            default: break
            }
        }
        .onReceive(self.repository.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .reset :
                self.onPageRestart()
            default: break
            }
        }
        
        .onReceive(self.pageObservable.$isBackground){isBack in
            if !isBack && self.isInit{
                self.vsManager.checkAccess()
            }
        }
        .onAppear(){
            self.isLoading = true
            UIScrollView.appearance().indicatorStyle = .white
            //UIScrollView.appearance().bounces = false
            //UITableView.appearance().separatorStyle = .none
            /*
            for family in UIFont.familyNames.sorted() {
                let names = UIFont.fontNames(forFamilyName: family)
                PageLog.d("Family: \(family) Font names: \(names)")
            }
            */
        }
    }
    
    @State var loadingInfo:[String]? = nil
    @State var isLoading = false
    @State var isStoreInit = false
    @State var isInit = false
    
    @State var isInitDataAlram = false
    @State var useLogCollector = false
    @State var toastMsg:String = ""
    @State var isToastShowing:Bool = false
    @State var floatBannerDatas:[BannerData]? = nil
    @State var isPairingHitchShowing:Bool = true
    @State var pageType:PageType = .btv
    @State var hasPopup:Bool = false
    
    
    @State private var delaySyncOrientation:AnyCancellable?
    func syncOrientation(){
        self.delaySyncOrientation?.cancel()
        self.delaySyncOrientation = Timer.publish(
            every: 0.1, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.cancelSyncOrientation()
                self.pagePresenter.syncOrientation()
            }
    }
    func cancelSyncOrientation(){
        self.delaySyncOrientation?.cancel()
        self.delaySyncOrientation = nil
    }
    
    func onUpdateAlram(flag:UpdateFlag, msg:String? = nil){
        if flag == .force {
            self.appSceneObserver.alert = .confirm(
                String.alert.update, msg ?? flag.defaultMessage,
                cancelText: String.alert.updateAfter){ isOk in
                if isOk {
                    AppUtil.goAppStore()
                    self.suspand()
                } else {
                    self.suspand()
                }
            }
        } else {
            self.appSceneObserver.alert = .confirm(
                String.alert.update,
                msg ?? flag.defaultMessage,
                cancelText: String.alert.updateAfter){ isOk in
                if isOk {
                    AppUtil.goAppStore()
                    self.suspand()
                } else {
                    self.repository.apiManager.initApi()
                }
            }
        }
    }
    func onDataAlram(){
        self.appSceneObserver.alert = .confirm(String.alert.apns, String.alert.dataAlram , confirmText: nil) { isOk in
            if !isOk {
                self.suspand()
            } else {
                self.onPageStart()
            }
        }
    }
    
    private func suspand(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
        }
    }
    
    
    func onStoreInit(){
        if self.isStoreInit {return}
        self.isStoreInit = true
        //self.appSceneObserver.event = .debug("onStoreInit")
        if SystemEnvironment.firstLaunch {
            self.pagePresenter.changePage(
                PageProvider.getPageObject(.auth)
            )
            return
        }
        self.onPageInit()
    }
    
    func onPageInit(){
        if self.networkObserver.status == .cellular && self.setup.dataAlram {
            self.onDataAlram()
            return
        }
        self.onPageStart()
    }
    
    func onPageStart(){
        if self.isInit {return}
        self.isInit = true
        self.isLoading = false
        self.pairing.ready()
        if !self.appObserverMove(self.appObserver.page) {
            let initMenuId = self.dataProvider.bands.datas.first?.menuId
            self.pagePresenter.changePage(PageProvider.getPageObject(.home).addParam(key: .id, value: initMenuId))
            
            if self.setup.drmTestUser {
                self.pagePresenter.openPopup(PageProvider.getPageObject(.playerTest))
            }
            
            
            //self.pagePresenter.openPopup(PageProvider.getPageObject(.pairingAppleTv))
            
            
            //http://mobilebtv.com:8080/view/v3.0/applink?type=family_invite&pairing_token=ba68a74dd9644a608cabaae0f36c91c6&nickname=%ED%98%B8
            //type=family_invite&pairing_token=21ed8a3bb05a42d9a2c66f1336a277b4&nickname=%E3%85%87%E3%85%87
            /*
             
             self.pagePresenter.openPopup(PageProvider.getPageObject(.pairingFamilyInvite)
                                             .addParam(key: .title, value: "ㅓㅓ")
                                             .addParam(key: .id, value: "ba68a74dd9644a608cabaae0f36c91c6")
             )
             
             self.pagePresenter.changePage(PageKidsProvider
                                             .getPageObject(.kidsHome)
                                             //.addParam(key: .id, value: "NM2000030726")
             
             self.pagePresenter.openPopup(
                 PageProvider.getPageObject(.recommandReceive)
                     .addParam(key: .title, value: "test")
                     .addParam(key: .id, value: "e63291c67b5f497c97d265f6409a9e26")
                     .addParam(key: .type, value: "02")
             )
             self.pagePresenter.openPopup(PageProvider.getPageObject(.pairingFamilyInvite)
                                             .addParam(key: .title, value: "ㅓㅓ")
                                             .addParam(key: .id, value: "ba68a74dd9644a608cabaae0f36c91c6")
             )
            */
        }
         
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            self.deepLinkMove(self.appObserver.deepLinkUrl)
            if let alram = self.appObserver.alram  {
                self.moveAlram(alram)
            }
            if self.vsManager.isGranted != false {
                self.vsManager.checkAccess()
            }
        }
       
    }
    
    func moveAlram(_ alram:AlramData){

        NotificationCoreData().readNotice(title: alram.title , body: alram.text, messageId:alram.messageId)
        self.repository.confirmPush(alram.messageId, data: alram)
        self.repository.alram.changedNotification()
        self.repository.alram.updatedNotification()
        self.appObserver.resetApns()
        AlramData.move(
            pagePresenter: self.pagePresenter,
            dataProvider: self.dataProvider,
            data: alram)
    }
    
    func onPageRestart(){
        self.isInit = true
        self.isLoading = false
        if self.pagePresenter.currentPage?.pageID == .serviceError {
            self.onPageReset()
        } else {
            self.pairing.ready()
        }
    }
    
    func onPageReset(){
        self.appSceneObserver.event = .toast("on PageReset " + (SystemEnvironment.isStage ? "stage" : "release"))
        let initMenuId = self.dataProvider.bands.datas.first?.menuId
        self.pagePresenter.changePage(
            PageProvider.getPageObject(.home)
                .addParam(key: .id, value: initMenuId)
                .addParam(key: SystemEnvironment.isStage ? .subType : .type, value: "reload")
        )
    }
    
    func onPageError(_ err:ApiResultError?){
        self.pagePresenter.changePage(
            PageProvider.getPageObject(.serviceError)
        )
    }
    
    func onFloatingBannerView(datas:[BannerData]?) {
        guard let datas = datas else {
            if floatBannerDatas == nil {return}
            withAnimation{ floatBannerDatas = nil }
            return
        }
        if datas.isEmpty {return}
        if Setup.getDateKey() == self.setup.floatingUnvisibleDate {return}
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.2) {
            DispatchQueue.main.async {
                withAnimation{ floatBannerDatas = datas }
            }
        }
    }
    
    func floatingBannerToDayUnvisible() {
        self.setup.floatingUnvisibleDate = Setup.getDateKey()
    }
    

    @discardableResult
    func appObserverMove(_ iwg:IwillGo? = nil) -> Bool {
        guard let page = iwg?.page else { return false }
        if PageProvider.isHome(page.pageID) { page.isPopup = false }
        if page.isPopup {
            self.pagePresenter.openPopup(page)
        }else{
            self.pagePresenter.changePage(page)
        }
        self.appObserver.reset()
        return !page.isPopup
    }
    
    @discardableResult
    func deepLinkMove(_ link:URL? = nil)  -> Bool {
        guard let link = link else { return false }
        DispatchQueue.main.async {
            self.appObserver.resetDeeplink()
        }
        return self.repository.webBridge.parseUrl(link.absoluteString) != nil
    }
}


