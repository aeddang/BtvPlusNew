//
//  ShareManager.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/23.
//

import Foundation
import SwiftUI
import Combine
import AdSupport
class NaviLogManager : ObservableObject, PageProtocol {
    private let pagePresenter:PagePresenter
    private let repository:Repository
    private var anyCancellable = Set<AnyCancellable>()

    private var currentTopPage:PageObject? = nil
    private var currentPageId:NaviLog.PageId? = nil
    private var currentPage:PageObject? = nil
    private var currentPop:PageObject? = nil
    private var webPageVersion:String? = nil
    private var currentMemberItem:MenuNaviMemberItem? = nil
    private var currentSysnopsisContentsItem:MenuNaviContentsBodyItem? = nil
    private var currentPlayStartTime:Double? = nil
    
    init(pagePresenter:PagePresenter , repository:Repository) {
        self.pagePresenter = pagePresenter
        self.repository = repository
       
        self.pagePresenter.$currentPage.sink(receiveValue: { page in
            guard let page = page else {return}
            if page == self.currentPage {return}
            self.currentPage = page
            self.pageLog(page, action: .pageShow)
            
        }).store(in: &anyCancellable)
        
        self.pagePresenter.$currentTopPage.sink(receiveValue: { pop in
            guard let pop = pop else {return}
            if NaviLog.getPageID(page:  pop, repository: self.repository) != nil {
                self.currentTopPage = pop
                self.currentPageId = nil
            }
            if !pop.isPopup {return}
            self.currentPop = pop
            if pop.sendLog {return}
            pop.sendLog = true
            self.pageLog(pop, action: .pageShow)
           
        }).store(in: &anyCancellable)
        
        self.repository.pairing.$status.sink(receiveValue: { status in
            switch status{
            case .disConnect :
                self.currentMemberItem = MenuNaviMemberItem()
            case .pairing :
                if let user = self.repository.pairing.user {
                    self.currentMemberItem = MenuNaviMemberItem(
                        gender: user.gender.logValue(),
                        birthyear: user.birth,
                        nickname: user.nickName)
                }
            default: break
            }
        }).store(in: &anyCancellable)
    }
    
    func setupWebPageVersion(_ ver:String){
        self.webPageVersion = ver
    }
    func setupSysnopsis(_ synop:SynopsisModel){
        var contentsItem = MenuNaviContentsBodyItem()
        contentsItem.type = "vod"        // VOD/실시간 구분 ex)vod | live
        contentsItem.series_id = synop.srisId
        contentsItem.title = synop.title ?? ""      // 제목, ex)1박2일, 9시 뉴스
        contentsItem.channel = ""   // live방송의 채널번호
        contentsItem.channel_name = synop.brcastChnlNm ?? ""    // channel 명
        contentsItem.genre_text = ""  // 장르, ex)영화
        contentsItem.genre_code = synop.metaTypCd ?? ""     // 장르, ex)MG0000000001 --> 드라마
        contentsItem.episode_id = synop.epsdId ?? ""      // episode_id, btv plus 는 episode_id 없음, 5.0
        
        contentsItem.paid = synop.isFree  // 유료 여부 ex)true (유료인 경우)
        contentsItem.purchase = synop.curSynopsisItem?.isDirectview ?? false          // 구매 여부 ex)true (구매한 경우)
        contentsItem.episode_resolution_id = synop.epsdRsluId ?? ""      // episode_id, btv plus 는 episode_id 없음, 5.0
        //contentsItem.cid = contents.contrp_id?.replace("", with: "{").replace("", with: "}") ?? ""        // 4.0
        //contentsItem.product_id = ""           // 패키지상품 ID(Btv plus) or 시리즈상품 ID(Btv)
        if let curSynopsisItem = synop.curSynopsisItem {
            contentsItem.product_id = curSynopsisItem.prdPrcId
            contentsItem.purchase_type = curSynopsisItem.prd_typ_cd  // 구매유형, ex) ppv(단품)/pps(시리즈)/ppp(패키지)/ppm(월정액) --> 재생 버튼 선택 후 확인 가능
            contentsItem.monthly_pay = curSynopsisItem.ppm_prd_typ_cd     // 월정액유형, ex)프리미어, 프리미어 라이트, 지상파월정액, JTBC월정액
            contentsItem.list_price = curSynopsisItem.prd_prc_vat.description    // 할인 전 가격
            contentsItem.payment_price = curSynopsisItem.sale_prc_vat.description  // 할인 후 최종 결제 시 지불한 가격
        }
        //contentsItem.running_time = ""    // 초단위
        //contentsItem.actor_id = ""   // 배우ID
        self.currentSysnopsisContentsItem = contentsItem
        self.currentPlayStartTime = nil
    }
    
    func contentsLog(pageId:NaviLog.PageId? = nil, action:NaviLog.Action,
                   actionBody:MenuNaviActionBodyItem? = nil,
                   watchType:NaviLog.watchType? = nil){
    
        let data = NaviLogData()
        data.actionBody = actionBody
        data.contentsBody = self.currentSysnopsisContentsItem
        data.member = self.currentMemberItem
        if let watch = watchType {
            switch watch {
            case .watchStart : self.currentPlayStartTime = Date().timeIntervalSince1970
            default : break
            }
        }
        if let playStartTime = self.currentPlayStartTime {
            self.currentSysnopsisContentsItem?.running_time = (Date().timeIntervalSince1970 - playStartTime).description
        }
        if let pageId = pageId {
            if let realNameData = self.getRealNameData(pageID: pageId, action: action,  watchType: watchType, naviLogData: data) {
                self.send(realNameData, isAnonymous: false)
            }
            if let anonymousData = self.getAnonymousData(pageID: pageId, action: action,  watchType: watchType, naviLogData: data) {
                self.send(anonymousData, isAnonymous: true)
            }
        } else {
            if let realNameData = self.getRealNameData(page:self.currentTopPage, pageID: self.currentPageId, action: action, naviLogData: data) {
                self.send(realNameData, isAnonymous: false)
            }
            if let anonymousData = self.getAnonymousData(page:self.currentTopPage, pageID: self.currentPageId, action: action, naviLogData: data) {
                self.send(anonymousData, isAnonymous: true)
            }
        }
    }
    
    func pairingLog(pageId:NaviLog.PageId, config:String){
        var actionBody = MenuNaviActionBodyItem()
        actionBody.config = config
        let data = NaviLogData()
        data.actionBody = actionBody
        data.member = self.currentMemberItem
        if let realNameData = self.getRealNameData(pageID: pageId, action: .pageShow, naviLogData: data) {
            self.send(realNameData, isAnonymous: false)
        }
        if let anonymousData = self.getAnonymousData(pageID: pageId, action: .pageShow, naviLogData: data) {
            self.send(anonymousData, isAnonymous: true)
        }
    }
    
    func actionLog(_ action:NaviLog.Action = .pageShow, pageId:NaviLog.PageId? = nil,
                   actionBody:MenuNaviActionBodyItem? = nil,
                   contentBody:MenuNaviContentsBodyItem? = nil,
                   memberBody:MenuNaviMemberItem? = nil
                   ){
        
        let data = NaviLogData()
        data.actionBody = actionBody
        data.contentsBody = contentBody
        data.member = memberBody ?? self.currentMemberItem
        if let pageId = pageId {
            if let realNameData = self.getRealNameData(pageID: pageId, action: action, naviLogData: data) {
                self.send(realNameData, isAnonymous: false)
            }
            if let anonymousData = self.getAnonymousData(pageID: pageId, action: action, naviLogData: data) {
                self.send(anonymousData, isAnonymous: true)
            }
        } else {
            if let realNameData = self.getRealNameData(page:self.currentTopPage, pageID: self.currentPageId, action: action, naviLogData: data) {
                self.send(realNameData, isAnonymous: false)
            }
            if let anonymousData = self.getAnonymousData(page:self.currentTopPage, pageID: self.currentPageId, action: action, naviLogData: data) {
                self.send(anonymousData, isAnonymous: true)
            }
        }
    }
    
    
    func setupPageId(_ pageId:NaviLog.PageId? = nil){
        self.currentPageId = pageId
    }
    
    private func pageLog(_ page:PageObject, action:NaviLog.Action){
        let data = NaviLogData()
        data.actionBody = NaviLog.getPageAction(page: page, repository: self.repository)
        data.member = self.currentMemberItem
        
        if let realNameData = self.getRealNameData(page: page, action: action, naviLogData: data) {
            self.send(realNameData, isAnonymous: false)
        }
        if let anonymousData = self.getAnonymousData(page: page, action: action, naviLogData: data) {
            self.send(anonymousData, isAnonymous: true)
        }
    }
    
    private func send(_ data:MenuNaviItem, isAnonymous:Bool){
        if !isAnonymous {
            DataLog.d("page_id : " + (data.page_id ?? "") , tag: self.tag )
            DataLog.d("action_id : " + (data.action_id ?? "") , tag: self.tag )
            if let watchType = data.vod_watch_type { DataLog.d("vod_watch_type : " + watchType , tag: self.tag )}
            if let action = data.action_body {
                DataLog.d("send action : "
                            + "config : " +  (action.config ?? "") + " "
                            + "category : " +  (action.category ?? "") + " "
                            + "menu_id : " +  (action.menu_id ?? "") + " "
                            + "menu_name : " +  (action.menu_name ?? "") + " "
                          , tag: self.tag )
            }
            if let content = data.contents_body {
                DataLog.d("send content : "
                            + "title : " + (content.title ?? "") + " "
                            + "episode_id : " + (content.episode_id ?? "") + " "
                            + "paid : " + (content.paid?.description ?? "") + " "
                            + "running_time : " + (content.running_time ?? "")
                          , tag: self.tag )
            }
        }
        self.repository.apiManager.load(.sendNaviLog(self.getJsonString(data: data), isAnonymous: isAnonymous))
    }

    private func getRealNameData(
        page:PageObject? = nil,
        pageID:NaviLog.PageId? = nil,
        action:NaviLog.Action? = nil,
        watchType:NaviLog.watchType? = nil,
        naviLogData:NaviLogData? = nil
        ) -> MenuNaviItem? {
    
        guard var menuNaviItem = self.getMenuNaviItem(
                page: page, pageId: pageID , action: action, watchType: watchType, contentBody: naviLogData?.contentsBody) else {
            return nil
        }
        menuNaviItem.vod_watch_type = watchType?.rawValue
        menuNaviItem.service_name = "btv_plus_pi"
        menuNaviItem.device_base_time = naviLogData?.now.toDateFormatter(dateFormat: "yyyyMMddHHmmss.SSS")
        menuNaviItem.pcid = self.repository.storage.getPcid()
        menuNaviItem.stb_id = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        menuNaviItem.stb_mac = self.repository.pairing.hostDevice?.convertMacAdress  ?? ""
        menuNaviItem.session_id = self.repository.storage.getSessionId()
        menuNaviItem.action_body = naviLogData?.actionBody// ?? MenuNaviActionBodyItem()
        menuNaviItem.url = "";
        menuNaviItem.client_ip = AppUtil.getIPAddress() ?? "0.0.0.0"
        menuNaviItem.member = naviLogData?.member
        return menuNaviItem
    }
    
    private func getAnonymousData(
        page:PageObject? = nil,
        pageID:NaviLog.PageId? = nil,
        action:NaviLog.Action? = nil,
        watchType:NaviLog.watchType? = nil,
        naviLogData:NaviLogData? = nil
        ) -> MenuNaviItem? {
    
        guard var menuNaviItem = self.getMenuNaviItem(
                page: page, pageId: pageID ,action: action, watchType: watchType, contentBody: naviLogData?.contentsBody) else {
            return nil
        }
        menuNaviItem.service_name = "btv_plus_npi" 
        menuNaviItem.device_base_time = naviLogData?.now.toDateFormatter(dateFormat: "yyyyMMddHH0000.000")
        menuNaviItem.gaid = "";
        menuNaviItem.idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        return menuNaviItem
    }

    
    private func getMenuNaviItem(
        page:PageObject? = nil,
        pageId:NaviLog.PageId? = nil,
        action:NaviLog.Action? = nil,
        watchType:NaviLog.watchType? = nil,
        contentBody:MenuNaviContentsBodyItem? = nil
        ) -> MenuNaviItem? {
        var logPageId:String = ""
        if let pageId = pageId {
            logPageId = pageId.rawValue
        } else if let page = page {
            guard let pageId = NaviLog.getPageID(page: page, repository: self.repository) else {
                //DataLog.d("getMenuNaviItem unused pageId",tag: self.tag)
                return nil
            }
            logPageId = pageId
        } else {
            return nil
        }
        var item = MenuNaviItem()
        item.log_type = SystemEnvironment.isStage ? "dev" : "live"
        item.poc_type = "mobile_app"
        item.page_id = logPageId
        item.action_id = action?.rawValue ?? ""
        item.vod_watch_type = watchType?.rawValue ?? ""
        item.contents_body = contentBody //?? MenuNaviContentsBodyItem()
        item.page_type = "native"
        item.app_release_version = SystemEnvironment.bundleVersion
        item.app_build_version = SystemEnvironment.buildNumber
        item.web_page_version = self.webPageVersion ?? Date().toDateFormatter(dateFormat: "yyyyMMddHH")
        item.os_name = "iOS"
        item.os_version = SystemEnvironment.systemVersion
        item.browser_name = "";
        item.browser_version = "";
        item.device_model = SystemEnvironment.model
        item.manufacturer = "Apple"
        return item
    }
    
    private func getJsonString(data:MenuNaviItem) -> String{
        if let jsonData = try? JSONEncoder().encode(data) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return ""
    }
    private func getJsonString(data:MenuNaviContentsBodyItem?) -> String{
        let data = data ?? MenuNaviContentsBodyItem()
        if let jsonData = try? JSONEncoder().encode(data) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return ""
    }
    private func getJsonString(data:MenuNaviMemberItem?) -> String{
        let data = data ?? MenuNaviMemberItem()
        if let jsonData = try? JSONEncoder().encode(data) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        
        return ""
    }
    private func getJsonString(data:MenuNaviActionBodyItem?) -> String {
        let data = data ?? MenuNaviActionBodyItem()
        if let jsonData = try? JSONEncoder().encode(data) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return ""
    }
}


class NaviLogData: Encodable {
    fileprivate var now:Date = Date()
    fileprivate(set) var actionBody:MenuNaviActionBodyItem? = nil
    fileprivate(set) var contentsBody:MenuNaviContentsBodyItem? = nil
    fileprivate(set) var member:MenuNaviMemberItem? = nil
}
