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
struct AppLayout: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @EnvironmentObject var setup:Setup
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    @State var loadingInfo:[String]? = nil
    @State var isLoading = false
    @State var isInit = false
    
    @State var toastMsg:String = ""
    @State var isToastShowing:Bool = false
    @State var floatBannerDatas:[BannerData]? = nil
    @State var pageType:PageType = .btv
    
    var body: some View {
        ZStack{
            
            SceneTab()
            SceneKidsTab()
           
            if let datas = self.floatBannerDatas {
                FloatingBanner(datas:datas){ today in
                    if today {self.floatingBannerToDayUnvisible()}
                    withAnimation{
                        floatBannerDatas = nil
                    }
                }
            }
            SceneRadioController()
            SceneSelectController()
            ScenePickerController()
            SceneAlertController()
            
            if self.isLoading {
                Spacer().modifier(MatchParent()).background(Color.transparent.black70)
                if self.loadingInfo != nil {
                    VStack {
                        VStack(spacing:0){
                            ForEach(self.loadingInfo!, id: \.self ) { text in
                                Text( text )
                                    .modifier(MediumTextStyle( size: Font.size.bold ))
                            }
                        }
                        .modifier(MatchParent())
                        Spacer().modifier(MatchParent())
                    }
                }
                if SystemEnvironment.currentPageType == .btv {
                    ActivityIndicator(isAnimating: self.$isLoading, style: .large)
                } else {
                    AnimateSpinner(isAnimating: self.$isLoading).frame(
                        width: DimenKids.loading.large.width,
                        height: DimenKids.loading.large.height)
                }
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
        .onReceive(self.appSceneObserver.$event){ evt in
            guard let evt = evt else { return }
            switch evt  {
            case .initate: self.onPageInit()
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
            self.pageType = SystemEnvironment.currentPageType
            PageLog.d("currentPageType " + self.pageType.rawValue, tag:self.tag)
            
            switch self.pageType {
            case .btv :
                self.pagePresenter.bodyColor = Color.brand.bg
            case .kids :
                self.pagePresenter.bodyColor = Color.kids.bg
            }
            
            
            if self.appSceneObserver.useTopFix != false {
                self.appSceneObserver.useTop = PageSceneModel.needTopTab(cPage)
            }
            self.appSceneObserver.useBottom = PageSceneModel.needBottomTab(cPage)
            AppUtil.hideKeyboard()
            if PageSceneModel.needKeyboard(cPage) {
                self.keyboardObserver.start()
            }else{
                self.keyboardObserver.cancel()
            }
        }
        .onReceive (self.appObserver.$page) { iwg in
            if !self.isInit { return }
            self.appObserverMove(iwg)
        }
        .onReceive (self.appObserver.$alram) { alram in
            if alram == nil {return}
            
            if !self.isInit { return }
            self.appSceneObserver.alert = .recivedApns(alram)
        }
        .onReceive (self.appObserver.$pushToken) { token in
            guard let token = token else { return }
            self.repository.registerPushToken(token)
        }
        
        .onReceive(self.repository.$status){ status in
            switch status {
            case .ready: self.onStoreInit()
            case .error(let err): self.onPageError(err)
            default: break
            }
        }
        .onReceive(self.repository.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .reset : self.onPageReset()
            default: break
            }
        }
        .onAppear(){
            self.isLoading = true
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
    
    func onStoreInit(){
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
        self.isInit = true
        self.isLoading = false
        //self.appSceneObserver.event = .debug("onPageInit")
        if !self.appObserverMove(self.appObserver.page) {
            let initMenuId = self.dataProvider.bands.datas.first?.menuId
            self.pagePresenter.changePage(PageKidsProvider.getPageObject(.kidsHome))
            //self.pagePresenter.changePage(PageProvider.getPageObject(.home).addParam(key: .id, value: initMenuId))
            //self.pagePresenter.openPopup(PageProvider.getPageObject(.playerTest))
        }
        if let alram = self.appObserver.alram  {
            self.appSceneObserver.event = .debug("apns exist")
            self.appSceneObserver.alert = .recivedApns(alram)
            return
        }
    }
    
    func onPageReset(){
        self.appSceneObserver.event = .debug("onPageReset")
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
    
}


