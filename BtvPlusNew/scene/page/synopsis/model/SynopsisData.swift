//
//  SynopsisData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/21.
//

import Foundation

struct SynopsisData {
    var srisId:String? = nil
    var searchType:String? = nil
    var epsdId:String? = nil
    var epsdRsluId:String? = nil
    var prdPrcId:String? = nil
    var kidZone:String? = nil
}

class SynopsisModel {
    
    
    private(set) var srisId:String? = nil
    private(set) var ppvProducts: Array< [String:String] > = []
    private(set) var ppsProducts: Array< [String:String] > = []
    private(set) var synopsisType:MetvNetwork.SynopsisType
    init(type:MetvNetwork.SynopsisType = .none ) {
        self.synopsisType = type
    }
    
    func setData(data:Synopsis) -> SynopsisModel {
        if synopsisType == .seasonFirst {
            if data.contents?.sris_typ_cd == EuxpNetwork.SrisTypCd.title.rawValue {
                self.synopsisType = .title
            }
        }
        
        self.srisId = data.contents?.sris_id
        var productsPpv: Array< [String:String] > = []
        var purchasPpv: Array< [String:String] > = []
        
        if let products = data.contents?.products {
            productsPpv = products.map {  product in
                var set = [String: String]()
                set["prd_prc_id"] = product.prd_prc_id
                set["epsd_id"] = product.epsd_id
                set["yn_prd_nscreen"] = data.contents?.nscrn_yn ?? "N"
                set["prd_typ_cd"] = product.prd_typ_cd
                set["purc_pref_rank"] = product.purc_pref_rank
                set["possn_yn"] = product.possn_yn
                return set
            }
        }
        if let purchares = data.purchares {
            purchasPpv = purchares.map { purchas in
                var set = [String: String]()
                set["prd_prc_id"] = purchas.prd_prc_id
                set["epsd_id"] = purchas.epsd_id
                set["yn_prd_nscreen"] = data.contents?.nscrn_yn ?? ""
                set["prd_typ_cd"] = purchas.prd_typ_cd
                set["purc_pref_rank"] = purchas.purc_pref_rank
                set["possn_yn"] = purchas.possn_yn
                return set
            }
        }
        switch self.synopsisType {
        case .seasonFirst :
            self.ppvProducts = productsPpv
            self.ppsProducts = purchasPpv
            
            var defaultSet = [String: String]()
            defaultSet["prd_prc_id"] = "0"
            defaultSet["epsd_id"] = "0"
            defaultSet["yn_prd_nscreen"] = "N"
            defaultSet["prd_typ_cd"] = "10"
            defaultSet["purc_pref_rank"] = "0200"
            defaultSet["possn_yn"] = "N"
            
            if self.ppvProducts.count == 0 { self.ppvProducts.append(defaultSet) }
            if self.ppsProducts.count == 0 { self.ppsProducts.append(defaultSet) }
        case .seriesChange :
            self.ppvProducts = productsPpv
        case .title :
            self.ppvProducts = purchasPpv
        case .none: do{}
        }
        return self
    }
}
