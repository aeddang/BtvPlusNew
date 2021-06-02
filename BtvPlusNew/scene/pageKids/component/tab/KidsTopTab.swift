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
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
 
    var body: some View {
        HStack(alignment: .center ,spacing:Dimen.margin.tiny){
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
                if let home  = dataProvider.bands.getHome() {
                    pagePresenter.changePage(
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
            KidsTopTab().environmentObject(PagePresenter()).frame(width:320,height:100)
                .background(Color.app.blue)
        }
    }
}
#endif
