//
//  Black.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/14.
//

import Foundation
import SwiftUI

enum CardType: String, Codable {
    case none,
    homeBigBanner,
    smallVod, bigVod,
    watched,
    thumb,
    smCircle,
    bgCircle,
    square,
    ranking,
    banner,
    bannerContent,
    bookmarked,
    cwSmallVod,
    cwthumb,
    cwranking,
    cwBigVod,
    oneDepthGrid,
    dropDownGrid,
    oceanJoinLead
}

class Block:Identifiable {
    private(set) var id = UUID().uuidString
    private(set) var name:String = ""
    private(set) var menuId:String = ""
    private(set) var type:CardType = .none
  
    func setDate(_ data:BlockItem) -> Block{
        name = data.menu_nm ?? ""
        menuId = data.menu_id ?? ""
        type = findType(data)
        return self
    }
    
    private func findType(_ data:BlockItem) -> CardType {
        if data.scn_mthd_cd == "504" { return .watched }
        else if data.svc_prop_cd == "501" { return .bookmarked }
        else if data.scn_mthd_cd == "501" || data.scn_mthd_cd == "507" { // block>scn_mthd_cd(상영 방식 코드)가 "501" or
            switch (data.blk_typ_cd, data.pst_exps_typ_cd, data.btm_bnr_blk_exps_cd) {
            case (_, "10", _): return .thumb
            case (_, "20", _): return .smallVod //
            case (_, "40", _): return .bigVod
            case (_, "30", _): return .thumb
            case (_, "50", _): return .ranking
            default: return .none }
        } else {
            switch (data.blk_typ_cd, data.pst_exps_typ_cd, data.btm_bnr_blk_exps_cd) {
            case ("30", "10", _): return .thumb
            case ("30", "20", _): return .smallVod
            case ("30", "40", _): return .bigVod
            case ("30", "30", _): return .thumb
            case ("30", "50", _): return .ranking
            case ("20", _, "05"): return .square
            case ("20", _, "04"): return .smCircle
            case ("20", _, "02"): return .bgCircle
            case ("20", _, "01"): return .square
            case ("70", _, _): return .banner
            default:
                if data.gnb_sub_typ_cd == "BP_03_04" && data.btm_bnr_blk_exps_cd == "03" { return .bannerContent }
                else if data.svc_prop_cd == "501" { return .bookmarked }
                else { return .none }
            }
        }
    }
}
