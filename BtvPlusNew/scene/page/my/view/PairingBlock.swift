//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI
struct PairingBlock: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    @State var safeAreaBottom:CGFloat = 0
    
    @State var character:String = Asset.characterList[0]
    @State var nick:String = ""
    
    var body: some View {
        VStack (alignment: .center, spacing: Dimen.margin.lightExtra){
            VStack (alignment: .center, spacing: Dimen.margin.lightExtra){
                ZStack (alignment: .bottom){
                    Image(self.character)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, Dimen.margin.tiny)
                        .frame(width: Dimen.item.profile.width, height: Dimen.item.profile.height)
                    
                    Text(String.pageText.myPairing)
                        .modifier(MediumTextStyle(size: Font.size.tinyExtra, color: Color.app.white))
                        .padding(.horizontal, Dimen.margin.thin)
                        .frame(height:Dimen.button.thin)
                        .background(Color.brand.primary)
                        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regularExtra))
                }
                TextButton(
                    defaultText: self.nick,
                    textModifier: TextModifier( family: Font.family.medium,
                        size: Font.size.mediumExtra, color:Color.app.white),
                    image: Asset.icon.profileEdit,
                    imageSize: Dimen.icon.thinExtra
                ) { _ in
                     
                    }
                TextButton(
                    defaultText: String.pageTitle.pairingManagement,
                    textModifier: TextModifier( family: Font.family.medium,
                        size: Font.size.thinExtra, color:Color.app.greyLight),
                    image: Asset.icon.more) { _ in
                     
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.pairingManagement)
                        )
                    }
            }
            HStack(spacing: 0){
                FillButton(
                    text: String.button.alarm,
                    image: Asset.icon.alarm,
                    isNew: true
                ){_ in
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.pairing)
                    )
                }
                Spacer().modifier(LineVertical())
                    .frame(height:Dimen.button.lightExtra)
                FillButton(
                    text: String.button.notice,
                    image: Asset.icon.notice,
                    isNew: true
                ){_ in
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.pairing)
                    )
                }
            }
            .background(Color.app.blueLight)
            
            HStack(spacing: 0){
                ValueInfo(key: "A", value: "B")
                    .modifier(MatchParent())
                Spacer().modifier(LineVertical())
                    .frame(height:Dimen.button.lightExtra)
                ValueInfo(key: "A", value: "B")
                    .modifier(MatchParent())
                Spacer().modifier(LineVertical())
                    .frame(height:Dimen.button.lightExtra)
                ValueInfo(key: "A", value: "B")
                    .modifier(MatchParent())
                Spacer().modifier(LineVertical())
                    .frame(height:Dimen.button.lightExtra)
                ValueInfo(key: "A", value: "B")
                    .modifier(MatchParent())
            }
            .frame(height:Dimen.tab.heavy)
            .background(Color.app.blueLight)
            
            Spacer()
        }
        .padding(.top, Dimen.margin.light)
        .padding(.horizontal, Dimen.margin.thin)
        .padding(.bottom, Dimen.margin.thin + self.safeAreaBottom)
        .background(Color.brand.bg)
    
        .onReceive(self.pairing.$user){ user in
            guard let user = user else {return}
            self.character = Asset.characterList[user.characterIdx]
            self.nick = user.nickName
        }
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
        
        
    }//body
}


#if DEBUG
struct PairingBlock_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            PairingBlock()
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Pairing())
                .frame(width:320,height:600)
                .background(Color.brand.bg)
        }
    }
}
#endif
