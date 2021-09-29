//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

struct VideoSetBlock:BlockProtocol, PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver

    var pageObservable:PageObservable
    var geometry:GeometryProxy
    var data: BlockData
    var limitedLine: Int? = nil
    var isMyWatch:Bool = false
    var margin:CGFloat = Dimen.margin.heavy - VideoSet.listPadding
    var body :some View {
        
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            HStack(alignment: .center, spacing:0){
                VStack(alignment: .leading, spacing:0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    HStack( spacing:Dimen.margin.thin){
                        Text(data.name).modifier(BlockTitle())
                            .lineLimit(1)
                        Text(data.subName).modifier(BlockTitle(color:Color.app.grey))
                            .lineLimit(1)
                    }
                }
                if self.hasMore {
                    TextButton(
                        defaultText: String.button.all,
                        textModifier: MediumTextStyle(size: Font.size.thin, color: Color.app.white).textModifier
                    ){_ in
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(self.isMyWatch
                                                       ? .myWatchedList
                                                       : data.dataType == .watched ? .watchedList : .categoryList)
                                .addParam(key: .data, value: data)
                                .addParam(key: .type, value: CateBlock.ListType.video)
                                .addParam(key: .subType, value:data.cardType)
                        )
                    }
                }
            }
            .modifier(MatchHorizontal(height: Dimen.tab.thin))
            .modifier(ContentHorizontalEdgesTablet())
            if !self.datas.isEmpty {
                VStack(alignment: .center, spacing:VideoSet.listPadding){
                    ForEach(self.datas) { data in
                        VideoSet(
                            pageObservable:self.pageObservable,
                            data:data,
                            screenSize : geometry.size.width
                                - (SystemEnvironment.isTablet ? (margin * 2) : 0)
                        )
                    }
                    
                }
                .padding(.horizontal, SystemEnvironment.isTablet ? margin : 0)
            } else {
                EmptyAlert( text: self.data.dataType == .watched
                            ? String.pageText.myWatchedEmpty
                            : String.alert.dataError)
                    .modifier(MatchParent())
            }
        }
        .onReceive(self.sceneObserver.$isUpdated){ update in
            if !update {return}
            self.setVideoSets()
        }
        .onAppear{
            if data.allVideos?.isEmpty == true {
                self.hasMore = false
            }
            self.setVideoSets()
        }
    }
    
    @State var datas:[VideoDataSet] = []
    @State var hasMore:Bool = true
    func setVideoSets() {
        self.datas = []
        guard let originVideos = data.videos else {return}
        if originVideos.isEmpty {return}
        let count:Int = 3
        let max = originVideos.count
        var videos:ArraySlice<VideoData> = []
        if let limitedLine = self.limitedLine {
            let len = min(max,  (limitedLine*count) ) - 1
            videos = originVideos[0...len]
        } else {
            videos = originVideos[0...max]
        }
        var rows:[VideoDataSet] = []
        var cells:[VideoData] = []
        var total = videos.count
        videos.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    VideoDataSet( count: count, datas: cells, isFull: true, index: total)
                )
                cells = [d]
                total += 1
            }
        }
        if !cells.isEmpty {
            rows.append(
                VideoDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        self.datas.append(contentsOf: rows)
    }
    
}
