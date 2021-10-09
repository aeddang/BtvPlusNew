//
//  EmptySerchList.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation
import SwiftUI

struct SearchResultKids: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    
    var viewModel: MultiBlockModel = MultiBlockModel(pageType:.kids, logType:.list)
    var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    var pageObservable:PageObservable
    var pageDragingModel:PageDragingModel
    var datas:[BlockData] = []
    var useTracking:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            MultiBlock(
                viewModel: self.viewModel,
                infinityScrollModel: self.infinityScrollModel,
                pageObservable: self.pageObservable,
                pageDragingModel: self.pageDragingModel,
                datas: self.datas,
                useTracking:self.useTracking,
                marginTop:DimenKids.margin.regular,
                marginBottom: sceneObserver.safeAreaIgnoreKeyboardBottom + DimenKids.margin.thin,
                isRecycle:true
                )
        }
    }//body
}
