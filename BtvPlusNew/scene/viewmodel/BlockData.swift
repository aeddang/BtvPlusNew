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
    private(set) var openId:String? = nil
  
  
    var errorMassage:String? = nil
    
    @Published private(set) var status:BlockStatus = .initate
    
    var kid:Kid? = nil
    var usePrice:Bool = true
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
    private(set) var logType:MultiBlockLogType = .list
    private(set) var totalBlockNum:Int  = 0
    private(set) var currentBlockIndex:Int  = 0
    init(pageType:PageType = .btv, logType:MultiBlockLogType = .list, idx:Int = -1, totalBlockNum:Int = 0) {
        self.pageType = pageType
        self.logType = logType
        self.totalBlockNum = totalBlockNum
        self.currentBlockIndex = idx
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
    func setData(grids:[GridsItemKids], usePrice:Bool = true) -> BlockData{
        self.usePrice = usePrice
        childrenBlock = grids.map{ g in
            BlockData(pageType: .kids, logType: self.logType,  idx:self.currentBlockIndex, totalBlockNum: self.totalBlockNum)
                .setData(parent:self, grid: g, usePrice: usePrice)
        }
        return self
    }
    @discardableResult
    func setData(grids:[GridsItem], usePrice:Bool = true) -> BlockData{
        self.usePrice = usePrice
        childrenBlock = grids.map{ g in
            BlockData(logType: self.logType, idx:self.currentBlockIndex, totalBlockNum: self.totalBlockNum)
                .setData(parent:self, grid: g, usePrice: usePrice)
        }
        return self
    }
    
    func setData(parent:BlockData, grid:GridsItemKids, usePrice:Bool = true) -> BlockData{
        self.uiType = parent.uiType
        self.cardType = parent.cardType
        self.dataType = parent.dataType
        self.name = grid.sub_title ?? parent.name
        self.cwCallId = parent.cwCallId
        self.usePrice = usePrice
        let max = MultiBlockBody.maxCellCount
        if let blocks = grid.block {
            switch self.uiType {
            case .poster :
                posters = blocks[0...min(max, blocks.count-1)].map{ d in
                    PosterData(pageType: .kids, usePrice:usePrice).setData(data: d, cardType: cardType)
                }
            case .video :
                videos = blocks[0...min(max, blocks.count-1)].map{ d in
                    VideoData(pageType: .kids, usePrice:usePrice).setData(data: d, cardType: cardType)
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
    
    func setData(parent:BlockData, grid:GridsItem, usePrice:Bool = true) -> BlockData{
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
                    PosterData(usePrice:usePrice).setData(data: d, cardType: cardType)
                }
            case .video :
                videos = blocks[0...min(max, blocks.count-1)].map{ d in
                    VideoData(usePrice:usePrice).setData(data: d, cardType: cardType)
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
    
    
    func setData(title:String, cardType:CardType, dataType:DataType, uiType:UiType, menuId:String? = nil, isCountView:Bool = false, usePrice:Bool = true) -> BlockData{
        self.usePrice = usePrice
        self.name = title
        self.cardType = cardType
        self.dataType = dataType
        self.uiType = uiType
        self.menuId = menuId
        self.isCountView = isCountView
        return self
    }
    
    func setData(title:String, datas:[PosterData], searchType:SearchType,
                 keyword:String?, max:Int = 30, usePrice:Bool = true) -> BlockData{
        name = title
        uiType = .poster
        self.usePrice = usePrice
        self.searchType = searchType
        self.allPosters = datas
        let len = min(datas.count, max)
        self.posters = datas.isEmpty ? datas : datas[0..<len].map{$0.copy()}
        let type = self.posters?.first?.pageType ?? .btv
        self.listHeight = (self.posters?.first?.type.size.height ?? 0)
            + ( type == .btv ? MultiBlockBody.tabHeight : MultiBlockBody.tabHeightKids  )
        self.setCountName(count: datas.count)
        return self
    }
    
    func setData(title:String, datas:[VideoData], searchType:SearchType,
                 keyword:String?, max:Int = 20, usePrice:Bool = true) -> BlockData{
        name = title
        uiType = .video
        cardType = (searchType == .clip) ? .clip : .video
        self.usePrice = usePrice
        self.searchType = searchType
        self.allVideos = datas
        let len = min(datas.count, max)
        self.videos = datas.isEmpty ? datas : datas[0..<len].map{$0.copy()}
        self.setCountName(count: datas.count)
        let type = self.videos?.first?.pageType ?? .btv
        if let video = self.videos?.first{
            let bottom = video.bottomHeight
            listHeight = video.type.size.height + bottom
                + ( type == .btv ? MultiBlockBody.tabHeight : MultiBlockBody.tabHeightKids  )
        } else {
            listHeight = MultiBlockBody.tabHeight
        }
        return self
    }
    
    func setData(title:String, datas:[TvData], searchType:SearchType,
                 keyword:String?, max:Int = 20, usePrice:Bool = true) -> BlockData{
        name = title
        uiType = .tv
        self.usePrice = usePrice
        self.allTvs = datas
        self.searchType = searchType
        let len = min(datas.count, max)
        self.tvs = datas.isEmpty ? datas : datas[0..<len].map{$0.copy()}
        self.listHeight = (self.tvs?.first?.type.size.height ?? 0) + MultiBlockBody.tabHeight
        self.setCountName(count: datas.count)
        return self
    }
    
    private func setCountName(count:Int){
        if self.pageType == .btv {
            self.subName = count.description
        } else {
            self.subName = "(" + count.description + String.app.count + ")"
        }
    }
    

            
    func setData(_ data:BlockItem, themaType:ThemaType = .category) -> BlockData{
        name = data.menu_nm ?? ""
        menuId = data.menu_id
        cwCallId = data.cw_call_id_val
        isAdult = data.lim_lvl_yn?.toBool() ?? false
        cardType = findType(data)
        dataType = findDataType(data)
        blocks = data.blocks
        if isAdult {
            if blocks?.first(where: {($0.lim_lvl_yn?.toBool() ?? false) == false}) != nil {
                isAdult = false
            }
        }
        switch dataType {
        case .banner : self.originData = data
        default: break
        }
        uiType = findUiType(themaType:themaType)
        return self
    }
    
    func setDataKids(_ data:BlockItem, usePrice:Bool = true)-> BlockData{
        self.name = data.menu_nm ?? ""
        self.menuId = data.menu_id
        self.usePrice = usePrice
        self.cwCallId = data.cw_call_id_val
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
        if self.uiType == .ticket && self.blocks?.count == 1,
           let ticket = self.blocks?.first {
            
            let ticketData = TicketData().setData(data: ticket)
            return ticketData.type == .big
                ? .init(id:apiId ?? self.id,
                             type:
                                .getGridEvent(ticket.menu_id),
                             isOptional: isOption)
                : nil
        }
         
        
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
                type: .getBookMark(0, 60),
                isOptional: isOption)
        case .watched:
            if pairing != .pairing {
                DataLog.d("Request watche not pairing " + self.name, tag: "BlockProtocol")
                return nil
            }
            DataLog.d("Request watche " + self.name, tag: "BlockProtocol")
            return .init(
                id: apiId ?? self.id,
                type: .getWatchMobile(),
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
    
    //kids tab menu
    private var logPageTitle:String? = nil
    private var logTabTitle:String? = nil
    func setupActionLog(pageTitle:String?, tabTitle:String?) -> BlockData {
        self.logPageTitle = pageTitle
        self.logTabTitle = tabTitle
        return self
    }
    
    func setDatabindingCompleted(
        total:Int? = nil,
        parentTitle:String? = nil,
        modifyTitle:String? = nil,
        openId:String? = nil,
        idx:Int = -1)
    {
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
        self.openId = openId // 키즈홈에서 자동 메뉴이동
        self.parentTitle = parentTitle
        self.status = .active
        let isRace = self.cwCallId?.contains("RACE") ?? false
        var action = MenuNaviActionBodyItem(
            menu_id: self.menuId,
            menu_name: self.name,
            config: parentTitle,
            target: isRace ? "Y" : "N"
        )
        if let logPageTitle = self.logPageTitle {
            action.config = logPageTitle
            action.target = self.logTabTitle
        }
        
        
        if let datas = self.posters {
            let count = datas.count
            let pageType = self.posters?.first?.pageType
            zip(0...count, datas).forEach{idx, data in
                if pageType == .kids && logType == .list {
                    action.position = (idx+1).description + "@" + count.description
                    action.category = data.synopsisType.logCategory
                    action.result = data.synopsisType.logResult
                    data.setNaviLogKids(action: action)
                } else {
                    if self.totalBlockNum > 0 {
                        action.position = (idx+1).description + "@"
                        + (self.currentBlockIndex+1).description + "@"
                        + self.totalBlockNum.description
                    } else {
                        action.position = (idx+1).description + "@"
                        + count.description
                    }
                    
                    action.category = data.synopsisType.logCategory
                    action.result = data.synopsisType.logResult
                    switch self.logType {
                    case .home :  data.setNaviLogHome(action: action)
                    case .list :  data.setNaviLog(action: action)
                    }
                }
            }
        }
        
        if let datas = self.videos {
            let count = datas.count
            let pageType = self.videos?.first?.pageType
            zip(0...count, datas).forEach{idx, data in
                if pageType == .kids && logType == .list{
                    action.position = (idx+1).description + "@" + count.description
                    action.category = data.synopsisType.logCategory
                    action.result = data.synopsisType.logResult
                    data.setNaviLogKids(action: action)
                } else {
                    if self.totalBlockNum > 0 {
                        action.position = (idx+1).description + "@"
                        + (self.currentBlockIndex+1).description + "@"
                        + self.totalBlockNum.description
                    } else {
                        action.position = (idx+1).description + "@"
                        + count.description
                    }
                    
                    action.category = data.synopsisType.logCategory
                    action.result = data.synopsisType.logResult
                    switch self.logType {
                    case .home :  data.setNaviLogHome(action: action)
                    case .list :  data.setNaviLog(action: action)
                    }
                }
            }
        }
    }
    
    
    
    func getActionLog()->MenuNaviActionBodyItem {
        var actionBody = MenuNaviActionBodyItem()
        actionBody.menu_name = self.name.replace(" ", with: "")
        actionBody.menu_id = self.cwCallId ?? self.menuId
        actionBody.search_keyword = self.keyword
        if let logPageTitle = self.logPageTitle {
            actionBody.config = logPageTitle
            actionBody.target = self.logTabTitle
        } else {
            actionBody.config = self.parentTitle?.replace(" ", with: "")
            actionBody.target = (self.cwCallId?.contains("RACE") ?? false) ? "Y" : "N"
        }
        if self.totalBlockNum > 0 {
            actionBody.position = (self.currentBlockIndex+1).description + "@" + self.totalBlockNum.description
        }
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
