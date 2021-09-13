//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

extension PlayerMoreBox{
    static let textSize = Font.size.thin
    static let textSizeFull = Font.size.lightExtra
}


struct PlayerMoreBox: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    
    @State var isFullScreen:Bool = false
    @State var isShowing:Bool = false
    var body: some View {
       
        VStack(spacing:self.isFullScreen ? Dimen.margin.regularExtra : Dimen.margin.light){
            Button(action: {
                self.viewModel.isLock = true
                self.hideBox()
            }) {
                Text( String.button.screenLock )
                    .modifier(
                        MediumTextStyle(size: self.isFullScreen ? Self.textSizeFull : Self.textSize))
            }
            .padding(.top, Dimen.margin.thin)
            Button(action: {
                self.viewModel.selectFunctionType = .ratio
                self.hideBox()
            }) {
                Text( String.button.screenRatio )
                    .modifier(
                        MediumTextStyle(size: self.isFullScreen ? Self.textSizeFull : Self.textSize))
            }
            if self.viewModel.synopsisPlayerData?.type != .clip() {
                Button(action: {
                    self.hideBox()
                    
                }) {
                    Text( String.button.watchBtv )
                        .modifier(
                            MediumTextStyle(size: self.isFullScreen ? Self.textSizeFull : Self.textSize))
                }
            }
            
            if self.isFullScreen {
                Button(action: {
                    self.viewModel.btvUiEvent = .guide
                    self.hideBox()
                    
                }) {
                    Text( String.button.guide )
                        .modifier(
                            MediumTextStyle(size: self.isFullScreen ? Self.textSizeFull : Self.textSize))
                }
            }
        }
        .padding(.all, Dimen.margin.thin)
        .background(
            Image( SystemEnvironment.isTablet ? Asset.player.popupBgFull : Asset.player.popupBg)
                .renderingMode(.original)
                .resizable(capInsets:
                            .init(top: Dimen.margin.regular, leading: Dimen.margin.thin,
                                  bottom: Dimen.margin.thin, trailing: Dimen.margin.medium),
                           resizingMode: .stretch)
                .scaledToFill()
        )
        /*
        .frame(
            width: self.isFullScreen
                ? SystemEnvironment.isTablet ? 215 : 120
                : SystemEnvironment.isTablet ? 174 :  81
            /*
            height: self.isFullScreen
                ? SystemEnvironment.isTablet ? 302 : 169
                : SystemEnvironment.isTablet ? 214 : 102
            */
        )*/
        .opacity(self.isShowing ? 1 : 0)
        .onReceive(self.viewModel.$btvUiEvent) { evt in
            withAnimation{
                switch evt {
                case .more :
                    self.isShowing = self.isShowing ? false : true
                    if self.isShowing {
                        self.viewModel.event = .fixUiStatus(true) 
                    } else {
                        self.viewModel.event = .fixUiStatus(false)
                        self.viewModel.playerUiStatus = .hidden
                    }
                default : break
                }
            }
        }
        
        .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
            self.isFullScreen = fullScreen
        }
            
    }//body
    
    
    func hideBox(){
        self.viewModel.playerUiStatus = .hidden
        withAnimation{ self.isShowing = false }
    }

}


#if DEBUG
struct PlayerMoreBox_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerMoreBox(
               
            )
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
