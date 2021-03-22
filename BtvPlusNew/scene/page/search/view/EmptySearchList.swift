//
//  EmptySerchList.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation
import SwiftUI

struct EmptySearchList: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var keyword:String? = nil
    var datas:[PosterDataSet] = []
    
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            scrollType : .reload(isDragEnd:false),
            marginTop : Dimen.margin.regular,
            marginBottom : Dimen.margin.regular,
            marginHorizontal : 0,
            spacing:0,
            isRecycle: true,
            useTracking:false
        ){
            if !self.datas.isEmpty {
                ForEach(self.datas) { data in
                    PosterSet( data:data )
                    .frame(height: PosterSet.listSize(data: data, screenWidth: self.sceneObserver.screenSize.width).height)
                    .modifier(ListRowInset( spacing: Dimen.margin.thin))
                }
            } else {
                Spacer().modifier(MatchParent())
            }
        }
    }//body
}
