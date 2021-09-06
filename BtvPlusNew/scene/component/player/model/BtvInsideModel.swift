//
//  BtvInsideModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/06.
//

import Foundation
import SwiftUI

class CookieInfo:Identifiable {
    private(set) var id:String = UUID().uuidString
    var index:Int = -1
    private(set) var startTime:Double = -1
    private(set) var endTime:Double = -1
    
    func setData(data:InsideSceneItem , idx:Int = -1) -> CookieInfo {
        startTime = data.tmtag_fr_tmsc ?? -1
        endTime = data.tmtag_to_tmsc ?? -1
        index = idx
        return self
    }
}


class BtvInsideModel:ObservableObject{
    private(set) var cookies:[CookieInfo]? = nil
    private(set) var searchTime:Double = -1
    private(set) var epsdId:String? = nil
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    func reset(epsdId:String?){
        self.cookies = nil
        self.searchTime = -1
        self.epsdId = epsdId
        self.isUpdate = true
    }
    
    @discardableResult
    func setData(data:InsideInfo)->BtvInsideModel{
        self.cookies = data.inside_info?.scenes?
            .filter{$0.scne_typ_code == "50"}
            .filter{$0.scne_dts_seq != nil}
            .map{CookieInfo().setData(data: $0)}.sorted(by: {$0.startTime < $1.startTime})
        if let cookies = self.cookies {
            zip(0...cookies.count, cookies).forEach{ idx ,cookie in
                cookie.index = idx+1
            }
        }
        
        self.searchTime = self.cookies?.first?.startTime ?? -1
        self.isUpdate = true
        return self
    }
}


