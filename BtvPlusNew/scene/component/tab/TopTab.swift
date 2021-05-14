//
//  TopTab.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct TopTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    var body: some View {
        HStack(alignment: .bottom ,spacing:Dimen.margin.tiny){
            Button(action: {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.my)
                )
            }) {
                Image(Asset.gnbTop.my)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular,
                           height: Dimen.icon.regular)
            }
            Spacer()
            
            Button(action: {
                
            }) {
                Image(Asset.gnbTop.zemkids)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.mediumExtra,
                           height: Dimen.icon.mediumExtra)
            }
            Button(action: {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.search)
                )
            }) {
                Image(Asset.gnbTop.search)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular,
                           height: Dimen.icon.regular)
            }
            Button(action: {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.schedule)
                )
            }) {
                Image(Asset.gnbTop.schedule)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular,
                           height: Dimen.icon.regular)
            }
            Button(action: {
                /*
                if self.pairing.status != .pairing {
                    self.appSceneObserver.alert = .needPairing()
                } else {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.remotecon)
                    )
                }*/
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.remotecon)
                )
            }) {
                
                Image(Asset.gnbTop.remote)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular,
                           height: Dimen.icon.regular)
            }
            
        }
        .modifier(ContentHorizontalEdges())
        
    }
}

#if DEBUG
struct TopTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            TopTab().environmentObject(PagePresenter()).frame(width:320,height:100)
                .background(Color.app.blue)
        }
    }
}
#endif
