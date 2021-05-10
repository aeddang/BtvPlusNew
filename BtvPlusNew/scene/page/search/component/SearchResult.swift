//
//  EmptySerchList.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation
import SwiftUI

struct SearchResult: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageObservable:PageObservable
    var pageDragingModel:PageDragingModel
    var total:Int = 0
    var keyword:String? = nil
    var datas:[BlockData] = []
    var useTracking:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            if let keyword = self.keyword {
                VStack(alignment: .leading, spacing:0){
                    Text(keyword + String.pageText.searchResult.replace(total.description))
                        .modifier(MediumTextStyle(size: Font.size.mediumExtra) )
                        .multilineTextAlignment(.leading)

                }
                .padding(.vertical, Dimen.margin.regular)
                .modifier(ContentHorizontalEdges())
                .background(PageStyle.dark.bgColor)
            }
            MultiBlock(
                viewModel: self.viewModel,
                pageObservable: self.pageObservable,
                pageDragingModel: self.pageDragingModel,
                datas: self.datas,
                useTracking:self.useTracking,
                marginTop:Dimen.margin.regular,
                marginBottom: Dimen.app.bottom,
                isRecycle:true,
                isLegacy:false
                )
            .background(Color.brand.bg)
        }
    }//body
}
