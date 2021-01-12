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
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    @State var positionTop:CGFloat = 0
    @State var positionBottom:CGFloat = 50
    
    @State var loadingInfo:[String]? = nil
    @State var isLoading = false
    @State var isInit = false
    
    @State var toastMsg:String = ""
    @State var isToastShowing:Bool = false
    
    var body: some View {
        ZStack{
            SceneTab()
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
        .onReceive(self.pageSceneObserver.$loadingInfo){ loadingInfo in
            self.loadingInfo = loadingInfo
            withAnimation{
                self.isLoading = loadingInfo == nil ? false : true
            }
        }
        .onReceive(self.pageSceneObserver.$event){ evt in
            guard let evt = evt else { return }
            switch evt  {
            case .toast(let msg):
                self.toastMsg = msg
                self.isToastShowing = true
            }
        }
        .onReceive(self.pagePresenter.$currentTopPage){ page in
            guard let cPage = page else { return }
            PageLog.d("currentTopPage " + cPage.pageID.debugDescription, tag:self.tag)
            self.pageSceneObserver.useTop = PageSceneModel.needTopTab(cPage)
            self.pageSceneObserver.useBottom = PageSceneModel.needBottomTab(cPage)
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
                self.pageSceneObserver.alert = .recivedApns
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
            case .ready: self.onPageInit()
            default: do{}
            }
        }
        .onAppear(){
            //UITableView.appearance().separatorStyle = .none
            /*
            for family in UIFont.familyNames.sorted() {
                let names = UIFont.fontNames(forFamilyName: family)
                PageLog.d("Family: \(family) Font names: \(names)")
            }
            */
    
        }
    }
    func onPageInit(){
        self.isInit = true
        if !self.appObserverMove(self.appObserver.page) {
            let initMenuId = self.dataProvider.bands.datas.first?.menuId
            self.pagePresenter.changePage(
                PageProvider.getPageObject(.home)
                    .addParam(key: .id, value: initMenuId)
            )
        }
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


