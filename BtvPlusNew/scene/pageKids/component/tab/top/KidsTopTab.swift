//
//  TopTab.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct KidsTopTab: PageComponent{
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    @State var selectedMenuId:String? = nil
    var body: some View {
        HStack(alignment: .center ,spacing:DimenKids.margin.light){
            KidProfile().onTapGesture {
                
                self.sendLog(menuName: "프로필")
                
                if self.pairing.kids.isEmpty || self.pairing.kid == nil{
                    if !self.setup.isRegistUnvisibleDate() {
                        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.registKid))
                        return
                    }
                }
                
                self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsMy))
            }
            Spacer()
            Button(action: {
                self.sendLog(menuName: "이용권")
                self.pagePresenter.openPopup(
                    PageKidsProvider.getPageObject(.kidsMonthly)
                )
            }) {
                Image(AssetKids.gnbTop.monthly)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: DimenKids.icon.regular,
                           height: DimenKids.icon.regular)
            }
            Button(action: {
                self.sendLog(menuName: "검색")
                self.pagePresenter.openPopup(
                    PageKidsProvider.getPageObject(.kidsSearch)
                )
            }) {
                Image(AssetKids.gnbTop.search)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular,
                           height: Dimen.icon.regular)
            }
            Button(action: {
                self.sendLog(menuName: "나가기")
                var move:PageObject? = nil
                if let historyPage = self.appSceneObserver.finalBtvPage {
                    move = historyPage
                    move?.removeParam(key: .subId)
                } else if let home  = self.dataProvider.bands.getHome() {
                    move = PageProvider.getPageObject(.home).addParam(key: .id, value: home.menuId)
                }
                if pairing.status == .pairing && self.setup.isKidsExitAuth {
                    self.pagePresenter.openPopup(
                        PageKidsProvider.getPageObject(.kidsConfirmNumber)
                            .addParam(key: .type, value: PageKidsConfirmType.exit)
                            .addParam(key: .data, value: move)
                    )
                } else if let move = move {
                    self.pagePresenter.changePage(move)
                }
                    
                
            }) {
                Image(AssetKids.gnbTop.exit)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular,
                           height: Dimen.icon.regular)
            }
        }
        .onReceive(self.appSceneObserver.$kidsGnbMenuId) { id in
            self.selectedMenuId = id
        }
        .onAppear(){
        }
        
    }
    
    private func sendLog(menuName:String){
        self.naviLogManager.actionLog(
            .clickTopGnbMenu,
            actionBody: .init(menu_id: self.selectedMenuId,
                              menu_name:menuName,
                              target: self.pairing.kids.isEmpty ? "N" : "Y"))
    }
}

#if DEBUG
struct KidsTopTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            KidsTopTab()
                .environmentObject(PagePresenter())
                .environmentObject(DataProvider())
                .frame(width:320,height:100)
        }
    }
}
#endif
