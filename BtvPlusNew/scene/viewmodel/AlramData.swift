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
    case marketKids
    
    static func getType(_ value:String)->AlramMsgType{
        switch value {
        case "market": return .event
        case "content": return .contentUpdate
        case "market_kids": return .marketKids
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
        case .reserve, .reservation: return String.alert.apnsReserve
            
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
        case .reserve, .reservation: return "B8.RESERVATION"
        case .coupon: return "B9.POINT"
        case .point: return "B10.COUPON"
        case .newpoint: return "B11.NEWBPOINT"
        default: return ""
        }
    }
}

class AlramData:InfinityData,ObservableObject{
    private(set) var type:AlramType = .none
    private(set) var imageType:AlramImageType = .none
    private(set) var msgType:AlramMsgType = .none
    private(set) var landingType:AlramLandingType = .none
    private(set) var title: String? = nil
    private(set) var text: String? = nil
    private(set) var date:String? = nil
    private(set) var remain:String? = nil
    private(set) var images:[String]? = nil
    private(set) var icon: String? = nil
    private(set) var location: String? = nil
    private(set) var limitTime: String? = nil
    private(set) var isCoreData: Bool = false
    private(set) var moveTitle: String? = nil
    private(set) var moveButton: String? = nil
    
    var isExpand:Bool = false
    var isMove:Bool = false
    @Published var isRead:Bool = false
    
    private(set) var move:PageID? = nil
    private(set) var moveData:[PageParam:Any]? = nil
    private(set) var outLink:String? = nil
    private(set) var inLink:String? = nil
    private(set) var inLinkTitle:String? = nil
    private(set) var actionLog:MenuNaviActionBodyItem = MenuNaviActionBodyItem()
    
    private(set) var messageId:String? = nil
    private(set) var ackUrl:String? = nil
    private(set) var blob:String? = nil
    func setData(data:NotificationEntity, idx:Int = -1) -> AlramData{
        self.isCoreData = true
        
        
        if let userData = data.userInfo as? [String: Any] {
            self.setUserData(userData)
            self.setSystemData(userData)
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
    private func setSystemData(_ userData:[String: Any]){
        guard let systemData = userData["system_data"] as? [String: Any] else {return}
        if let value = systemData["messageId"] as? String {
            self.messageId = value
        }
       
        if let value = systemData["ackUrl"] as? String {
            self.ackUrl = value
        }
        
        if let value = systemData["blob"] as? String {
            self.blob = value
        }
    }
    
    private func setUserData(_ userData:[String: Any]){
        guard let userInfo = userData["user_data"] as? [String: Any] else {return}
        
        if let value = userInfo ["notiType"] as? String {
            self.type = AlramType.getType(value.uppercased())
        }
       
        if let value = userInfo ["msgType"] as? String {
            self.msgType = AlramMsgType.getType(value)
        }
        
        
        
        if let value = userInfo ["landingPath"] as? String {
            self.landingType = AlramLandingType.getType(value.uppercased())
        }
        
        if let value = userInfo ["imgType"] as? String {
            self.imageType = AlramImageType.getType(value)
        }
        
        if let value = userInfo ["posterUrl"] as? String {
            if !value.isEmpty {
                self.images = value == "PIMG"
                    ? nil
                    : value.split(separator: ",").map{String($0)}
            }
        }
        
        if let value = userInfo ["iconUrl"] as? String {
            if !value.isEmpty {
                self.icon = value == "IIMG" ? nil : value
            }
        }
        
        if let value = userInfo ["limitTime"] as? String {
            self.limitTime = value
        }
        if let value = userInfo ["title"] as? String {
            self.moveTitle = value
        }
        
        if let location = userInfo ["destPos"] as? String {
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
            self.actionLog.menu_name = "B1.WEBINAPP"

        case .eventWeb:
            guard var url = self.location else { return }
            if url.hasPrefix("http://") ||  url.hasPrefix("https://") {
                if let range = url.range(of: "outlink:", options: .caseInsensitive) {
                    url.removeSubrange(range)
                    self.outLink = url
                    self.actionLog.menu_name = "B3.WEB"
                }else if let range = url.range(of: "inlink:", options: .caseInsensitive) {
                    url.removeSubrange(range)
                    self.inLink = url
                    self.inLinkTitle = self.text
                    self.actionLog.menu_name = "B1.WEBINAPP"
                } else {
                    self.move = .category
                    var param = [PageParam:Any]()
                    param[.id] = EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue
                    self.moveData = param
                    self.inLink = url
                    self.inLinkTitle = self.text
                    self.actionLog.menu_name = "B4.MENU"
                }
            } else {
                self.inLink = BtvWebView.event + "?menuId=" + url
                self.inLinkTitle = self.text
                self.actionLog.menu_name = "B1.WEBINAPP"
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
                searchType: EuxpNetwork.SearchType.prd,
                epsdRsluId: epsdRsluId
            )
            var param = [PageParam:Any]()
            param[.data] = synopsisData
            self.moveData = param
            self.actionLog.menu_name = "B2.SYNOP"
            
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
            self.actionLog.menu_name = "B1.WEBINAPP"
        case .browser:
            guard let url = self.location else { return }
            self.outLink = url
            self.actionLog.menu_name = "B3.WEB"
        case .home:
            self.move = .home
            var param = [PageParam:Any]()
            param[.id] = EuxpNetwork.GnbTypeCode.GNB_HOME.rawValue
            self.moveData = param
            self.actionLog.menu_name = "B4.MENU"
        case .trailer, .season, .monthly:
            guard let epsdId = self.location else { return }
            self.move = .synopsis
            let synopsisData = SynopsisData(
                searchType: EuxpNetwork.SearchType.sris,
                epsdId: epsdId,
                synopType: landingType == .season
                    ? .season
                    : landingType == .trailer ? .none : .title
            )
            var param = [PageParam:Any]()
            param[.data] = synopsisData
            self.actionLog.menu_name = landingType == .trailer
                ? "B5.CONTENT"
                : landingType == .season ? "B6.SEASON" : "B7.MONTH"
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
            let gnbType = EuxpNetwork.GnbTypeCode.getType(menuId)
            if self.msgType == .marketKids {
                if menus.isEmpty {return}
                let menuA = menus.split(separator: "/")
                if menuA.isEmpty {return}
                
                var menuCId:String? = nil
                var menuOpenId:String? = nil
                if menuA.count == 2 {
                    menuOpenId = menuA[1..<menuA.count].reduce("", {$0 + "|" + $1})
                }else if menuA.count > 2 {
                    menuCId = String(menuA[1])
                    menuOpenId = menuA[2..<menuA.count].reduce("", {$0 + "|" + $1})
                }
    
                var param = [PageParam:Any]()
                if menuId == EuxpNetwork.KidsGnbCd.monthlyTicket.rawValue {
                    self.move = .kidsMonthly
                    param[.subId] =  menuOpenId
                } else {
                    self.move = .kidsHome
                    param[.cid] = menuCId
                    param[.subId] = menuOpenId
                }
                self.moveData = param
                self.actionLog.menu_name = "B4.MENU"
                
            } else {
                var param = [PageParam:Any]()
                
                if gnbType != nil {
                    param[.id] = gnbType!.rawValue
                    self.move = gnbType == EuxpNetwork.GnbTypeCode.GNB_CATEGORY ? .category : .home
                    if arrParam.count >= 1 {
                        if self.move == .category
                            , let subId = arrParam.first(where: {$0 == EuxpNetwork.MenuTypeCode.MENU_KIDS.rawValue}) {
                            param[.subId] = subId
                            param[.link] = url.replace(menuId, with: "")
                        } else {
                            param[.subId] = url.replace(menuId, with: "")
                        }
                    }
                
                } else {
                    param[.data] = menuId
                    self.move = .home
                    if arrParam.count >= 1 {
                        param[.subId] = url
                    }
                }
                self.actionLog.menu_name = "B4.MENU"
                self.moveData = param
            }
            
        case .synop:
            guard let url = self.location else { return }
            guard let type = AppUtil.getQurry(url: url, key: "type") else { return }
            guard let id = AppUtil.getQurry(url: url, key: "id") else { return }
            let synopsisType:SynopsisType = SynopsisType(value: type)
            var param = [PageParam:Any]()
            
            switch synopsisType {
            case .package :
                let synopsisData = SynopsisData(
                    srisId: id,
                    searchType: EuxpNetwork.SearchType.sris,
                    synopType: synopsisType
                )
                param[.data] = synopsisData
                self.move = .synopsisPackage
            default :
                let synopsisData = SynopsisData(
                    searchType: EuxpNetwork.SearchType.sris,
                    epsdId: id,
                    synopType: synopsisType
                )
                param[.data] = synopsisData
                self.move = .synopsis
            }
            self.actionLog.menu_name = "B2.SYNOP"
            self.moveData = param
            
        case .coupon:
            self.move = .myBenefits
            var param = [PageParam:Any]()
            param[.id] = PageMyBenefits.MenuType.coupon.rawValue
            self.moveData = param
            self.actionLog.menu_name = "B10.COUPON"
        case .point:
            self.move = .myBenefits
            var param = [PageParam:Any]()
            param[.id] = PageMyBenefits.MenuType.point.rawValue
            self.moveData = param
            self.actionLog.menu_name = "B9.POINT"
        case .newpoint:
            self.move = .myBenefits
            var param = [PageParam:Any]()
            param[.id] = PageMyBenefits.MenuType.point.rawValue
            self.moveData = param
            self.actionLog.menu_name = "B11.NEWBPOINT"
        case .reserve, .reservation:
            guard let svcId = self.location else { return }
            self.move = .schedule
            var param = [PageParam:Any]()
            param[.id] = svcId
            self.moveData = param
            self.actionLog.menu_name = "B8.RESERVATION"
        default:
            self.actionLog.menu_name = self.title
            break
        }
        
        if self.move != nil || self.inLink != nil || self.outLink != nil {
            self.moveButton = self.moveTitle ?? String.app.confirm
        }
    }
    
    
    func setDummy(_ idx:Int = -1) -> AlramData {
        title = "오늘만 무료! 반도"
        text = "(광고) 좀비는 무섭고 사람은 더 무섭다!! 부산행 이후 돌아온 K-좀비 무비. 강동원 주연의 <반도>! 오늘 하루만 모바일 B tv 로 무료로 감상해 보세요."
        date = "2020.08.31 18:30"
        return self
    }
    
    
    static func move(pagePresenter:PagePresenter, dataProvider:DataProvider ,data:AlramData?) {
        guard let data = data  else {return}
        if let move = data.move {
            switch move {
            case .home, .category:
                var findBand:Band? = nil
                if let gnbTypCd = data.moveData?[PageParam.id] as? String {
                    findBand = dataProvider.bands.getData(gnbTypCd: gnbTypCd)
                }else if let menuId = data.moveData?[PageParam.data] as? String {
                    findBand = dataProvider.bands.getData(menuId: menuId)
                }
                guard let band = findBand else { return }
                pagePresenter.changePage(
                    PageProvider
                        .getPageObject(move)
                        .addParam(params: data.moveData)
                        .addParam(key: .id, value: band.menuId)
                        .addParam(key: UUID().uuidString , value: "")
                )
                
            case .kidsHome:
                let pageObj = PageKidsProvider.getPageObject(move)
                                .addParam(params: data.moveData)
                pagePresenter.changePage(pageObj)
                
            default :
                if PageFactory.getPage(PageProvider.getPageObject(move)) != nil {
                    let pageObj = PageProvider.getPageObject(move)
                    pageObj.params = data.moveData
                    pagePresenter.openPopup(pageObj)
                }
                if PageKidsFactory.getPage( PageKidsProvider.getPageObject(move)) != nil {
                    let pageObj = PageKidsProvider.getPageObject(move)
                    pageObj.params = data.moveData
                    pagePresenter.openPopup(pageObj)
                }
                
            }
        }
        else if let link = data.outLink {
            AppUtil.openURL(link)
        }
        
        if let link = data.inLink {
            pagePresenter.openPopup(
                PageProvider
                    .getPageObject(.webview)
                    .addParam(key: .data, value: link)
                    .addParam(key: .title , value: data.title)
            )
        }
    }

}
