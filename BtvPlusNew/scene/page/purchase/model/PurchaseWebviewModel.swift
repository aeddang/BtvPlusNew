//
//  PurchaseModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/17.
//

import Foundation
import Foundation
import SwiftUI
enum PurchaseSynopsisType {
    case season, title, package
    var code:String {
        get {
            switch self {
            case .season: return "02"
            case .title: return "01"
            case .package: return "03"
            }
        }
    }
}

enum PurchasePType {
    case ppv, pps, ppm, ppp, pkg
    var code:String {
        get {
            switch self {
            case .ppv: return "10"
            case .pps: return "20"
            case .ppm: return "30"
            case .ppp: return "40"
            case .pkg: return "41"
            }
        }
    }
    static func getType(_ value:String?) -> PurchasePType{
        switch value {
            case "10": return .ppv
            case "20": return .pps
            case "30": return .ppm
            case "40": return .ppp
            default : return .ppm
        }
    }
}
    
class PurchaseWebviewModel {
    var epsdIds:[String] = [] // 에피소드 ID    여러 개일 경우 입력 값 포맷: URL Encoding(<id>,<id>,<id>)
    var srisId:String = "" // 시리즈 ID
    var synopsisType:PurchaseSynopsisType = .title //진입한 시놉시스 유형(01 : 단편 시놉, 02 : 시즌 시놉)
    var ptype: PurchasePType = .ppv  // 상품 Type(10 : ppv, 20 : pps, 30: ppm, 41: ppp)    * pps는 시리즈 전편 구매 시에 사용(전편이 아닌 경우 ppv)
    var conTitle: String = ""  // 구입할 콘텐츠 제목(구매 화면에 제목 노출에 사용) URL Encoding
    var seriesNo: String? = nil  // 시리즈의 회차(시리즈 상품 구매 시 회차 노출에 사용)
    var pid: String? = nil   // 월정액 상품 ID, 패키지 상품 ID
    var exceptPids: [String]? = nil // 구매화면에서 노출을 제한할 PID    입력 값 포맷: URL Encoding(<id>,<id>,<id>)    입력 값 샘플: test5959437%2Ctest5959437%2Ctest5959437    * 미노출해야 되는 상품이 있는 경우 사용
    var pidOnly: String? = nil  // dyjung_20201124 : 월정액 가입
    
    var gurry:String {
        get{
            var q =
                "?epsd_id=" + (epsdIds.isEmpty ? "" :  epsdIds.dropFirst().reduce(epsdIds.first!, {$0 + "," + $1}))
                + "&sris_id=" + srisId
                + "&synopsis_type=" + synopsisType.code
                + "&ptype=" + ptype.code
                + "&conTitle=" + conTitle
            if let value = seriesNo { q = q + "&seriesNo=" + value }
            if let value = pid { q = q + "&pid=" + value }
            if let value = exceptPids { q = q + "&except_pid=" + (value.isEmpty ? "" : value.dropFirst().reduce(value.first!, {$0 + "," + $1})) }
            if let value = pidOnly { q = q + "&pidOnly=" + value }
            return q
        }
    }
    
    func reset(){
        epsdIds = []
        srisId = ""
        synopsisType = .title
        ptype = .ppv
        conTitle = ""
        seriesNo = nil
        pid = nil
        exceptPids = nil
        pidOnly = nil
        synopsisData = nil
    }
    
    @discardableResult
    func addEpsdId(epsdId: String?) -> PurchaseWebviewModel{
        guard let epsdId = epsdId else { return self}
        let find = epsdIds.first(where: {$0 == epsdId})
        if find == nil { epsdIds.append(epsdId) }
        return self
    }
    
    @discardableResult
    func addExcepPid(pid: String?) -> PurchaseWebviewModel{
        guard let pid = pid else { return self}
        if exceptPids == nil { exceptPids = [] }
        let find = exceptPids!.first(where: {$0 == pid})
        if find == nil { exceptPids!.append(pid) }
        return self
    }
    /*
     * 일반 시놉인 경우 구매
     */
    var synopsisData:Synopsis? = nil
    @discardableResult
    func setParam(synopsisData: Synopsis) -> PurchaseWebviewModel{
        self.synopsisData = synopsisData
        return self
    }
    @discardableResult
    func setParam(directView:DirectView? , monthlyPid: String?) -> PurchaseWebviewModel{
       
        func checkPurchase(pid: String?) -> Bool {
            guard let pid = pid else { return false}
            if directView?.ppv_products?.first(where: {$0.prd_prc_id == pid && $0.yn_directview == "Y"}) != nil { return true }
            if directView?.pps_products?.first(where: {$0.prd_prc_id == pid && $0.yn_directview == "Y"}) != nil { return true }
            return false
        }
        guard let epsdId = synopsisData?.contents?.epsd_id else { return self }
        var isPPS = false
        if let srisTypCd = synopsisData?.contents?.sris_typ_cd {
            if srisTypCd == "01" { isPPS = true }
        }
        //me061Info
        //단편일 때 metv.ppv = contetns.purchase
        //시즌처음일 때 metv.ppv = contetns.proudct, metv.pps = contetns.purchase
        //시즌회차변경일 때 metv.ppv = contetns.proudct
        if isPPS {
            synopsisType = .season
            seriesNo = synopsisData?.contents?.brcast_tseq_nm ?? ""
        } else {
            // 단편인 경우 purchares만 확인
            synopsisType = .title
        }
        synopsisData?.purchares?.forEach { purcItem in
            if checkPurchase(pid: purcItem.prd_prc_id) == false && purcItem.prd_typ_cd == "10" {
                addEpsdId(epsdId: purcItem.epsd_id)
            }
        }
        synopsisData?.contents?.products?.forEach { prdItem in
            if epsdId == prdItem.epsd_id {
                print("prdType: \(String(describing: prdItem.prd_typ_cd))")
                if checkPurchase(pid: prdItem.prd_prc_id) == false && prdItem.prd_typ_cd == "10" {
                    addEpsdId(epsdId: prdItem.epsd_id)
                }
                if synopsisData?.contents?.gstn_yn == "Y" {
                    // 맛보기 콘텐츠인 경우 except_pid에 추가
                    addExcepPid(pid: prdItem.prd_prc_id)
                }
            }
        }
        if epsdIds.isEmpty { addEpsdId(epsdId: epsdId) }
        srisId = synopsisData?.contents?.sris_id ?? ""
    
        if !(monthlyPid?.isEmpty ?? true) {
            ptype = .ppm
            pid = monthlyPid
        } else {
            ptype = .ppv
        }
        conTitle = synopsisData?.contents?.title ?? ""
        return self
    }
    
   
    /*
    * 월정액 경우 구매
    */
    @discardableResult
    func setParam(data: BlockItem, seriesId: String? = nil , epsId: String? = nil) -> PurchaseWebviewModel{
        if let epsId = epsId { addEpsdId(epsdId: epsId) }
        if let seriesId = seriesId { self.srisId = seriesId }
        ptype = PurchasePType.getType(data.prd_typ_cd)
        synopsisType = .title
        conTitle = data.menu_nm ?? ""
        pid = data.prd_prc_id
        pidOnly = "true"
        return self
    }
    @discardableResult
    func setParam(data: TicketData, seriesId: String? = nil , epsId: String? = nil) -> PurchaseWebviewModel{
        if let epsId = epsId { addEpsdId(epsdId: epsId) }
        if let seriesId = seriesId { self.srisId = seriesId }
        ptype = PurchasePType.getType(data.prodTypeCd)
        synopsisType = .title
        conTitle = data.title ?? ""
        pid = data.prodId
        pidOnly = "true"
        return self
    }
    @discardableResult
    func setParam(data: MonthlyData, seriesId: String? = nil , epsId: String? = nil) -> PurchaseWebviewModel{
        if let epsId = epsId { addEpsdId(epsdId: epsId) }
        if let seriesId = seriesId { self.srisId = seriesId }
        ptype = PurchasePType.getType(data.prodTypeCd)
        synopsisType = .title
        conTitle = data.title ?? ""
        pid = data.prdPrcId
        pidOnly = "true"
        return self
    }
    @discardableResult
    func setParam(seriesId: String? = nil , epsId: String? = nil) -> PurchaseWebviewModel{
        if let epsId = epsId { addEpsdId(epsdId: epsId) }
        if let seriesId = seriesId { self.srisId = seriesId }
        return self
    }
    
    /*
    * 패키지 시놉인 경우 구매
    */
    @discardableResult
    func setParam(data: GatewaySynopsis) -> PurchaseWebviewModel{
        guard let package =  data.package else {return self}
        package.contents?.forEach{
            self.addEpsdId(epsdId: $0.epsd_id)
        }
        srisId = package.sris_id ?? ""
        ptype = .pkg
        synopsisType = .package
        conTitle = package.title ?? ""
        pid = package.prd_prc_id
        return self
    }
    
}
