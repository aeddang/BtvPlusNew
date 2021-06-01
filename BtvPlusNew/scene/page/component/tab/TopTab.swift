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
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @State var showAlram:Bool = false
    var body: some View {
        HStack(alignment: .bottom ,spacing:Dimen.margin.tiny){
            Button(action: {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.my)
                )
            }) {
                ZStack(alignment: .topLeading){
                    Image(Asset.gnbTop.my)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regular,
                               height: Dimen.icon.regular)
                    if self.showAlram {
                        Image(Asset.icon.new)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.tinyExtra, height: Dimen.icon.tinyExtra)
                            .padding(.leading, Dimen.icon.regular - (Dimen.icon.tinyExtra/2))
                    }
                }
                .frame(width: Dimen.icon.regular,
                       height: Dimen.icon.regular,
                       alignment: .topLeading)
            }
            Spacer()
            Button(action: {
                self.pagePresenter.changePage(PageKidsProvider.getPageObject(.kidsIntro))
                
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
                
                if self.pairing.status != .pairing {
                    self.appSceneObserver.alert = .needPairing()
                } else {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.remotecon)
                    )
                }
                
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
        .onReceive(self.repository.alram.$newCount){ count in
            withAnimation{self.showAlram = count>0}
        }
        .onReceive(self.repository.alram.$needUpdateNew){ update in
            if self.pairing.status != .pairing {return}
            if update {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.repository.alram.updateNew()
                }
            }
        }
        .onAppear(){
        }
        
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
