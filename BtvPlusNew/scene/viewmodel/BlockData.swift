//
//  Black.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/14.
//
import Foundation
import SwiftUI
enum BlockStatus:String{
    case initate, active, passive
}

class BlockData:InfinityData, ObservableObject{
    private(set) var parentTitle:String? = nil
    private(set) var keyword:String? = nil
    private(set) var name:String = ""
    private(set) var subName:String = ""
    private(set) var isAdult:Bool = false
    private(set) var isSortAble:Bool = false
    private(set) var menuId:String? = nil
    private(set) var cwCallId:String? = nil
    private(set) var cardType:CardType = .none
    private(set) var dataType:DataType = .none
    private(set) var uiType:UiType = .poster
    private(set) var blocks:[BlockItem]? = nil
    private(set) var originData:BlockItem? = nil
    private(set) var isCountView:Bool = false
    private(set) var childrenBlock:[BlockData] = []
    private(set) var searchType:SearchType = .none
    var errorMassage:String? = nil
    
    @Published private(set) var status:BlockStatus = .initate
    
    var kid:Kid? = nil
    var kidsHomeBlockData:KidsHomeBlockData? = nil
    var leadingBanners:[BannerData]? = nil
    var posters:[PosterData]? = nil
    var videos:[VideoData]? = nil
    var themas:[ThemaData]? = nil
    var tickets:[TicketData]? = nil
    var banners:[BannerData]? = nil
    var tvs:[TvData]? = nil
    var listHeight:CGFloat? = nil
    var allPosters:[PosterData]? = nil
    var allVideos:[VideoData]? = nil
    var allTvs:[TvData]? = nil
    
    private(set) var pageShowActionLog:MenuNaviActionBodyItem? = nil
    private(set) var pageCloseActionLog:MenuNaviActionBodyItem? = nil
    
    var allResultCount:Int {
        get{
            return (allPosters?.count ?? 0) + (allVideos?.count ?? 0) + (allTvs?.count ?? 0)
        }
    }
    
    public static func == (l:BlockData, r:BlockData)-> Bool {
        return l.id == r.id
    }
    
    private(set) var pageType:PageType = .btv
  
    init(pageType:PageType = .btv) {
        self.pageType = pageType
        super.init()
    }
    
    func reset(){
        status = .initate
        kidsHomeBlockData = nil
        leadingBanners = nil
        posters = nil
        videos = nil
        themas = nil
        banners = nil
        tvs = nil
    }
    
    func setNaviLog(pageShowActionLog:MenuNaviActionBodyItem? = nil) -> BlockData {
        self.pageShowActionLog = pageShowActionLog
        return self
    }
    func setNaviLog(pageCloseActionLog:MenuNaviActionBodyItem? = nil) -> BlockData {
        self.pageCloseActionLog = pageCloseActionLog
        return self
    }
    
    @discardableResult
    func setData(grids:[GridsItemKids]) -> BlockData{
        childrenBlock = grids.map{ g in
            BlockData(pageType: .kids).setData(parent:self, grid: g)
        }
        return self
    }
    @discardableResult
    func setData(grids:[GridsItem]) -> BlockData{
        childrenBlock = grids.map{ g in
            BlockData().setData(parent:self, grid: g)
        }
        return self
    }
    
    func setData(parent:BlockData, grid:GridsItemKids) -> BlockData{
        self.uiType = parent.uiType
        self.cardType = parent.cardType
        self.dataType = parent.dataType
        self.name = grid.sub_title ?? parent.name
        self.cwCallId = parent.cwCallId
        
        let max = MultiBlockBody.maxCellCount
        if let blocks = grid.block {
            switch self.uiType {
            case .poster :
                posters = blocks[0...min(max, blocks.count-1)].map{ d in
                    PosterData(pageType: .kids).setData(data: d, cardType: cardType)
                }
            case .video :
                videos = blocks[0...min(max, blocks.count-1)].map{ d in
                    VideoData(pageType: .kids).setData(data: d, cardType: cardType)
                }
                /* 전체 데이타 동일시 처리
                allVideos = blocks.map{ d in
                    VideoData(pageType: .kids).setData(data: d, cardType: cardType)
                }
                self.isSortAble = true
                */
            default: break
            }
        }
        
        var listHeight:CGFloat = 0
        var blockHeight:CGFloat = 0
        let tabHeight:CGFloat =  MultiBlockBody.tabHeightKids
        
        if let size = posters?.first?.type {
            listHeight = size.size.height
            blockHeight = listHeight + tabHeight
        }
        if let size = videos?.first{
            listHeight = size.type.size.height + size.bottomHeight
            blockHeight = listHeight + tabHeight
        }
        if blockHeight != 0 {
            self.listHeight = blockHeight
        }
        self.setDatabindingCompleted(total: grid.block_cnt?.toInt() ?? 0)
        return self
    }
    
    func setData(parent:BlockData, grid:GridsItem) -> BlockData{
        self.uiType = parent.uiType
        self.cardType = parent.cardType
        self.dataType = parent.dataType
        self.name = grid.sub_title ?? parent.name
        self.cwCallId = parent.cwCallId
        
        let max = MultiBlockBody.maxCellCount
        if let blocks = grid.block {
            switch self.uiType {
            case .poster :
                posters = blocks[0...min(max, blocks.count-1)].map{ d in
                    PosterData().setData(data: d, cardType: cardType)
                }
            case .video :
                videos = blocks[0...min(max, blocks.count-1)].map{ d in
                    VideoData().setData(data: d, cardType: cardType)
                }
            default: break
            }
        }
        
        var listHeight:CGFloat = 0
        var blockHeight:CGFloat = 0
        let tabHeight:CGFloat =  MultiBlockBody.tabHeightKids
        
        if let size = posters?.first?.type {
            listHeight = size.size.height
            blockHeight = listHeight + tabHeight
        }
        if let size = videos?.first{
            listHeight = size.type.size.height + size.bottomHeight
            blockHeight = listHeight + tabHeight
        }
        if blockHeight != 0 {
            self.listHeight = blockHeight
        }
        self.setDatabindingCompleted(total: grid.block_cnt?.toInt() ?? 0)
        return self
    }
    
    
    func setData(title:String, cardType:CardType, dataType:DataType, uiType:UiType, menuId:String? = nil, isCountView:Bool = false) -> BlockData{
        self.name = title
        self.cardType = cardType
        self.dataType = dataType
        self.uiType = uiType
        self.menuId = menuId
        self.isCountView = isCountView
        return self
    }
    
    func setData(title:String, datas:[PosterData], searchType:SearchType, keyword:String?, max:Int = 10) -> BlockData{
        name = title
        uiType = .poster
        self.searchType = searchType
        self.allPosters = datas
        let len = min(datas.count, max)
        self.posters = datas.isEmpty ? datas : datas[0..<len].map{$0}
        self.listHeight = (self.posters?.first?.type.size.height ?? 0) + MultiBlockBody.tabHeight
       
        self.subName = datas.count.description
        return self
    }
    
    func setData(title:String, datas:[VideoData], searchType:SearchType, keyword:String?, max:Int = 10) -> BlockData{
        name = title
        uiType = .video
        self.searchType = searchType
        self.allVideos = datas
        let len = min(datas.count, max)
        self.videos = datas.isEmpty ? datas : datas[0..<len].map{$0}
        self.subName = datas.count.description
        if let video = self.videos?.first{
            listHeight = video.type.size.height + video.bottomHeight + MultiBlockBody.tabHeight
        } else {
            listHeight = MultiBlockBody.tabHeight
        }
        return self
    }
    
    func setData(title:String, datas:[TvData], searchType:SearchType, keyword:String?, max:Int = 10) -> BlockData{
        name = title
        uiType = .tv
        self.allTvs = datas
        self.searchType = searchType
        let len = min(datas.count, max)
        self.tvs = datas.isEmpty ? datas : datas[0..<len].map{$0}
        self.listHeight = (self.tvs?.first?.type.size.height ?? 0) + MultiBlockBody.tabHeight
        self.subName = datas.count.description
        return self
    }
    /*
    func setData(title:String, datas:[CategoryCornerItem], searchType:SearchType, keyword:String?, max:Int = 10) -> BlockData{
        name = title
        uiType = .video
        self.searchType = searchType
        self.allVideos = []
        self.videos = []
        var idx:Int = 0
        datas.forEach{
            let video = VideoData().setData(data: $0, searchType: searchType)
            self.allVideos?.append(video)
            if idx < max {
                self.videos?.append(video)
            }
            idx += 1
        }
        self.subName = idx.description
        if let video = self.videos?.first{
            listHeight = video.type.size.height + video.bottomHeight + MultiBlockBody.tabHeight
        } else {
            listHeight = MultiBlockBody.tabHeight
        }
        return self
    }
    */
            
    func setData(_ data:BlockItem, themaType:ThemaType = .category) -> BlockData{
        name = data.menu_nm ?? ""
        menuId = data.menu_id
        cwCallId = data.cw_call_id_val
        isAdult = data.lim_lvl_yn?.toBool() ?? false
        cardType = findType(data)
        dataType = findDataType(data)
        blocks = data.blocks
        switch dataType {
        case .banner : self.originData = data
        default: break
        }
        uiType = findUiType(themaType:themaType)
        return self
    }
    
    func setDataKids(_ data:BlockItem) -> BlockData{
        name = data.menu_nm ?? ""
        menuId = data.menu_id
        cwCallId = data.cw_call_id_val
        if data.btm_bnr_blk_exps_cd == KidsHomeBlockData.code {
            self.uiType = .kidsHome
            self.dataType = .none
            self.cardType = .none
            self.blocks = data.blocks
        
        }  else {
            switch data.scn_mthd_cd {
            case  PageKidsMy.recentlyWatchCode:
                self.uiType = .video
                self.dataType = .cwGridKids
                self.cardType = .watchedVideo

            case  "522", "516":
                self.uiType = .poster
                self.dataType = .cwGridKids
                self.cardType = .smallPoster
            default :
                return self.setData(data)
            }
        }
        return self
    }
    
    func setDataKids(data:KidsGnbItemData, isTicket:Bool = false) -> BlockData{
        self.uiType = isTicket ? .kidsTicket : .kidsHome
        name = data.title ?? ""
        menuId = data.menuId
        self.dataType = .none
        self.cardType = .none
        self.blocks = data.blocks
        return self
    }
    
    func getRequestApi(apiId:String? = nil, pairing:PairingStatus, kid:Kid? = nil, sortType:EuxpNetwork.SortType? = nil, page:Int = 1, isOption:Bool = true) -> ApiQ? {
        self.kid = kid
        
        switch self.dataType {
        case .cwGrid:
            DataLog.d("Request cwGrid " + self.name, tag: "BlockProtocol")
            return .init(
                id: apiId ?? self.id,
                type: .getCWGrid(
                    self.menuId,
                    self.cwCallId),
                isOptional: isOption)
        case .cwGridKids:
            DataLog.d("Request cwGridKids " + self.name, tag: "BlockProtocol")
            return .init(
                id: apiId ?? self.id,
                type: .getCWGridKids(
                    kid,
                    self.cwCallId,
                    sortType ?? (self.cardType == .watchedVideo ? .latest : .popularity)),
                isOptional: isOption)
        case .grid:
            DataLog.d("Request grid " + self.name, tag: "BlockProtocol")
            return .init(
                id: apiId ?? self.id,
                type: .getGridEvent(self.menuId, sortType, page),
                isOptional: isOption)
            
        case .bookMark:
            if pairing != .pairing {
                DataLog.d("Request bookMark not pairing " + self.name, tag: "BlockProtocol")
                return nil
            }
            DataLog.d("Request bookMark " + self.name, tag: "BlockProtocol")
            return .init(
                id: apiId ?? self.id,
                type: .getBookMark(),
                isOptional: isOption)
        case .watched:
            if pairing != .pairing {
                DataLog.d("Request watche not pairing " + self.name, tag: "BlockProtocol")
                return nil
            }
            DataLog.d("Request watche " + self.name, tag: "BlockProtocol")
            return .init(
                id: apiId ?? self.id,
                type: .getWatch(),
                isOptional: isOption)
        case .banner:
            DataLog.d("Request banner " + self.name, tag: "BlockProtocol")
            return .init(
                id: apiId ?? self.id,
                type: .getEventBanner(self.menuId, .list),
                isOptional: isOption)
       
        default:
            DataLog.d("RequestFail " + self.name, tag: "BlockProtocol")
            return nil
        }
    }
        
    func setRequestFail(){
        if status != .initate { return }
        status = .passive
    }
    
    func setBlank(){
        if status != .initate { return }
        status = .passive
    }
    
    func setDatabindingCompleted(total:Int? = nil, parentTitle:String? = nil, modifyTitle:String? = nil){
        if self.status != .initate { return }
        if isCountView, let count = total {
            self.subName = count.description
        }
        if self.cardType == .rankingPoster , let posters = self.posters{
            zip(posters, 0...posters.count).forEach{ data , idx in
                data.setRank(idx)
            }
        }
        if let modifyTitle = modifyTitle { self.name = modifyTitle }
        self.parentTitle = parentTitle
        self.status = .active
    }
    
    func setError(_ err:ApiResultError?){
        if status != .initate { return }
        self.status = .passive
    }
    
    private func findType(_ data:BlockItem) -> CardType {
        if data.scn_mthd_cd == "504" { return .watchedVideo }
        else if data.svc_prop_cd == "501" { return .bookmarkedPoster }
        else if data.scn_mthd_cd == "501" || data.scn_mthd_cd == "507" { // block>scn_mthd_cd(상영 방식 코드)가 "501" or
            switch (data.blk_typ_cd, data.pst_exps_typ_cd, data.btm_bnr_blk_exps_cd) {
            case (_, "10", _): return data.svc_prop_cd == "522" ?.clip : .video
            case (_, "20", _): return .smallPoster //
            case (_, "40", _): return .bigPoster
            case (_, "30", _): return data.svc_prop_cd == "522" ?.clip : .video
            case (_, "50", _): return .rankingPoster
            default: return .none }
        } else {
            switch (data.blk_typ_cd, data.pst_exps_typ_cd, data.btm_bnr_blk_exps_cd) {
            case ("30", "10", _): return .video
            case ("30", "20", _): return .smallPoster
            case ("30", "40", _): return .bigPoster
            case ("30", "30", _): return data.svc_prop_cd == "522" ?.clip : .video
            case ("30", "50", _): return .rankingPoster
            case ("20", _, "05"): return .squareThema
            case ("20", _, "04"): return .circleTheme
            case ("20", _, "02"): return .bigTheme
            case ("20", _, "01"): return .squareThema
                
            case ("70", _, _):
                return data.exps_rslu_cd == "20" ? .bannerList : .banner
                
            default:
                if data.gnb_sub_typ_cd == "BP_03_04" && data.btm_bnr_blk_exps_cd == "03" { return .contentBanner }
                else if data.svc_prop_cd == "501" { return .bookmarkedPoster }
                else { return .none }
            }
            
        }
    }
    
    private func findDataType(_ data:BlockItem) -> DataType{
        if self.cardType == .banner {return .banner}
        if self.cardType == .bannerList {return .banner}
        
        if data.svc_prop_cd == "501", data.gnb_typ_cd == EuxpNetwork.GnbTypeCode.GNB_HOME.rawValue {
            return .bookMark
        } else if data.scn_mthd_cd == "501" || data.scn_mthd_cd == "507" {
            return .cwGrid
        } else if data.scn_mthd_cd == "504",
                  (data.gnb_typ_cd ==  EuxpNetwork.GnbTypeCode.GNB_HOME.rawValue ||
                    data.gnb_typ_cd == EuxpNetwork.GnbTypeCode.GNB_OCEAN.rawValue ||
                    data.gnb_typ_cd == EuxpNetwork.GnbTypeCode.GNB_MONTHLY.rawValue) {
            return .watched
        } else if data.blk_typ_cd == "20" {
            return .theme
        } else {
            return .grid
        }
    }
    
    private func findUiType(themaType:ThemaType) -> UiType{
        switch self.cardType {
        case .smallPoster, .bigPoster, .bookmarkedPoster, .rankingPoster :
            return .poster
        case .video, .watchedVideo, .clip:
            return .video
        case .circleTheme, .bigTheme, .squareThema :
            if themaType == .ticket {return .ticket}
            return .theme
        case .banner :
            return .banner
        case .bannerList :
            return .bannerList
        default:
            return .poster
        }
    }
    
    func getActionLog()->MenuNaviActionBodyItem {
        var actionBody = MenuNaviActionBodyItem()
        actionBody.menu_name = self.name.replace(" ", with: "")
        actionBody.menu_id = self.cwCallId ?? self.menuId
        actionBody.config = self.parentTitle?.replace(" ", with: "")
        actionBody.search_keyword = self.keyword
        //actionBody.target = self.parentTitle == nil ? "N" : "Y"
        return actionBody
    }
    
    enum CardType: String, Codable {
        case none,
        homeBigBanner,
        banner,
        bannerList,
        contentBanner,
        
        smallPoster,
        bigPoster,
        rankingPoster,
        bookmarkedPoster,
        
        watchedVideo,
        clip,
        video,
        
        circleTheme,
        bigTheme,
        squareThema
        
    }

    enum DataType: String, Codable {
        case none,
        bookMark,
        grid,
        watched,
        cwGrid,
        cwGridKids,
        theme,
        banner
    }
    
    enum UiType: String, Codable {
        case poster,
        video,
        theme,
        ticket,
        banner,
        tv,
        bannerList,
        kidsHome,
        kidsTicket
        
        var listType: CateBlock.ListType? {
            switch self {
            case .poster: return .poster
            case .video: return .video
            default : return nil
            }
        }
    }
    
    enum ThemaType: String, Codable {
        case category,
        ticket
    }
    
    enum SearchType: String, Codable {
        case none,
        vod,
        live,
        clip,
        demand,
        vodSeq
        
        var logType: String {
            switch self {
            case .vod, .vodSeq: return "vod"
            case .live: return "live"
            case .clip: return "clip"
            case .demand: return "demand"
            default : return ""
            }
        }
    }
}
