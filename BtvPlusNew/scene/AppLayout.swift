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
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    @State var positionTop:CGFloat = 0
    @State var positionBottom:CGFloat = 50
    @State var isLoading = false
    @State var isInit = false
    var body: some View {
        ZStack{
            SceneTab()
            SceneRadioController()
            SceneSelectController()
            ScenePickerController()
            SceneAlertController()
            if self.isLoading {
                Spacer().modifier(MatchParent()).background(Color.transparent.black15)
                ActivityIndicator(isAnimating: self.$isLoading)
            }
        }
        .onReceive(self.pagePresenter.$isLoading){ loading in
            DispatchQueue.main.async {
                withAnimation{
                    self.isLoading = loading
                }
            }
        }
        
        .onReceive(self.pagePresenter.$currentTopPage){ page in
            guard let cPage = page else { return }
            PageLog.d("currentTopPage " + cPage.pageID.debugDescription, tag:self.tag)
            self.sceneObserver.useTop = PageSceneModel.needTopTab(cPage)
            self.sceneObserver.useBottom = PageSceneModel.needBottomTab(cPage)
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
                self.sceneObserver.alert = .recivedApns
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
            UITableView.appearance().separatorStyle = .none
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


