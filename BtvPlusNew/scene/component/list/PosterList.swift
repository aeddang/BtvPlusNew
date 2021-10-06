//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class PosterData:InfinityData, Copying{
    private(set) var image: String? = nil
    private(set) var originImage: String? = nil
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var progress:Float? = nil
    private(set) var epsdId:String? = nil
    private(set) var prsId:String? = nil
    private(set) var prodId:String? = nil
    private(set) var tagData: TagData? = nil
    private(set) var isAdult:Bool = false
    private(set) var watchLv:Int = 0
    private(set) var isContinueWatch:Bool = false
    fileprivate(set) var isBookmark:Bool? = nil
    private(set) var synopsisType:SynopsisType = .title
    private(set) var type:PosterType = .small
    private(set) var synopsisData:SynopsisData? = nil
    private(set) var pageType:PageType = .btv
    private(set) var usePrice:Bool = true
    private(set) var isPeople:Bool = false
    private(set) var isPreview:Bool = false
    
    required init(original: PosterData) {
        image = original.image
        originImage = original.originImage
        title = original.title
        subTitle = original.subTitle
        progress = original.progress
        epsdId = original.epsdId
        prsId = original.prsId
        prodId = original.prodId
        tagData = original.tagData
        isAdult = original.isAdult
        watchLv = original.watchLv
        isContinueWatch = original.isContinueWatch
        isBookmark = original.isBookmark
        synopsisType = original.synopsisType
        type = original.type
        synopsisData = original.synopsisData
        pageType = original.pageType
        usePrice = original.usePrice
        isPeople = original.isPeople
        isPreview = original.isPreview
        actionLog = original.actionLog
        contentLog = original.contentLog
        logPage = original.logPage
        logAction = original.logAction
    }
    
    var hasLog:Bool { get{ return logAction != nil || actionLog != nil || contentLog != nil } }
    
    private(set) var contentLog:MenuNaviContentsBodyItem? = nil
    private(set) var actionLog:MenuNaviActionBodyItem? = nil

    var logPage:NaviLog.PageId = .empty
    var logAction:NaviLog.Action? = nil

    
    init(pageType:PageType = .btv, usePrice:Bool = true) {
        self.pageType = pageType
        self.usePrice = usePrice
        super.init()
    }
    
    @discardableResult
    func setNaviLog(action:MenuNaviActionBodyItem?) -> PosterData {
        logAction = .clickContentsList
        self.actionLog = action
        return self
    }
    @discardableResult
    func setNaviLogKids(action:MenuNaviActionBodyItem?) -> PosterData {
        logAction = .clickContentsButton
        self.actionLog = action
        return self
    }
    
    func setData(data:ContentItem, cardType:BlockData.CardType = .smallPoster , idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        watchLv = data.wat_lvl_cd?.toInt() ?? 0
        isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
        originImage = data.poster_filename_v
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_v, size: type.size, isAdult: self.isAdult)
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        isPreview = data.rsv_orgnz_yn?.toBool() ?? false
        index = idx
        epsdId = data.epsd_id
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris,
            epsdId: data.epsd_id, epsdRsluId: "", prdPrcId: data.prd_prc_id,
            kidZone:data.kids_yn, synopType: synopsisType, isPreview:self.isPreview,
            isDemand: data.svc_typ_cd == "12")
        
        return self
    }
    
    func setNaviLog(data:ContentItem) -> PosterData {
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
            list_price: data.prd_prc?.description ?? nil,
            payment_price: nil
        )
        return self
    }
    
    
    func setData(data:PackageContentsItem, prdPrcId:String, cardType:BlockData.CardType = .smallPoster ,
                 isPosson:Bool, anotherStb:String?,
                 idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
        watchLv = data.wat_lvl_cd?.toInt() ?? 0
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        originImage = data.poster_filename_v
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_v, size: type.size, isAdult: self.isAdult)
        
        index = idx
        epsdId = data.epsd_id
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris,
            epsdId: data.epsd_id, epsdRsluId: "", prdPrcId: prdPrcId , kidZone:nil,
            isPosson: isPosson, anotherStbId: isPosson ? anotherStb : nil, synopType: synopsisType
            )
        
        return self.setNaviLog(data: data)
    }
    
    func setNaviLog(data:PackageContentsItem? = nil) -> PosterData {
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
    
    func setData(data:BookMarkItem, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        epsdId = data.epsd_id
        isAdult = data.adult?.toBool() ?? false
        watchLv = data.level?.toInt() ?? 0
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        originImage = data.poster
        image = ImagePath.thumbImagePath(filePath: data.poster, size: type.size, isAdult: self.isAdult)
        
        index = idx
        
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",
            kidZone:data.yn_kzone, synopType: synopsisType)
        return self
    }
    
    func setData(data:WatchItem, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        epsdId = data.epsd_id
        prodId = data.prod_id
        isAdult = data.adult?.toBool() ?? false
        watchLv = data.level?.toInt() ?? 0
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        
        if let rt = data.watch_rt?.toInt() {
            self.progress = Float(rt) / 100.0
            self.isContinueWatch = MetvNetwork.isWatchCardRateIn(data: data)
            
        }
        originImage = data.thumbnail
        image = ImagePath.thumbImagePath(filePath: data.thumbnail, size: type.size, isAdult: self.isAdult)
        
        index = idx
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.prd,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id,
            prdPrcId: "", kidZone:nil, progress:self.progress, synopType: synopsisType)
        return self
    }
    
    func setData(data:CWBlockItem, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        epsdId = data.epsd_id
        isAdult = EuxpNetwork.adultCodes.contains(data.adlt_lvl_cd)
        watchLv = data.wat_lvl_cd?.toInt() ?? 0
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        originImage = data.poster_filename_v
        image = ImagePath.thumbImagePath(filePath: data.poster_filename_v, size: type.size, isAdult: self.isAdult)
        
        index = idx
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: ""
            , kidZone:nil, synopType: synopsisType)
        return self.setNaviLog(data: data)
    }
    
    func setNaviLog(data:CWBlockItem? = nil) -> PosterData {
        self.contentLog = MenuNaviContentsBodyItem(
            type: "vod",
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
            list_price: self.tagData?.price,
            payment_price: nil
        )
        return self
    }
    
    func setData(data:SearchPopularityVodItem, searchType:BlockData.SearchType, idx:Int = -1) -> PosterData {
        title = data.title
        epsdId = data.epsd_id
        //isAdult = data.adult?.toBool() ?? false
        watchLv = data.level?.toInt() ?? 0
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        originImage = data.poster
        image = ImagePath.thumbImagePath(filePath: data.poster , size: type.size, isAdult: self.isAdult)
        
        index = idx
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        synopsisData = .init(
            srisId: nil, searchType: EuxpNetwork.SearchType.sris,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id,
            prdPrcId: "", kidZone:nil, synopType: synopsisType)
        return self.setNaviLog(searchType: searchType, data:nil)
    }
    
    func setData(data:CategoryVodItem, searchType:BlockData.SearchType, cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        watchLv = data.level?.toInt() ?? 0
        tagData = TagData(pageType: self.pageType).setData(data: data, isAdult: self.isAdult)
        
        synopsisType = SynopsisType(value: data.synon_typ_cd)
        originImage = data.poster
        image = ImagePath.thumbImagePath(filePath: data.poster, size: type.size, isAdult: self.isAdult)
        
        index = idx
        epsdId = data.epsd_id
    
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "", kidZone:nil, synopType: synopsisType)
        return self.setNaviLog(searchType: searchType, data:data)
    }
    
    func setData(data:CategoryPeopleItem, searchType:BlockData.SearchType , cardType:BlockData.CardType = .smallPoster ,idx:Int = -1) -> PosterData {
        setCardType(cardType)
        title = data.title
        index = idx
        prsId = data.prs_id
        isPeople = true
        return self.setNaviLog(searchType: searchType)
    }
    
    func setNaviLog(searchType:BlockData.SearchType, data:CategoryVodItem? = nil) -> PosterData {
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
    
    func setRank(_ idx:Int){
        if self.tagData == nil {
            self.tagData = TagData(pageType: self.pageType).setRank(idx)
        } else{
            self.tagData?.setRank(idx)
        }
    }
    
    private func setCardType(_ cardType:BlockData.CardType){
        self.isBookmark = (cardType == .bookmarkedPoster) ? true : nil
        if self.pageType == .kids {
            type = .kids
            return
        }
        switch cardType {
        case .bigPoster: type = .big
        case .smallPoster: type = .small
        default: type = .small
        }
    }
    
    var moveSynopsis:PageObject
    {
        get {
            if self.pageType == .btv {
                return PageProvider.getPageObject(self.synopsisType == .package ? .synopsisPackage : .synopsis)
            } else {
                return PageKidsProvider.getPageObject(self.synopsisType == .package ? .kidsSynopsisPackage : .kidsSynopsis)
            }
        }
    }
    
    fileprivate func updatedImage(){
        image = ImagePath.thumbImagePath(filePath: self.originImage, size: type.size, isAdult: self.isAdult)
    }
    
    fileprivate func setCardType(width:CGFloat, height:CGFloat, padding:CGFloat) -> PosterData {
        self.type =  self.pageType == .btv
            ? .cell(CGSize(width: width, height: height), padding)
            : .cellKids(CGSize(width: width, height: height), padding)
        return self
    }
    
    func setDummy(_ idx:Int = -1) -> PosterData {
        title = "[Q&A] 이민?레나채널 삭제 안하는 이유?외국인남친?"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        return self
    }
    
    func setDummyBig(_ idx:Int = -1) -> PosterData {
        title = "[Q&A] 이민?레나채널 삭제 안하는 이유?외국인남친?"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        type = .big
        return self
    }
    
    func setDummyBanner(_ idx:Int = -1) -> PosterData {
        index = idx
        type = .banner
        image = Asset.noImg4_3
        return self
    }
}

enum PosterType {
    case small, big, banner, cell(CGSize, CGFloat), kids, cellKids(CGSize, CGFloat)
    var size:CGSize {
        get{
            switch self {
            case .small: return ListItem.poster.type01
            case .big: return ListItem.poster.type02
            case .banner: return ListItem.poster.type03
            case .cell(let size, _ ): return size
            case .cellKids(let size, _ ): return size
            case .kids: return ListItemKids.poster.type01
            }
        }
    }
    
    var isBigTag:Bool {
        get{
            switch self {
            case .big: return true
            default : return false
            }
        }
    }
    
    var radius:CGFloat {
        get{
            switch self {
            case .kids, .cellKids: return DimenKids.radius.light
            default : return 0
            }
        }
    }
    
    var noImg:String {
        get{
            switch self {
            case .banner: return Asset.noImg4_3
            case .kids, .cellKids: return AssetKids.noImg9_16
            default : return Asset.noImg9_16
            }
        }
    }
    
    var selectedColor:Color {
        get{
            switch self {
            case .kids, .cellKids: return Color.kids.primary
            default : return Color.brand.primary
            }
        }
    }
    
    var selectedStroke:CGFloat {
        get{
            switch self {
            case .kids, .cellKids: return 0
            default : return Dimen.stroke.medium
            }
        }
    }
    
    var bgColor:Color {
        get{
            switch self {
            case .kids, .cellKids: return Color.app.ivoryDeep
            default : return Color.app.blueLight
            }
        }
    }
}

extension PosterList{
    static let headerSize:Int = 2
}

struct PosterList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var naviLogManager:NaviLogManager
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var banners:[BannerData]? = nil
    var datas:[PosterData]
    var contentID:String? = nil
    var useTracking:Bool = false
 
    var margin:CGFloat = SystemEnvironment.currentPageType == .btv ? Dimen.margin.thin : DimenKids.margin.regular
    var spacing:CGFloat = SystemEnvironment.currentPageType == .btv ? Dimen.margin.tiny : DimenKids.margin.thinUltra
    var action: ((_ data:PosterData) -> Void)? = nil
    
   
    @State var subDataSets:[PosterDataSet]? = nil
    
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin,
            spacing: self.spacing,
            isRecycle: true, //self.banners?.isEmpty == false ? false : true,
            useTracking: self.useTracking
            ){
            if banners?.isEmpty == false, let banners = self.banners {
                ForEach(banners) { data in
                    BannerItem(data: data)
                        //.modifier(HolizentalListRowInset(spacing: self.spacing))
                }
                if let subDataSets = self.subDataSets {
                    ForEach(subDataSets) {sets in
                        HStack(spacing:self.spacing){
                            ForEach(sets.datas) { data in
                                PosterItem( data:data )
                                    .onTapGesture {
                                        self.onTap(data: data)
                                    }
                            }
                        }
                        //.modifier(HolizentalListRowInset(spacing: self.spacing))
                    }
                }
            } else {
                ForEach(self.datas) { data in
                    PosterItem( data:data , isSelected: self.contentID == nil
                                    ? false
                                    : self.contentID == data.epsdId)
                        //.modifier(HolizentalListRowInset(spacing: self.spacing))
                        .onTapGesture {
                            self.onTap(data: data)
                        }
                }
            }
        }
        .onAppear{
            guard let banners = self.banners else {return}
            if banners.isEmpty {return}
            self.onBindingData(datas: self.datas)
        }
    }//body
    
    func onBindingData(datas:[PosterData]?)  {
        let count:Int = 2
        var rows:[PosterDataSet] = []
        var cells:[PosterData] = []
        var total = self.datas.count
        datas?.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    PosterDataSet( count: count, datas: cells, isFull: true, index: total)
                )
                cells = [d]
                total += 1
            }
        }
        if !cells.isEmpty {
            rows.append(
                PosterDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        self.subDataSets = rows
    }
    
    func onTap(data:PosterData)  {
        if data.hasLog {
            self.naviLogManager.actionLog(
                data.logAction ?? .clickContentsList,
                pageId: data.logPage,
                actionBody: data.actionLog, contentBody: data.contentLog)
        }
        
        if let action = self.action {
            action(data)
        }else{
            if let synopsisData = data.synopsisData {
                self.pagePresenter.openPopup(
                    data.moveSynopsis
                        .addParam(key: .data, value: synopsisData)
                        .addParam(key: .watchLv, value: data.watchLv)
                )
            } else {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.person)
                        .addParam(key: .data, value: data)
                        .addParam(key: .watchLv, value: data.watchLv)
                )
            }
        }
    }
}

struct PosterViewList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[PosterData]
    var contentID:String? = nil
    var episodeViewerData:EpisodeViewerData? = nil
    var useTracking:Bool = false
    var hasAuthority:Bool = false
    var text:String = String.button.detail
    var isRecycle:Bool = true
    var margin:CGFloat = SystemEnvironment.currentPageType == .btv ? Dimen.margin.thin : DimenKids.margin.regular
    var spacing:CGFloat = SystemEnvironment.currentPageType == .btv ? Dimen.margin.tiny : DimenKids.margin.thinUltra
    var action: ((_ data:PosterData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin,
            spacing: 0,
            isRecycle:  self.isRecycle,
            useTracking: self.useTracking
            ){
            ForEach(self.datas) { data in
                PosterViewItem(
                    data:data ,
                    isSelected: self.contentID == nil ? false : self.contentID == data.epsdId,
                    hasAuthority: self.hasAuthority,
                    text: self.text,
                    episodeViewerData: self.episodeViewerData
                )
                .modifier(HolizentalListRowInset(spacing: self.spacing))
                .onTapGesture {
                    if let action = self.action {
                        action(data)
                    }
                }
            }
        }
    }//body
}


struct PosterDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 2
    var datas:[PosterData] = []
    var isFull = false
    var index:Int = -1
}

extension PosterSet{
    
    static func listSize(data:PosterDataSet, screenWidth:CGFloat,
                         padding:CGFloat = Self.listPadding) -> CGSize {
        
        let datas = data.datas
        if datas.isEmpty {return CGSize()}
        let ratio = datas.first!.type.size.height / datas.first!.type.size.width
        let count = CGFloat(data.count)
        let w = screenWidth - ( padding * 2) 
        let cellW = ( w - (padding*(count-1)) ) / count
        let cellH = round(cellW * ratio)
        
        return CGSize(width: floor(cellW), height: cellH )
    }
    static let listPadding:CGFloat = SystemEnvironment.currentPageType == .btv
        ? SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin
        : DimenKids.margin.thinUltra
}

struct PosterSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    var pageObservable:PageObservable = PageObservable()
    var data:PosterDataSet
    var screenSize:CGFloat? = nil
    var padding:CGFloat = Self.listPadding
    var action: ((_ data:PosterData) -> Void)? = nil
    
    @State var cellDatas:[PosterData] = []
    @State var isUiActive:Bool = true
    var body: some View {
        HStack(spacing: self.padding){
            if self.isUiActive {
                ForEach(self.cellDatas) { data in
                    PosterItem( data:data )
                    .onTapGesture {
                        if data.hasLog {
                            self.naviLogManager.actionLog(
                                data.logAction ?? .clickContentsList,
                                pageId:data.logPage,
                                actionBody: data.actionLog, contentBody: data.contentLog)
                        }
                        if let action = self.action {
                            action(data)
                        }else{
                            if let synopsisData = data.synopsisData {
                                self.pagePresenter.openPopup(
                                    data.moveSynopsis
                                        .addParam(key: .data, value: synopsisData)
                                        .addParam(key: .watchLv, value: data.watchLv)
                                )
                            } else {
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.person)
                                        .addParam(key: .data, value: data)
                                        .addParam(key: .watchLv, value: data.watchLv)
                                )
                            }
                        }
                        
                    }
                }
                if !self.data.isFull && self.data.count > 1 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, self.padding)
        .frame(width: self.screenSize ?? self.sceneObserver.screenSize.width)
        .onAppear {
            if self.data.datas.isEmpty { return }
            let size = Self.listSize(
                data: self.data,
                screenWidth: self.screenSize ?? sceneObserver.screenSize.width,
                padding: self.padding)
            
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


struct PosterItem: PageView {
    @EnvironmentObject var repository:Repository
    var data:PosterData
    var isSelected:Bool = false
    @State var isBookmark:Bool? = nil
    var body: some View {
        ZStack(alignment: self.data.isPeople ? .center : .topLeading){
            
            if self.data.isPeople {
                VStack(alignment: .center, spacing: Dimen.margin.thin){
                    Image(Asset.icon.person)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:Dimen.icon.light, height: Dimen.icon.light)
                    if let title = self.data.title {
                        Text(title)
                            .modifier(MediumTextStyle(size: Font.size.tiny, color:Color.white))
                            .opacity(0.3)
                    }
                }
            } else {
                
                ImageView(url: self.data.image, contentMode: .fit, noImg: self.data.type.noImg)
                    .modifier(MatchParent())
                Image(Asset.shape.listGradient)
                    .resizable()
                    .scaledToFill()
                    .modifier(MatchParent())
                    .opacity(self.data.pageType == .btv ? 1 : 0.3)
                
            }
            if let tag = self.data.tagData {
                if tag.pageType == .btv {
                    Tag(data: tag, isBig: self.data.type.isBigTag, usePrice:self.data.usePrice).modifier(MatchParent())
                } else {
                    TagKids(data: tag, usePrice:self.data.usePrice).modifier(MatchParent())
                }
            }
            if self.isBookmark != nil , let synop = self.data.synopsisData  {
                BookMarkButton(
                    type: self.data.pageType,
                    data:synop,
                    isSimple:true,
                    isBookmark: self.$isBookmark
                ){ ac in
                    self.data.isBookmark = ac
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .frame(
            width: self.data.type.size.width,
            height: self.data.type.size.height)
        .background(self.data.isPeople ? Color.app.black : self.data.type.bgColor)
        .clipShape(RoundedRectangle(cornerRadius: self.data.type.radius))
        .overlay(
            RoundedRectangle(cornerRadius: self.data.type.radius)
            .strokeBorder(
                self.isSelected ? self.data.type.selectedColor : Color.transparent.clear,
                lineWidth: self.data.type.selectedStroke)
        )
        
        .onReceive(self.repository.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedWatchLv : self.data.updatedImage()
            default : break
            }
        }
        .onAppear(){
            self.isBookmark = self.data.isBookmark
        }
        
        
    }
}

struct PosterViewItem: PageView {
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var pagePresenter:PagePresenter
    var data:PosterData
    var isSelected:Bool = false
    var hasAuthority:Bool = false
    var text:String = String.button.detail
    var episodeViewerData:EpisodeViewerData? = nil
    var spacing:CGFloat = SystemEnvironment.currentPageType == .btv ? Dimen.margin.thin : DimenKids.margin.thin
    @State var isBookmark:Bool? = nil
    var body: some View {
        VStack( spacing:self.spacing){
            ZStack{
                PosterItem(data: self.data, isSelected:self.isSelected)
                if self.isSelected , let episodeViewerData = self.episodeViewerData {
                    VStack(alignment: .leading){
                        Text(episodeViewerData.episodeTitleKids)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color:Color.app.white))
                            .fixedSize()
                        Spacer().modifier(MatchParent())
                        Text(episodeViewerData.info)
                            .modifier(BoldTextStyleKids(size: Font.sizeKids.tinyExtra, color:Color.app.white))
                        
                    }
                    .padding(.vertical, DimenKids.margin.thinExtra)
                    .padding(.horizontal, DimenKids.margin.tiny)
                    .frame(
                        width: self.data.type.size.width,
                        height: self.data.type.size.height)
                    .background(Color.kids.primary.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: self.data.type.radius))
                }
            }
            if self.isSelected {
                if data.pageType == .btv {
                    if self.hasAuthority {
                        FillButton(
                            text: self.text,
                            isSelected: true,
                            size: Dimen.button.regular
                            ){ _ in
                            if let synopsisData = data.synopsisData {
                                
                                if data.hasLog {
                                    self.naviLogManager.actionLog(
                                        data.logAction ?? .clickContentsList,
                                        pageId:data.logPage,
                                        actionBody: data.actionLog, contentBody: data.contentLog)
                                }
                                
                                self.pagePresenter.openPopup(
                                   data.moveSynopsis
                                        .addParam(key: .data, value: synopsisData)
                                        .addParam(key: .watchLv, value: data.watchLv)
                                )
                            }
                        }
                    } else {
                        FillButton(
                            text: self.text,
                            strokeWidth: 1){ _ in
                            if let synopsisData = data.synopsisData {
                                
                                if data.hasLog {
                                    self.naviLogManager.actionLog(
                                        data.logAction ?? .clickContentsList,
                                        pageId:data.logPage,
                                        actionBody: data.actionLog, contentBody: data.contentLog)
                                }
                                
        
                                self.pagePresenter.openPopup(
                                   data.moveSynopsis
                                        .addParam(key: .data, value: synopsisData)
                                        .addParam(key: .watchLv, value: data.watchLv)
                                )
                            }
                        }
                    }
                    
                } else {
                    RectButtonKids(
                        text: self.text,
                        size: CGSize(width: data.type.size.width, height: DimenKids.button.light),
                        isFixSize: true ){ _ in
                           if let synopsisData = data.synopsisData {
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
    }
    
}


#if DEBUG
struct PosterList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PosterList( datas: [
                PosterData().setDummyBanner(0),
                PosterData().setDummy(),
                PosterData().setDummy(),
                PosterData().setDummy()
            ])
            .environmentObject(PagePresenter()).modifier(MatchParent())
        }
    }
}
#endif

