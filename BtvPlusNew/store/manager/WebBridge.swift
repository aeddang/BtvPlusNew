//
//  ApiManager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Combine

enum WebviewMethod:String {
    case getSTBInfo, getNetworkState, getLogInfo, stopLoading,
         setUserAgreementInfo, requestRemoconFunction
    case requestVoiceSearch, requestSTBViewInfo
    case externalBrowser
    case bpn_showSynopsis,
         bpn_backWebView, bpn_closeWebView, bpn_showModalWebView,
         bpn_setShowModalWebViewResult,bpn_setIdentityVerfResult, bpn_setPurchaseResult,
         bpn_setKidsMode,
         bpn_showTopBar,bpn_changeTopBar,bpn_hideTopBar,bpn_setTopBarTitle,
         bpn_requestGnbBlockData,bpn_requestMoveWebByCallUrl,
         bpn_setPassAge, bpn_requestPassAge,bpn_showMyBtv,
         bpn_requestHlsTokenInfo,bpn_setMute,bpn_requestMuteState,
         bpn_setMoveListener,bpn_setBackListener,
         bpn_requestFocus,bpn_showComingSoon,bpn_showMyPairing,bpn_familyInvite
    case bpn_registPaymentMethod,
         bpn_reqSendEventpageLog,
         bpn_eventSharing,
         bpn_getAttendanceInfo,
         bpn_reqAttendance,
         bpn_getNickName,
         bpn_getRecomCntNPoint,
         bpn_eventMonthlyPoint,
         bpn_eventCommerce
}
enum WebviewRespond:String {
    case responseVoiceSearch, responseSTBViewInfo
}

struct DeepLinkItem{
    var path:String? = nil
    var querys:[URLQueryItem]? = nil
    
    var funcName:String? = nil
    var query:String? = nil
    var jsonParam:String?  = nil
    var cbName:String?  = nil
    
    var dic:[String: Any]? = nil
    var value:String? = nil

    //webview action
    var isForceRetry:Bool = false
    var isCallFuncion:Bool = false
    
    
}


class WebBridge :PageProtocol{
    private let pairing:Pairing
    private let storage:LocalStorage
    var namedStorage:LocalNamedStorage? = nil
    private let setup:Setup
    private let shareManager:ShareManager
    private let networkObserver:NetworkObserver
    private let pagePresenter:PagePresenter?
    private let dataProvider:DataProvider
    private let appSceneObserver:AppSceneObserver?
    
    init(pagePresenter:PagePresenter?,
         dataProvider: DataProvider,
         appSceneObserver:AppSceneObserver?,
         pairing:Pairing,
         storage:LocalStorage,
         setup:Setup,
         shareManager:ShareManager,
         networkObserver:NetworkObserver) {
        
        self.pairing = pairing
        self.storage = storage
        self.setup = setup
        self.shareManager = shareManager
        self.pagePresenter = pagePresenter
        self.dataProvider = dataProvider
        self.appSceneObserver = appSceneObserver
        self.networkObserver = networkObserver
    }
    func getNetworkState()->[String: Any] {
        var networkState:String = ""
        switch (self.networkObserver.status) {
        case .wifi: networkState = "WIFI"
        case .cellular: networkState = "MOBILE"
        default: networkState = "UNCONNECTED"
        }
        var info = [String: Any]()
        info["networkState"] = networkState
        return info
    }

    func getSTBInfo()->[String: Any] {
        var info = [String: Any]()
        let maskingPhoneNumber:String = (pairing.phoneNumer.count == 10)
            ? pairing.phoneNumer.replace(start: 3, len: 2, with:  "****")
            : pairing.phoneNumer.replace(start: 3, len: 3, with:  "****")
        info["phoneNumer"] = maskingPhoneNumber
        info["networkState"] = self.networkObserver.status == .wifi ? 1 : 0
        info["pairingState"] = pairing.status == .pairing ? 0 : 1
        info["pairingType"] = 0
        info["stbId"] = AppUtil.getSafeString(pairing.stbId, defaultValue: "null")
        info["hashId"] = ApiUtil.getHashId(pairing.stbId)
        info["stbName"] = nil
        info["macAddress"] = AppUtil.getSafeString(pairing.hostDevice?.convertMacAdress, defaultValue: "null")
        //var adultMenuLimit = false
        
        
        var RCUAgentVersion:String? = nil
        if let hostDevice = pairing.hostDevice {
            // adultMenuLimit = hostDevice.adultAafetyMode
            RCUAgentVersion = hostDevice.agentVersion
        }
        info["isAdultAuth"] = setup.isAdultAuth       // 성인인증 ON/OFF
        info["isPurchaseAuth"] = setup.isPurchaseAuth   // 구매인증 ON/OFF
        info["isMemberAuth"] = setup.isFirstMemberAuth   // 최초 본인 인증 여부
        info["restrictedAge"] = setup.isAdultAuth ? (setup.restrictedAge ?? 0) : 0 
        info["RCUAgentVersion"] = AppUtil.getSafeString(RCUAgentVersion, defaultValue: "0.0.0")
        info["userAgent"] = ScsNetwork.getUserAgentParameter()
        info["isShowRemoconSelectPopup"] = setup.autoRemocon
        info["isShowAutoRemocon"] = setup.autoRemocon
        
        info["marketingInfo"] = pairing.user?.isAgree3 == true ? 1 : 0
        info["pushInfo"] = pairing.user?.isAgree3 == true ? 1 : 0
        
        let userInfo = pairing.userInfo?.user
        info["regionCode"] = pairing.getRegionCode()
        info["svc"] = AppUtil.getSafeString(userInfo?.svc, defaultValue: "0")
        info["ukey_prod_id"] = AppUtil.getSafeString(userInfo?.ukey_prod_id, defaultValue: "null")
        
        info["combine_product_use"] = AppUtil.getSafeString(userInfo?.combine_product_use, defaultValue: "N")
        info["combine_product_list"] = AppUtil.getSafeString(userInfo?.combine_product_list, defaultValue: "null")
        info["isSupportSimplePairing"] = pairing.hostDevice?.isSupportSimplePairing() ?? false
        
        info["evaluation"] = SystemEnvironment.isEvaluation
        info["clientId"] = SystemEnvironment.getGuestDeviceId()
        info["expiredSTB"] = false
        
        return info
    }
    
    func getSTBPlayInfo(result:ResultMessage, broadcastProgram:BroadcastProgram?)->[String: Any] {
        var info = [String: Any]()
        var subInfo = [String: Any]()
        let type =  result.body?.message?.SvcType ?? ""
        if let program =  broadcastProgram {
            if program.isOnAir {
                subInfo["serviceId"] = program.serviceId
                subInfo["channelNo"] = program.channelNo
                subInfo["channelName"] = program.channel
                subInfo["channelImageName"] = program.image
                if let programTitle = program.title {
                    subInfo["currentProgramName"] = programTitle
                    subInfo["programRating"] = program.rating
                    subInfo["isAdultProgram"] = program.isAdult
                    subInfo["lStartTime"] = program.startTime
                    subInfo["lEndTime"] = program.endTime
                }
            } else{
                subInfo["playTime"] = program.duration
                subInfo["rating"] = program.rating
                subInfo["contentId"] = result.body?.message?.CurCID
                subInfo["poster"] = program.image
                subInfo["isAdult"] = program.isAdult
                subInfo["title"] = program.title
                subInfo["seriesNo"] = program.seriesNo
                subInfo["isSeries"] = program.isSeries
                
            }
            info["isPlaying"] = true
        } else {
            if type == "OAP" {
                info["isPlaying"] = true
                subInfo["title"] = String.remote.playNoInfo
            } else {
                info["isPlaying"] = false
            }
        }
        info["result"] = result.header?.result?.toInt() ?? -1
        info["svcType"] = type
        info["stbViewInfo"] = subInfo
        return info
    }

    func getPassAge()-> String {
        return SystemEnvironment.watchLv.description
    }
    func getNickname()-> String {
        return self.pairing.user?.nickName ?? ""
    }
    
    func getLogInfo()->[String: Any] {
        var info = [String: Any]()
        info["log_type"] = SystemEnvironment.isStage ? "dev" : "live"
        info["stb_onead_id"] = nil
        info["pcid"] = self.namedStorage?.getPcid()
        info["session_id"] = self.namedStorage?.getSessionId()
        info["stbId"] = pairing.stbId
        info["stb_mac"] = pairing.hostDevice?.convertMacAdress ?? ""
        info["app_release_version"] = SystemEnvironment.bundleVersion
        info["app_build_version"] = SystemEnvironment.buildNumber
        info["os_name"] = "iOS"
        info["os_version"] = SystemEnvironment.systemVersion
        info["device_model"] = AppUtil.model
        
        info["manufacturer"] = "Apple"
        info["gaid"] = nil
        info["idfa"] = AppUtil.idfa
        info["client_ip"] = AppUtil.getIPAddress() ?? "0.0.0.0"
        
        info["pi_url"] = ApiPath.getRestApiPath(.NAVILOG)
        info["npi_url"] = ApiPath.getRestApiPath(.NAVILOG_NPI)
        return info
    }
    
    func parseUrl(_ url:String?) -> DeepLinkItem?{
        ComponentLog.d("url : " + (url ?? ""), tag:"WebBridge")
        if (url?.hasPrefix("btvplus://"))! {
            if let urlStr = url {
                if let components = URLComponents(string: urlStr) {
                    if let path = components.host {
                        let param = components.queryItems
                        ComponentLog.d("path " + path, tag: self.tag)
                        ComponentLog.d("param " + (param?.debugDescription ?? ""), tag: self.tag)
                        
                       
                        self.callPage(path, param: param)
                        return DeepLinkItem(path: path, querys: param)
                    }
                }
            }
            return DeepLinkItem()
        }
        if (url?.hasPrefix("btvplusapp://"))! {
            var deepLinkItem = DeepLinkItem()
            var funcName:String? = nil
            var query:String? = nil
            var jsonParam:String?  = nil
            var cbName:String?  = nil
            if let path = url?.replace("btvplusapp://", with: "") {
                let paths = path.components(separatedBy: "?")
                if paths.count > 0  { funcName = paths[0] }
                if paths.count > 1  { query = paths[1] }
                if (query?.count ?? 0) > 0 {
                    for pair in query!.components(separatedBy: "&") {
                        let key = pair.components(separatedBy: "=")[0]
                        let value = pair
                            .components(separatedBy:"=")[1]
                            .replacingOccurrences(of: "+", with: " ")
                            .removingPercentEncoding ?? ""
                        switch key {
                        case "jsonParam": jsonParam = value
                        case "cbName": cbName = value
                        default:break
                        }
                    }
                }
                if let fn = funcName {
                    ComponentLog.d("funcName " + fn, tag: self.tag)
                    ComponentLog.d("query " + (query ?? ""), tag: self.tag)
                    ComponentLog.d("jsonParam " + (jsonParam ?? ""), tag: self.tag)
                    ComponentLog.d("cbName " + (cbName ?? ""), tag: self.tag)
                    var dic:[String: Any]? = nil
                    var value:String? = nil
                    
                    switch fn {
                    case WebviewMethod.getNetworkState.rawValue :
                        dic = self.getNetworkState()
                    case WebviewMethod.getSTBInfo.rawValue :
                        dic = self.getSTBInfo()
                    case WebviewMethod.getLogInfo.rawValue :
                        dic = self.getLogInfo()
                    case WebviewMethod.bpn_requestPassAge.rawValue :
                        value = self.getPassAge()
                    case WebviewMethod.bpn_getNickName.rawValue :
                        value = self.getNickname()
                        
                    case WebviewMethod.bpn_showSynopsis.rawValue :
                        if let jsonString = jsonParam {
                            let jsonData = jsonString.data(using: .utf8)!
                            do {
                                let data = try JSONDecoder().decode(SynopsisJson.self, from: jsonData)
                                let type = SynopsisType(value: data.synopType)
                                self.pagePresenter?.openPopup(
                                    PageProvider.getPageObject(type == .package ? .synopsisPackage : .synopsis)
                                        .addParam(key: .data, value: data)
                                )
                            } catch {
                                ComponentLog.e("json parse error", tag:"WebviewMethod.bpn_showSynopsis")
                            }
                        }
                    case WebviewMethod.bpn_showComingSoon.rawValue :
                        if let block = self.dataProvider.bands.getPreviewBlockData()  {
                            let data = CateData().setData(data: block)
                            self.pagePresenter?.openPopup(
                                PageProvider.getPageObject(.previewList)
                                    .addParam(key: .title, value: data.title)
                                    .addParam(key: .id, value: data.menuId)
                                    .addParam(key: .data, value: data)
                                    .addParam(key: .needAdult, value: data.isAdult)
                            )
                            
                        } else {
                            ComponentLog.e("band notfound", tag:"WebviewMethod.bpn_showComingSoon")
                        }
                    case WebviewMethod.bpn_showMyPairing.rawValue :
                        if self.pairing.status == .pairing  {
                            self.pagePresenter?.openPopup(
                                PageProvider.getPageObject(.pairingManagement)
                            )
                        }
                    case WebviewMethod.bpn_registPaymentMethod.rawValue :
                        if self.pairing.status == .pairing ,  let jsonString = jsonParam  {
                            let jsonData = AppUtil.getJsonParam(jsonString: jsonString)
                            if let type = jsonData?["type"] as? String {
                                //let purchaseUrl = jsonData?["purchaseUrl"] as? String
                                self.pagePresenter?.openPopup(
                                    PageProvider.getPageObject(.myRegistCard)
                                        .addParam(key: PageParam.type, value: CardBlock.ListType.getType(type))
                                )
                            } else {
                                ComponentLog.e("type notfound", tag:"WebviewMethod.bpn_registPaymentMethod")
                            }
                        }
                        
                    case WebviewMethod.bpn_showModalWebView.rawValue :
                        if let jsonString = jsonParam {
                            let jsonData = jsonString.data(using: .utf8)!
                            do {
                                let data = try JSONDecoder().decode(WebviewJson.self, from: jsonData)
                                self.pagePresenter?.openPopup(
                                    PageProvider
                                        .getPageObject(.webview)
                                        .addParam(key: .data, value: data.url)
                                        .addParam(key: .title , value: data.title)
                                )
                            } catch {
                                ComponentLog.e("json parse error", tag:"WebviewMethod.bpn_showModalWebView")
                            }
                        }
                    case WebviewMethod.externalBrowser.rawValue :
                        if let jsonString = jsonParam {
                            let jsonData = AppUtil.getJsonParam(jsonString: jsonString)
                            if let url = jsonData?["url"] as? String {
                                AppUtil.openURL(url)
                            }
                        }
                    case WebviewMethod.bpn_eventSharing.rawValue:
                        if let jsonString = jsonParam {
                            let jsonData = AppUtil.getJsonParam(jsonString: jsonString)
                            let title = jsonData?["title"] as? String
                            let descript = jsonData?["descript"] as? String
                            if let url = jsonData?["url"] as? String{
                                self.shareEvent(eventLink: url, text: title, linkText: descript)
                            }
                        }
                        
                    case WebviewMethod.stopLoading.rawValue :
                        deepLinkItem.isForceRetry = true
                        //self.forceRetry(webView: webView)
                    default :
                        deepLinkItem.isCallFuncion = true
                        //self.parent.viewModel.event = .callFuncion(fn, jsonParam, cbName )
                    }
                    deepLinkItem.dic = dic
                    deepLinkItem.value = value
                    
                }
            }
            deepLinkItem.funcName = funcName
            deepLinkItem.query = query
            deepLinkItem.jsonParam = jsonParam
            deepLinkItem.cbName = cbName
            return deepLinkItem
        }
        
        return nil
    }
    
    func shareEvent(eventLink :String, text:String? = nil, linkText:String? = nil){
       
        let link = ApiPath.getRestApiPath(.WEB)
            + SocialMediaSharingManage.event
            + "&id=" + eventLink
            
        self.shareManager.share(
            Shareable(
                link:link,
                text: text ?? String.share.eventTitle,
                linkText: linkText,
                useDynamiclink:true
            )
        ){ isComplete in
            self.appSceneObserver?.event = .toast(isComplete ? String.share.complete : String.share.fail)
        }
    }
    
    func requestRemocon(eventLink :String, text:String? = nil, linkText:String? = nil){
       
        let link = ApiPath.getRestApiPath(.WEB)
            + SocialMediaSharingManage.event
            + "&id=" + eventLink
            
        self.shareManager.share(
            Shareable(
                link:link,
                text: text ?? String.share.eventTitle,
                linkText: linkText,
                useDynamiclink:true
            )
        ){ isComplete in
            self.appSceneObserver?.event = .toast(isComplete ? String.share.complete : String.share.fail)
        }
    }
   
    func callPage(_ path:String, param:[URLQueryItem]? = nil) {
        
        switch path {
        case "synopsis":
            let id = param?.first(where: {$0.name == "id"})?.value
            let contentId = param?.first(where: {$0.name == "contentId"})?.value
            let cid = param?.first(where: {$0.name == "cid"})?.value
            let type = param?.first(where: {$0.name == "type"})?.value
            let synopsisType = SynopsisType(value:type)
            let epsdId = synopsisType != .package ? ((id ?? contentId) ?? cid) : cid
            let srisId = synopsisType == .package ? ((id ?? contentId) ?? cid) : nil
            self.pagePresenter?.openPopup(
                PageProvider.getPageObject(synopsisType == .package ? .synopsisPackage : .synopsis)
                    .addParam(key: .data, value: SynopsisQurry(srisId: srisId, epsdId: epsdId))
                    .addParam(key: .datas, value: param)
            )
        case "menu":
            guard let menus = param?.first(where: {$0.name == "menus"})?.value else {return}
            if menus.isEmpty {return}
            let menuA = menus.split(separator: "/")
            if menuA.isEmpty {return}
            
            
            let gnbTypCd:String = String(menuA[0])
            let menuOpenId:String? =
                menuA.count > 1 ? menuA[1..<menuA.count].reduce("", {$0 + "|" + $1}) : nil
            
            let page:PageID = gnbTypCd.hasPrefix(EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue)
                ? .category : .home
            let band = self.dataProvider.bands.getData(gnbTypCd: gnbTypCd)
            
            PageLog.t("callPage menu " + page)
            self.pagePresenter?.changePage(PageProvider
                                            .getPageObject(page)
                                            .addParam(key: .id, value: band?.menuId)
                                            .addParam(key: .subId, value: menuOpenId)
                                            .addParam(key: UUID().uuidString, value: "")
            )
            
        case "event":
             if let menuOpenId = param?.first(where: {$0.name == "menu_id"})?.value {
                let band = self.dataProvider.bands.getData(gnbTypCd: EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue)
                self.pagePresenter?.openPopup(
                    PageProvider
                        .getPageObject(.category)
                        .addParam(key: .id, value: band?.menuId)
                        .addParam(key: .subId, value: menuOpenId)
                )
             } else if let callUrl = param?.first(where: {$0.name == "event_url"})?.value {
                let data = BannerData().setData(callUrl: callUrl)
                if let move = data.move {
                    switch move {
                    case .home, .category:
                        if let gnbTypCd = data.moveData?[PageParam.id] as? String {
                            if let band = dataProvider.bands.getData(gnbTypCd: gnbTypCd) {
                                self.pagePresenter?.changePage(
                                    PageProvider
                                        .getPageObject(move)
                                        .addParam(params: data.moveData)
                                        .addParam(key: .id, value: band.menuId)
                                        .addParam(key: UUID().uuidString , value: "")
                                )
                            }
                        }
                        
                    default :
                        let pageObj = PageProvider.getPageObject(move)
                        pageObj.params = data.moveData
                        self.pagePresenter?.openPopup(pageObj)
                    }
                }
                else if let link = data.outLink {
                    AppUtil.openURL(link)
                }
                else if let link = data.inLink {
                    self.pagePresenter?.openPopup(
                        PageProvider
                            .getPageObject(.webview)
                            .addParam(key: .data, value: link)
                            .addParam(key: .title , value: data.title)
                    )
                }
             }
            
            
        case "point", "coupon", "bpoint":
            if self.pairing.status != .pairing {
                self.appSceneObserver?.alert = .needPairing()
                return
            }
            let num:String? = param?.first(where: {$0.name == "extra"})?.value
            let menuType:PageMyBenefits.MenuType = PageMyBenefits.getType(path)
            self.pagePresenter?.openPopup(
                PageProvider.getPageObject(.myBenefits)
                    .addParam(key: .id, value: menuType.rawValue)
            )
           
            self.pagePresenter?.openPopup(
                PageProvider.getPageObject(.confirmNumber)
                    .addParam(key: .type, value: menuType)
                    .addParam(key: .data, value: num)
                    
            )
       
        case "family_invite":
            
            guard let token:String = param?.first(where: {$0.name == "pairing_token"})?.value else {return}
            let name:String? = param?.first(where: {$0.name == "nickname"})?.value
            self.pagePresenter?.openPopup(
                PageProvider
                    .getPageObject(.pairingFamilyInvite)
                    .addParam(key: .id, value: token)
                    .addParam(key: .title , value: name)
            )
            
        default: break
        }
        
    }

}
