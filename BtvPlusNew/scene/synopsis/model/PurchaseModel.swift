//
//  Purchas.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/21.
//

import Foundation
import TrueTime

class PurchaseModel {
    var originType: PurchasDataType = .none
    init(product: ProductItem){
        originType = .product
        epsdId = product.epsd_id ?? ""
        prdPrcId = product.prd_prc_id ?? ""
        prd_typ_cd = product.prd_typ_cd ?? ""
        asis_prd_typ_cd = product.asis_prd_typ_cd ?? ""
        prdPrcFrDt = product.prd_prc_fr_dt?.toDate(dateFormat:"yyyyMMddHHmmss", local:"ko_kr") ?? Date(timeIntervalSince1970: 0)
        prdPrcToDt = product.prd_prc_to_dt?.toDate(dateFormat:"yyyyMMddHHmmss", local:"ko_kr") ?? Date(timeIntervalSince1970: 0)
        purc_pref_rank = product.purc_pref_rank ?? ""
        isNScreen = product.nscrn_yn?.toBool() ?? false
        prd_prc_vat = product.prd_prc_vat ?? 0
        sale_prc_vat = product.sale_prc_vat ?? 0
        sale_prc = product.sale_prc ?? 0
        isFree = sale_prc_vat == 0
        ppm_prd_nm = nil
        ppm_prd_typ_cd = ""
        isUse =  product.use_yn?.toBool() ?? false
        isPossn =  product.possn_yn?.toBool() ?? false
        epsd_rslu_id =  product.epsd_rslu_id ?? ""
        rsluTypCd = RsluTypCd(value:  product.rslu_typ_cd ?? "")
        purc_wat_dd_fg_cd =  product.purc_wat_dd_fg_cd ?? ""
        purcWatDdFgCd = PurcWatDdFgCd(rawValue: purc_wat_dd_fg_cd) ?? .none
        purc_wat_dd_cnt =  product.purc_wat_dd_cnt ?? 0
        prdTypCd = PrdTypCd(rawValue: prd_typ_cd) ?? .none //isFree, psson_yn  사용중이라 뒤에 호출
        poc_det_typ_cd_list =  product.poc_det_typ_cd_list
        sale_tgt_fg_yn =  product.sale_tgt_fg_yn
        prd_prc_fr_dt_raw = product.prd_prc_fr_dt
        prd_prc_to_dt_raw = product.prd_prc_to_dt
        self.setupProductRank()
         
    }
    init(purchas: PurchasItem){
        self.originType = .purchase
        epsdId = purchas.epsd_id ?? ""
        prdPrcId = purchas.prd_prc_id ?? ""
        prd_typ_cd = purchas.prd_typ_cd ?? ""
        asis_prd_typ_cd = purchas.asis_prd_typ_cd ?? ""
        prdPrcFrDt = purchas.prd_prc_fr_dt?.toDate(dateFormat:"yyyyMMddHHmmss", local:"ko_kr") ?? Date(timeIntervalSince1970: 0)
        prdPrcToDt = purchas.prd_prc_to_dt?.toDate(dateFormat:"yyyyMMddHHmmss", local:"ko_kr") ?? Date(timeIntervalSince1970: 0)
        purc_pref_rank = purchas.purc_pref_rank ?? ""
        isNScreen = purchas.nscrn_yn?.toBool() ?? false
        lag_capt_typ_cd = purchas.lag_capt_typ_cd ?? ""
        lag_capt_typ_exps_yn = purchas.lag_capt_typ_exps_yn?.toBool() ?? false
        sale_prc = purchas.sale_prc ?? 0
        prd_prc_vat = purchas.prd_prc_vat ?? 0
        sale_prc_vat = purchas.sale_prc_vat ?? 0
        isFree = sale_prc_vat == 0
        ppm_prd_nm = purchas.ppm_prd_nm 
        ppmPrdTypCd = PpmPrdTypCd(rawValue: ppm_prd_typ_cd) ?? .none
        isUse =  purchas.use_yn?.toBool() ?? false
        isPossn =  purchas.possn_yn?.toBool() ?? false
        epsd_rslu_id =  purchas.epsd_rslu_id ?? ""
        rsluTypCd = RsluTypCd(value:  purchas.rslu_typ_cd ?? "")
        purc_wat_dd_fg_cd =  purchas.purc_wat_dd_fg_cd ?? ""
        purcWatDdFgCd = PurcWatDdFgCd(rawValue: purc_wat_dd_fg_cd) ?? .none
        purc_wat_dd_cnt =  purchas.purc_wat_dd_cnt ?? 0
        prdTypCd = PrdTypCd(rawValue: prd_typ_cd) ?? .none //isFree, psson_yn  사용중이라 뒤에 호출
        poc_det_typ_cd_list =  purchas.poc_det_typ_cd_list
        sale_tgt_fg_yn =  purchas.sale_tgt_fg_yn
        prd_prc_fr_dt_raw = purchas.prd_prc_fr_dt
        prd_prc_to_dt_raw = purchas.prd_prc_to_dt
        self.setupProductRank()
    }
    
    func setupSynopsis(_ contents:SynopsisContentsItem, idx:Int){
        self.sris_id = contents.sris_id ?? ""
        self.index = idx
        self.title = contents.title ?? ""
        self.sson_choic_nm = contents.sson_choic_nm ?? ""
        if let series = contents.series_info {
            if let seris =  series.first(where: { self.epsdId == $0.epsd_id }) {
                self.brcast_tseq_nm = seris.brcast_tseq_nm ?? ""
            }
        }
        if self.originType == .product {
            self.lag_capt_typ_exps_yn = contents.lag_capt_typ_exps_yn?.toBool() ?? false
        }
    }
    
    
    var mePPVProduct: PPVProductItem? {
        didSet {
            guard let item = mePPVProduct else { return }
            isDirectview = item.yn_directview?.toBool() ?? self.isDirectview
            isPurchase = item.yn_purchase?.toBool() ?? self.isPurchase
            period = item.period?.toInt() ?? self.period
            period_hour = item.period_hour?.toInt() ?? self.period_hour
            period_min = item.period_min?.toInt() ?? self.period_min
            end_date = item.end_date ?? self.end_date
            
        }
    }
    
    var mePPSProduct: PPSProductItem? {
        didSet {
            guard let item = mePPSProduct else { return }
            isDirectview = item.yn_directview?.toBool() ?? self.isDirectview
            isPurchase = item.yn_purchase?.toBool() ?? self.isPurchase
            period = item.period?.toInt() ?? self.period
            period_hour = item.period_hour?.toInt() ?? self.period_hour
            period_min = item.period_min?.toInt() ?? self.period_min
            end_date = item.end_date ?? self.end_date
        }
    }
   
    //구매했을 때 노출 우선순위
    //월정액, 기간권(0) > 소장(3) > 무료(4) > 대여(시리즈, 5)
    // metv 월정액/기간권.
    private(set) var prdTypCd: PrdTypCd = .none
    private(set) var purchaseProductRank: Int = 999
    private func setupProductRank(){
        switch prdTypCd {
        case .vodppm, .vodppmterm, .cbvodppm, .relvodppm:
        purchaseProductRank = 10
        default:
            if isPossn {
               purchaseProductRank = 30
               if prdTypCd == .ppv {
                   purchaseProductRank += 5
               }
           } else if isFree {
               purchaseProductRank = 40
               //대여
           } else {
               purchaseProductRank = 50
               if prdTypCd == .ppv {
                   purchaseProductRank += 5
               }
           }
        }
    }
    
    
    
    var purRank: Int { self.isDirectview ? 50 : 0 }
    var purStateText: String {
        if let subType = LagCaptTypCd(rawValue: lag_capt_typ_cd) {
            let lagTyps: [LagCaptTypCd] = [.korean, .cndubbing, .endubbing]
            if lagTyps.contains(subType) {
                return subType.name
            } else {
                return String.sort.subtitle
            }
        } else {
            return String.sort.dubbing
        }
    }
    var isSalesPeriod: Bool {
        let trueTime = TrueTimeClient.sharedInstance.referenceTime?.now() ?? Date()
        return trueTime.isBetween(prdPrcFrDt, and: prdPrcToDt)
    }
    
    private(set) var isDirectview: Bool = false //metv
    func forceModifyDirectview(){ self.isDirectview = true }
    private(set) var epsd_rslu_id: String = ""
    func forceModifyEpsdRsluId(_ id:String){ self.epsd_rslu_id = id }
    private(set) var epsdId: String = ""
    func forceModifyEpsdId(_ id:String){ self.epsdId = id }

    var purSubstateText: String { isPossn ? String.app.owner : String.app.rent }
    var pssonRank: Int { isPossn ? 20 : 10 }
    var isRentPeriod: Bool { period != -1 || period_hour != -1 || period_min != -1 }
    var purcWatDDay: String { purc_wat_dd_cnt.description + purcWatDdFgCd.name }
    var salePrice: String {
        let price  = self.sale_prc_vat 
        return price.formatted(style: .decimal) + String.app.cash
    }
    var hasAuthority: Bool { self.isFree || self.isDirectview }
    
    
    private(set) var ppmPrdTypCd: PpmPrdTypCd = .none
    private(set) var rsluTypCd: RsluTypCd = .none
    private(set) var purcWatDdFgCd: PurcWatDdFgCd = .none
    
    private(set) var isNScreen: Bool = false
    private(set) var isFree = false
    private(set) var isPurchase: Bool = false //metv 패키지 구매 여부
    private(set) var isUse: Bool = false
    private(set) var isPossn: Bool = false // 소장 / 대여
    
    private(set) var prdPrcFrDt: Date = Date(timeIntervalSince1970: 0)
    private(set) var prdPrcToDt: Date = Date(timeIntervalSince1970: 0)
    
    private(set) var title = ""
    private(set) var index: Int = 0
    private(set) var sson_choic_nm = ""
    private(set) var brcast_tseq_nm = ""
    private(set) var lag_capt_typ_exps_yn: Bool = false //언어자막 지원
    
    private(set) var prd_typ_cd: String = ""
    private(set) var asis_prd_typ_cd: String = ""
    private(set) var prdPrcId: String = ""
    private(set) var purc_pref_rank: String = "0"
    private(set) var lag_capt_typ_cd: String = "0"
    private(set) var prd_prc_vat: Double = 0
    private(set) var sale_prc_vat: Double = 0
    private(set) var sale_prc: Double = 0
    private(set) var ppm_prd_nm: String? = nil
    private(set) var ppm_prd_typ_cd: String = "0"
    private(set) var period: Int = -1
    private(set) var period_hour: Int = -1
    private(set) var period_min: Int = -1
    private(set) var end_date: String = "" //metv 만료 날짜
    private(set) var sris_id: String = ""
    private(set) var origin_epsd_rslu_id = ""
    private(set) var purc_wat_dd_fg_cd: String = ""
    private(set) var purc_wat_dd_cnt: Int = -1
    private(set) var sale_tgt_fg_yn: String?
    private(set) var prd_prc_fr_dt_raw: String?
    private(set) var prd_prc_to_dt_raw: String?
    private(set) var poc_det_typ_cd_list: [String]?
    
    var debugString: String {
        var msg = "Raw. prd. #\(asis_prd_typ_cd) "
        let startDate = prdPrcFrDt.description
        let endDate = prdPrcToDt.description
        let prdType = prdTypCd.name
        msg.append("타입: \(prd_typ_cd) (\(prdType)) id:(\(prdPrcId))")
        msg.append(", epsdId: \(epsdId)")
        msg.append(", 화질: \(rsluTypCd)")
        msg.append(", 월정액: \(ppm_prd_nm ?? "")")
        msg.append(", 구매순위: \(purc_pref_rank)")
        msg.append(", 가격: \(sale_prc)")
        msg.append(", 가격(vat): \(sale_prc_vat)")
        msg.append(", 판매: \(isUse.description)")
        msg.append(", 바로보기: \(isDirectview.description)")
        msg.append(", 무료보기: \(isFree.description)")
        msg.append(", \(purSubstateText)")
        msg.append(", 판매기간: \(startDate)~\(endDate)")
        msg.append(", 판매중: \(isSalesPeriod.description)")
        msg.append(", 옵션: \(purStateText)")
        
        return msg
    }
}


public enum PurchasDataType {
    case none , product ,purchase
}


