//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class VideoData:InfinityData{
    private(set) var image: String = Asset.noImg16_9
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var count: String = "0"
    private(set) var type:VideoType = .nomal
    
    
    func setData(data:ContentItem, cardType:Block.CardType = .video, idx:Int = -1) -> VideoData {
        setCardType(cardType)
        title = data.title
        if let thumb = data.poster_filename_h {
            image = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.thumb.size)
        }
        index = idx
        return self
    }
    
    func setData(data:BookMarkItem, cardType:Block.CardType = .video, idx:Int = -1) -> VideoData {
        setCardType(cardType)
        title = data.title
        if let thumb = data.poster {
            image = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.thumb.size)
        }
        index = idx
        return self
    }
    
    
    private func setCardType(_ cardType:Block.CardType){
        switch cardType {
        case .watchedVideo: type = .watching
        default: type = .nomal
        }
    }
    
    
    func setDummy(_ idx:Int = -1) -> VideoData {
        title = "[Q&A] 이민?레나채널 삭제 안하는 이유?외국인남친?"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        return self
    }
    func setDummyWatching(_ idx:Int = -1) -> VideoData {
        title = "[Q&A] 이민?레나채널 삭제 안하는 이유?외국인남친?"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        type = .watching
        return self
    }
}

enum VideoType {
    case nomal, watching
}



struct VideoList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    @Binding var datas:[VideoData]
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: Dimen.margin.thin,
            spacing: Dimen.margin.tiny
        ){
            ForEach(self.datas) { data in
                VideoItem( data:data )
                .onTapGesture {
                   
                }
            }
        }
    }//body
}

struct VideoItem: PageView {
    var data:VideoData
    var body: some View {
        VStack(spacing:0){
            ZStack{
                ImageView(url: self.data.image, contentMode: .fit, noImg: Asset.noImg16_9)
                    .modifier(MatchParent())
                if self.data.subTitle != nil {
                    Text(self.data.subTitle!)
                        .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.grey))
                }
            }
            .frame(
                width: ListItem.thumb.size.width,
                height: ListItem.thumb.size.height)
            .clipped()
            if self.data.title != nil {
                Text(self.data.title!)
                    .modifier(MediumTextStyle(size: Font.size.medium))
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, Dimen.margin.thin)
                    .frame(width: ListItem.thumb.size.width)
            }
        }
        .background(Color.app.blueLight)
        
    }
    
}

#if DEBUG
struct VideoList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            VideoList( datas: .constant([
                VideoData().setDummy(0),
                VideoData().setDummyWatching(),
                VideoData().setDummy(),
                VideoData().setDummy()
            ]))
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif

