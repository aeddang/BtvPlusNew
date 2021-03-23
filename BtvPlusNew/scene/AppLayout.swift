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
    
    @State var positionTop:CGFloat = 0
    @State var positionBottom:CGFloat = 50
    
    @State var loadingInfo:[String]? = nil
    @State var isLoading = false
    @State var isInit = false
    
    @State var toastMsg:String = ""
    @State var isToastShowing:Bool = false
    @State var floatBannerDatas:[BannerData]? = nil
    var body: some View {
        ZStack{
            SceneTab()
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
                ActivityIndicator(isAnimating: self.$isLoading, style: .large)
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
        .onReceive(self.pagePresenter.$currentTopPage){ page in
            guard let cPage = page else { return }
            PageLog.d("currentTopPage " + cPage.pageID.debugDescription, tag:self.tag)
            PageLog.d("current useTopFix " + (self.appSceneObserver.useTopFix?.description ?? "nil"), tag:self.tag)
            if self.appSceneObserver.useTopFix != false {
                self.appSceneObserver.useTop = PageSceneModel.needTopTab(cPage)
            }
            self.appSceneObserver.useBottom = PageSceneModel.needBottomTab(cPage)
            if PageSceneModel.needKeyboard(cPage) {
                self.keyboardObserver.start()
            }else{
                self.keyboardObserver.cancel()
                AppUtil.hideKeyboard()
            }
        }
        .onReceive (self.appObserver.$page) { iwg in
            if !self.isInit { return }
            if self.appObserver.apns != nil {
                self.appSceneObserver.alert = .recivedApns
                return
            }
            PageLog.d("onReceive : \(self.pageObservable.status)" , tag : self.tag)
            self.appObserverMove(iwg)
        }
        .onReceive (self.appObserver.$pushToken) { token in
            guard let token = token else { return }
            self.repository.registerPushToken(token)
        }
        
        .onReceive(self.repository.$status){ status in
            switch status {
            case .ready: self.onStoreInit()
            case .error(let err): self.onPageError(err)
            default: do{}
            }
        }
        .onAppear(){
            self.isLoading = true
            //UITableView.appearance().separatorStyle = .none
            for family in UIFont.familyNames.sorted() {
                let names = UIFont.fontNames(forFamilyName: family)
                PageLog.d("Family: \(family) Font names: \(names)")
            }
        }
    }
    func onStoreInit(){
        self.appSceneObserver.event = .debug("onStoreInit")
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
        self.appSceneObserver.event = .debug("onPageInit")
        if !self.appObserverMove(self.appObserver.page) {
            let initMenuId = self.dataProvider.bands.datas.first?.menuId
            self.pagePresenter.changePage(
                PageProvider.getPageObject(.home)
                    .addParam(key: .id, value: initMenuId)
            )
        }
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
        if self.getFloatingDateKey() == self.setup.floatingUnvisibleDate {return}
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.2) {
            DispatchQueue.main.async {
                withAnimation{ floatBannerDatas = datas }
            }
        }
        
    }
    
    func floatingBannerToDayUnvisible() {
        self.setup.floatingUnvisibleDate = self.getFloatingDateKey()
    }
    
    private func getFloatingDateKey() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let todayString: String = dateFormatter.string(from: Date())
        return todayString
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


