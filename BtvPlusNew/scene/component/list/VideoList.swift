//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class VideoData:InfinityData{
    private(set) var image: String? = nil
    private(set) var originImage: String? = nil
    private(set) var title: String? = nil
    private(set) var watchLv:Int = 0
    private(set) var isAdult:Bool = false
    private(set) var subTitle: String? = nil
    private(set) var count: String = "0"
    private(set) var type:VideoType = .nomal
    private(set) var progress:Float? = nil
    private(set) var synopsisType:SynopsisType = .title
    private(set) var synopsisData:SynopsisData? = nil
    private(set) var epsdId:String? = nil
    private(set) var srisId:String? = nil
    private(set) var isInside:Bool = false
    private(set) var isClip:Bool = false
    private(set) var tagData: TagData? = nil
    private(set) var playTime:String? = nil
    func setData(data:ContentItem, cardType:BlockData.CardType = .video, idx:Int = -1) -> VideoData {
        setCardType(cardType)
        if let typeCd = data.svc_typ_cd {
            isClip = typeCd == "38"
        } else {
            isClip = cardType == .clip
        }
        title = data.title
        watchLv = data.wat_lvl_cd?.toInt() ?? 0
        isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
        originImage = data.poster_filename_h
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_h, size: ListItem.video.size, isAdult: self.isAdult)
        
        if self.isClip {
            playTime = data.play_tms_hms?.toHMS()
        } else {
            tagData = TagData().setData(data: data, isAdult: self.isAdult)
        }
        
        index = idx
        epsdId = data.epsd_id
        srisId = data.sris_id
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: "", prdPrcId: data.prd_prc_id ,kidZone:data.kids_yn)
        
        return self
    }
    
    func setData(data:PackageContentsItem, prdPrcId:String, cardType:BlockData.CardType = .video ,idx:Int = -1) -> VideoData {
        setCardType(cardType)
        isClip = cardType == .clip
        title = data.title
        watchLv = data.wat_lvl_cd?.toInt() ?? 0
        isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        originImage = data.poster_filename_v
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_v, size: ListItem.video.size, isAdult: self.isAdult)
        
        index = idx
        epsdId = data.epsd_id
        srisId = data.sris_id
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: "", prdPrcId: prdPrcId , kidZone:nil)
        
        return self
    }
    
    func setData(data:BookMarkItem, cardType:BlockData.CardType = .video, idx:Int = -1) -> VideoData {
        setCardType(cardType)
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        title = data.title
        watchLv = data.level?.toInt() ?? 0
        isAdult = data.adult?.toBool() ?? false
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
       
        originImage = data.poster
        image = ImagePath.thumbImagePath(filePath: data.poster, size: ListItem.video.size, isAdult: self.isAdult)
      
        index = idx
        epsdId = data.epsd_id
        srisId = data.sris_id
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",  kidZone:data.yn_kzone)
        return self
    }
    
    func setData(data:WatchItem, cardType:BlockData.CardType = .video, idx:Int = -1) -> VideoData {
        setCardType(cardType)
        isClip = cardType == .clip
        watchLv = data.level?.toInt() ?? 0
        isAdult = data.adult?.toBool() ?? false
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        if let rt = data.watch_rt?.toInt() {
            self.progress = Float(rt) / 100.0
        }
        title = data.title
        originImage = data.thumbnail
        image = ImagePath.thumbImagePath(filePath: data.thumbnail , size: ListItem.video.size, isAdult: self.isAdult)
      
        
        index = idx
        epsdId = data.epsd_id
        srisId = data.sris_id
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",  kidZone:nil)
        return self
    }
    
    func setData(data:SeriesInfoItem, title:String? = nil, idx:Int = -1) -> VideoData {
        self.title = title
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        if let count = data.brcast_tseq_nm {
            self.title = count + String.app.broCount + " " + (self.title ?? "")
        }
        
        originImage = data.poster_filename_h
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_h, size: ListItem.video.size, isAdult: self.isAdult)
      
        index = idx
        epsdId = data.epsd_id
        isInside = true
        return self
    }
    
    func setData(data:CategorySrisItem, idx:Int = -1) -> VideoData {
    
        title = data.title
        subTitle = data.title_sub
        index = idx
        epsdId = data.epsd_id
        watchLv = data.level?.toInt() ?? 0
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        
        originImage = data.poster_tseq
        image = ImagePath.thumbImagePath(filePath: data.poster_tseq, size: ListItem.video.size, isAdult: self.isAdult)
    
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        synopsisData = .init(
            srisId: nil, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",  kidZone:nil)
        return self
    }
    
    func setData(data:CategoryCornerItem, idx:Int = -1) -> VideoData {
        self.title = data.title
        index = idx
        epsdId = data.epsd_id
        watchLv = data.level?.toInt() ?? 0
        originImage = data.thumb
        image = ImagePath.thumbImagePath(filePath: data.thumb, size: ListItem.video.size, isAdult: self.isAdult)
      
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        synopsisData = .init(
            srisId: nil, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",  kidZone:nil)
        return self
    }
    
    var bottomHeight:CGFloat {
        get{
            if (self.title != nil && self.subTitle != nil) || self.isClip {
                return ListItem.video.type02
            } else {
                return ListItem.video.type01
            }
        }
    }
    
    private func setCardType(_ cardType:BlockData.CardType){
        switch cardType {
        case .watchedVideo: type = .watching
        default: type = .nomal
        }
    }
    
    fileprivate func updatedImage(){
        image = ImagePath.thumbImagePath(filePath: self.originImage, size: type.size, isAdult: self.isAdult)
    }
    
    fileprivate func setCardType(width:CGFloat, height:CGFloat, padding:CGFloat) -> VideoData {
        self.type = .cell(CGSize(width: width, height: height), padding)
        return self
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
    case nomal, watching, cell(CGSize, CGFloat)
    var size:CGSize {
        get{
            switch self {
            case .nomal: return ListItem.video.size
            case .watching: return ListItem.video.size
            case .cell(let size, _ ): return size
            }
        }
    }
}

struct VideoList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var banners:[BannerData]? = nil
    var datas:[VideoData]
    var contentID:String? = nil
    var margin:CGFloat = Dimen.margin.thin
    var useTracking:Bool = false
    var action: ((_ data:VideoData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin,
            spacing: Dimen.margin.tiny,
            isRecycle: self.banners?.isEmpty == false ? false : true,
            useTracking: self.useTracking
        ){
            if let banners = self.banners {
                ForEach(banners) { data in
                    BannerItem(data: data)
                }
            }
            ForEach(self.datas) { data in
                if data.index == -1 {
                    VideoItem( data:data , isSelected: self.contentID == nil
                                ? false
                                : self.contentID == data.epsdId)
                    .onTapGesture {
                        if let action = self.action {
                            action(data)
                        }else{
                            guard let synopsisData = data.synopsisData else { return }
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(
                                    data.synopsisType == .package
                                        ? .synopsisPackage
                                        : data.isClip ? .synopsisPlayer : .synopsis)
                                    .addParam(key: .data, value: synopsisData)
                                    .addParam(key: .watchLv, value: data.watchLv)
                            )
                        }
                    }
                } else {
                    VideoItem( data:data , isSelected: self.contentID == nil
                                ? false
                                : self.contentID == data.epsdId)
                    .id(data.index)
                    .onTapGesture {
                        if let action = self.action {
                            action(data)
                        }else{
                            guard let synopsisData = data.synopsisData else { return }
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(
                                    data.synopsisType == .package
                                        ? .synopsisPackage
                                        : data.isClip ? .synopsisPlayer : .synopsis)
                                    .addParam(key: .data, value: synopsisData)
                                    .addParam(key: .watchLv, value: data.watchLv)
                            )
                        }
                    }
                }
            }
        }
        
        
    }//body
}

struct VideoDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 2
    var datas:[VideoData] = []
    var isFull = false
    var index:Int = -1
}

extension VideoSet{
    static let padding:CGFloat = Dimen.margin.thin
    static func listSize(data:VideoDataSet, screenWidth:CGFloat, isFull:Bool = false) -> CGSize{
        let datas = data.datas
        let ratio = ListItem.video.size.height / ListItem.video.size.width
        let count = CGFloat(data.count)
        let w = screenWidth - ( padding * 2)
        let cellW = ( w - (padding*(count-1)) ) / count
        var cellH = round(cellW * ratio)
        
        if datas.first?.isInside == false && isFull{
            cellH = cellH + datas.first!.bottomHeight
        }
        return CGSize(width: cellW, height: cellH )
    }
}

struct VideoSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var pageObservable:PageObservable = PageObservable()
    var data:VideoDataSet
    
    @State var cellDatas:[VideoData] = []
    @State var isUiActive:Bool = true
    var body: some View {
        HStack(spacing: Self.padding){
            if self.isUiActive {
                ForEach(self.cellDatas) { data in
                    VideoItem( data:data )
                    .onTapGesture {
                        guard let synopsisData = data.synopsisData else { return }
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(
                                data.synopsisType == .package
                                    ? .synopsisPackage
                                    : data.isClip ? .synopsisPlayer : .synopsis)
                                .addParam(key: .data, value: synopsisData)
                                .addParam(key: .watchLv, value: data.watchLv)
                        )
                    }
                }
                if !self.data.isFull && self.data.count > 1{
                    Spacer()
                }
            }
        }
        .padding(.horizontal, Self.padding)
        .frame(width: self.sceneObserver.screenSize.width)
        .onAppear {
            if self.data.datas.isEmpty { return }
            let size = Self.listSize(data: self.data, screenWidth: sceneObserver.screenSize.width)
            self.cellDatas = self.data.datas.map{
                $0.setCardType(width: size.width, height: size.height, padding: Self.padding)
            }
        }
        .onReceive(self.pageObservable.$layer ){ layer  in
            switch layer {
            case .bottom : self.isUiActive = false
            case .top, .below : self.isUiActive = true
            }
        }
    }//body
}


struct VideoItem: PageView {
    @EnvironmentObject var repository:Repository
    var data:VideoData
    var isSelected:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            ZStack{
                ImageView(url: self.data.image,contentMode: .fill, noImg: Asset.noImg16_9)
                    .modifier(MatchParent())
                if self.data.isInside {
                    Spacer().modifier(MatchParent()).background(
                        self.isSelected ? Color.transparent.black45 : Color.transparent.black70)
                }
                if (self.data.progress != nil || self.isSelected) && self.data.tagData?.isLock != true {
                    Image(Asset.icon.thumbPlay)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regularExtra, height: Dimen.icon.regularExtra)
                }
                VStack(alignment: .leading, spacing:0){
                    if let tag = self.data.tagData {
                        Tag(data: tag)
                            .modifier(MatchParent())
                    }else if let time = self.data.playTime {
                        ZStack(alignment:.bottomTrailing){
                            Spacer().modifier(MatchParent())
                            Text(time)
                                .modifier(BoldTextStyle(size: Font.size.tiny))
                                .lineLimit(1)
                                .padding(.all, Dimen.margin.micro)
                                .background(Color.transparent.black70)
                                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                                .padding(.all, Dimen.margin.tinyExtra)
                        }
                        .modifier(MatchParent())
                    } else {
                        Spacer().modifier(MatchParent())
                    }
                   
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
                width: self.data.type.size.width,
                height: self.data.type.size.height)
            .clipped()
            if self.data.title != nil && !self.data.isInside {
                VStack(alignment: .leading, spacing:Dimen.margin.tiny){
                    if let title = self.data.title {
                        Text(title)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra))
                            .lineLimit(self.data.isClip ? 2 : 1)
                    }
                    if let subTitle = self.data.subTitle {
                        Text(subTitle)
                            .modifier(MediumTextStyle(size: Font.size.tiny, color:Color.app.grey))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, Dimen.margin.thin)
                .frame(height:self.data.bottomHeight)
            }
        }
        .frame(width: self.data.type.size.width)
        .background(Color.app.blueLight)
        .onReceive(self.repository.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedWatchLv : self.data.updatedImage()
            default : break
            }
        }
        .onAppear(){
        }
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

