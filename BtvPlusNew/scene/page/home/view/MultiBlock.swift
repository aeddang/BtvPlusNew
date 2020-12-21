//
//  MultiBlack.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

struct MultiBlock:PageComponent {
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    @Binding var datas:[Block]

    var body :some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginVertical : Dimen.app.bottom,
            marginHorizontal : 0,
            spacing: 0 ){
            
            ForEach(self.datas) { data in
                switch data.cardType {
                case .smallPoster, .bigPoster, .bookmarkedPoster, .rankingPoster :
                    PosterBlock(data: data) 
                case .video, .watchedVideo :
                    VideoBlock(data: data)
                case .circleTheme, .bigTheme, .squareThema :
                    ThemaBlock(data: data)
                default: Text(data.name).modifier(BlockTitle())
                }
               
            }
        }
    }
    
}
