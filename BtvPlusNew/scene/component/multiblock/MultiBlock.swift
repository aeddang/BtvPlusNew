//
//  MultiBlack.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

struct MultiBlock:PageComponent {
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageObservable:PageObservable = PageObservable()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var topDatas:[BannerData]? = nil
    var datas:[BlockData]
    
    var useTracking:Bool = false
    var marginVertical : CGFloat = 0
    
    var monthlyViewModel: InfinityScrollModel? = nil
    var monthlyDatas:[MonthlyData]? = nil
    var action: ((_ data:MonthlyData) -> Void)? = nil
   
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
                    pageObservable:self.pageObservable,
                    datas: self.topDatas! )
                    .modifier(MatchHorizontal(height: TopBanner.height))
            } else if marginVertical > 0 {
                Spacer().frame( height:self.marginVertical)
            }
            
            if self.monthlyDatas != nil {
               MonthlyBlock(
                    viewModel:self.monthlyViewModel ?? InfinityScrollModel(),
                    pageDragingModel:self.pageDragingModel,
                    monthlyDatas:self.monthlyDatas!,
                    useTracking:self.useTracking,
                    action:self.action
               )
            }
            
            ForEach(self.datas) { data in
                switch data.cardType {
                case .smallPoster, .bigPoster, .bookmarkedPoster, .rankingPoster :
                    PosterBlock(
                        pageDragingModel:self.pageDragingModel,
                        data: data,
                        useTracking:self.useTracking
                        )
                case .video, .watchedVideo :
                    VideoBlock(
                        pageDragingModel:self.pageDragingModel,
                        data: data,
                        useTracking:self.useTracking
                        )
                case .circleTheme, .bigTheme, .squareThema :
                    ThemaBlock(
                        pageDragingModel:self.pageDragingModel,
                        data: data,
                        useTracking:self.useTracking
                        )
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
