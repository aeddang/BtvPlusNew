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
    
    
    private var currentPage:PageObject? = nil
    private var currentPop:PageObject? = nil
    private var webPageVersion:String? = nil
    private var currentMemberItem:MenuNaviMemberItem? = nil
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
    
    private func pageLog(_ page:PageObject, action:NaviLog.action){
        let data = NaviLogData()
        data.member = self.currentMemberItem
        if let realNameData = self.getRealNameData(page: page, action: action, naviLogData: data) {
            self.send(realNameData, isAnonymous: false)
        }
        if let anonymousData = self.getAnonymousData(page: page, action: action, naviLogData: data) {
            self.send(anonymousData, isAnonymous: true)
        }
    }
    
    private func send(_ data:MenuNaviItem, isAnonymous:Bool){
        self.repository.apiManager.load(.sendNaviLog(self.getJsonString(data: data), isAnonymous: isAnonymous))
    }

    private func getRealNameData(
        page:PageObject,
        action:NaviLog.action? = nil,
        watchType:NaviLog.watchType? = nil,
        naviLogData:NaviLogData? = nil
        ) -> MenuNaviItem? {
    
        guard var menuNaviItem = self.getMenuNaviItem(
                page: page, action: action, watchType: watchType, contentBody: naviLogData?.contentsBody) else {
            return nil
        }
        menuNaviItem.service_name = "btv_plus_pi"
        menuNaviItem.device_base_time = naviLogData?.now.toDateFormatter(dateFormat: "yyyyMMddHHmmss.SSS")
        menuNaviItem.pcid = self.repository.storage.getPcid()
        menuNaviItem.stb_id = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        menuNaviItem.stb_mac = self.repository.pairing.hostDevice?.convertMacAdress  ?? ""
        menuNaviItem.session_id = self.repository.storage.getSessionId()
        menuNaviItem.action_body = naviLogData?.actionBody ?? MenuNaviActionBodyItem()
        menuNaviItem.url = "";
        menuNaviItem.client_ip = AppUtil.getIPAddress() ?? "0.0.0.0"
        menuNaviItem.member = naviLogData?.member
        return menuNaviItem
    }
    
    private func getAnonymousData(
        page:PageObject,
        action:NaviLog.action? = nil,
        watchType:NaviLog.watchType? = nil,
        naviLogData:NaviLogData? = nil
        ) -> MenuNaviItem? {
    
        guard var menuNaviItem = self.getMenuNaviItem(
                page: page, action: action, watchType: watchType, contentBody: naviLogData?.contentsBody) else {
            return nil
        }
        menuNaviItem.service_name = "btv_plus_npi" 
        menuNaviItem.device_base_time = naviLogData?.now.toDateFormatter(dateFormat: "yyyyMMddHH0000.000")
        menuNaviItem.gaid = "";
        menuNaviItem.idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        return menuNaviItem
    }

    
    private func getMenuNaviItem(
        page:PageObject,
        action:NaviLog.action? = nil,
        watchType:NaviLog.watchType? = nil,
        contentBody:MenuNaviContentsBodyItem? = nil
        ) -> MenuNaviItem? {
        
        guard let pageId = NaviLog.getPageID(page: page, repository: self.repository) else {
            DataLog.d("getMenuNaviItem unused pageId",tag: self.tag)
            return nil
        }
        var item = MenuNaviItem()
        item.log_type = SystemEnvironment.isReleaseMode ? "live": "dev"
        item.poc_type = "mobile_app"
        item.page_id = pageId
        item.action_id = action?.rawValue ?? ""
        item.vod_watch_type = watchType?.rawValue ?? ""
        item.contents_body = contentBody ?? MenuNaviContentsBodyItem()
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
