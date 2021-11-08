//
//  TopTab.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI


struct QuickData : Identifiable{
    let id = UUID().uuidString
    let pageId:PageID
    let text:String
    let icon:String
    var isLast:Bool = false
   
}

struct QuickTab: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    var menus:[QuickData] = []

    var body: some View {
        HStack(alignment: .center ,
               spacing: SystemEnvironment.isTablet ? Dimen.margin.tiny : 0){
            ForEach(self.menus) {menu in
                if SystemEnvironment.isTablet {
                    QuickTabItemTablet(data: menu){
                        self.move(data: menu)
                    }
                } else {
                    QuickTabItem(data: menu){
                        self.move(data: menu)
                    }
                    .modifier(MatchHorizontal(height: 46))
                    if !menu.isLast {
                        Spacer().modifier(MatchVertical(width: 1))
                            .frame( height: Dimen.line.heavy)
                            .background(Color.app.white.opacity(0.2))
                    }
                }
            }
        }
        .padding(.horizontal,  SystemEnvironment.isTablet ? Dimen.margin.thin : Dimen.margin.regularExtra)
    }
    func move(data:QuickData ){
        switch data.pageId {
        case .previewList : self.movePreview()
        case .webviewList :
            if data.text ==  String.quickMenu.menu2 {
                self.moveEvent()
            } else {
                self.moveTip()
            }
        case .cashCharge : self.moveCashCharge()
        case .category : self.moveCategory()
        default : self.moveJoinCenter()
        }
    }
    func movePreview(){
        self.naviLogManager.actionLog(.clickGnbQuickMenu, actionBody:.init(result:"공개예정"))
        if let block = self.dataProvider.bands.getPreviewBlockData()  {
            let data = CateData().setData(data: block)
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.previewList)
                    .addParam(key: .title, value: data.title)
                    .addParam(key: .id, value: data.menuId)
                    .addParam(key: .data, value: data)
                    .addParam(key: .needAdult, value: data.isAdult)
            )
            
        } else {
            ComponentLog.e("previewList notfound", tag:self.tag)
        }
    }
    
    func moveCategory(){
        self.naviLogManager.actionLog(.clickGnbQuickMenu, actionBody:.init(result:"클립"))
        if let block = self.dataProvider.bands.getClipBlockData()  {
            let data = CateData().setData(data: block)
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.multiBlock)
                    .addParam(key: .title, value: data.title)
                    .addParam(key: .id, value: data.menuId)
                    .addParam(key: .data, value: data)

            )
            
        } else {
            ComponentLog.e("clipList notfound", tag:self.tag)
        }
    }
    
    func moveEvent(){
        self.naviLogManager.actionLog(.clickGnbQuickMenu, actionBody:.init(result:"이벤트"))
        if let block = self.dataProvider.bands.getEventBlockData()  {
            let data = CateData().setData(data: block)
            self.pagePresenter.openPopup(
                PageProvider
                    .getPageObject(.webviewList)
                    .addParam(key: .data, value: BtvWebView.event)
                    .addParam(key: .title , value: data.title)
            )
            
        } else {
            ComponentLog.e("event notfound", tag:self.tag)
        }
    }
    
    func moveTip(){
        self.naviLogManager.actionLog(.clickGnbQuickMenu, actionBody:.init(result:"이용꿀팁"))
        if let block = self.dataProvider.bands.getTipBlockData()  {
            let data = CateData().setData(data: block)
            self.pagePresenter.openPopup(
                PageProvider
                    .getPageObject(.webviewList)
                    .addParam(key: .data, value: BtvWebView.tip)
                    .addParam(key: .title , value: data.title)
            )
        } else {
            ComponentLog.e("tip notfound", tag:"WebviewMethod.bpn_showComingSoon")
        }
    }
    
    func moveCashCharge(){
        self.naviLogManager.actionLog(.clickGnbQuickMenu, actionBody:.init(result:"충전소"))
        self.pagePresenter.openPopup(
            PageProvider
                .getPageObject(.cashCharge)
        )
    }
    
    func moveJoinCenter(){
        self.naviLogManager.actionLog(.clickGnbQuickMenu, actionBody:.init(result:"B가입샵"))
        self.pagePresenter.openPopup(
            PageProvider
                .getPageObject(.webview)
                .addParam(key: .data, value: "https://m.bdirectshop.com/Btvapp/Btvapp.do")
                .addParam(key: .title , value: String.pageTitle.joinCenter)
        )
        
            
    }
}

struct QuickTabItem: PageComponent{
    var data:QuickData
    var action:()->Void
    var body: some View {
       
        Button(action: {
            action()
        }) {
            VStack(spacing:Dimen.margin.tiny){
                Image(data.icon)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.lightUltra,
                           height: Dimen.icon.lightUltra)
                Text(data.text)
                    .modifier(BoldTextStyle(
                        size: Font.size.tinyExtra,
                        color: Color.app.greyLight
                    ))
                    .fixedSize(horizontal: true, vertical: false)
            }
            
        }
    }
}

struct QuickTabItemTablet: PageComponent{
    var data:QuickData
    var action:()->Void
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing:Dimen.margin.tiny){
                Image(data.icon)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.light,
                           height: Dimen.icon.light)
                Text(data.text)
                    .modifier(BoldTextStyle(
                        size: Font.size.tinyExtra,
                        color: Color.app.greyLight
                    ))
                    .fixedSize(horizontal: true, vertical: false)
            }
            .frame(width: 140, height: 52)
            .background(Color.app.blueLight)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.tiny))
        }
    }
}
            
#if DEBUG
struct QuickTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            QuickTab().environmentObject(PagePresenter()).frame(width:320,height:100)
                .background(Color.app.blue)
        }
    }
}
#endif
