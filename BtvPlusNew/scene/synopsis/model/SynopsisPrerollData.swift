//
//  SynopsisPrerollData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/09.
//

import Foundation


enum SynopsisPrerollType {
    case continuous , first , seris , preplay, unowned
    var adCode: String {
        switch self {
        case .continuous : return "0"
        case .first: return "1"
        case .seris: return "2"
        case .preplay: return "3"
        default: return ""
        }
    }
}

class SynopsisPrerollData {
    private(set) var type:SynopsisPrerollType = .unowned
    private(set) var isFree:Bool = false
    private(set) var contentId:String = ""
    private(set) var productId:String = ""

    func setData(data:SynopsisModel, playType:SynopsisPlayType, epsdRsluId:String) -> SynopsisPrerollData{
       
        var startType:SynopsisPrerollType = .unowned
        if (data.isFree || data.isGstn) && (data.holdbackType == .none) {
            self.isFree = true
        }
        switch playType {
        case .vod(let t, _), .vodChange(let t, _): startType = t > 0 ? .continuous : .first
        case .vodNext : startType = .seris
        case .preplay : startType = .preplay
        case .preview : startType = .first
        default:do{}
        }
        
        self.type = startType
        self.contentId = epsdRsluId
        self.productId = data.curSynopsisItem?.prdPrcId ?? ""
        return self
        
    }
    
}
