//
//  AlramData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/22.
//

import Foundation
import SwiftUI

enum AlramType:String {
    case none, notification, popup, notificationNPopup
    static func getType(_ value:String)->AlramType{
        switch value {
        case "ALL": return .notification
        case "APNS": return .popup
        case "FCM": return .notificationNPopup
        default: return .none
        }
    }
}
enum AlramMsgType: Int {
    case none = -1
    case event
    case contentUpdate
    static func getType(_ value:String)->AlramMsgType{
        switch value {
        case "market": return .event
        case "content": return .contentUpdate
        case "reservation": return .event
        case "service": return .event
        case "inform": return .event
        default: return .event
        }
    }
    /*
    case "market" : config = "A1.market"
    case "content" : config = "A2.content"
    case "reservation" : config = "A3.reservation"
    case "service" : config = "A4.service"
    case "inform" : config = "A5.inform"
    */
}
enum AlramImageType:String {
    case none, local, poster
    static func getType(_ value:String)->AlramImageType{
        switch value {
        case "icon": return .local
        case "poster" : return .poster
        default: return .none
        }
    }
}
enum AlramLandingType:String {
    case none, notice ,eventWeb, vodDetail, webInApp, browser, home, trailer, menu, synop
    case season, monthly, reserve
    case coupon ,point, newpoint
    case recentVOD, reservation, remindReservation
    
    static func getType(_ value:String)->AlramLandingType{
        switch value {
        case "WEBINAPP" : return .webInApp
        case "SYNOP" : return .synop
        case "WEB" : return .browser
        case "MENU" : return .menu
        case "CONTENT" : return .trailer
        case "SEASON" : return .season
        case "MONTH" : return .monthly
        case "RESERVATION" : return .reservation
        case "POINT" : return .point
        case "COUPON" : return .coupon
        case "NEWBPOINT" : return .newpoint
        default: return .none
        }
    }
    
    func getCategoryTitle() -> String {
        switch self {
        case .notice: return String.alert.apnsNotice
        case .eventWeb: return String.alert.apnsEventWeb
        case .vodDetail: return String.alert.apnsVodDetail
        case .webInApp: return String.alert.apnsWebInApp
        case .browser: return String.alert.apnsBrowser
        case .home: return String.alert.apnsHome
        case .trailer: return String.alert.apnsTrailer
        case .menu: return String.alert.apnsMenu
        case .synop: return String.alert.apnsSynop
        case .season: return String.alert.apnsSeason
        case .monthly: return String.alert.apnsMonthly
        case .reserve: return String.alert.apnsReserve
        case .coupon: return ""
        case .point: return ""
        case .newpoint: return ""
        default: return ""
        }
    }
    
   func getIcon() -> String {
        switch self {
        case .trailer: return Asset.icon.noticeRelease
        case .reserve, .reservation: return Asset.icon.noticeReserve
        case .coupon: return Asset.icon.noticeCoupon
        case .point: return Asset.icon.noticePoint
        default: return Asset.icon.noticeAd
        }
    }
    
   func getLogValue() -> String {
        switch self {
        case .notice: return ""
        case .eventWeb: return ""
        case .vodDetail: return ""
        case .webInApp: return "B1.WEBINAPP"
        case .browser: return "B3.WEB"
        case .home: return ""
        case .trailer: return "B5.CONTENT"
        case .menu: return "B4.MENU"
        case .synop: return "B2.SYNOP"
        case .season: return "B6.SEASON"
        case .monthly: return "B7.MONTH"
        case .reserve: return "B8.RESERVATION"
        case .coupon: return "B9.POINT"
        case .point: return "B10.COUPON"
        case .newpoint: return "B11.NEWBPOINT"
        default: return ""
        }
    }
}


class AlramData:InfinityData{
    private(set) var type:AlramType = .none
    private(set) var imageType:AlramImageType = .none
    private(set) var msgType:AlramMsgType = .none
    private(set) var landingType:AlramLandingType = .none
    private(set) var title: String? = nil
    private(set) var text: String? = nil
    private(set) var date:String? = nil
    private(set) var remain:String? = nil
    private(set) var image: String? = nil
    private(set) var location: String? = nil
    private(set) var limitTime: String? = nil
    private(set) var isCoreData: Bool = false
    private(set) var moveTitle: String? = nil
    private(set) var moveButton: String? = nil
    var isExpand:Bool = false
    var isRead:Bool = false
    
    private(set) var move:PageID? = nil
    private(set) var moveData:[PageParam:Any]? = nil
    private(set) var outLink:String? = nil
    private(set) var inLink:String? = nil
    private(set) var inLinkTitle:String? = nil
    
    func setData(data:NotificationEntity, idx:Int = -1) -> AlramData{
        self.isCoreData = true
        if let userData = data.userInfo as? [String: Any] {
            self.setUserData(userData)
        }
        
        title = data.title
        text = data.body
        isRead = data.isRead
        if let regDate = data.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd hh:mm"
            date = dateFormatter.string(from: regDate)
        }
        self.index = idx
        self.parseAction()
        return self
    }
    
    func setData( title:String?, text:String?, userData:[String: Any]?) -> AlramData{
        if let userData = userData {
            self.setUserData(userData)
        }
        self.title = title
        self.text = text
        self.parseAction()
        return self
    }
    
    
    private func setUserData(_ userData:[String: Any]){
        if let value = userData["notiType"] as? String {
            self.type = AlramType.getType(value.uppercased())
        }
       
        if let value = userData["msgType"] as? String {
            self.msgType = AlramMsgType.getType(value)
        }
        
        if let value = userData["landingPath"] as? String {
            self.landingType = AlramLandingType.getType(value.uppercased())
        }
        
        if let value = userData["imgType"] as? String {
            self.imageType = AlramImageType.getType(value)
        }
        
        if let value = userData["posterUrl "] as? String {
            self.image = value
        } else if let value = userData["iconUrl"] as? String {
            self.image = value
        }
        
        if let value = userData["limitTime"] as? String {
            self.limitTime = value
        }
        if let value = userData["title"] as? String {
            self.moveTitle = value
        }
        
        if let location = userData["destPos"] as? String {
            self.location = location.replace("\n", with: "")
            if let components = URLComponents(string: self.location!) {
                // Coupon 만료 알림|0|0|0|4|http://58.123.205.55/mybtvCouponPoint.do?type=coupon&state=E
                // Bpoint 만료 알림|0|0|0|4|http://10.41.10.25:8080/mybtvCouponPoint.do?type=point&state=E
                if let query = components.queryItems {
                    for item in query where item.name == "type" {
                        if item.value == "coupon" {
                            self.landingType = .coupon
                        } else if item.value == "point" {
                            self.landingType = .point
                        }
                    }
                }
            }
        }
    }
    private func parseAction(){
        switch landingType {
        case .notice:
            guard let location = self.location else { return }
            if location.contains("http://") || location.contains("https://") {
                self.inLink = location
                self.inLinkTitle = self.text
            } else {
                self.inLink = BtvWebView.notice + "?menuId=" + location
                self.inLinkTitle = String.button.notice
            }

        case .eventWeb:
            guard var url = self.location else { return }
            if url.hasPrefix("http://") ||  url.hasPrefix("https://") {
                if let range = url.range(of: "outlink:", options: .caseInsensitive) {
                    url.removeSubrange(range)
                    self.outLink = url
                }
                if let range = url.range(of: "inlink:", options: .caseInsensitive) {
                    url.removeSubrange(range)
                    self.inLink = url
                    self.inLinkTitle = self.text
                    
                } else {
                    self.move = .category
                    var param = [PageParam:Any]()
                    param[.id] = EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue
                    self.moveData = param
                    self.inLink = url
                    self.inLinkTitle = self.text
                }
            } else {
                self.inLink = BtvWebView.event + "?menuId=" + url
                self.inLinkTitle = self.text
            }
            
        case .vodDetail:
            guard let valueString = self.location else { return }
            let values = valueString.components(separatedBy: ",")
            var conId: String?
            var serNo: String?
            if values.count > 0 {
                conId = values[0]
                if values.count > 1 {
                    serNo = values[1]
                }
            }
            guard let epsdRsluId = conId else { return }
            self.move = .synopsis
            let synopsisData = SynopsisData(
                srisId: serNo,
                searchType: EuxpNetwork.SearchType.prd.rawValue,
                epsdRsluId: epsdRsluId
            )
            var param = [PageParam:Any]()
            param[.data] = synopsisData
            self.moveData = param
            
        case .webInApp:
            guard let valueString = self.location else { return }
            let values = valueString.components(separatedBy: ",")
            guard let url = values.first else { return }
            if url.isEmpty { return }
            let pairingRange = url.range(of: "btvplusapp/MyPairgingManager", options: .caseInsensitive)
            if !url.contains("http://") && !url.contains("https://") && pairingRange != .none {
                //Landing.goInvite()
            } else {
                self.inLink = url
                self.inLinkTitle = self.text
            }
            
        case .browser:
            guard let url = self.location else { return }
            self.outLink = url
            
        case .home:
            self.move = .home
            var param = [PageParam:Any]()
            param[.id] = EuxpNetwork.GnbTypeCode.GNB_HOME.rawValue
            self.moveData = param
            
        case .trailer, .season, .monthly:
            guard let epsdId = self.location else { return }
            self.move = .synopsis
            let synopsisData = SynopsisData(
                searchType: EuxpNetwork.SearchType.sris.rawValue,
                epsdId: epsdId
            )
            var param = [PageParam:Any]()
            param[.data] = synopsisData
            self.moveData = param
            
        case .menu:
            // 메뉴 이동 (PUSH/외부진입)
            // http://m.btvplus.co.kr?menus=BP_03_04/NM2000002159/NM2000002444/NM2000004860/NM2000004861
            // http://m.btvplus.co.kr?menus=NM2000002159/NM2000002444
            guard var url = self.location else { return }
            guard let menus = AppUtil.getQurry(url: url, key: "menus") else { return }
            if menus.starts(with: "NM2000002159") == true {
                url = String("/" + menus)
            } else {
                url = menus
            }
            let arrParam = url.components(separatedBy: "/")
            guard let menuId = arrParam.first(where: {!$0.isEmpty}) else { return }
            var param = [PageParam:Any]()
            let gnbType = EuxpNetwork.GnbTypeCode.getType(menuId)
            if gnbType != nil {
                param[.id] = gnbType!.rawValue
                self.move = gnbType == EuxpNetwork.GnbTypeCode.GNB_CATEGORY ? .category : .home
                if arrParam.count >= 1 {
                    param[.subId] = url.replace(menuId, with: "")
                }
            } else {
                param[.data] = menuId
                self.move = .home
                if arrParam.count >= 1 {
                    param[.subId] = url
                }
            }
            self.moveData = param
                
        case .synop:
            guard let url = self.location else { return }
            guard let type = AppUtil.getQurry(url: url, key: "type") else { return }
            guard let id = AppUtil.getQurry(url: url, key: "id") else { return }
            let synopsisType:SynopsisType = SynopsisType(value: type)
            var param = [PageParam:Any]()
            
            switch synopsisType {
            case .title :
                let synopsisData = SynopsisData(
                    searchType: EuxpNetwork.SearchType.sris.rawValue,
                    epsdId: id
                )
                param[.data] = synopsisData
                self.move = .synopsis
            case .package :
                let synopsisData = SynopsisData(
                    srisId: id,
                    searchType: EuxpNetwork.SearchType.sris.rawValue
                )
                param[.data] = synopsisData
                self.move = .synopsisPackage
            }
            self.moveData = param
            
        case .coupon:
            self.move = .myBenefits
            var param = [PageParam:Any]()
            param[.id] = PageMyBenefits.MenyType.coupon.rawValue
            self.moveData = param
            
        case .point:
            self.move = .myBenefits
            var param = [PageParam:Any]()
            param[.id] = PageMyBenefits.MenyType.point.rawValue
            self.moveData = param
        case .newpoint:
            self.move = .myBenefits
            var param = [PageParam:Any]()
            param[.id] = PageMyBenefits.MenyType.point.rawValue
            self.moveData = param
            
        case .reserve:
            guard let svcId = self.location else { return }
            self.move = .schedule
            var param = [PageParam:Any]()
            param[.id] = svcId
            self.moveData = param
        default:
            break
        }
        
        if self.move != nil || self.inLink != nil || self.outLink != nil {
            self.moveButton = self.moveTitle ?? String.app.corfirm
        }
    }
    
    
    func setDummy(_ idx:Int = -1) -> AlramData {
        title = "오늘만 무료! 반도"
        text = "(광고) 좀비는 무섭고 사람은 더 무섭다!! 부산행 이후 돌아온 K-좀비 무비. 강동원 주연의 <반도>! 오늘 하루만 모바일 B tv 로 무료로 감상해 보세요."
        date = "2020.08.31 18:30"
        return self
    }

}
