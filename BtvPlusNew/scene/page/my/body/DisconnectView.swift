//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI



struct DisconnectView: PageComponent{
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    
    var pageObservable:PageObservable = PageObservable()
    @State var safeAreaBottom:CGFloat = 0
    @State var sceneOrientation: SceneOrientation = .portrait
    @State var isPossession:Bool = false
    var body: some View {
        HStack ( spacing: Dimen.margin.regular ){
            VStack (alignment: .leading, spacing: Dimen.margin.lightExtra){
                VStack (alignment: .leading, spacing: 0){
                    Text(String.pageText.myText1)
                        .kerning(Font.kern.thin)
                        .modifier(MediumTextStyle(size: Font.size.boldExtra, color: Color.app.white))
                        
                    Text(String.pageText.myText2)
                        .modifier(MediumTextStyle(size: Font.size.light, color: Color.app.greyLight))
                        .padding(.top, Dimen.margin.lightExtra)
                    if self.sceneOrientation == .portrait {
                        Image(Asset.image.myConnectIos)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.vertical, Dimen.margin.medium)
                            .modifier(MatchParent())
                    } else {
                        Spacer().modifier(MatchParent())
                    }
                   
                }
                .padding(.horizontal, SystemEnvironment.isTablet ? 0 : Dimen.margin.light)
                FillButton(
                    text: String.button.connectBtv
                ){_ in
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.pairing)
                    )
                }
                HStack(spacing: 0){
                    FillButton(
                        text: String.button.alarm,
                        image: Asset.icon.alarm,
                        isNew: false
                    ){_ in
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.myAlram)
                        )
                    }
                    Spacer().modifier(LineVertical())
                        .frame(height:Dimen.button.lightExtra)
                    FillButton(
                        text: String.button.notice,
                        image: Asset.icon.notice,
                        isNew: false
                    ){_ in
                        self.pagePresenter.openPopup(
                            PageProvider
                                .getPageObject(.webview)
                                .addParam(key: .data, value: BtvWebView.notice)
                                .addParam(key: .title , value: String.button.notice)
                        )
                    }
                }
                .background(Color.app.blueLight)
                if self.isPossession {
                    FillButton(
                        text: String.pageTitle.myTerminatePurchase,
                        isMore: true
                    ){_ in
                        
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.myPossessionPurchase)
                        )
                    }
                }
            }
            if self.sceneOrientation == .landscape {
                Image(Asset.image.myConnectIos)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .modifier(MatchParent())
            }
        }
        .padding(.top, SystemEnvironment.isTablet ? Dimen.margin.heavyExtra : Dimen.margin.light)
        .padding(.horizontal ,
                 (SystemEnvironment.isTablet && self.sceneOrientation == .portrait )
                    ? Dimen.margin.heavy : Dimen.margin.thin)
        
        .modifier(MatchParent())
        .background(Color.brand.bg)
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
        .onReceive(self.sceneObserver.$isUpdated){ update in
            if !update {return}
            self.sceneOrientation  = self.sceneObserver.sceneOrientation
        }
        .onReceive(self.pagePresenter.$currentTopPage){ page in
            self.isPossession = self.setup.possession.isEmpty == false
        }
        .onAppear{
            self.sceneOrientation  = self.sceneObserver.sceneOrientation
            self.isPossession = self.setup.possession.isEmpty == false
        }
        
    }//body
}


#if DEBUG
struct DisconnectBlock_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            DisconnectView()
                .environmentObject(Setup())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .frame(width:320,height:600)
                .background(Color.brand.bg)
        }
    }
}
#endif
