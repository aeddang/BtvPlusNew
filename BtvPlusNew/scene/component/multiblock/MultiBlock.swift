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
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var topDatas:[BannerData]? = nil
    var datas:[BlockData]
   
    var useTracking:Bool = false
    var marginVertical : CGFloat = 0
   
    var body :some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginVertical : 0,
            marginHorizontal : 0,
            spacing: Dimen.margin.medium,
            isRecycle : false,
            useTracking:self.useTracking){
            if self.topDatas != nil {
                TopBanner(
                 datas: self.topDatas! )
                    .modifier(MatchHorizontal(height: TopBanner.height))
            } else if marginVertical > 0 {
                Spacer().frame( height:self.marginVertical)
            }
            ForEach(self.datas) { data in
                switch data.cardType {
                case .smallPoster, .bigPoster, .bookmarkedPoster, .rankingPoster :
                    PosterBlock(
                        pageDragingModel:self.pageDragingModel,
                        data: data)
                case .video, .watchedVideo :
                    VideoBlock(
                        pageDragingModel:self.pageDragingModel,
                        data: data)
                case .circleTheme, .bigTheme, .squareThema :
                    ThemaBlock(
                        pageDragingModel:self.pageDragingModel,
                        data: data)
                case .banner :
                    BannerBlock(data: data)
                default:
                    ThemaBlock(data: data)
                }
            }
            Spacer().frame( height:self.marginVertical)
        }
    }
    
}
