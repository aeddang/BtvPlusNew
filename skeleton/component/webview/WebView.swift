//
//  WebView.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/29.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

enum WebViewRequest {
    case home, foward, back, link(String), writeHtml(String), evaluateJavaScript(String), evaluateJavaScriptMethod(String, [String:Any]?)
}
enum WebViewError{
    case update(WebViewRequest), busy
}

enum WebViewEvent {
    case callPage(String, [URLQueryItem]?), callFuncion(String,String?,String?)
}

open class WebViewModel: ComponentObservable {
    @Published var path:String = ""
    @Published var request:WebViewRequest? = nil{ willSet{ self.status = .update } }
    @Published var event:WebViewEvent? = nil{didSet{ if event != nil { event = nil} }}
    @Published var error:WebViewError? = nil
    @Published var screenHeight:CGFloat = 0
    var base = ""
    convenience init(base:String, path: String? = nil) {
        self.init()
        self.base = base
        if let p = path { self.path = p }
        else { self.path = base }
    }
}

protocol WebViewProtocol{
    var path: String { get set }
    var request: URLRequest? { get }
    var scriptMessageHandler :WKScriptMessageHandler? { get set }
    var scriptMessageHandlerName : String { get set }
    var uiDelegate:WKUIDelegate? { get set }
}

class Console: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler" {
            print("LOG: \(message.body)")
        }
    }
}

extension WebViewProtocol{
    var request: URLRequest? {
        get{
            guard let url:URL = path.toUrl() else { return nil }
            return URLRequest(url: url)
        }
    }
    var scriptMessageHandler :WKScriptMessageHandler? { get{ nil } set{} }
    var scriptMessageHandlerName : String { get{""} set{} }
    var uiDelegate:WKUIDelegate? { get{nil} set{} }
    
    func creatWebView(config:WKWebViewConfiguration? = nil) -> WKWebView  {
        let webView:WKWebView
        if let configuration = config {
            webView = WKWebView(frame: .zero, configuration: configuration)
        }
        else if let scriptMessage = scriptMessageHandler {
            let configuration = WKWebViewConfiguration()
            let contentController = WKUserContentController()
            contentController.add(scriptMessage, name: scriptMessageHandlerName)
            configuration.userContentController = contentController
            webView = WKWebView(frame: .zero, configuration: configuration)
        }
        else{
            webView = WKWebView()
        }
        
        webView.uiDelegate = uiDelegate
        webView.frame.size.height = 1
        webView.frame.size = webView.sizeThatFits(.zero)
        let source = "function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;"
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(Console() , name: "logHandler")
        return webView
    }

    func load(_ uiView: WKWebView) {
        guard let rq = request else { return }
        ComponentLog.d("load " + rq.description)
        uiView.load(rq)
    }
    
    func stop(_ uiView: WKWebView) {
        uiView.stopLoading()
    }
    
    static func dismantleUIView(_ uiView: WKWebView) {
        uiView.stopLoading()
    }
}

struct WebView : UIViewRepresentable, WebViewProtocol {
    @Binding var path: String
    var viewModel: WebViewModel? = nil
    var scriptMessageHandler :WKScriptMessageHandler? = nil
    var scriptMessageHandlerName : String = ""
    var uiDelegate:WKUIDelegate? = nil
    func makeUIView(context: Context) -> WKWebView  {
        return creatWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        load( uiView )
    }
    static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) {
        dismantleUIView( uiView )
    }
}



class CustomWKUIDelegate: NSObject, WKUIDelegate {

    func webViewDidClose(_ webView: WKWebView) {}
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void){}
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void){}

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void){}

    func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void){}

    func webView(_ webView: WKWebView, contextMenuWillPresentForElement elementInfo: WKContextMenuElementInfo){}

    func webView(_ webView: WKWebView, contextMenuForElement elementInfo: WKContextMenuElementInfo, willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating){}
    func webView(_ webView: WKWebView, contextMenuDidEndForElement elementInfo: WKContextMenuElementInfo){}
}

class WKScriptController: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message:WKScriptMessage) {
        /*
        // message.name = "scriptHandler" -> 위에 WKUserContentController()에 설정한 name
        // message.body = "searchBar" -> 스크립트 부분에 webkit.messageHandlers.scriptHandler.postMessage(<<이부분>>)
        
        if let body = message.body as? String, body == "searchBar" {
            guard let url = URL(string: Key.searchUrl) else { return }
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
            
        }
        if message.body is Array<Any> { print(message.body) }
        */
    }
}

/*
#if DEBUG
struct WebView_Previews : PreviewProvider {
    static var previews: some View {
        WebView(path: .constant("https://www.apple.com"))
    }
}
#endif
*/
