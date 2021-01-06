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
    @Binding var datas:[Block]

    var body :some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginVertical : .constant(Dimen.app.bottom + sceneObserver.safeAreaTop),
            marginHorizontal : .constant(0),
            spacing: .constant(Dimen.margin.medium),
            isRecycle : false){
            
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
            Spacer().frame(height:Dimen.margin.heavy)
        }
    }
    
}
