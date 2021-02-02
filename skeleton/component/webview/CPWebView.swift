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



struct CPWebView: PageComponent {
    
    @ObservedObject var viewModel:WebViewModel = WebViewModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @State private var isLoading:Bool = false
    var scriptMessageHandler :WKScriptMessageHandler? = nil
    var scriptMessageHandlerName : String = ""
    var uiDelegate:WKUIDelegate? = nil
    
    var body: some View {
        ZStack{
            CustomWebView( viewModel: self.viewModel )
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

struct CustomWebView : UIViewRepresentable, WebViewProtocol, PageProtocol {
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
        let uiView = creatWebView()
        uiView.navigationDelegate = context.coordinator
        uiView.uiDelegate = context.coordinator
        return uiView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if self.viewModel.status != .update { return }
        if uiView.isLoading {
            self.viewModel.status = .error
            self.viewModel.error = .busy
            return
        }
        if let e = self.viewModel.request { update(uiView , evt:e) }
    }
    
    private func checkLoading(_ uiView: WKWebView){
        var job:AnyCancellable? = nil
        job = Timer.publish(every: 0.1, on:.current, in: .common)
            .autoconnect()
            .sink{_ in
                if self.viewModel.status == .end {
                    job?.cancel()
                    return
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
        uiView.evaluateJavaScript(jsStr, completionHandler: { (result, error) in
            let resultString = result.debugDescription
            let errorString = error.debugDescription
            let msg = "result: " + resultString + " error: " + errorString
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
        var parent: CustomWebView
        init(_ parent: CustomWebView) {
            self.parent = parent
        }
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     preferences: WKWebpagePreferences,
                     decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {}
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {}
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {}
        
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
        }
        
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            ComponentLog.d("error: " + error.localizedDescription , tag: self.tag )
    
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
struct CPWebView_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CPWebView(viewModel:WebViewModel(base: "https://www.todaypp.com")).contentBody
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

