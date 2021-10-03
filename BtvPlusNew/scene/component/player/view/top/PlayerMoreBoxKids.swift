//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

extension PlayerMoreBoxKids{
    static let textSize = Font.sizeKids.microUltra
    static let textSizeFull = Font.sizeKids.light
}

struct PlayerMoreBoxKids: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    var isLock:Bool = false
    @State var isFullScreen:Bool = false
    @State var isShowing:Bool = false
    
    var body: some View {
        ZStack{
            VStack(spacing:DimenKids.margin.thin){
                Button(action: {
                    self.viewModel.btvLogEvent = .clickConfigButton(.clickVodConfigEtc, config: "screen_propotion")
                    self.viewModel.selectFunctionType = .quality
                    self.hideBox()
                }) {
                    Text( String.button.playQuality )
                        .modifier(
                            BoldTextStyleKids(
                                size: self.isFullScreen ? Self.textSizeFull : Self.textSize,
                                color: Color.app.sepia
                            ))
                }
                Spacer().modifier(LineHorizontal(color:Color.app.black))
                    .padding(.horizontal, DimenKids.margin.tiny)
                Button(action: {
                    self.viewModel.btvLogEvent = .clickConfigButton(.clickVodConfigEtc, config: "speed")
                    self.viewModel.selectFunctionType = .rate
                    self.hideBox()
                }) {
                    Text( String.button.playRate )
                        .modifier(
                            BoldTextStyleKids(
                                size: self.isFullScreen ? Self.textSizeFull : Self.textSize,
                                color: Color.app.sepia
                            ))
                }
            }
            
        }
        .frame(
            width: self.isFullScreen
                ? SystemEnvironment.isTablet ? 228 : 119
                : SystemEnvironment.isTablet ? 119 :  67,
            height: self.isFullScreen
                ? SystemEnvironment.isTablet ? 184 : 96
                : SystemEnvironment.isTablet ? 96 : 54
        )
        .background(Color.kids.bg)
        .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
        
        .opacity(self.isShowing && !self.isLock ? 1 : 0)
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
struct PlayerMoreBoxKids_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerMoreBoxKids(
               
            )
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
