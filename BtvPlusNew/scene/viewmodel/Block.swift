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

class Block:Identifiable, ObservableObject, Equatable{
    private(set) var id = UUID().uuidString
    private(set) var name:String = ""
    private(set) var menuId:String? = nil
    private(set) var cwCallId:String? = nil
    private(set) var cardType:CardType = .none
    private(set) var dataType:DataType = .none
    private(set) var blocks:[BlockItem]? = nil
    private(set) var originData:BlockItem? = nil
    @Published private(set) var status:BlockStatus = .initate
    
    public static func == (l:Block, r:Block)-> Bool {
        return l.id == r.id
    }
    
    func reset(){
        status = .initate
    }
        
    func setDate(_ data:BlockItem) -> Block{
        name = data.menu_nm ?? ""
        menuId = data.menu_id
        cwCallId = data.cw_call_id_val
        cardType = findType(data)
        dataType = findDataType(data)
        blocks = data.blocks
        switch cardType {
        case .banner: self.originData = data
        default: break
        }
        return self
    }
    
    func getRequestApi(apiId:String? = nil, sortType:EuxpNetwork.SortType? = Optional.none, page:Int = 1, isOption:Bool = true) -> ApiQ? {
        switch self.dataType {
        case .cwGrid:
            DataLog.d("Request cwGrid " + self.name, tag: "BlockProtocol")
            return .init(
                id: apiId ?? self.id,
                type: .getCWGrid(
                    self.menuId,
                    self.cwCallId),
                isOptional: isOption)
        case .grid:
            DataLog.d("Request grid " + self.name, tag: "BlockProtocol")
            return .init(
                id: apiId ?? self.id,
                type: .getGridEvent(self.menuId, sortType, page),
                isOptional: isOption)
            
        case .bookMark:
            DataLog.d("Request bookMark " + self.name, tag: "BlockProtocol")
            return .init(
                id: apiId ?? self.id,
                type: .getBookMark(),
                isOptional: isOption)
        case .watched:
            DataLog.d("Request watche " + self.name, tag: "BlockProtocol")
            return .init(
                id: apiId ?? self.id,
                type: .getWatch(false),
                isOptional: isOption)
        case .banner:
            DataLog.d("Request banner " + self.name, tag: "BlockProtocol")
            return .init(
                id: apiId ?? self.id,
                type: .getEventBanner(self.menuId, .list),
                isOptional: isOption)
       
        default:
            DataLog.d("onRequestFail " + self.name, tag: "BlockProtocol")
            return nil
        }
        
    }
        
    var posters:[PosterData]? = nil {
        didSet{
            if posters != nil {
                status = posters!.isEmpty ? .passive : .active
                //DataLog.d(name + " " + posters!.count.description + " " + status.rawValue, tag: "BlockProtocol")
            }
        }
    }
    
    var videos:[VideoData]? = nil {
        didSet{
            if videos != nil {
                status = videos!.isEmpty ? .passive : .active
                //DataLog.d(name + " " + videos!.count.description + " " + status.rawValue, tag: "BlockProtocol")
            }
        }
    }
    
    var themas:[ThemaData]? = nil {
        didSet{
            if themas != nil {
                status = themas!.isEmpty ? .passive : .active
               //DataLog.d(name + " " + themas!.count.description + " " + status.rawValue, tag: "BlockProtocol")
            }
        }
    }
    
    var banners:[BannerData]? = nil {
        didSet{
            if banners != nil {
                status = banners!.isEmpty ? .passive : .active
               //DataLog.d(name + " " + themas!.count.description + " " + status.rawValue, tag: "BlockProtocol")
            }
        }
    }
    
    func setRequestFail(){
        status = .passive
    }
    
    func setBlank(){
        status = .passive
    }
    
    func setDatabindingCompleted(){
        status = .active
    }
    
    func setError(_ err:ApiResultError?){
        status = .passive
    }
    
    
    private func findType(_ data:BlockItem) -> CardType {
        if data.scn_mthd_cd == "504" { return .watchedVideo }
        else if data.svc_prop_cd == "501" { return .bookmarkedPoster }
        else if data.scn_mthd_cd == "501" || data.scn_mthd_cd == "507" { // block>scn_mthd_cd(상영 방식 코드)가 "501" or
            switch (data.blk_typ_cd, data.pst_exps_typ_cd, data.btm_bnr_blk_exps_cd) {
            case (_, "10", _): return .video
            case (_, "20", _): return .smallPoster //
            case (_, "40", _): return .bigPoster
            case (_, "30", _): return .video
            case (_, "50", _): return .rankingPoster
            default: return .none }
        } else {
            switch (data.blk_typ_cd, data.pst_exps_typ_cd, data.btm_bnr_blk_exps_cd) {
            case ("30", "10", _): return .video
            case ("30", "20", _): return .smallPoster
            case ("30", "40", _): return .bigPoster
            case ("30", "30", _): return .video
            case ("30", "50", _): return .rankingPoster
            case ("20", _, "05"): return .squareThema
            case ("20", _, "04"): return .circleTheme
            case ("20", _, "02"): return .bigTheme
            case ("20", _, "01"): return .squareThema
            case ("70", _, _): return .banner
            default:
                if data.gnb_sub_typ_cd == "BP_03_04" && data.btm_bnr_blk_exps_cd == "03" { return .contentBanner }
                else if data.svc_prop_cd == "501" { return .bookmarkedPoster }
                else { return .none }
            }
        }
    }
    
    
    private func findDataType(_ data:BlockItem) -> DataType{
        if self.cardType == .banner {return .banner}
        
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
    
    enum CardType: String, Codable {
        case none,
        homeBigBanner,
        banner,
        contentBanner,
        
        smallPoster,
        bigPoster,
        rankingPoster,
        bookmarkedPoster,
        
        watchedVideo,
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
        theme,
        banner
    }
}
