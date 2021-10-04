//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI



struct PageKidsTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var naviLogManager:NaviLogManager
    var title:String? = nil
    var titleTip:String? = nil
    var titleTipColor:Color = Color.app.sepia
    var isBack:Bool = false
    var isClose:Bool = false
    var isSetting:Bool = false
    var style:PageStyle = .kidsWhite
    var close: (() -> Void)? = nil
    var body: some View {
        ZStack(alignment: .leading){
            if let title = self.title {
                HStack(spacing:Dimen.margin.thin) {
                    Text(title)
                        .modifier(BoldTextStyleKids(
                                    size: SystemEnvironment.isTablet ?  Font.sizeKids.light : Font.sizeKids.regular,
                                    color: self.style.textColor))
                        .lineLimit(1)
                    if let tip = self.titleTip {
                        Text(tip)
                            .modifier(BoldTextStyleKids(
                                        size: SystemEnvironment.isTablet ?  Font.sizeKids.tiny : Font.sizeKids.thinExtra,
                                        color: Color.app.white))
                            .padding(.all, DimenKids.margin.tinyExtra)
                            .background(self.titleTipColor)
                            .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.regular))
                    }
                }
                .padding(.horizontal, DimenKids.icon.mediumExtra)
                .frame(maxWidth: .infinity)
                .padding(.top, 1)
            }
            HStack{
                if self.isBack {
                    Button(action: {
                        if let close = self.close{
                            close()
                        } else {
                            self.pagePresenter.goBack()
                        }
                    }) {
                        Image(AssetKids.icon.backTop)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.icon.mediumExtra,
                                   height: DimenKids.icon.mediumExtra)
                    }
                }
                Spacer()
                
                if self.isSetting {
                    Button(action: {
                        self.naviLogManager.actionLog(.clickSettingButton)
                        self.moveSetupCheck()
                        
                    }) { 
                        Image(AssetKids.icon.setting)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.icon.mediumExtra,
                                   height: DimenKids.icon.mediumExtra)
                    }
                }
                if self.isClose {
                    Button(action: {
                        if let close = self.close{
                            close()
                        } else {
                            self.pagePresenter.goBack()
                        }
                    }) {
                        Image(AssetKids.icon.close)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.icon.regularUltra,
                                   height: DimenKids.icon.regularUltra)
                    }
                }
            }
        }
        .modifier(ContentHorizontalEdgesKids())
        .modifier(MatchHorizontal(height: DimenKids.app.pageTop))
        .background(self.style.bgColor)
        .onReceive(self.pagePresenter.$event){ evt in
            guard let evt = evt else {return}
            if evt.id != self.tag { return }
            switch evt.type {
            case .completed :
                let type = evt.data as? PageKidsConfirmType
                switch type {
                case .exitSetup: self.moveSetup()
                default : self.moveSetupCheck()
                }
            default : break
            }
        }
    }
    
    func moveSetupCheck() {
        if !SystemEnvironment.isAdultAuth {
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.adultCertification, animationType: .opacity)
                    .addParam(key: .id, value: self.tag)
            )
            return
        }
        self.pagePresenter.openPopup(
            PageKidsProvider.getPageObject(.kidsConfirmNumber)
                .addParam(key: .type, value: PageKidsConfirmType.exitSetup)
                .addParam(key: .id, value: self.tag)
        )
    }
    func moveSetup() {
        let move = PageProvider.getPageObject(.setup, animationType: .opacity)
        move.isPopup = true
        self.pagePresenter.openPopup(move)
    }
}

#if DEBUG
struct PageKidsTab_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            PageKidsTab(
                title: "title",
                isBack: true
                )
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
        }
        .background(Color.kids.bg)
    }
}
#endif
