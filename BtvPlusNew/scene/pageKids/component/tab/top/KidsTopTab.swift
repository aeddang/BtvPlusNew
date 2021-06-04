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
            KidProfile()
            Spacer()
            Button(action: {
                self.pagePresenter.changePage(PageKidsProvider.getPageObject(.kidsIntro))
            }) {
                Image(AssetKids.gnbTop.monthly)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: DimenKids.icon.regular,
                           height: DimenKids.icon.regular)
            }
            Button(action: {
                
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
                    self.pagePresenter.changePage(
                        PageProvider.getPageObject(.home)
                            .addParam(key: .id, value: home.menuId)
                    )
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
