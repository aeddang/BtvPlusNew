//
//  MultiBlack.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

struct MultiBlock:PageComponent {
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    @Binding var datas:[Block]

    var body :some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginVertical : Dimen.app.bottom,
            marginHorizontal : 0,
            spacing: Dimen.margin.light,
            isRecycle : false
            ){
            
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
        .onReceive(self.viewModel.$event){evt in
            ComponentLog.d("evt " + evt.debugDescription, tag: self.tag)
            guard let evt = evt else {return}
            switch evt {
            case .top : self.pageSceneObserver.useTop = true
            case .down, .up : self.pageSceneObserver.useTop = false
            default : do{}
            }
        }
    }
    
}
