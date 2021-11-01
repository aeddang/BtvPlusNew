//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class VideoData:InfinityData, Copying{
    private(set) var image: String? = nil
    private(set) var originImage: String? = nil
    private(set) var title: String? = nil
    private(set) var watchLv:Int = 0
    private(set) var isAdult:Bool = false
    private(set) var isContinueWatch:Bool = false
    private(set) var subTitle: String? = nil
    private(set) var clipTitle: String? = nil
    private(set) var count: String? = nil
    private(set) var type:VideoType = .nomal
    private(set) var progress:Float? = nil
    private(set) var synopsisType:SynopsisType = .title
    private(set) var synopsisData:SynopsisData? = nil
    private(set) var epsdId:String? = nil
    private(set) var srisId:String? = nil
    private(set) var prodId:String? = nil
    private(set) var isClip:Bool = false
    private(set) var isSearch:Bool = false
    private(set) var usePrice:Bool = true
    private(set) var useAge:Bool = true
    private(set) var tagData: TagData? = nil
    private(set) var playTime:String? = nil
    private(set) var pageType:PageType = .btv
    private(set) var isWatched:Bool = false
    
    private(set) var contentLog:MenuNaviContentsBodyItem? = nil
    private(set) var actionLog:MenuNaviActionBodyItem? = nil
      
    var logPage:NaviLog.PageId = .empty
    var logAction:NaviLog.Action? = nil
    
    required init(original: VideoData) {
        image = original.image
        originImage = original.originImage
        title = original.title
        subTitle = original.subTitle
        clipTitle = original.clipTitle
        count = original.count
        type = original.type
        progress = original.progress
        synopsisType = original.synopsisType
        synopsisData = original.synopsisData
        epsdId = original.epsdId
        srisId = original.srisId
        prodId = original.prodId
        isClip = original.isClip
        usePrice = original.usePrice
        useAge = original.useAge
        tagData = original.tagData
        playTime = original.playTime
        pageType = original.pageType
        isWatched = original.isWatched
        isSearch = original.isSearch
        actionLog = original.actionLog
        contentLog = original.contentLog
    
        logPage = original.logPage
        logAction = original.logAction
    }
    
    var hasLog:Bool { get{ return logAction != nil || actionLog != nil || contentLog != nil } }
   
    var fullTitle:String? {
        get{
            guard let title = self.title else {return nil}
            if let count = self.count {
                if count.isEmpty {return title}
                return count + String.app.broCount + " " + title
            } else {
                return title
            }
            
        }
    }
    
    init(pageType:PageType = .btv, usePrice:Bool = true) {
        self.pageType = pageType
        self.usePrice = usePrice
        super.init()
    }
    @discardableResult
    func setNaviLog(action:MenuNaviActionBodyItem?) -> VideoData  {
        logAction = .clickContentsList
        self.actionLog = action
        return self
    }
    
    @discardableResult
    func setNaviLogHome(action:MenuNaviActionBodyItem?) -> VideoData  {
        logAction = .clickContentsView
        self.actionLog = action
        return self
    }
    
    @discardableResult
    func setNaviLogKids(action:MenuNaviActionBodyItem?) -> VideoData  {
        logAction = .clickContentsButton
        self.actionLog = action
        return self
    }
   
    func setData(data:ContentItem, cardType:BlockData.CardType = .video, idx:Int = -1) -> VideoData {
        setCardType(cardType)
        if let typeCd = data.svc_typ_cd {
            isClip = typeCd == "38"
        } else {
            isClip = cardType == .clip
        }
        if isClip {
            clipTitle = data.keywrd_val
        }
        count = data.brcast_tseq_nm
        if pageType == .kids { //같은타입인데 키즈랑 비티비 내려오는 데이타가 다름 그럴수도 있다.. 흔한일이다
            let count = data.brcast_tseq_nm?.isEmpty == false
            ? (data.brcast_tseq_nm ?? "") + String.app.broCount + " "
            : ""
            if data.episode_title?.isEmpty == false, let epsdTitle = data.episode_title {
                title = data.title
                subTitle = count + epsdTitle
            } else {
                title = count + (data.title ?? "")
            }
        } else {
            title = data.title
        }
        if cardType == .watchedVideo {
            self.usePrice = false
            self.isWatched = true
            if let rt = data.kes?.watching_progress?.toDouble() {
                self.progress = Float(rt) / 100.0
            } else {
                self.progress = 0
            }
           
        }
        originImage = data.poster_filename_h
        image = ImagePath.thumbImagePath(
            filePath: data.poster_filename_h,
            size: CGSize(width: ListItem.video.size.width, height: 0),
            isAdult: self.isAdult)
        /*
        if let rt = data.kes?.watching_progress?.toInt() {
            self.progress = Float(rt) / 100.0 
        }
        */
        if self.isClip {
            playTime = data.play_tms_hms?.toHMS()
        } else {
            watchLv = data.wat_lvl_cd?.toInt() ?? 0
            isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
            tagData = TagData(pageType: self.pageType).setData(
                data: data, isAdult: self.isAdult,  useCaptionFlag:self.isWatched)
        }
        
        index = idx
        epsdId = data.epsd_id
        srisId = data.sris_id
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.prd,
            epsdId: data.epsd_id, epsdRsluId: "", prdPrcId: data.prd_prc_id ,
            kidZone:data.kids_yn, progress:self.progress,
            synopType: synopsisType, isDemand: data.svc_typ_cd == "12")
        
        return self.setNaviLog(data: data)
    }
    
    func setNaviLog(data:ContentItem) -> VideoData {
        self.contentLog = MenuNaviContentsBodyItem(
            type: "vod",
            title: self.title,
            channel_name: nil,
            genre_text: nil,
            genre_code: data.meta_typ_cd,
            paid: self.tagData?.isFree,
            purchase: nil,
            episode_id: self.epsdId,
            episode_resolution_id: self.synopsisData?.epsdRsluId,
            product_id: data.prd_prc_id,
            purchase_type: nil,
            monthly_pay: nil,
            list_price: data.prd_prc?.number?.description ?? nil,
            payment_price: nil
        )
        return self
    }
    
    
    func setData(data:PackageContentsItem, prdPrcId:String, cardType:BlockData.CardType = .video ,idx:Int = -1) -> VideoData {
        setCardType(cardType)
        isClip = cardType == .clip
        title = data.title
        if !isClip {
            watchLv = data.wat_lvl_cd?.toInt() ?? 0
            isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
        }
       
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        originImage = data.poster_filename_v
        image = ImagePath.thumbImagePath(
            filePath: data.poster_filename_v,
            size: CGSize(width: ListItem.video.size.width, height: 0),
            isAdult: self.isAdult)
        index = idx
        epsdId = data.epsd_id
        srisId = data.sris_id
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.prd,
            epsdId: data.epsd_id, epsdRsluId: "", prdPrcId: prdPrcId , kidZone:nil, synopType: synopsisType)
        
        return self.setNaviLog(data: data)
    }
    func setNaviLog(data:PackageContentsItem? = nil) -> VideoData {
        self.contentLog = MenuNaviContentsBodyItem(
            type: "vod",
            title: self.title,
            channel_name: nil,
            genre_text: nil,
            genre_code: nil,
            paid: self.tagData?.isFree,
            purchase: nil,
            episode_id: self.epsdId,
            episode_resolution_id: self.synopsisData?.epsdRsluId,
            product_id: nil,
            purchase_type: nil,
            monthly_pay: nil,
            list_price: self.tagData?.price,
            payment_price: nil
        )
        return self
    }
    
    func setData(data:BookMarkItem, cardType:BlockData.CardType = .video, idx:Int = -1) -> VideoData {
        setCardType(cardType)
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        title = data.title
        watchLv = data.level?.toInt() ?? 0
        isAdult = data.adult?.toBool() ?? false
        tagData = TagData().setData(data: data, isAdult: self.isAdult)
        originImage = data.poster
        image = ImagePath.thumbImagePath(
            filePath: data.poster,
            size: CGSize(width: ListItem.video.size.width, height: 0),
            isAdult: self.isAdult)
        index = idx
        epsdId = data.epsd_id
        srisId = data.sris_id
        
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.prd,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",  kidZone:data.yn_kzone, synopType: synopsisType)
        return self.setNaviLog(data:data)
    }
    func setNaviLog(data:BookMarkItem) -> VideoData {
        self.logAction = .clickPickContentsList
        self.contentLog = MenuNaviContentsBodyItem(
            type: "vod",
            title: self.title,
            channel_name: nil,
            genre_text: nil,
            genre_code: nil,
            paid: self.tagData?.isFree,
            purchase: nil,
            episode_id: self.epsdId,
            episode_resolution_id: self.synopsisData?.epsdRsluId,
            product_id: nil,
            purchase_type: nil,
            monthly_pay: nil,
            list_price: nil,
            payment_price: nil
        )
        return self
    }
    
    func setData(data:WatchItem, cardType:BlockData.CardType = .video, idx:Int = -1) -> VideoData {
        setCardType(cardType)
        isClip = cardType == .clip
        count = data.yn_series == "Y" ? data.series_no : nil
        
        if !isClip {
            watchLv = data.level?.toInt() ?? 0
            isAdult = data.adult?.toBool() ?? false
            useAge = false
            isWatched = true
        }
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        
       
        if let rt = data.watch_rt?.toInt() {
            self.progress = Float(rt) / 100.0
            self.isContinueWatch = MetvNetwork.isWatchCardRateIn(data: data)
        }
        title = data.title
        originImage = data.thumbnail
        image = ImagePath.thumbImagePath(
            filePath: data.thumbnail ,
            size: CGSize(width: ListItem.video.size.width, height: 0),
            isAdult: self.isAdult)
        index = idx
        epsdId = data.epsd_id
        srisId = data.sris_id
        prodId = data.prod_id
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.prd,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id,
            prdPrcId: "",  kidZone:nil, progress:self.progress, synopType: synopsisType)
        return self
    }
    
    func setNaviLog(data:WatchItem, logAction:NaviLog.Action) -> VideoData  {
        self.logAction = logAction // .clickMyRecentsContents
        let content = MenuNaviContentsBodyItem(
            type: "vod",
            title: data.title,
            genre_text: nil,
            genre_code: nil,
            paid: nil,
            purchase: nil,
            episode_id: data.epsd_id,
            episode_resolution_id: data.epsd_rslu_id,
        
            product_id: data.prod_id,
            purchase_type: nil,
            monthly_pay: nil,
            running_time: data.watch_time,
            list_price: nil,
            payment_price: nil)
        self.contentLog = content
        return self
    }

    func setData(data:CategoryClipItem, searchType:BlockData.SearchType, idx:Int = -1) -> VideoData {
        setCardType(.clip)
        isClip = true
        isSearch = true
        count = data.no_epsd
        playTime = data.running_time?.toHMS()
        title = data.title
        clipTitle = data.title_sris
        index = idx
        epsdId = data.epsd_id
        watchLv = data.level?.toInt() ?? 0
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        originImage = data.thumb
        image = ImagePath.thumbImagePath(
            filePath: data.thumb,
            size: CGSize(width: ListItem.video.size.width, height: 0),
            isAdult: self.isAdult)
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        synopsisData = .init(
            srisId: nil, searchType: EuxpNetwork.SearchType.prd,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",  kidZone:nil, synopType: synopsisType)
        return self.setNaviLog(searchType: searchType, data: nil)
    }
    func setData(data:CategorySrisItem, searchType:BlockData.SearchType, idx:Int = -1) -> VideoData {
        setCardType(.video)
        title = data.title
        isSearch = true
        subTitle = data.title_sub
        index = idx
        epsdId = data.epsd_id
        watchLv = data.level?.toInt() ?? 0
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        
        originImage = data.poster_tseq
        image = ImagePath.thumbImagePath(
            filePath: data.poster_tseq,
            size: CGSize(width: ListItem.video.size.width, height: 0),
            isAdult: self.isAdult)
    
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        synopsisData = .init(
            srisId: nil, searchType: EuxpNetwork.SearchType.prd,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",  kidZone:nil, synopType: synopsisType)
        return self.setNaviLog(searchType: searchType, data: data)
    }
    
    func setData(data:CategoryCornerItem, searchType:BlockData.SearchType, idx:Int = -1) -> VideoData {
        setCardType(.video)
        isSearch = true
        title = data.title
        index = idx
        epsdId = data.epsd_id
        watchLv = data.level?.toInt() ?? 0
        originImage = data.thumb
        image = ImagePath.thumbImagePath(
            filePath: data.thumb,
            size: CGSize(width: ListItem.video.size.width, height: 0),
            isAdult: self.isAdult)
      
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        
        var progressTime:Double? = nil
        if let startTime = data.start_time?.toInt(){
            progressTime = Double(startTime)
        }
        synopsisData = .init(
            srisId: nil, searchType: EuxpNetwork.SearchType.prd,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",
            kidZone:nil, progressTime:progressTime, synopType: synopsisType)
        
        return self.setNaviLog(searchType: searchType, data: nil)
    }
    func setNaviLog(searchType:BlockData.SearchType, data:CategorySrisItem? = nil) -> VideoData  {
        self.contentLog = MenuNaviContentsBodyItem(
            type: searchType.logType,
            title: self.title,
            channel_name: nil,
            genre_text: nil,
            genre_code: data?.meta_typ_cd,
            paid: self.tagData?.isFree,
            purchase: nil,
            episode_id: self.epsdId,
            episode_resolution_id: self.synopsisData?.epsdRsluId,
            product_id: nil,
            purchase_type: nil,
            monthly_pay: nil,
            list_price: data?.price
        )
        return self
    }
    
    
    var bottomHeight:CGFloat {
        get{
            if self.pageType == .kids {
                return 0
            }
            if self.isClip {
                return ListItem.video.type03
            }
            
            if (self.title != nil && self.subTitle != nil) {
                return ListItem.video.type02
            }
            else {
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
        self.type =  self.pageType == .btv
            ? .cell(CGSize(width: width, height: height), padding)
            : .cellKids(CGSize(width: width, height: height), padding)
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
    case nomal, watching, cell(CGSize, CGFloat), kids, cellKids(CGSize, CGFloat), watchingKids
    var size:CGSize {
        get{
            switch self {
            case .nomal: return ListItem.video.size
            case .watching: return ListItem.video.size
            case .kids: return ListItemKids.video.type01
            case .watchingKids: return ListItemKids.video.type01
            case .cell(let size, _ ): return size
            case .cellKids(let size, _ ): return size
            }
        }
    }
    var bgColor:Color {
        get{
            switch self {
            case .kids, .watchingKids, .cellKids: return Color.app.white
            default : return Color.app.blueLight
            }
        }
    }
    var radius:CGFloat {
        get{
            switch self {
            case .kids, .watchingKids, .cellKids: return DimenKids.radius.light 
            default : return 0
            }
        }
    }
    
}


struct VideoList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var naviLogManager:NaviLogManager
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var banners:[BannerData]? = nil
    var datas:[VideoData]
    var parentData: BlockData? = nil
    var contentID:String? = nil
    var margin:CGFloat = SystemEnvironment.currentPageType == .btv ? Dimen.margin.thin : DimenKids.margin.regular
    var spacing:CGFloat = SystemEnvironment.currentPageType == .btv ? Dimen.margin.tiny : DimenKids.margin.thinUltra
   
    var useTracking:Bool = false
    var action: ((_ data:VideoData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin,
            spacing: self.spacing,
            isRecycle: true,
            useTracking: self.useTracking
        ){
            if let banners = self.banners {
                ForEach(banners) { data in
                    BannerItem(data: data){
                        var actionBody = MenuNaviActionBodyItem()
                        actionBody.menu_id = data.menuId
                        actionBody.menu_name = data.menuNm
                        actionBody.position = data.logPosition
                        actionBody.target = "banner"
                        actionBody.config = data.logConfig
                        self.naviLogManager.actionLog(
                            data.pageType == .btv ? .clickContentsView : .clickContentsButton,
                            actionBody: actionBody)
                    }
                }
            }
            ForEach(self.datas) { data in
                VideoItem( data:data , isSelected: self.contentID == nil
                            ? false
                            : self.contentID == data.epsdId)
                .id(data.hashId)
                .accessibility(label: Text(data.title ?? data.subTitle ?? ""))
                .onTapGesture {
                    self.onTap(data: data)
                }
            }
        }
    }//body
    
    func onTap(data:VideoData)  {
        if data.hasLog {
            self.naviLogManager.actionLog(
                data.logAction ?? .clickContentsList,
                pageId: data.logPage ,
                actionBody: data.actionLog, contentBody: data.contentLog)
        }
        if let action = self.action {
            action(data)
        }else{
            guard let synopsisData = data.synopsisData else { return }
            if data.isClip && !data.isSearch , let parent = self.parentData {
                
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.clipPreviewList)
                        .addParam(key: .data, value: parent)
                        .addParam(key: .id, value: data.epsdId)
                )
                return 
            }
            self.pagePresenter.openPopup(
                data.moveSynopsis
                    .addParam(key: .data, value: synopsisData)
                    .addParam(key: .watchLv, value: data.watchLv)
            )
        }
    }
}

struct VideoDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 2
    var datas:[VideoData] = []
    var isFull = false
    var index:Int = -1
}

extension VideoSet{
   
    static func listSize(data:VideoDataSet, screenWidth:CGFloat,
                         padding:CGFloat = Self.listPadding,
                         isFull:Bool = false) -> CGSize{
        let datas = data.datas
        let dataCell = datas.first ?? VideoData()
        let ratio = dataCell.type.size.height / dataCell.type.size.width
        let count = CGFloat(data.count)
        let w = screenWidth - (padding * 2)
        let cellW = ( w - ( padding * (count-1)) ) / count
        var cellH = round(cellW * ratio)
        
        if isFull{
            cellH = cellH + dataCell.bottomHeight
        }
        return CGSize(width: floor(cellW), height: cellH )
    }
    
    static let listPadding:CGFloat = SystemEnvironment.currentPageType == .btv
        ? SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin
        : DimenKids.margin.thinUltra
    
}

struct VideoSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    var pageObservable:PageObservable = PageObservable()
    var data:VideoDataSet
    var screenSize:CGFloat? = nil
    var padding:CGFloat = Self.listPadding
    
    @State var cellDatas:[VideoData] = []
    @State var isUiActive:Bool = true
    var body: some View {
        HStack(spacing: self.padding ){
            if self.isUiActive {
                ForEach(self.cellDatas) { data in
                    VideoItem( data:data )
                    .accessibility(label: Text(data.title ?? data.subTitle ?? ""))
                    .onTapGesture {
                        if data.hasLog {
                            self.naviLogManager.actionLog(
                                data.logAction ?? .clickContentsList,
                                pageId: data.logPage,
                                actionBody: data.actionLog, contentBody: data.contentLog)
                        }
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
        .padding(.horizontal, self.padding)
        .frame(width: self.screenSize ?? self.sceneObserver.screenSize.width)
        .onAppear {
            if self.data.datas.isEmpty { return }
            let size = Self.listSize(data: self.data,
                                     screenWidth: self.screenSize ?? sceneObserver.screenSize.width,
                                     padding: self.padding,
                                     isFull: false)
            self.cellDatas = self.data.datas.map{
                $0.setCardType(width: size.width, height: size.height, padding: self.padding)
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
            ImageView(url: self.data.image,isFull: true, noImg: Asset.noImg16_9)
                .modifier(MatchParent())
            
            Image(Asset.shape.listGradientH)
                .resizable()
                .scaledToFill()
                .modifier(MatchParent())
            
            if (self.data.progress != nil || self.isSelected) && self.data.tagData?.isLock != true {
                Image(Asset.icon.thumbPlay)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regularExtra, height: Dimen.icon.regularExtra)
            }
            VStack(alignment: .leading, spacing:0){
                if let tag = self.data.tagData {
                    Tag(data: tag, usePrice:self.data.usePrice, useAge: self.data.useAge).modifier(MatchParent())
                }else if let time = self.data.playTime {
                    ZStack(alignment:.bottomTrailing){
                        Spacer().modifier(MatchParent())
                        Text(time)
                            .modifier(BoldTextStyle(size: Font.size.tiny))
                            .lineLimit(1)
                            .padding(.horizontal, Dimen.margin.micro)
                            .padding(.top, Dimen.margin.micro)
                            .padding(.bottom, Dimen.margin.microExtra)
                            .background(Color.transparent.black70)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                            .padding(.all, Dimen.margin.microUltra)
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
            VStack(alignment: .leading, spacing:0){
                Spacer().modifier(MatchHorizontal(height: 0))
                VStack(alignment: .leading, spacing:Dimen.margin.tiny){
                    if let title = self.data.fullTitle {
                        Text(title)
                            .kerning(Font.kern.thin)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra))
                            .lineLimit(self.data.isClip ? 2 : 1)
                            .multilineTextAlignment(.leading)

                    }
                    if let subTitle = self.data.subTitle {
                        Text(subTitle)
                            .kerning(Font.kern.thin)
                            .modifier(MediumTextStyle(size: Font.size.tiny, color:Color.app.grey))
                            .lineLimit(self.data.fullTitle?.isEmpty == false ? 1 : 2)
                    }
                    
                    if let clipTitle = self.data.clipTitle {
                        Text(clipTitle)
                            .kerning(Font.kern.thin)
                            .modifier(BoldTextStyle(size: Font.size.tiny, color:Color.app.white))
                            .lineLimit(1)
                            .padding(.top, 1)
        
                    }
                }
            }
            .padding(.horizontal, Dimen.margin.thin)
            .frame(
                width: self.data.type.size.width,
                height:self.data.bottomHeight)
        }
    }
    
}


struct VideoItemBodyKids: PageView {
    @EnvironmentObject var repository:Repository
    var data:VideoData
    var isSelected:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            ZStack{
                ImageView(url: self.data.image, isFull: true, noImg: AssetKids.noImg16_9)
                    .modifier(MatchParent())
                Image(Asset.shape.listGradientH)
                    .resizable()
                    .scaledToFill()
                    .modifier(MatchParent())
                    .opacity(0.3)
                if (self.data.progress != nil || self.isSelected) && self.data.tagData?.isLock != true {
                    Image(AssetKids.icon.thumbPlayVideo)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: DimenKids.icon.regular, height: DimenKids.icon.regular)
                }
                VStack(alignment: .leading, spacing:0){
                    if  let tag = self.data.tagData {
                        TagKids(data: tag, usePrice:self.data.usePrice).modifier(MatchParent())
                    }else {
                        Spacer().modifier(MatchParent())
                    }
                    if let progress = self.data.progress {
                        if progress < MetvNetwork.maxWatchedProgress {
                            Spacer().frame(
                                width: (self.data.type.size.width - (DimenKids.margin.thinExtra*2)) * CGFloat(progress),
                                height: DimenKids.line.medium)
                                .background(Color.kids.primary)
                        }
                    }
                }
            }
            .frame(
                width: self.data.type.size.width - (DimenKids.margin.microUltra*2),
                height: (self.data.type.size.width - (DimenKids.margin.microUltra*2)) * 9 / 16
            )
            .clipShape(RoundedRectangle(cornerRadius:  DimenKids.radius.light))
            .padding(.top, DimenKids.margin.microUltra)
            .padding(.horizontal, DimenKids.margin.microUltra)
            
            
            if self.data.title != nil {
                VStack(alignment: .leading, spacing:0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    if let title = self.data.title {
                        Text(title)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color:Color.app.brownDeep))
                            .lineLimit(1)
                            
                    }
                    if let subTitle = self.data.subTitle {
                        Text(subTitle)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.tinyExtra, color:Color.app.brownDeep.opacity(0.7)))
                            .lineLimit(1)
                            .padding(.top, DimenKids.margin.tiny)
                           
                    }
                    
                }
                .padding(.horizontal, DimenKids.margin.thin)
                .modifier(MatchParent())
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

