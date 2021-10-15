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
    private(set) var currentSysnopsisContentsItem:MenuNaviContentsBodyItem? = nil
    private(set) var currentPlayStartTime:Double? = nil
    
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
    
    func clearSysnopsis(){
        self.currentSysnopsisContentsItem = nil
        self.currentPlayStartTime = nil
        DataLog.d("clearSysnopsis" , tag: self.tag )
    }
    
    func setupSysnopsis(_ synop:SynopsisModel?, type:String? = nil  ){
        guard let synop = synop else {
            self.currentSysnopsisContentsItem = nil
            self.currentPlayStartTime = nil
            return
        }
        var contentsItem = MenuNaviContentsBodyItem()
        contentsItem.type = type ?? "vod"   // VOD/실시간 구분 ex)vod | live
        contentsItem.series_id = synop.srisId
        contentsItem.title = synop.title ?? ""      // 제목, ex)1박2일, 9시 뉴스
        contentsItem.channel = ""   // live방송의 채널번호
        contentsItem.channel_name = synop.brcastChnlNm ?? ""    // channel 명
        contentsItem.genre_text = ""  // 장르, ex)영화
        contentsItem.genre_code = synop.metaTypCd ?? ""     // 장르, ex)MG0000000001 --> 드라마
        contentsItem.episode_id = synop.epsdId ?? ""
        contentsItem.paid = !synop.isFree  // 유료 여부 ex)true (유료인 경우)
        contentsItem.purchase = synop.curSynopsisItem?.isDirectview ?? false          // 구매 여부 ex)true (구매한 경우)
        contentsItem.episode_resolution_id = synop.epsdRsluId?.replace("{", with: "").replace("}", with: "") ?? ""      // episode_id, btv plus 는 episode_id 없음, 5.0
        //contentsItem.cid = contents.contrp_id?.replace("", with: "{").replace("", with: "}") ?? ""        // 4.0

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
        DataLog.d("setupSysnopsis " + (contentsItem.title ?? "") , tag: self.tag )
    }
    
    func setupSysnopsis(_ synop:SynopsisPackageModel?, type:String? = nil  ){
        guard let synop = synop else {
            self.currentSysnopsisContentsItem = nil
            self.currentPlayStartTime = nil
            return
        }
        var contentsItem = MenuNaviContentsBodyItem()
        contentsItem.type = type ?? "vod"   // VOD/실시간 구분 ex)vod | live
        contentsItem.series_id = synop.srisId
        contentsItem.title = synop.originData?.package?.title ?? ""      // 제목, ex)1박2일, 9시 뉴스
        contentsItem.channel = ""   // live방송의 채널번호
        contentsItem.channel_name = ""    // channel 명
        contentsItem.genre_text = ""  // 장르, ex)영화
        contentsItem.genre_code = synop.originData?.package?.meta_typ_cd ?? ""     // 장르, ex)MG0000000001 --> 드라마
        contentsItem.episode_id = ""      // episode_id, btv plus 는 episode_id 없음, 5.0
        contentsItem.paid = synop.originData?.package?.sale_prc != 0 // 유료 여부 ex)true (유료인 경우)
        contentsItem.purchase = synop.hasAuthority         // 구매 여부 ex)true (구매한 경우)
        contentsItem.episode_resolution_id = ""      // episode_id, btv plus 는 episode_id 없음, 5.0
        contentsItem.product_id = synop.originData?.package?.prd_prc_id          // 패키지상품 ID(Btv plus) or 시리즈상품 ID(Btv)
        contentsItem.list_price = synop.originData?.package?.prd_prc?.description
        contentsItem.payment_price = synop.originData?.package?.sale_prc?.description
 
        self.currentSysnopsisContentsItem = contentsItem
        self.currentPlayStartTime = nil
        
        DataLog.d("setupSysnopsis Package " + (contentsItem.title ?? "") , tag: self.tag )

    }
    
    func contentsWatch(isPlay:Bool){
        if isPlay {
            self.currentPlayStartTime = Date().timeIntervalSince1970
            DataLog.d(" contentsWatch : " + (self.currentPlayStartTime?.description ?? "") , tag: self.tag )
        } else {
            self.currentPlayStartTime = nil
            DataLog.d(" contentsWatch : nil" , tag: self.tag )
        }
    }
    
    func getContentsWatchTime()->String?{
        if let playStartTime = self.currentPlayStartTime {
            let runTime = Int(round((Date().timeIntervalSince1970 - playStartTime)))
            return runTime.description
        } else {
            return nil
        }
    }
    func contentsLog(pageId:NaviLog.PageId? = nil, action:NaviLog.Action,
                   actionBody:MenuNaviActionBodyItem? = nil,
                   watchType:NaviLog.watchType? = nil){
        
        let fixedPageId:String? = pageId?.rawValue.isEmpty == true
            ? nil
            : pageId?.rawValue
    
        let data = NaviLogData()
        data.actionBody = actionBody
        data.contentsBody = self.currentSysnopsisContentsItem
        data.member = self.currentMemberItem
    
        if let findPageId = fixedPageId {
            if let realNameData = self.getRealNameData(pageID:findPageId, action: action,  watchType: watchType, naviLogData: data) {
                self.send(realNameData, isAnonymous: false)
            }
            if let anonymousData = self.getAnonymousData(pageID:findPageId, action: action,  watchType: watchType, naviLogData: data) {
                self.send(anonymousData, isAnonymous: true)
            }
        } else {
            if let realNameData = self.getRealNameData(page:self.currentTopPage, pageID: self.currentPageId?.rawValue, action: action, naviLogData: data) {
                self.send(realNameData, isAnonymous: false)
            }
            if let anonymousData = self.getAnonymousData(page:self.currentTopPage, pageID: self.currentPageId?.rawValue, action: action, naviLogData: data) {
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
        if let realNameData = self.getRealNameData(pageID: pageId.rawValue, action: .pageShow, naviLogData: data) {
            self.send(realNameData, isAnonymous: false)
        }
        if let anonymousData = self.getAnonymousData(pageID: pageId.rawValue, action: .pageShow, naviLogData: data) {
            self.send(anonymousData, isAnonymous: true)
        }
    }
    
    func actionLog(_ action:NaviLog.Action = .pageShow,
                   pageId:NaviLog.PageId = .empty,
                   pagePageID:PageID? = nil,
                   actionBody:MenuNaviActionBodyItem? = nil,
                   contentBody:MenuNaviContentsBodyItem? = nil,
                   memberBody:MenuNaviMemberItem? = nil
                   ){
        
       
        let  data = NaviLogData()
        data.actionBody = actionBody
        data.contentsBody = contentBody
        data.member = memberBody ?? self.currentMemberItem
        
        let fixedPageId:String? = pageId.rawValue.isEmpty == true
            ? NaviLog.getPageID(pageID: pagePageID, repository: repository)
            : pageId.rawValue
        
        if let findPageId = fixedPageId {
            if let realNameData = self.getRealNameData(pageID: findPageId, action: action, naviLogData: data) {
                self.send(realNameData, isAnonymous: false)
            }
            if let anonymousData = self.getAnonymousData(pageID: findPageId, action: action, naviLogData: data) {
                self.send(anonymousData, isAnonymous: true)
            }
        } else {
            if let realNameData = self.getRealNameData(page:self.currentTopPage, pageID: self.currentPageId?.rawValue, action: action, naviLogData: data) {
                self.send(realNameData, isAnonymous: false)
            }
            if let anonymousData = self.getAnonymousData(page:self.currentTopPage, pageID: self.currentPageId?.rawValue, action: action, naviLogData: data) {
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
    func send(logString:String, completion: @escaping (NavilogResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        self.repository.apiManager.navilog.sendLog(log: logString, completion: completion, error: error)
    }
    
    func sendNpi(logString:String, completion: @escaping (Blank) -> Void, error: ((_ e:Error) -> Void)? = nil){
        self.repository.apiManager.navilogNpi.sendLogNpi(log: logString, completion: completion, error: error)
    }
    
    private func send(_ data:MenuNaviItem, isAnonymous:Bool){
        
        var modifyData = data
        if var modifyContentBody = data.contents_body {
            if modifyContentBody.episode_resolution_id?.isEmpty == false {
                modifyContentBody.episode_resolution_id = modifyContentBody
                    .episode_resolution_id?
                    .replace("{", with: "").replace("}", with: "")
            }
            if modifyContentBody.payment_price?.isEmpty == false, let price = modifyContentBody.payment_price {
                modifyContentBody.payment_price = Int(round(price.toDouble())).description
            }
            if modifyContentBody.purchase_type?.isEmpty == false, let purchase_type = modifyContentBody.purchase_type{
                modifyContentBody.purchase_type = PrdTypCd(rawValue: purchase_type)?.logName 
            }
            modifyData.contents_body = modifyContentBody
        }
        #if DEBUG
        if !isAnonymous {
            DataLog.d("***********", tag: self.tag )
            DataLog.d("***********", tag: self.tag )
            
            DataLog.d("NaviLog Start", tag: self.tag )
            DataLog.d("page_id : " + (modifyData.page_id ?? "") , tag: self.tag )
            DataLog.d("action_id : " + (modifyData.action_id ?? "") , tag: self.tag )
            if let watchType = modifyData.vod_watch_type { DataLog.d("vod_watch_type : " + watchType , tag: self.tag )}
            if let action = modifyData.action_body {
                DataLog.d("send action : ", tag: self.tag )
                if let value = action.config{ DataLog.d("  config : " +  value, tag: self.tag )}
                if let value = action.category{ DataLog.d("  category : " +  value, tag: self.tag )}
                if let value = action.menu_name{ DataLog.d("  menu_name : " +  value, tag: self.tag )}
                if let value = action.menu_id{ DataLog.d("  menu_id : " +  value, tag: self.tag )}
                if let value = action.result{ DataLog.d("  result : " +  value, tag: self.tag )}
                if let value = action.target{ DataLog.d("  target : " +  value, tag: self.tag )}
                if let value = action.search_keyword{ DataLog.d("  search_keyword : " +  value, tag: self.tag )}
                if let value = action.position{ DataLog.d("  position : " +  value, tag: self.tag )}
            }
            if let content = modifyData.contents_body {
                DataLog.d("send content : ", tag: self.tag )
                if let value = content.title{ DataLog.d("  title : " +  value, tag: self.tag )}
                if let value = content.episode_id{ DataLog.d("  episode_id : " +  value, tag: self.tag )}
                if let value = content.episode_resolution_id{
                    DataLog.d("  episode_resolution_id : " +  value, tag: self.tag )
                }
                if let value = content.genre_code{ DataLog.d("  genre_code : " +  value, tag: self.tag )}
                if let value = content.genre_text{ DataLog.d("  genre_text : " +  value, tag: self.tag )}
                if let value = content.paid{ DataLog.d("  paid : " +  value.description, tag: self.tag )}
                if let value = content.payment_price{ DataLog.d("  payment_price : " +  value, tag: self.tag )}
                if let value = content.running_time{ DataLog.d("  running_time : " +  value, tag: self.tag )}
                if let value = content.channel_name{ DataLog.d("  channel_name : " +  value, tag: self.tag )}
                if let value = content.channel{ DataLog.d("  channel : " +  value, tag: self.tag )}
                if let value = content.purchase_type{ DataLog.d("  purchase_type : " +  value, tag: self.tag )}
                
            }
        }
        #endif
        
        self.repository.apiManager.load(.sendNaviLog(self.getJsonString(data: modifyData), isAnonymous: isAnonymous))
    }

    private func getRealNameData(
        page:PageObject? = nil,
        pageID:String? = nil,
        action:NaviLog.Action? = nil,
        watchType:NaviLog.watchType? = nil,
        naviLogData:NaviLogData? = nil
        ) -> MenuNaviItem? {
            
        if naviLogData?.contentsBody != nil,  let playStartTime = self.currentPlayStartTime {
            let runTime = Int(round((Date().timeIntervalSince1970 - playStartTime)))
            DataLog.d(" contentsWatch : runTime " + runTime.description , tag: self.tag )
            naviLogData?.contentsBody?.running_time = runTime.description
        }
        guard var menuNaviItem = self.getMenuNaviItem(
                page: page, pageId: pageID , action: action, watchType: watchType, contentBody: naviLogData?.contentsBody) else {
            return nil
        }
            
        menuNaviItem.vod_watch_type = watchType?.rawValue
        menuNaviItem.service_name = "btv_plus_pi"
        menuNaviItem.device_base_time = naviLogData?.now.toDateFormatter(dateFormat: "yyyyMMddHHmmss.SSS")
        menuNaviItem.pcid = self.repository.namedStorage?.getPcid()
        menuNaviItem.stb_id = (NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId)
                .replace("{", with: "").replace("}", with: "")
        menuNaviItem.stb_mac = self.repository.pairing.hostDevice?.convertMacAdress  ?? ""
        menuNaviItem.session_id = self.repository.namedStorage?.getSessionId()
        menuNaviItem.action_body = naviLogData?.actionBody// ?? MenuNaviActionBodyItem()
        menuNaviItem.url = "";
        menuNaviItem.client_ip = AppUtil.getIPAddress() ?? "0.0.0.0"
        menuNaviItem.member = naviLogData?.member
        return menuNaviItem
    }
    
    private func getAnonymousData(
        page:PageObject? = nil,
        pageID:String? = nil,
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
        pageId:String? = nil,
        action:NaviLog.Action? = nil,
        watchType:NaviLog.watchType? = nil,
        contentBody:MenuNaviContentsBodyItem? = nil
        ) -> MenuNaviItem? {
        var logPageId:String = ""
        if let pageId = pageId {
            logPageId = pageId
        } else if let page = page {
            guard let pageId = NaviLog.getPageID(page: page, repository: self.repository) else {
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
