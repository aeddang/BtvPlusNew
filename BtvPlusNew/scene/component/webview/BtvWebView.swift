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
    case getSTBInfo
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

extension BtvWebView {
    static let identity = "/view/v3.0/identityverification"
    static let purchase = "/view/v3.0/purchase/list"
    
    static let callJsPrefix = "javascript:"
}


struct BtvWebView: PageComponent {
    
    @ObservedObject var viewModel:WebViewModel = WebViewModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @State private var isLoading:Bool = false
    var scriptMessageHandler :WKScriptMessageHandler? = nil
    var scriptMessageHandlerName : String = ""
    var uiDelegate:WKUIDelegate? = nil
    
    var body: some View {
        ZStack{
            BtvCustomWebView( viewModel: self.viewModel )
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
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @ObservedObject var viewModel:WebViewModel
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
    
    fileprivate func callJS(_ uiView: WKWebView, jsStr: String) {
        ComponentLog.d("callJS " + jsStr, tag: "callJS")
        uiView.evaluateJavaScript(jsStr, completionHandler: { (result, error) in
            let resultString = result.debugDescription
            let errorString = error.debugDescription
            let msg = jsStr + " -> result: " + resultString + " error: " + errorString
            ComponentLog.d(msg, tag: "callJS")
        })
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
            ComponentLog.d("update " + jsStr, tag: "callJS")
            self.callJS(uiView, jsStr: jsStr)
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
            if (url?.hasPrefix("btvplus://"))! {
                if let urlStr = url {
                    if let components = URLComponents(string: urlStr) {
                        if let path = components.host {
                            let param = components.queryItems
                            ComponentLog.d("path " + path, tag: self.tag)
                            ComponentLog.d("param " + (param?.debugDescription ?? ""), tag: self.tag)
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
                        self.parent.viewModel.event = .callFuncion(fn, jsonParam, cbName )
                    }
                }
                decisionHandler(.cancel, preferences)
                return
            }
            decisionHandler(.allow, preferences)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {}
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {}
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {}
        
       
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
                DispatchQueue.main.async {
                    self.parent.viewModel.screenHeight = height as! CGFloat
                    webView.bounds.size.height = self.parent.viewModel.screenHeight
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
                    //Tool.debugLog("cookie.name:\(cookie.name), cookie.value:\(cookie.value)")
                    if cookie.name.contains("BtvplusWebVer") {
                        //MenuNaviBuilder.setWebPageVersion(cookie.value)
                    }
                }
            }
        }
        
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            ComponentLog.d("error: " + error.localizedDescription , tag: self.tag )
    
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
                    self.parent.pageSceneObserver.alert = .serviceUnavailable(failingUrlStr)
                    return
                }
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            
            self.parent.pageSceneObserver.alert = .alert(nil,  message, completionHandler)
           
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            
            self.parent.pageSceneObserver.alert = .confirm(nil,  message, completionHandler)
        }

        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
                     defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (String?) -> Void) {
            self.parent.pageSceneObserver.alert = .serviceSelect( prompt, defaultText, completionHandler)
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

