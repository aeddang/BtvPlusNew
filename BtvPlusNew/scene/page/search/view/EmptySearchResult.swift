//
//  EmptySerchList.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation
import SwiftUI

struct EmptySearchResult: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var keyword:String? = nil
    var datas:[PosterDataSet] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            if let keyword = self.keyword {
                VStack(alignment: .leading, spacing:0){
                    Text(keyword + String.pageText.searchEmpty)
                        .modifier(MediumTextStyle(size: Font.size.mediumExtra) )
                        .multilineTextAlignment(.leading)
                    Text( String.pageText.searchEmptyGuide)
                        .modifier(LightTextStyle(size: Font.size.thinExtra, color:Color.brand.primary) )
                        .padding(.top, Dimen.margin.thin)
                }
                .padding(.vertical, Dimen.margin.regular)
                .modifier(ContentHorizontalEdges())
                .background(PageStyle.dark.bgColor)
            }
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
                Text(String.pageText.searchEmptyTitle)
                    .modifier(BlockTitle())
                    .modifier(ListRowInset(marginHorizontal: Dimen.margin.thin, spacing: Dimen.margin.thin))
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
            .background(Color.brand.bg)
        }
    }//body
}
