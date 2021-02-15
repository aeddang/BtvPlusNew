//
//  MultiBlack.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

struct MultiBlock:PageComponent {
    @EnvironmentObject var sceneObserver:SceneObserver
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[Block]
    var useTracking:Bool = false
    @State var safeAreaBottom:CGFloat = 0
    var body :some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginVertical : Dimen.app.bottom + sceneObserver.safeAreaTop,
            marginHorizontal : 0,
            spacing: Dimen.margin.medium,
            isRecycle : false,
            useTracking:self.useTracking){
            
            ForEach(self.datas) { data in
                switch data.cardType {
                case .smallPoster, .bigPoster, .bookmarkedPoster, .rankingPoster :
                    PosterBlock(data: data) 
                case .video, .watchedVideo :
                    VideoBlock(data: data)
                case .circleTheme, .bigTheme, .squareThema :
                    ThemaBlock(data: data)
                default:
                    ThemaBlock(data: data)
                }
            }
            //Spacer().frame( height:self.safeAreaBottom )
        }
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            self.safeAreaBottom = pos
        }
    }
    
}
