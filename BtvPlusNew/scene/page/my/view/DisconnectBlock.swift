//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI
struct DisconnectBlock: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @State var safeAreaBottom:CGFloat = 0
    var body: some View {
        VStack (alignment: .leading, spacing: Dimen.margin.lightExtra){
            VStack (alignment: .leading, spacing: 0){
                Text(String.pageText.myText1)
                    .modifier(MediumTextStyle(size: Font.size.boldExtra, color: Color.app.white))
                Text(String.pageText.myText2)
                    .modifier(MediumTextStyle(size: Font.size.light, color: Color.app.greyLight))
                    .padding(.top, Dimen.margin.lightExtra)
                Image(Asset.source.myConnectIos)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .modifier(MatchParent())
                    .padding(.vertical, Dimen.margin.medium)
            }
            .padding(.horizontal, Dimen.margin.regular)
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
            FillButton(
                text: String.pageTitle.myPurchase,
                isMore: true
            ){_ in
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.pairing)
                )
            }
        }
        .padding(.top, Dimen.margin.light)
        .padding(.horizontal, Dimen.margin.thin)
        .padding(.bottom, Dimen.margin.thin + self.safeAreaBottom)
        .background(Color.brand.bg)
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
        
    }//body
}


#if DEBUG
struct DisconnectBlock_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            DisconnectBlock()
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .frame(width:320,height:600)
                .background(Color.brand.bg)
        }
    }
}
#endif
