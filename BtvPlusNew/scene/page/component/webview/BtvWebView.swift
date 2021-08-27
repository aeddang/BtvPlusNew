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

enum WebviewMethod:String {
    case getSTBInfo, getNetworkState, getLogInfo, stopLoading
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
}
enum WebviewRespond:String {
    case responseVoiceSearch, responseSTBViewInfo
}

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
    
    static let happySenior = "/view/v3.0/setting/happysenior"
    
    static let callJsPrefix = "javascript:"
    
}



struct BtvWebView: PageComponent {
    
    @ObservedObject var viewModel:WebViewModel = WebViewModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    @State private var isLoading:Bool = false
    var useNativeScroll:Bool = true
    var scriptMessageHandler :WKScriptMessageHandler? = nil
    var scriptMessageHandlerName : String = ""
    var uiDelegate:WKUIDelegate? = nil
    
    var body: some View {
        ZStack{
            BtvCustomWebView( viewModel: self.viewModel , useNativeScroll:self.useNativeScroll)
                .opacity(self.isLoading ? 0 : 1)
            ActivityIndicator( isAnimating: self.$isLoading,
                               style: .large,
                               color: Color.app.white )
        }
        .onReceive(self.viewModel.$status){ stat in
            if stat == .complete {self.isLoading = false}
            else if stat == .ready {self.isLoading = true}
        }
        .onReceive(self.pageObservable.$status){ stat in
            if stat == .disconnect || stat == .disAppear { self.viewModel.status = .end }
        }
    }
}

struct BtvCustomWebView : UIViewRepresentable, WebViewProtocol, PageProtocol {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var viewModel:WebViewModel
    var useNativeScroll:Bool = true
    var path: String = ""
    var request: URLRequest? {
        get{
            ComponentLog.log("origin request " + viewModel.path , tag:self.tag )
            let encodedString = viewModel.path.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)
            guard let path = encodedString else { return nil }
            ComponentLog.log("encoded request " + viewModel.path , tag:self.tag )
            guard let url:URL = URL(string: path) else { return nil }
            return URLRequest(url: url)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        let config = WKWebViewConfiguration()
        let deviceType = AppUtil.isPad() ? "BtvTablet" : "BtvPhone"
        config.applicationNameForUserAgent = "BtvPlusApp/1.54/\(deviceType)"
        config.mediaTypesRequiringUserActionForPlayback = []
        //config.requiresUserActionForMediaPlayback = false
        //config.mediaPlaybackRequiresUserAction = false
        config.allowsInlineMediaPlayback = true
        config.processPool = WKProcessPool()
        #if DEBUG
            config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif
        let uiView = creatWebView(config: config)
        uiView.navigationDelegate = context.coordinator
        uiView.uiDelegate = context.coordinator
        uiView.allowsLinkPreview = false
        uiView.scrollView.bounces = false
        uiView.isOpaque = false
        return uiView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if self.viewModel.status != .update { return }
        switch self.viewModel.request{
        case .evaluateJavaScript : break
        default :
            if uiView.isLoading {
                self.viewModel.status = .error
                self.viewModel.error = .busy
                return
            }
        }
        
        if let e = self.viewModel.request { update(uiView , evt:e) }
    }
    
    private func checkLoading(_ uiView: WKWebView){
        var job:AnyCancellable? = nil
        
        job = Timer.publish(every: 0.1, on:.current, in: .common)
            .autoconnect()
            .sink{_ in
                switch self.viewModel.status {
                case .end :
                    job?.cancel()
                    return
                default : break
                }
                
                if !uiView.isLoading {
                    job?.cancel()
                    self.viewModel.status = .complete
                    return
                }
        }
    }
    
    private func goHome(_ uiView: WKWebView){
        self.viewModel.path = self.viewModel.base
        if self.viewModel.path == "" {
            self.viewModel.error = .update(.home)
            return
        }
        self.viewModel.status = .ready
        load(uiView)
        checkLoading(uiView)
    }
    
    @State var isReady = true
    @State var evalQ:[String] = []
    fileprivate func callJS(_ uiView: WKWebView, jsStr: String) {
        if !isReady {
            ComponentLog.d("callJS add Q", tag: self.tag)
            evalQ.append(jsStr)
            return
        }
        self.isReady = false
        ComponentLog.d("callJS " + jsStr, tag: self.tag)
        uiView.evaluateJavaScript(jsStr, completionHandler: { (result, error) in
            let resultString = result.debugDescription
            let errorString = error.debugDescription
            let msg = jsStr + " -> result: " + resultString + " error: " + errorString
            ComponentLog.d(msg, tag: self.tag)
            self.isReady = true
            if !self.evalQ.isEmpty {
                let first = self.evalQ.removeFirst()
                DispatchQueue.main.async { callJS(uiView, fn: first)}
            }
        })
        
    }
    
    fileprivate func callJS(_ uiView: WKWebView, fn: String, dic:[String: Any]? = nil) {
        var jsStr = ""
        if let dic = dic {
            let jsonString = AppUtil.getJsonString(dic: dic) ?? ""
            jsStr = fn + "(\'" + jsonString + "\');"
        } else {
            
            jsStr = fn.last == ";" ? fn : fn + "();"
        }
        self.callJS(uiView, jsStr: jsStr)
    }
    
    fileprivate func callPage(_ path:String, param:[URLQueryItem]? = nil) {
        
        switch path {
        case "synopsis":
            let id = param?.first(where: {$0.name == "id"})?.value
            let contentId = param?.first(where: {$0.name == "contentId"})?.value
            let cid = param?.first(where: {$0.name == "cid"})?.value
            let type = param?.first(where: {$0.name == "type"})?.value
            let synopsisType = SynopsisType(value:type)
            let epsdId = synopsisType == .title ? ((id ?? contentId) ?? cid) : cid
            let srisId = synopsisType == .package ? ((id ?? contentId) ?? cid) : nil
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(synopsisType == .package ? .synopsisPackage : .synopsis)
                    .addParam(key: .data, value: SynopsisQurry(srisId: srisId, epsdId: epsdId))
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
            self.pagePresenter.changePage(PageProvider
                                            .getPageObject(page)
                                            .addParam(key: .id, value: band?.menuId)
                                            .addParam(key: .subId, value: menuOpenId)
                                            .addParam(key: UUID().uuidString, value: "")
            )
            
        case "event":
             if let menuOpenId = param?.first(where: {$0.name == "menu_id"})?.value {
                let band = self.dataProvider.bands.getData(gnbTypCd: EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue)
                self.pagePresenter.openPopup(
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
                                self.pagePresenter.changePage(
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
                        self.pagePresenter.openPopup(pageObj)
                    }
                }
                else if let link = data.outLink {
                    AppUtil.openURL(link)
                }
                else if let link = data.inLink {
                    self.pagePresenter.openPopup(
                        PageProvider
                            .getPageObject(.webview)
                            .addParam(key: .data, value: link)
                            .addParam(key: .title , value: data.title)
                    )
                }
             }
            
            
        case "point", "coupon", "bpoint":
            if self.pairing.status != .pairing {
                self.appSceneObserver.alert = .needPairing()
                return
            }
            let num:String? = param?.first(where: {$0.name == "extra"})?.value
            let menuType:PageMyBenefits.MenuType = PageMyBenefits.getType(path)
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.myBenefits)
                    .addParam(key: .id, value: menuType.rawValue)
            )
           
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.confirmNumber)
                    .addParam(key: .type, value: menuType)
                    .addParam(key: .data, value: num)
                    
            )
       
        case "family_invite":
            if self.pairing.status != .pairing {
                self.appSceneObserver.alert = .needPairing()
                return
            }
            guard let token:String = param?.first(where: {$0.name == "pairing_token"})?.value else {return}
            let name:String? = param?.first(where: {$0.name == "nickname"})?.value
            self.pagePresenter.openPopup(
                PageProvider
                    .getPageObject(.pairingFamilyInvite)
                    .addParam(key: .id, value: token)
                    .addParam(key: .title , value: name)
            )
            
        default: break
        }
        
    }
    
    private func update(_ uiView: WKWebView, evt:WebViewRequest){
        switch evt {
        case .home:
            goHome(uiView)
            return
        case .writeHtml(let html):
            uiView.loadHTMLString(html, baseURL: nil)
            return
        case .evaluateJavaScript(let jsStr):
            DispatchQueue.main.async {
                self.callJS(uiView, jsStr: jsStr)
            }
            return
        case .evaluateJavaScriptMethod(let fn, let dic):
            DispatchQueue.main.async {
                self.callJS(uiView, fn: fn, dic: dic)
            }
            return
        case .back:
            if uiView.canGoBack {uiView.goBack()}
            else {
                self.viewModel.error = .update(.back)
                return
            }
        case .foward:
            if uiView.canGoForward {uiView.goForward() }
            else {
                self.viewModel.error = .update(.foward)
                return
            }
        case .link(let path) :
            viewModel.path = path
            load(uiView)
        }
        self.viewModel.status = .ready
        checkLoading(uiView)
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) {
        dismantleUIView( uiView )
    }
    
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, PageProtocol {
        
        var parent: BtvCustomWebView
        init(_ parent: BtvCustomWebView) {
            self.parent = parent
        }
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     preferences: WKWebpagePreferences,
                     decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            
            preferences.preferredContentMode = .mobile
            let url = navigationAction.request.url?.absoluteString
            if navigationAction.navigationType == .backForward {
                //checkReload(curUrl: url!)
                // 편성표를 back으로 오는 경우에는 reload한다.
            }
            ComponentLog.d(url ?? "", tag:"WebView")
            if (url?.hasPrefix("btvplus://"))! {
                if let urlStr = url {
                    if let components = URLComponents(string: urlStr) {
                        if let path = components.host {
                            let param = components.queryItems
                            ComponentLog.d("path " + path, tag: self.tag)
                            ComponentLog.d("param " + (param?.debugDescription ?? ""), tag: self.tag)
                            self.parent.callPage(path, param: param)
                            self.parent.viewModel.event = .callPage(path, param)
                        }
                    }
                }
                decisionHandler(.cancel, preferences)
                return
            }
            if (url?.hasPrefix("btvplusapp://"))! {
    
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
                            default:do{}
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
                            dic = self.parent.repository.webBridge.getNetworkState()
                        case WebviewMethod.getSTBInfo.rawValue :
                            dic = self.parent.repository.webBridge.getSTBInfo()
                        case WebviewMethod.getLogInfo.rawValue :
                            dic = self.parent.repository.webBridge.getLogInfo()
                        case WebviewMethod.bpn_requestPassAge.rawValue :
                            value = self.parent.repository.webBridge.getPassAge()
                            
                        case WebviewMethod.bpn_showSynopsis.rawValue :
                            if let jsonString = jsonParam {
                                let jsonData = jsonString.data(using: .utf8)!
                                do {
                                    let data = try JSONDecoder().decode(SynopsisJson.self, from: jsonData)
                                    let type = SynopsisType(value: data.synopType)
                                    self.parent.pagePresenter.openPopup(
                                        PageProvider.getPageObject(type == .package ? .synopsisPackage : .synopsis)
                                            .addParam(key: .data, value: data)
                                    )
                                } catch {
                                    ComponentLog.e("json parse error", tag:"WebviewMethod.bpn_showSynopsis")
                                }
                            }
                        case WebviewMethod.bpn_showModalWebView.rawValue :
                            if let jsonString = jsonParam {
                                let jsonData = jsonString.data(using: .utf8)!
                                do {
                                    let data = try JSONDecoder().decode(WebviewJson.self, from: jsonData)
                                    self.parent.pagePresenter.openPopup(
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
                        
                        case WebviewMethod.stopLoading.rawValue :
                            self.forceRetry(webView: webView)
                        default :
                            self.parent.viewModel.event = .callFuncion(fn, jsonParam, cbName )
                        }
                        if let dic = dic, let cb = cbName, !cb.isEmpty {
                            let js = BtvWebView.callJsPrefix + cb
                            DispatchQueue.main.async {
                                self.parent.callJS(webView, fn: js, dic: dic)
                            }
                        }
                        if let value = value, let cb = cbName, !cb.isEmpty {
                            let js = BtvWebView.callJsPrefix + cb + "(" + value + ");"
                            DispatchQueue.main.async {
                                self.parent.callJS(webView, jsStr: js)
                            }
                        }
                    }
                }
                decisionHandler(.cancel, preferences)
                return
            }
            decisionHandler(.allow, preferences)
        }
        
        func forceRetry(webView: WKWebView) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if webView.isLoading { webView.reload() }
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {}
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            ComponentLog.d("didCommit" , tag: self.tag )
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            ComponentLog.e("didFail: " + error.localizedDescription , tag: self.tag )
        }
        
       
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
                DispatchQueue.main.async {
                    self.parent.viewModel.screenHeight = height as! CGFloat
                    if self.parent.useNativeScroll {
                        webView.bounds.size.height = self.parent.viewModel.screenHeight
                    }
                    ComponentLog.d("document.documentElement.scrollHeight " + webView.bounds.size.height.description, tag: self.tag)
                }
            })
            //선택 제거
            let disabledSelect = "document.documentElement.style.webkitUserSelect='none';"
            //복사 붙여넣기 같은 팝업 제거
            let disabledOptionBubble = "document.documentElement.style.webkitTouchCallout='none';"
            //하이라이트 제거
            let disabledHightlight = "document.documentElement.style.webkitTapHighlightColor='rgba(0,0,0,0)';"
            //let disabledScroll = "document.body.style.overflow = 'hidden';"
            let disabledScroll = "document.querySelectorAll('*[style]').forEach(el => el.style.overflow = 'scroll');"
            // 자동 완성 제거
            let disableAutocompleteScript: String = """
                var textFields = document.getElementsByTagName('textarea');
                if (textFields) {
                    var i;
                    for( i = 0; i < textFields.length; i++) {
                        var txtField = textFields[i];
                        if(txtField) {
                            txtField.setAttribute('autocomplete','off');
                            txtField.setAttribute('autocorrect','off');
                            txtField.setAttribute('autocapitalize','off');
                            txtField.setAttribute('spellcheck','false');
                        }
                    }
                }
            """
            [disabledSelect, disabledOptionBubble, disabledHightlight, disableAutocompleteScript, disabledScroll ].forEach { option in
                self.parent.callJS(webView, jsStr: option)
            }
            
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
                for cookie in cookies {
                    if cookie.name.contains("BtvplusWebVer") {
                        self.parent.naviLogManager.setupWebPageVersion(cookie.value)
                    }
                }
            }
        }
        
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            ComponentLog.e("error: " + error.localizedDescription , tag: self.tag )
            guard let failingUrlStr = (error as NSError).userInfo["NSErrorFailingURLStringKey"] as? String  else { return }
            guard let failingUrl = URL(string: failingUrlStr) else { return }
            guard let scheme = failingUrl.scheme?.lowercased() else { return }
            ComponentLog.d("scheme: " + scheme , tag: self.tag )
            
            if scheme == "tel" || scheme == "mailto"
                || scheme == "itmss" || scheme == "itms-appss" || scheme == "btvmobile" {
                
                ComponentLog.d("openURL: " + failingUrlStr , tag:self.tag)
                AppUtil.openURL(failingUrlStr)
                return
            }
            
            if scheme == "outlink" {
                let replacedUrl = failingUrlStr
                    .replace("outlink://", with: "")
                    .replace("https//", with: "https://")
                    .replace("http//", with: "http://")
                
                ComponentLog.d("openURL: " + replacedUrl , tag:self.tag)
                AppUtil.openURL(replacedUrl)
                return
            }
            
            if scheme == "http" || scheme == "https" {
                let errorCode = (error as NSError).code
                if errorCode == -1001 || errorCode == -1003 || errorCode == -1009 {
                    self.parent.appSceneObserver.alert = .serviceUnavailable(failingUrlStr)
                    return
                }
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            
            self.parent.appSceneObserver.alert = .alert(nil,  message, nil ,completionHandler)
           
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            
            self.parent.appSceneObserver.alert = .confirm(nil,  message, nil, completionHandler)
        }

        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
                     defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (String?) -> Void) {
            self.parent.appSceneObserver.alert = .serviceSelect( prompt, defaultText, completionHandler)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                     decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
            
            guard
                let response = navigationResponse.response as? HTTPURLResponse,
                let url = navigationResponse.response.url
                else {
                    decisionHandler(.cancel)
                    return
                }
            if let headerFields = response.allHeaderFields as? [String: String] {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
                cookies.forEach { (cookie) in
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
            decisionHandler(.allow)
        }
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

