//
//  BtvWebViewController.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/29.
//

import Foundation
import SwiftUI
import WebKit
import Combine


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
    var viewHeight:CGFloat? = nil
    @State var backState = NSMutableArray()
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
        let uiView = creatWebView(config: config, viewHeight: self.viewHeight)
        uiView.navigationDelegate = context.coordinator
        uiView.uiDelegate = context.coordinator
        uiView.allowsLinkPreview = false
        uiView.scrollView.bounces = false
        uiView.scrollView.alwaysBounceVertical = false
        uiView.keyboardDisplayRequiresUserAction = false
        uiView.isOpaque = false
        uiView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return uiView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if self.viewModel.status != .update { return }
        switch self.viewModel.request{
        case .evaluateJavaScript : break
        case .evaluateJavaScriptMethod : break
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
    func callJS(_ uiView: WKWebView, jsStr: String) {
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
    
    func callJS(_ uiView: WKWebView, fn: String, dic:[String: Any]? = nil) {
        var jsStr = ""
        if let dic = dic {
            let jsonString = AppUtil.getJsonString(dic: dic) ?? ""
            jsStr = fn + "(\'" + jsonString + "\');"
        } else {
            
            jsStr = fn.last == ";" ? fn : fn + "();"
        }
        self.callJS(uiView, jsStr: jsStr)
    }
    
    func pushBackState(state: String) {
        ComponentLog.d("pushBackState: \(state)", tag: self.tag)
        backState.add(state)
        for idx in 0..<backState.count {
            ComponentLog.d("backState \(idx) : \(backState[idx])", tag: self.tag)
        }
    }
    
    func popBackState(_ uiView: WKWebView) {
        if backState.count > 0 {
            if let state = backState.lastObject as? String {
                callJS(uiView, jsStr: state)
                ComponentLog.d("popBackState: \(state)", tag: self.tag)
                backState.removeLastObject()
            }
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
            if let deepLinkItem = self.parent.repository.webBridge.parseUrl(url) {
                if let path = deepLinkItem.path {
                    self.parent.viewModel.event = .callPage(path, deepLinkItem.querys)
                } else {
                    if deepLinkItem.isPopBackState {
                        self.parent.popBackState(webView)
                    }
                    if let pushBackState = deepLinkItem.pushBackState {
                        self.parent.pushBackState(state: pushBackState)
                    }
                    
                    if deepLinkItem.isForceRetry {
                        self.forceRetry(webView: webView)
                    } else if deepLinkItem.isCallFuncion, let funcName = deepLinkItem.funcName {
                        self.parent.viewModel.event = .callFuncion(funcName, deepLinkItem.jsonParam, deepLinkItem.cbName )
                    }
                    if let dic = deepLinkItem.dic, let cb = deepLinkItem.cbName, !cb.isEmpty {
                        let js = BtvWebView.callJsPrefix + cb
                        DispatchQueue.main.async {
                            self.parent.callJS(webView, fn: js, dic: dic)
                        }
                    }
                    if let value = deepLinkItem.value, let cb = deepLinkItem.cbName, !cb.isEmpty {
                        let js = BtvWebView.callJsPrefix + cb + "(" + value + ");"
                        DispatchQueue.main.async {
                            self.parent.callJS(webView, jsStr: js)
                        }
                    }
                }
                decisionHandler(.cancel, preferences)
                return
            } else {
                decisionHandler(.allow, preferences)
            }
        }
        
        private var forceRetryCount:Int = 0
        private var isForceRetry:Bool = false
        func forceRetry(webView: WKWebView) {
            if isForceRetry {return}
            if forceRetryCount == 3 {return}
            isForceRetry = true
            forceRetryCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isForceRetry = false
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
            //let disabledScroll = "document.querySelectorAll('*[style]').forEach(el => el.style.overflow = 'scroll');"
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
            
            [disabledSelect, disabledOptionBubble, disabledHightlight, disableAutocompleteScript ].forEach { option in
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
