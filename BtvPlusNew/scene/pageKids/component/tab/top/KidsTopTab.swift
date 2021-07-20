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
   
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    
    var body: some View {
        HStack(alignment: .center ,spacing:DimenKids.margin.light){
            KidProfile().onTapGesture {
                self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsMy))
            }
            Spacer()
            Button(action: {
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
                if let home  = self.dataProvider.bands.getHome() {
                    let move = PageProvider.getPageObject(.home).addParam(key: .id, value: home.menuId)
                    
                    /*
                    self.pagePresenter.openPopup(
                        PageKidsProvider.getPageObject(.kidsConfirmNumber)
                            .addParam(key: .type, value: PageKidsConfirmType.exit)
                            .addParam(key: .data, value: move)
                    )
                    */
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
       
        .onAppear(){
        }
        
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
