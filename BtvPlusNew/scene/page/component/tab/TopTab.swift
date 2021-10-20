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
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var setup:Setup
    @State var showAlram:Bool = false
    @State var newCount:Int = 0
    @State var newCountStr:String = ""
    @State var pairingStbType:PairingDeviceType = .btv
    @State var isPairing:Bool = false
    @State var character:String? = nil
    var body: some View {
        HStack(alignment: .bottom ,spacing:Dimen.margin.tiny){
            Button(action: {
                self.naviLogManager.actionLog(.clickTopGnbMy)
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.my)
                )
            }) {
                ZStack(alignment: .topLeading){
                    Image(self.character ?? Asset.gnbTop.my)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regular,
                               height: Dimen.icon.regular)
                    if self.showAlram && self.isPairing{
                        Text(self.newCountStr)
                            .modifier(BoldTextStyle(
                                size: SystemEnvironment.isTablet ? Font.size.microExtra : Font.size.micro,
                                color: Color.app.white
                            ))
                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                            .background(Color.brand.primary)
                            .clipShape(Circle())
                            .padding(.leading, Dimen.icon.regular - (Dimen.icon.tinyExtra/2))
                        /*
                        Image(Asset.icon.new)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.tinyExtra, height: Dimen.icon.tinyExtra)
                            .padding(.leading, Dimen.icon.regular - (Dimen.icon.tinyExtra/2))
                        */
                    }
                }
                .accessibility(label: Text(String.button.my))
                .frame(width: Dimen.icon.regular,
                       height: Dimen.icon.regular,
                       alignment: .topLeading)
            }
            Spacer()
            
            
            Button(action: {
                self.naviLogManager.actionLog(.clickTopGnbZemkids)
                self.pagePresenter.changePage(PageKidsProvider.getPageObject(.kidsIntro))
                
            }) {
                Image(Asset.gnbTop.zemkids)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.mediumExtra,
                           height: Dimen.icon.mediumExtra)
            }
            .accessibility(label: Text(String.button.kids))
            Button(action: {
                self.naviLogManager.actionLog(.clickTopGnbSearch)
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
            .accessibility(label: Text(String.button.search))
            Button(action: {
                self.naviLogManager.actionLog(.clickTopGnbEpg)
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
            .accessibility(label: Text(String.button.schedule))
            if self.pairingStbType == .btv {
                Button(action: {
                    self.naviLogManager.actionLog(.clickTopGnbRemotecon)
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
                .accessibility(label: Text(String.button.remotecon))
            }
        }
        .modifier(ContentHorizontalEdges())
        .onReceive(self.pairing.$event){ evt in
            switch evt{
            case .connected :
                self.pairingStbType = self.pairing.pairingStbType
            case .disConnected :
                self.pairingStbType = self.pairing.pairingStbType
                self.onUpdatedUser(self.pairing.user)
            case .pairingCompleted :
                self.onUpdatedUser(self.pairing.user)
            case .updatedUser :
                self.onUpdatedUser(self.pairing.user)
            default :break
            }
        }
        .onReceive (self.pairing.$status){ stat in
            self.isPairing = stat == .pairing
        }
        .onReceive (self.appSceneObserver.$useTop) { use in
            self.pairingStbType = self.pairing.pairingStbType
        }
        .onReceive(self.repository.alram.$newCount){ count in
            if self.pairing.status != .pairing { return }
            self.newCount = min(99, count)
            self.newCountStr = self.newCount == 99 ? "99+" : self.newCount.description
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
            self.pairingStbType = self.pairing.pairingStbType
        }
        
    }
    
    private func onUpdatedUser(_ user:User?){
        if self.pairing.status != .pairing {
            self.character = nil
        } else if let user = user {
            self.character = Asset.characterList[user.characterIdx]
        } else {
            self.character = nil
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
