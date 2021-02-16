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
    private(set) var progress:Float? = nil
    private(set) var synopsisData:SynopsisData? = nil
    private(set) var epsdId:String? = nil
    private(set) var isInside:Bool = false
    
    func setData(data:ContentItem, cardType:Block.CardType = .video, idx:Int = -1) -> VideoData {
        setCardType(cardType)
        title = data.title
        if let thumb = data.poster_filename_h {
            image = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.video.size)
        }
        index = idx
        
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: "", prdPrcId: data.prd_prc_id ,kidZone:data.kids_yn)
        
        return self
    }
    
    func setData(data:BookMarkItem, cardType:Block.CardType = .video, idx:Int = -1) -> VideoData {
        setCardType(cardType)
        title = data.title
        if let thumb = data.poster {
            image = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.video.size)
        }
        index = idx
        
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",  kidZone:data.yn_kzone)
        return self
    }
    
    func setData(data:WatchItem, cardType:Block.CardType = .video, idx:Int = -1) -> VideoData {
        setCardType(cardType)
        if let rt = data.watch_rt?.toInt() {
            self.progress = Float(rt) / 100.0
        }
        title = data.title
        if let thumb = data.thumbnail {
            image = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.video.size)
        }
        index = idx
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",  kidZone:nil)
        return self
    }
    
    func setData(data:SeriesInfoItem, title:String? = nil, idx:Int = -1) -> VideoData {
        if let thumb = data.poster_filename_h {
            image = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.video.size)
        }
        self.title = title
        if let count = data.brcast_tseq_nm {
            self.title = count + String.app.broCount + " " + (self.title ?? "")
        }
        index = idx
        epsdId = data.epsd_id
        isInside = true
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
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    
    var datas:[VideoData]
    var contentID:String? = nil
    var margin:CGFloat = Dimen.margin.thin
    var action: ((_ data:VideoData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin,
            spacing: Dimen.margin.tiny
        ){
            ForEach(self.datas) { data in
                if data.index == -1 {
                    VideoItem( data:data , isSelected: self.contentID == nil
                                ? false
                                : self.contentID == data.epsdId)
                    .onTapGesture {
                        if let action = self.action {
                            action(data)
                        }else{
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.synopsis)
                                    .addParam(key: .data, value: data.synopsisData)
                            )
                        }
                        
                    }
                }else{
                    VideoItem( data:data , isSelected: self.contentID == nil
                                ? false
                                : self.contentID == data.epsdId)
                        .id(data.index)
                    .onTapGesture {
                        if let action = self.action {
                            action(data)
                        }else{
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.synopsis)
                                    .addParam(key: .data, value: data.synopsisData)
                            )
                        }
                        
                    }
                }
                
            }
        }
        
    }//body
}

struct VideoItem: PageView {
    var data:VideoData
    var isSelected:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            ZStack{
                ImageView(url: self.data.image, contentMode: .fill, noImg: Asset.noImg16_9)
                    .modifier(MatchParent())
                if self.data.isInside {
                    Spacer().modifier(MatchParent()).background(
                        self.isSelected ? Color.transparent.black45 : Color.transparent.black70)
                }
                if self.data.progress != nil || self.isSelected {
                    Image(Asset.icon.thumbPlay)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regularExtra, height: Dimen.icon.regularExtra)
                }
                VStack(alignment: .leading, spacing:0){
                    HStack(spacing:0){}
                    Spacer().modifier(MatchParent())
                    if self.data.title != nil && self.data.isInside {
                        VStack(alignment: .center, spacing:0){
                            Spacer().modifier(MatchHorizontal(height: 0))
                            Text(self.data.title!)
                                .modifier(MediumTextStyle(size: Font.size.thinExtra))
                                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, Dimen.margin.thinExtra)
                                .lineLimit(1)
                        }
                    }
                    if self.data.progress != nil {
                        Spacer().frame(
                            width: ListItem.video.size.width * CGFloat(self.data.progress!),
                            height: Dimen.line.regular)
                            .background(Color.brand.primary)
                    }
                }
                
            }
            .frame(
                width: ListItem.video.size.width,
                height: ListItem.video.size.height)
            .clipped()
            if self.data.title != nil && !self.data.isInside {
                Text(self.data.title!)
                    .modifier(MediumTextStyle(size: Font.size.thinExtra))
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, Dimen.margin.thin)
                    
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(width: ListItem.video.size.width)
        .background(Color.app.blueLight)
        
    }
    
}

#if DEBUG
struct VideoList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            VideoList( datas: [
                VideoData().setDummy(0),
                VideoData().setDummyWatching(),
                VideoData().setDummy(),
                VideoData().setDummy()
            ])
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif

