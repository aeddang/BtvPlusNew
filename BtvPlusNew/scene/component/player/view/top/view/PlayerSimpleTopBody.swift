//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine


struct PlayerSimpleTopBody: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    var isFullScreen:Bool = false
    var isShowing:Bool = false
    var isMute:Bool = false
    var body: some View {
        VStack(
            alignment :.trailing,
            spacing:0){
            Spacer().modifier(MatchHorizontal(height: 0))
            ImageButton(
                defaultImage: Asset.player.volumeOn,
                activeImage: Asset.player.volumeOff,
                isSelected: self.isMute,
                size: CGSize(width:Dimen.icon.regular,height:Dimen.icon.regular)
            ){ _ in
                if self.isMute {
                    if self.viewModel.volume == 0 {
                        self.viewModel.event = .volume(0.5)
                    }else{
                        self.viewModel.event = .mute(false)
                    }
                } else {
                    self.viewModel.event = .mute(true)
                }
            }
            .fixedSize()
            Spacer()
        }
    }//body
    
    
   
    
}


