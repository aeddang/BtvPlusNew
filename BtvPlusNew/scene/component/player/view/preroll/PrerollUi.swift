//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine



struct PrerollUi: PageView{
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    @ObservedObject var prerollModel: PrerollModel = PrerollModel()
    var type:PageType = .btv
    @State var isFullScreen:Bool = false
    @State var isShow:Bool = false
    @State var isUiShowing:Bool = false
    var body: some View {
        ZStack(alignment: .topLeading){
            Preroll(viewModel: self.prerollModel)
            PlayerEffect(viewModel: self.viewModel)
            VStack(spacing:0){ //광고버튼 피해서 영역잡음
                Spacer().modifier(MatchParent())
                    .background(Color.transparent.clearUi)// Color.transparent.clearUi)
                HStack(spacing:0){
                    Spacer().modifier(MatchHorizontal(height: self.isFullScreen
                                                      ? SystemEnvironment.isTablet ? 154 : 106
                                                      : SystemEnvironment.isTablet ? 124 : 86))
                        .background(Color.transparent.clearUi)
                }.padding(.trailing, self.isFullScreen
                          ? SystemEnvironment.isTablet ? 300 : 200
                          : SystemEnvironment.isTablet ? 166 : 110)
            }
            .onTapGesture {
                self.uiViewChange()
            }
            ZStack(alignment: .topLeading){
                
                if self.type == .btv{
                    HStack(spacing: 0){
                        Button(action: {
                            self.viewModel.btvPlayerEvent = .close
                            
                        }) {
                            Image(Asset.icon.back)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Dimen.icon.regular,
                                       height: Dimen.icon.regular)
                        }
                        Text(String.player.adTitle)
                            .modifier(MediumTextStyle(
                                    size: Font.size.lightExtra,
                                    color: Color.app.white)
                            )
                    }
                    .padding(.all, self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
                } else {
                    HStack(spacing: 0){
                        Button(action: {
                            self.viewModel.btvPlayerEvent = .close
                        }) {
                            Image(AssetKids.player.back)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: self.isFullScreen
                                        ? KidsPlayerUI.iconFullScreen.width : KidsPlayerUI.icon.width,
                                    height: self.isFullScreen
                                        ? KidsPlayerUI.iconFullScreen.height : KidsPlayerUI.icon.height)
                        }
                        Text(String.player.adTitle)
                            .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.lightExtra,
                                    color: Color.app.white)
                            )
                    }
                    .padding(.all, self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
                }
            }
            .opacity(self.isUiShowing ? 1.0 : 0)
            
            
        }
        .modifier(MatchParent())
        .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
            self.isFullScreen = fullScreen
        }
        .onReceive(self.prerollModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .start : self.isShow = true
            case .finish, .skipAd : self.isShow = false
            default : break
            }
        }
        .opacity(self.isShow ? 1.0 : 0)
        
        
    }//body
    
    func uiViewChange(){
        if !self.isUiShowing {
            withAnimation{
                self.isUiShowing = true
            }
            self.delayAutoUiHidden()
        }else {
            withAnimation{
                self.isUiShowing = false
            }
            self.autoUiHidden?.cancel()
        }
    }

    @State var autoUiHidden:AnyCancellable?
    func delayAutoUiHidden(){
        self.autoUiHidden?.cancel()
        self.autoUiHidden = Timer.publish(
            every: 2.0, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.viewModel.playerUiStatus = .hidden
                self.clearAutoUiHidden()
            }
    }
    func clearAutoUiHidden() {
        self.autoUiHidden?.cancel()
        self.autoUiHidden = nil
    }
   
    
}


#if DEBUG
struct PrerollUi_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PrerollUi()
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
