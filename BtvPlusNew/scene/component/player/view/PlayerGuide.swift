//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
struct PlayerGuide: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    @State var isShowing:Bool = false
    var body: some View {
        ZStack(alignment: .topTrailing){
            Image( Asset.player.guide)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .modifier(MatchParent())
            
            Button(action: {
                withAnimation{ self.isShowing = false }
                
            }) {
                Image(Asset.icon.close)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular,
                           height: Dimen.icon.regular)
            }
        }
        .padding(.all,  PlayerUI.paddingFullScreen)
        .modifier(MatchParent())
        .background(Color.transparent.black80)
        .opacity(self.isShowing ? 1 : 0)
        .onReceive(self.viewModel.$btvUiEvent) { evt in
            withAnimation{
                switch evt {
                case .guide :
                    self.isShowing = self.isShowing ? false : true
                    if self.isShowing {
                        self.viewModel.playerUiStatus = .hidden
                    }
                default : do{}
                }
            }
        }
        .onReceive(self.pagePresenter.$isFullScreen){ fullScreen in
            if fullScreen == false {
                withAnimation{ self.isShowing = false }
            }
        }
    }//body
    
}


#if DEBUG
struct PlayerGuide_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerGuide(
               
            )
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
