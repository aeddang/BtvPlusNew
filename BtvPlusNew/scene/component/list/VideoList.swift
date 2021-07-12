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
  
    private(set) var isClip:Bool = false
    private(set) var tagData: TagData? = nil
    private(set) var playTime:String? = nil
    private(set) var pageType:PageType = .btv
    init(pageType:PageType = .btv) {
        self.pageType = pageType
        super.init()
    }
    
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
        if let rt = data.kes?.watching_progress?.toInt() {
            self.progress = Float(rt) / 100.0 
        }
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
            if self.pageType == .kids {
                return 0
            }
            if (self.title != nil && self.subTitle != nil) || self.isClip {
                return ListItem.video.type02
            } else {
                return ListItem.video.type01
            }
        }
    }
    
    
    
    private func setCardType(_ cardType:BlockData.CardType){
        if self.pageType == .kids {
            switch cardType {
            case .watchedVideo: type = .watchingKids
            default: type = .kids
            }
            return
        } else {
            switch cardType {
            case .watchedVideo: type = .watching
            default: type = .nomal
            }
        }
        
    }
    
    var moveSynopsis:PageObject
    {
        get {
            if self.pageType == .btv {
                return PageProvider.getPageObject(
                    self.synopsisType == .package
                        ? .synopsisPackage
                        : self.isClip ? .synopsisPlayer : .synopsis)
            } else {
                return PageKidsProvider.getPageObject(
                    self.synopsisType == .package
                        ? .kidsSynopsisPackage
                        : self.isClip ? .synopsisPlayer : .kidsSynopsis)
            }
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
    case nomal, watching, cell(CGSize, CGFloat), kids, watchingKids
    var size:CGSize {
        get{
            switch self {
            case .nomal: return ListItem.video.size
            case .watching: return ListItem.video.size
            case .kids: return ListItemKids.video.type01
            case .watchingKids: return ListItemKids.video.type01
            case .cell(let size, _ ): return size
            }
        }
    }
    var bgColor:Color {
        get{
            switch self {
            case .kids, .watchingKids: return Color.app.white
            default : return Color.app.blueLight
            }
        }
    }
    var radius:CGFloat {
        get{
            switch self {
            case .kids, .watchingKids: return DimenKids.radius.light
            default : return 0
            }
        }
    }
    
}
extension VideoList{
    static let spacing:CGFloat = Dimen.margin.tiny
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
            spacing: Self.spacing,
            isRecycle: true,
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
                                data.moveSynopsis
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
                                data.moveSynopsis
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
    static func listSize(data:VideoDataSet, screenWidth:CGFloat, isFull:Bool = false,
                         paddingHorizontal:CGFloat? = nil , spacing:CGFloat? = nil) -> CGSize{
        let datas = data.datas
        let dataCell = datas.first ?? VideoData()
        let ratio = dataCell.type.size.height / dataCell.type.size.width
        let count = CGFloat(data.count)
        let w = screenWidth - ( (paddingHorizontal ?? padding) * 2)
        let cellW = ( w - ( (spacing ?? padding) * (count-1)) ) / count
        var cellH = round(cellW * ratio)
        
        if isFull{
            cellH = cellH + dataCell.bottomHeight
        }
        return CGSize(width: cellW, height: cellH )
    }
    
}

struct VideoSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var pageObservable:PageObservable = PageObservable()
    var data:VideoDataSet
    var paddingHorizontal:CGFloat? = nil
    var spacing:CGFloat? = nil
    @State var cellDatas:[VideoData] = []
    @State var isUiActive:Bool = true
    var body: some View {
        HStack(spacing: (self.spacing ?? Self.padding) ){
            if self.isUiActive {
                ForEach(self.cellDatas) { data in
                    VideoItem( data:data )
                    .onTapGesture {
                        guard let synopsisData = data.synopsisData else { return }
                        self.pagePresenter.openPopup(
                            data.moveSynopsis
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
        .padding(.horizontal, self.paddingHorizontal ?? Self.padding)
        .frame(width: self.sceneObserver.screenSize.width)
        .onAppear {
            if self.data.datas.isEmpty { return }
            let size = Self.listSize(data: self.data, screenWidth: sceneObserver.screenSize.width, isFull: false, paddingHorizontal: self.paddingHorizontal, spacing: self.spacing)
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
            if self.data.pageType == .btv {
                VideoItemBody( data: self.data, isSelected: self.isSelected)
            } else {
                VideoItemBodyKids( data: self.data, isSelected: self.isSelected)
            }
        }
        .background(self.data.type.bgColor)
        .clipShape(RoundedRectangle(cornerRadius:  self.data.type.radius))
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

struct VideoItemBody: PageView {
    @EnvironmentObject var repository:Repository
    var data:VideoData
    var isSelected:Bool = false
    var body: some View {
        ZStack{
            ImageView(url: self.data.image,contentMode: .fill, noImg: Asset.noImg16_9)
                .modifier(MatchParent())
             
            if (self.data.progress != nil || self.isSelected) && self.data.tagData?.isLock != true {
                Image(Asset.icon.thumbPlay)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regularExtra, height: Dimen.icon.regularExtra)
            }
            VStack(alignment: .leading, spacing:0){
                if let tag = self.data.tagData {
                    Tag(data: tag).modifier(MatchParent())
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
                if self.data.progress != nil {
                    Spacer().frame(
                        width: self.data.type.size.width * CGFloat(self.data.progress!),
                        height: Dimen.line.regular)
                        .background(Color.brand.primary)
                }
            }
            
        }
        .frame(
            width: self.data.type.size.width,
            height: self.data.type.size.height)
        
        if self.data.title != nil {
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
            .frame(
                width: self.data.type.size.width,
                height:self.data.bottomHeight)
        }
    }
    
}
extension VideoItemBodyKids {
    static let bottomHeight:CGFloat = SystemEnvironment.isTablet ? 68 : 38
}

struct VideoItemBodyKids: PageView {
    @EnvironmentObject var repository:Repository
    var data:VideoData
    var isSelected:Bool = false
    var body: some View {
        VStack(spacing:0){
            ZStack{
                ImageView(url: self.data.image,contentMode: .fill, noImg: Asset.noImg16_9)
                    .modifier(MatchParent())
                 
                if (self.data.progress != nil || self.isSelected) && self.data.tagData?.isLock != true {
                    Image(AssetKids.icon.thumbPlayVideo)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: DimenKids.icon.regular, height: DimenKids.icon.regular)
                }
                VStack(alignment: .leading, spacing:0){
                    if let tag = self.data.tagData {
                        TagKids(data: tag).modifier(MatchParent())
                    }else {
                        Spacer().modifier(MatchParent())
                    }
                    if self.data.progress != nil {
                        Spacer().frame(
                            width: (self.data.type.size.width + (DimenKids.margin.thinExtra*2)) * CGFloat(self.data.progress!),
                            height: DimenKids.line.medium)
                            .background(Color.kids.primary)
                    }
                }
            }
            .modifier(MatchParent())
            .clipShape(RoundedRectangle(cornerRadius:  DimenKids.radius.light))
            .padding(.top, DimenKids.margin.thinExtra)
            .padding(.horizontal, DimenKids.margin.thinExtra)
            
            if self.data.title != nil {
                VStack(alignment: .leading, spacing:Dimen.margin.tiny){
                    if let title = self.data.title {
                        Text(title)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color:Color.app.brownDeep))
                            .lineLimit(self.data.isClip ? 2 : 1)
                    }
                    if let subTitle = self.data.subTitle {
                        Text(subTitle)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.tinyExtra, color:Color.app.brownDeep.opacity(0.7)))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, DimenKids.margin.thin)
                .frame(height:Self.bottomHeight)
            }
        }
        .frame(
            width: self.data.type.size.width,
            height: self.data.type.size.height)
        
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

