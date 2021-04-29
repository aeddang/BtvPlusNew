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
    var data: BlockData
    
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            HStack(alignment: .bottom, spacing:Dimen.margin.thin){
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
                            PageProvider.getPageObject(data.dataType == .watched ? .watchedList : .categoryList)
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
                VStack(alignment: .leading, spacing:Dimen.margin.tiny){
                    ForEach(self.datas) { data in
                        VideoSet(
                            pageObservable:self.pageObservable,
                            data:data ,
                            paddingHorizontal: SystemEnvironment.isTablet ? Dimen.margin.heavy : Dimen.margin.thin,
                            spacing: Dimen.margin.tiny
                            )
                    }
                }
            } else {
                EmptyAlert( text: self.data.dataType != .watched
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
        datas = []
        guard let videos = data.videos else {return}
        let count:Int = self.sceneObserver.sceneOrientation == .portrait ? 3 : 4
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
