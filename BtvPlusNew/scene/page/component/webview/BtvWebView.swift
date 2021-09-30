//
//  ComponentWebView.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
import Combine

extension BtvWebView {
    static let identity = "/view/v3.0/identityverification"
    static let purchase = "/view/v3.0/purchase/list"
    static let person = "/view/v3.0/synopsis/person"
    static let search = "/view/v3.0/search/main"
    static let searchMore = "/view/v3.0/search/more_info"
    static let schedule = "/view/v3.0/epg"
    static let watchHabit = "/view/v3.0/child/parentalctrls"
    static let opensrcLicense = "/view/v3.0/opensrclicense"
    static let faq = "/view/v3.0/customer/helpfaq"
    static let notice = "/view/v3.0/customer/notice"
    static let event = "/view/v3.0/event/all"
    static let tip = "/view/v3.0/tip/all"
    static let serviceTerms = "/view/v3.0/terms"
    static let privacyAgreement = "/view/v3.0/agreement"

    static let happySenior = "/view/v3.0/setting/happysenior"
    static let callJsPrefix = "javascript:"
    
}

struct BtvWebView: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var viewModel:WebViewModel = WebViewModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    @State private var isLoading:Bool = false
    var useNativeScroll:Bool = false
    var scriptMessageHandler :WKScriptMessageHandler? = nil
    var scriptMessageHandlerName : String = ""
    var viewHeight:CGFloat? = nil
    var uiDelegate:WKUIDelegate? = nil
    
    var body: some View {
        ZStack{
            BtvCustomWebView( viewModel: self.viewModel ,
                              useNativeScroll:self.useNativeScroll,
                              viewHeight:self.viewHeight)
                .opacity(self.isLoading ? 0 : 1)
            
            ActivityIndicator( isAnimating: self.$isLoading,
                               style: .large,
                               color: Color.app.white )
        }
        .onReceive(self.appSceneObserver.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .update(let type):
                switch type {
                case .registCard(_) :
                    self.viewModel.request = .link(viewModel.path)
                default : break
                }
            default : break
            }
        }
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) { return }
            self.respondCallFuncion(res: res)
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            if !err.id.hasPrefix(self.tag) { return }
            self.errorCallFuncion(err: err)
            
        }
        .onReceive(self.viewModel.$status){ stat in
            if stat == .complete {self.isLoading = false}
            else if stat == .ready {self.isLoading = true}
        }
        .onReceive(self.pageObservable.$status){ stat in
            if stat == .disconnect || stat == .disAppear { self.viewModel.status = .end }
        }
        .onReceive(self.viewModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .callFuncion(let fn, let jsonParams, let callback) :
                self.callFuncion(fn: fn, jsonParams: jsonParams, callback: callback)
            default : break
            }
        }
        .onAppear(){
        }
    }
    
    @State var eventData:Any? = nil
   
    func callFuncion(fn:String, jsonParams:String?, callback:String? ){
        switch fn {
        case WebviewMethod.bpn_getRecomCntNPoint.rawValue :
            if self.pairing.status != .pairing {return}
            self.dataProvider.requestData(q: .init(id:self.tag, type: .getRecommendHistory(callback:callback)))
            return
        
        case WebviewMethod.bpn_reqSendEventpageLog.rawValue:
            guard let log = jsonParams else { return }
           
            self.naviLogManager.send(
                logString: log,
                completion: { res in
                    guard let callback = callback else {return}
                    var dic:[String : Any] = [:]
                    dic["result"] = res.result ?? ""
                    dic["reason"] = res.reason ?? ""
                    self.viewModel.request = .evaluateJavaScriptMethod( callback, dic)
                    
                },
                error: { err in
                    guard let callback = callback else {return}
                    var dic:[String : Any] = [:]
                    dic["result"] = ""
                    dic["reason"] = ""
                    self.viewModel.request = .evaluateJavaScriptMethod( callback, dic)
                }
            )
            return
        case WebviewMethod.setUserAgreementInfo.rawValue:
            if self.pairing.status != .pairing {
                self.appSceneObserver.alert = .needPairing()
                return
            }
            self.dataProvider.requestData(q: .init(id:self.tag, type: .updateAgreement(true, callback:callback)))
            return
        case WebviewMethod.bpn_registPaymentMethod.rawValue :
            if self.pairing.status == .pairing ,  let jsonString = jsonParams  {
                let jsonData = AppUtil.getJsonParam(jsonString: jsonString)
                if let type = jsonData?["type"] as? String {
                    //let purchaseUrl = jsonData?["purchaseUrl"] as? String
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.myRegistCard)
                            .addParam(key: PageParam.type, value: CardBlock.ListType.getType(type))
                    )
                } else {
                    ComponentLog.e("type notfound", tag:"WebviewMethod.bpn_registPaymentMethod")
                }
            }
        default : break
        }
        self.callFuncionEventAttendance(fn: fn, jsonParams: jsonParams, callback: callback)
        self.callFuncionEventMonthlyPoint(fn: fn, jsonParams: jsonParams, callback: callback)
        self.callFuncionEventCommerce(fn: fn, jsonParams: jsonParams, callback: callback)
        self.callFuncionRemocon(fn: fn, jsonParams: jsonParams, callback: callback)
    }
    
    func respondCallFuncion(res:ApiResultResponds){
        switch res.type {
        case .getRecommendHistory(let callback):
            guard let callback = callback else { return }
            guard let historys = res.data as? RecommandHistory else { return }
            var dic:[String : Any] = [:]
            dic["recomCnt"] = Int(historys.rec_total_cnt ?? "0") ?? 0
            dic["recomSuccessCnt"] = Int(historys.rec_succ_cnt ?? "0") ?? 0
            dic["myPoint"] = Int(historys.bpoint_total ?? "0") ?? 0
            self.viewModel.request = .evaluateJavaScriptMethod( callback, dic)
            return
        case .updateAgreement(_ , let callback) :
            guard let callback = callback else { return }
            let result = res.data as? NpsResult
            let code = result?.header?.result ?? ""
            let jsonString = code == ApiCode.success ? "0" : code
            self.viewModel.request = .evaluateJavaScript(callback + "(\'" + jsonString + "\')")
        
        default: break
        }
        self.respondCallFuncionEventAttendance(res: res)
        self.respondCallFuncionEventMonthlyPoint(res: res)
        self.respondCallFuncionEventCommerce(res: res)
        self.respondCallFuncionRemocon(res: res)
        
    }
    
    func errorCallFuncion(err:ApiResultError) {
        self.errorCallFuncionEventAttendance(err:err)
        self.errorCallFuncionEventMonthlyPoint(err:err)
        self.errorCallFuncionEventCommerce(err:err)
        self.errorCallFuncionRemocon(err:err)
    }
}


#if DEBUG
struct BtvWebView_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            BtvWebView(viewModel:WebViewModel(base: "https://www.todaypp.com")).contentBody
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

