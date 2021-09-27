//
//  SceneDelegate.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/18.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//
import UIKit
import SwiftUI
import Combine


final class PagePresenter:ObservableObject{
    func changePage(_ pageObject:PageObject , isCloseAllPopup:Bool = true){
        if isBusy { return }
        PageSceneDelegate.instance?.changePage( pageObject, isCloseAllPopup:isCloseAllPopup )
    }
    func changePage(_ pageID:PageID, idx:Int = 0, params:[String:Any]? = nil, isCloseAllPopup:Bool = true){
        if isBusy { return }
        let page = PageObject(pageID: pageID, pageIDX: idx, params: params, isPopup: false)
        PageSceneDelegate.instance?.changePage( page , isCloseAllPopup:isCloseAllPopup)
    }
    func changePage(_ pageID:PageID, params:[String:Any]? = nil, idx:Int = 0, isCloseAllPopup:Bool = true){
        if isBusy { return }
        let page = PageObject(pageID: pageID, pageIDX: idx, params: params, isPopup: false)
        PageSceneDelegate.instance?.changePage( page , isCloseAllPopup:isCloseAllPopup)
    }
    func openPopup(_ pageObject:PageObject ){
        pageObject.isPopup = true
        PageSceneDelegate.instance?.openPopup( pageObject )
    }
    func openPopup(_ pageID:PageID, params:[String:Any]? = nil, idx:Int = 0){
        let popup = PageObject(pageID: pageID, pageIDX: idx, params: params, isPopup: true)
        PageSceneDelegate.instance?.openPopup( popup )
    }
    func closePopup(pageId:PageID?){
        guard let pageKey = pageId else { return }
        PageSceneDelegate.instance?.closePopup(pageID:pageKey )
    }
    func setLayerPopup(pageObject: PageObject, isLayer:Bool){
        pageObject.isLayer = isLayer
        self.currentTopPage = isLayer ? getBelowPage(page:pageObject) : pageObject
        if let top = self.currentTopPage {
            self.currentPopup = top.isPopup ? top : nil
        }
    }
    func closePopup(_ id:String?){
        guard let pageKey = id else { return }
        PageSceneDelegate.instance?.closePopup(id:pageKey )
    }
    func closeAllPopup(exception pageKey:String? = nil){
        PageSceneDelegate.instance?.closeAllPopup(exception: pageKey ?? "")
    }
    func goBack(){
        PageSceneDelegate.instance?.goBack()
    }
    func onPageEvent(_ pageObject: PageObject?, event:PageEvent){
        PageSceneDelegate.instance?.contentController?.onPageEvent(pageObject, event: event)
        self.event = event
        self.event = nil
    }
    
    func getBelowPage(page:PageObject)->PageObject?{
        if page.isPopup {
            if page.isLayer {
                guard let find = PageSceneDelegate.instance?.popups.filter({!$0.isLayer}).last else { return currentPage }
                return find
            } else {
                guard let find = PageSceneDelegate.instance?.popups.filter({!$0.isLayer}).firstIndex(of: page)  else { return currentPage }
                if find > 0{
                    return PageSceneDelegate.instance?.popups[find - 1]
                }
                return currentPage
            }
        } else {
            return nil
        }
    }
    
    func hasLayerPopup()->Bool{
        let result = PageSceneDelegate.instance?.popups.first{ $0.isLayer }
        return result != nil
    }
    
    func hasPopup(find:PageID)->Bool{
        let result = PageSceneDelegate.instance?.popups.first{ $0.pageID == find}
        return result != nil
    }
    func hasPopup(exception:PageID)->Bool{
        let result = PageSceneDelegate.instance?.popups.first{ $0.pageID != exception}
        return result != nil
    }
    
    
    func hasHistory()->Bool{
        let result = PageSceneDelegate.instance?.historys.first
        return result != nil
    }
    
    func syncOrientation(){
        PageSceneDelegate.instance?.syncOrientation(self.currentTopPage)
    }
    
    func setIndicatorAutoHidden(_ isHidden:Bool){
        PageSceneDelegate.instance?.setIndicatorAutoHidden(isHidden)
    }
    
    func orientationLock(lockOrientation:UIInterfaceOrientationMask){
        AppDelegate.orientationLock = lockOrientation
    }
    
    func orientationLock(isLock:Bool = false){
        PageSceneDelegate.instance?.requestDeviceOrientationLock(isLock)
        PageLog.d("orientationLock " + isLock.description , tag: "PagePresenter")
    }
    
    func fullScreenEnter(isLock:Bool = false, changeOrientation:UIInterfaceOrientationMask? = .landscape){
        if self.isFullScreen {return}
        self.isFullScreen = true
        PageSceneDelegate.instance?.onFullScreenEnter(isLock: isLock, changeOrientation:changeOrientation)
        PageLog.d("fullScreenEnter " + isLock.description, tag: "PagePresenter")
    }
    func fullScreenExit(isLock:Bool = false, changeOrientation:UIInterfaceOrientationMask? = nil){
        if !self.isFullScreen {return}
        self.isFullScreen = false
        PageSceneDelegate.instance?.onFullScreenExit(isLock : isLock, changeOrientation: changeOrientation)
        PageLog.d("fullScreenExit " + isLock.description, tag: "PagePresenter")
    }
    
    func requestDeviceOrientation(_ mask:UIInterfaceOrientationMask){
        PageSceneDelegate.instance?.requestDeviceOrientation(mask)
    }
    
    @Published fileprivate(set) var event:PageEvent? = nil
    @Published fileprivate(set) var currentPage:PageObject? = nil
    @Published fileprivate(set) var currentPopup:PageObject? = nil
    @Published fileprivate(set) var currentTopPage:PageObject? = nil
   
    @Published var isLoading:Bool = false
    @Published var bodyColor:Color = Color.brand.bg
    @Published var dragOpercity:Double = 0.0
    @Published fileprivate(set) var isBusy:Bool = false
    @Published fileprivate(set) var isFullScreen:Bool = false
    @Published fileprivate(set) var hasPopup:Bool = false
}

struct SceneModel: PageModel {
    var currentPageObject: PageObject? = nil
    var topPageObject: PageObject? = nil
}

class PageSceneDelegate: UIResponder, UIWindowSceneDelegate, PageProtocol {
    static let CHANGE_DURATION = Duration.ani.long
    
    static fileprivate var instance:PageSceneDelegate?
    var window: UIWindow? = nil
   
    fileprivate let changeDelay = 0.1
    fileprivate let changeAniDelay =  CHANGE_DURATION
    private(set) var contentController:PageContentController? = nil
    fileprivate var historys:[PageObject] = []
    fileprivate var popups:[PageObject] = []
    let pagePresenter = PagePresenter()
    let sceneObserver = PageSceneObserver()
    private(set) lazy var pageModel:PageModel = getPageModel()
    
    private var changeSubscription:AnyCancellable?
    private var popupSubscriptions:[String:AnyCancellable] = [String:AnyCancellable]()
    private var isRock:Bool = false
    deinit {
        changeSubscription?.cancel()
        changeSubscription = nil
        preventDuplicateSubscription?.cancel()
        preventDuplicateSubscription = nil
        popupSubscriptions.forEach{ $0.value.cancel() }
        popupSubscriptions.removeAll()
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        PageSceneDelegate.instance = self
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            setupRootViewController(window)
            window.makeKeyAndVisible()
        }
        onInitPage()
    }
    func getPageModel() -> PageModel { return SceneModel()}
    
    private func setupRootViewController(_ window: UIWindow){
        contentController = PageContentController()
        onInitController(controller: contentController!)
        let view = contentController?
            .environmentObject(pagePresenter)
            .environmentObject(sceneObserver)
        
        let rootViewController = PageHostingController(rootView: adjustEnvironmentObjects(view))
        rootViewController.sceneObserver = sceneObserver
        rootViewController.view.backgroundColor = Color.brand.bg.uiColor()
        window.rootViewController = rootViewController
        window.backgroundColor = Color.brand.bg.uiColor()
        window.overrideUserInterfaceStyle = .light
       
    }
    
    private func updateUserInterfaceStyle(style:UIStatusBarStyle){
        guard let window = self.window , let rootViewController = window.rootViewController as? PageHostingController<AnyView> else {return}
        rootViewController.statusBarStyle = style
        switch style {
        case .default:
            window.overrideUserInterfaceStyle = .unspecified
        case .lightContent:
            window.overrideUserInterfaceStyle = .light
        case .darkContent:
            window.overrideUserInterfaceStyle = .dark
        default: break
        }
    }
    
    private let preventDelay =  0.5
    private var preventDuplicate = false
    private var preventDuplicateSubscription:AnyCancellable?
    final func preventDuplicateStart(){
        self.preventDuplicateSubscription?.cancel()
        self.preventDuplicate = true
        preventDuplicateSubscription = Timer.publish(
            every: self.preventDelay, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.pagePresenter.isBusy = false
                self.preventDuplicateSubscription?.cancel()
                self.preventDuplicateSubscription = nil
                self.preventDuplicate = false
        }
    }

    final func changePage(_ newPage:PageObject, isBack:Bool = false, isCloseAllPopup:Bool = true){
        if isRock {
            PageLog.d("changePage rock " + newPage.pageID + " " + isBack.description, tag: self.tag)
            return
        }
        PageLog.d("changePage " + newPage.pageID + " " + isBack.description, tag: self.tag)
        if pageModel.currentPageObject?.pageID == newPage.pageID {
            if( pageModel.currentPageObject?.params?.keys == newPage.params?.keys){
                pageModel.currentPageObject?.params = newPage.params
                self.contentController?.reloadPage()
                return
            }
        }
        if !pageModel.isChangePageAble( newPage ) { return }
        if !willChangeAblePage( newPage) { return }
        if pageModel.isHomePage( newPage ){ historys.removeAll() }
        let prevContent = contentController?.currnetPage
        let prevPage = pageModel.currentPageObject
        if prevPage == newPage  {
            prevContent?.pageReload()
            return
        }
        if isCloseAllPopup {
            closeAllPopup(exception: "", exceptions: self.pageModel.getCloseExceptions())
        }
        pagePresenter.isBusy = true
        var pageOffset:CGFloat = 0
        if let historyPage = prevPage {
            if isBack {
                pageOffset = -UIScreen.main.bounds.width
            }else{
                pageOffset = (historyPage.pageIDX > newPage.pageIDX) ? -UIScreen.main.bounds.width : UIScreen.main.bounds.width
                if pageModel.isHistoryPage( historyPage ){
                    historys.append(historyPage)
                    
                }
            }
            prevPage?.isAnimation = newPage.isAnimation 
            prevContent?.removeAnimationStart()
            prevContent?.pageObservable.pagePosition.x = -pageOffset
            
        }
        let nextContent = getPageContentBody(newPage)
        nextContent.setPageObject(newPage)
        nextContent.pageObservable.pagePosition.x = pageOffset
        if self.popups.filter({!$0.isLayer}).isEmpty {
            onWillChangePage(prevPage: prevPage, nextPage: newPage)
        }
        contentController?.addPage(nextContent)
        if pageModel.isChangedCategory(prevPage: prevPage, nextPage: newPage) { nextContent.categoryChanged(prevPage) }
        
        let delay = newPage.isAnimation ? self.changeAniDelay : self.changeDelay
        self.isRock = true
        changeSubscription = Timer.publish(
            every: delay, on: .main, in: .common)
            .autoconnect()
            .sink() {_ in
                if prevContent != nil { self.contentController?.removePage()}
                self.pagePresenter.isBusy = false
                self.changeSubscription?.cancel()
                self.changeSubscription = nil
                PageLog.d("initAnimationComplete", tag: self.tag)
                nextContent.initAnimationComplete()
                self.isRock = false
               
        }
        pageModel.currentPageObject = newPage
    }
    
    final func openPopup(_ popup:PageObject){
        PageLog.d("openPopup " + popup.pageID, tag: self.tag)
        if !popups.isEmpty {
            if let prev = popups.last {
                if prev.pageID == popup.pageID && self.preventDuplicate { return }
            }
        }
        preventDuplicateStart()
        if !willChangeAblePage( popup ) { return }
        popups.append(popup)
        pagePresenter.hasPopup = true
        let popupContent = getPageContentBody(popup)
        popupContent.setPageObject(popup)
        onWillChangePage(prevPage: nil, nextPage: popup)
       
        
        var delay = self.changeDelay
        if let pageObject = popupContent.pageObject {
            delay = pageObject.animationType == .none ? self.changeDelay : self.changeAniDelay
            //let opacity = pageObject.animationType == .none ? 1.0 : 0.0
            switch  pageObject.animationType {
            case .vertical:
                popupContent.pageObservable.pagePosition.y = UIScreen.main.bounds.height
            case .horizontal:
                popupContent.pageObservable.pagePosition.x = UIScreen.main.bounds.width
            default: break
            }
            //popupContent.pageObservable.pageOpacity = opacity
        }
        contentController?.addPopup(popupContent)
        let key = popup.id
        let subscription = Timer.publish(
            every: delay,
            on: .main,
            in: .common)
            .autoconnect()
            .sink() {_ in
                
                self.popupSubscriptions[key]?.cancel()
                self.popupSubscriptions.removeValue(forKey: key)
                popupContent.initAnimationComplete()
            }
        popupSubscriptions.updateValue(subscription, forKey: key)
    }
    final func closePopup(pageID:PageID){
        PageLog.d("closePopup " + pageID, tag: self.tag)
        guard let findIdx = popups.firstIndex(where: { $0.pageID == pageID}) else { return }
        self.closePopup(id:popups[findIdx].id)
    }
    final func closePopup(id:String){
        PageLog.d("closePopup " + id, tag: self.tag)
        guard let findIdx = popups.firstIndex(where: { $0.id == id}) else { return }
        popups.remove(at: findIdx)
        pagePresenter.hasPopup = !popups.isEmpty
        guard let popupContent = contentController?.getPopup(id) else { return }
        popupContent.removeAnimationStart()
        PageLog.d("closePopup Start" + id, tag: self.tag)
        var delay = self.changeDelay
        if let pageObject = popupContent.pageObject {
            delay = pageObject.animationType == .none ? self.changeDelay : self.changeAniDelay
            let opacity = pageObject.animationType == .opacity ? 0.0 : 1.0
            switch  pageObject.animationType {
            case .vertical:
                popupContent.pageObservable.pagePosition.y = UIScreen.main.bounds.height
            case .horizontal:
                popupContent.pageObservable.pagePosition.x = UIScreen.main.bounds.width
            default: break
            }
            popupContent.pageObservable.pageOpacity = opacity
        }
        let next = popups.isEmpty
            ? contentController?.currnetPage?.pageObject
            : popups.last
        onWillChangePage(prevPage: nil, nextPage: next)
        
        let subscription = Timer.publish(
            every: delay,
            on: .main,
            in: .common)
            .autoconnect()
            .sink() {_ in
                PageLog.d("closePopup completed" + id, tag: self.tag)
                self.popupSubscriptions[id]?.cancel()
                self.popupSubscriptions.removeValue(forKey: id)
                self.contentController?.removePopup(id)
            }
        popupSubscriptions.updateValue(subscription, forKey: id)
    }
    
    final func closeAllPopup(exception pageKey:String = "", exceptions:[PageID]? = nil){
        PageLog.d("closeAllPopup", tag: self.tag)
        if popups.isEmpty { return }
        
        let key = UUID().description
        var removePops:[String] = []
        popups.removeAll( where: { pop in
            var remove = true
            if pop.id == pageKey { remove = false }
            if let exps = exceptions {
                if let _ = exps.first(where: { pop.pageID == $0 }) { remove = false }
            }
            if remove {
                removePops.append(pop.id)
            }
            return remove
        })
        
        pagePresenter.hasPopup = !popups.isEmpty
        var delay = self.changeDelay
        contentController?.pageControllerObservable.popups.forEach{  pop in
            let key = pop.pageObject?.id
            var remove = true
            if key == pageKey { remove = false }
            if let exps = exceptions {
                if let _ = exps.first(where: { pop.pageID == $0 }) { remove = false }
            }
            if remove {
                PageLog.d("closeAllPopup remove " + pop.pageID, tag:self.tag)
                pop.removeAnimationStart()
                if let pageObject =  pop.pageObject {
                    delay = pageObject.animationType != .none ? self.changeAniDelay : delay
                   
                    let opacity = pageObject.animationType == .none ? 1.0 : 0.0
                    
                    switch  pageObject.animationType {
                    case .vertical:
                        pop.pageObservable.pagePosition.y = UIScreen.main.bounds.height
                    case .horizontal:
                        pop.pageObservable.pagePosition.x = UIScreen.main.bounds.width
                    default: break
                    }
        
                    pop.pageObservable.pageOpacity = opacity
                }
                //pop.pageObservable.pagePosition.y = UIScreen.main.bounds.height
                pop.pageObservable.pageOpacity = 0.0
            }
        }
        onWillChangePage(prevPage: nil, nextPage: contentController?.currnetPage?.pageObservable.pageObject)
        
        let subscription = Timer.publish(
            every: delay,
            on: .main,
            in: .common)
            .autoconnect()
                .sink() {_ in
                    self.popupSubscriptions[key]?.cancel()
                    self.popupSubscriptions.removeValue(forKey: key)
                    self.contentController?.removeAllPopup(removePops:removePops)
                   
            }
        popupSubscriptions.updateValue(subscription, forKey: key)
    }
    
    final func goBack(){
        var popups:[PageObject] = []
        if let exps = pageModel.getCloseExceptions() {
            popups = self.popups.filter{ top in
                exps.first(where: { $0 == top.pageID }) == nil
            }
        }else{
            popups = self.popups
        }
        let isHistoryBack = popups.isEmpty
    
        guard let back = isHistoryBack ? pageModel.currentPageObject : popups[popups.count-1] else { return }
        if isHistoryBack {
            guard let next = historys.last else { return }
            if !isGoBackAble(prevPage: back, nextPage: next) { return }
            historys.removeLast()
            changePage(next, isBack: true)
        }else{
            guard let next = popups.count > 1
                ? popups[popups.count-2]
                : pageModel.currentPageObject
                else { return }
            if !isGoBackAble(prevPage: back, nextPage: next) { return }
            closePopup(id:back.id)
        }
    }
    
    func onInitPage(){}
    func onInitController(controller:PageContentController){}
    func getPageContentProtocol(_ page:PageObject) -> PageViewProtocol{ return PageContent() }
    func adjustEnvironmentObjects<T>(_ view:T) -> AnyView where T : View { return AnyView(view) }
    func isGoBackAble(prevPage:PageObject?, nextPage:PageObject?) -> Bool { return true }
    
    func getPageContentBody(_ page:PageObject) -> PageViewProtocol{
        return PageContentBody(childViews:[getPageContentProtocol(page)])
    }
    func willChangeAblePage(_ page:PageObject?)->Bool{ return true }
    
    func onWillChangePage(prevPage:PageObject?, nextPage:PageObject?){
        guard let nextPage = nextPage else {return}
        guard let willChangePage = ( !nextPage.isLayer
                ? nextPage
                : pagePresenter.getBelowPage(page: nextPage) )
              else { return }
        
        PageLog.d("willChangePage " + willChangePage.pageID, tag:self.tag)
        
        if willChangePage.isPopup {
            pagePresenter.currentPopup = willChangePage
        }else{
            pagePresenter.currentPage = willChangePage
            pagePresenter.currentPopup = nil
        }
        pagePresenter.currentTopPage = willChangePage
        pageModel.topPageObject = willChangePage
       
        self.syncOrientation(willChangePage)
    }
    
    func syncOrientation(_ syncPage:PageObject? = nil) {
        let willChangeOrientationMask = pageModel.getPageOrientation(syncPage)
        AppDelegate.orientationLock = pageModel.getPageOrientationLock(syncPage) ?? .all
        guard let willChangeOrientation = willChangeOrientationMask else { return }
        if  willChangeOrientation == .all { return }
        self.requestDeviceOrientation(willChangeOrientation)
    }
    
    func setIndicatorAutoHidden(_ isHidden:Bool){
        if let controller = self.window?.rootViewController as? PageHostingController<AnyView> {
            controller.isIndicatorAutoHidden = isHidden
            DispatchQueue.main.async {
                controller.setNeedsUpdateOfHomeIndicatorAutoHidden()
            }
        }
    }
    
    func onFullScreenEnter(isLock:Bool = false, changeOrientation:UIInterfaceOrientationMask? = .landscape){
        self.setIndicatorAutoHidden(true)
        guard let changeOrientation = changeOrientation else { return }
        if isLock {
            AppDelegate.orientationLock = changeOrientation
            
        }
        if self.needOrientationChange(changeOrientation: changeOrientation) {
            self.requestDeviceOrientation(changeOrientation)
        }
    }
    func onFullScreenExit(isLock:Bool = false, changeOrientation:UIInterfaceOrientationMask? = nil){
        self.setIndicatorAutoHidden(false)
        if isLock , let orientation = changeOrientation{
            AppDelegate.orientationLock = orientation
        } else {
            AppDelegate.orientationLock = pageModel.getPageOrientationLock(nil) ?? .all
        }
        
        if let mask = changeOrientation, self.needOrientationChange(changeOrientation: changeOrientation) {
            self.requestDeviceOrientation(mask)
        }
    }
    
    func needOrientationChange(changeOrientation:UIInterfaceOrientationMask? = nil) -> Bool {
        guard let willChangeOrientation = changeOrientation else { return false }
        let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.unknown
        if willChangeOrientation == .portrait {
            if interfaceOrientation == .portrait || interfaceOrientation == .portraitUpsideDown { return false }
        } else {
            if interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight { return false }
        }
        return true
    }
    
    func requestDeviceOrientationLock(_ lock:Bool){
        let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.unknown
        
        let orientationLock = lock
            ? getDeviceOrientationMask(orientation: interfaceOrientation)
            : pageModel.getPageOrientationLock(nil) ?? .all
       
        DataLog.d("orientationLock " + orientationLock.rawValue.description, tag:"PageSceneModel")
        AppDelegate.orientationLock = orientationLock
    }
    
    final func requestDeviceOrientation(_ mask:UIInterfaceOrientationMask, isForce:Bool = false){
        let changeOrientation:UIInterfaceOrientation? = getChangeDeviceOrientation(mask: mask)
        /*
        if let controller = self.window?.rootViewController as? PageHostingController<AnyView> {
            switch changeOrientation {
                case .landscapeLeft, .landscapeRight:
                    controller.isIndicatorAutoHidden = true
                case .portrait, .portraitUpsideDown:
                    controller.isIndicatorAutoHidden = false
                default:break
            }
        }*/
        if isForce {
            PageLog.d("requestDeviceOrientation mask force" , tag: "PageScene")
            UINavigationController.attemptRotationToDeviceOrientation()
            return
        }
        
        guard let change = changeOrientation else { return }
        DispatchQueue.main.async {
            UIDevice.current.setValue(change.rawValue, forKey: "orientation")
            PageLog.d("requestDeviceOrientation mask" , tag: "PageScene")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
       
    }

    final func getChangeDeviceOrientation(mask:UIInterfaceOrientationMask) -> UIInterfaceOrientation? {
        
        let sceneOrientation = sceneObserver.sceneOrientation
        var current:UIDeviceOrientation? = UIDevice.current.orientation
        if sceneOrientation == .portrait {
            switch current {
            case .landscapeLeft, .landscapeRight: current = nil
            default:break
            }
        } else {
            switch current {
            case .portrait, .portraitUpsideDown: current = nil
            default:break
            }
        }
        
        if current == .portrait {
            switch mask {
                case .landscape, .landscapeRight: return .landscapeRight
                case .landscapeLeft: return .landscapeLeft
                //ase .portraitUpsideDown:return .portraitUpsideDown
                default:return nil
            }
        }
        else if current == .portraitUpsideDown {
            switch mask {
                case .landscape, .landscapeRight: return .landscapeRight
                case .landscapeLeft: return .landscapeLeft
            case .portrait:return AppUtil.isPad() ? nil : .portrait
                default:return nil
            }
        }
        else if current == .landscapeRight{
            switch mask {
                //case .landscapeLeft: return .landscapeLeft
                case .portrait:return .portrait
                case .portraitUpsideDown:return .portraitUpsideDown
                default:return nil
            }
        }
        else if current == .landscapeLeft{
            switch mask {
                //case .landscapeRight: return .landscapeRight
                case .portrait:return .portrait
                case .portraitUpsideDown:return .portraitUpsideDown
                default:return nil
            }
        }
        else {
            
            switch mask {
            case .landscape: return sceneOrientation == .landscape ? nil : .landscapeLeft
            case .portrait: return sceneOrientation == .portrait ? nil : .portrait
            default:return nil
            }
            
        }
    }
    final func getDeviceOrientationMask(orientation:UIInterfaceOrientation) -> UIInterfaceOrientationMask {
        switch orientation {
        case .portrait: return .portrait
        case .portraitUpsideDown:return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        default: return .portrait
        }
    }
    func sceneDidDisconnect(_ scene: UIScene) {
        contentController?.sceneDidDisconnect(scene)
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
        contentController?.sceneDidBecomeActive(scene)
    }
    func sceneWillResignActive(_ scene: UIScene) {
        contentController?.sceneWillResignActive(scene)
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
        contentController?.sceneWillEnterForeground(scene)
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        contentController?.sceneDidEnterBackground(scene)
    }
}

