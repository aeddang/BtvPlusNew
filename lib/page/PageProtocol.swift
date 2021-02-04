//
//  PageProtocol.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/20.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//
import SwiftUI


typealias PageID = String
typealias PageParam = String

enum PageAnimationType {
    case none, vertical, horizental, opacity
}

class PageObject : Equatable, Identifiable{
    let pageID: PageID
    var pageIDX:Int
    var params:[PageParam:Any]?
    var isPopup:Bool
    var zIndex:Int = 0
    var isDimed:Bool
    var isHome:Bool = false
    var isAnimation:Bool = false
    var animationType:PageAnimationType = .horizental
    let id:String
    init(
        pageID:PageID,
        pageIDX:Int = 0,
        params:[PageParam:Any]? = nil,
        isPopup:Bool = false,
        isDimed:Bool = false,
        
        pageKey:String = UUID().uuidString
    ){
        self.pageID = pageID
        self.pageIDX = pageIDX
        self.params = params
        self.isPopup = isPopup
        self.isDimed = isDimed
        self.id = pageKey
    }
    
    func addParam(key:PageParam, value:Any?)->PageObject{
        guard let value = value else { return self }
        if params == nil {
            params = [PageParam:Any]()
        }
        params![key] = value
        return self
    }
    
    func getParamValue(key:PageParam)->Any?{
        if params == nil { return nil }
        return params![key]
    }
    
    
    public static func == (l:PageObject, r:PageObject)-> Bool {
        return l.id == r.id
    }
}

enum SceneStatus:String {
    case initate,
    appear,
    disAppear,
    transactionComplete,
    becomeActive,
    disconnect ,
    resignActive  ,
    enterForeground ,
    enterBackground
}

enum SceneOrientation :String{
    case portrait, landscape
}

open class PageObservable: ObservableObject  {
    @Published var status:SceneStatus = SceneStatus.initate
    @Published var pageObject:PageObject?
    @Published var pagePosition:CGPoint = CGPoint()
    @Published var pageOpacity:Double = 1.0
    @Published var isBackground:Bool = false
    @Published var isAnimationComplete:Bool = false
}

open class SceneObserver: ObservableObject{
    
    @Published private(set) var safeAreaStart:CGFloat = 0
    @Published private(set) var safeAreaEnd:CGFloat = 0
    @Published private(set) var safeAreaBottom:CGFloat = 0
    @Published private(set) var safeAreaTop:CGFloat = 0
    @Published var willScreenSize:CGSize? = nil
    @Published private(set) var screenSize:CGSize = CGSize()
    @Published var isUpdated:Bool = false
        {didSet{ if isUpdated { isUpdated = false} }}
    func update(geometry:GeometryProxy) {
        self.safeAreaBottom = geometry.safeAreaInsets.bottom
        self.safeAreaTop = geometry.safeAreaInsets.top
        self.safeAreaStart = geometry.safeAreaInsets.leading
        self.safeAreaEnd = geometry.safeAreaInsets.trailing
        self.screenSize = geometry.size
        //ComponentLog.d("safeAreaBottom " + safeAreaBottom.description, tag: "SceneObserver")
        self.isUpdated = true
    }
    var willSceneOrientation: SceneOrientation? {
        get{
            guard let screen = willScreenSize else {return nil}
            return screen.width > screen.height
                        ? .landscape
                        : .portrait
            //return UIDevice.current.orientation.isLandscape ? .landscape : .portrait
        }
    }
    var sceneOrientation: SceneOrientation {
        get{
            return self.screenSize.width > self.screenSize.height
                        ? .landscape
                        : .portrait
            //return UIDevice.current.orientation.isLandscape ? .landscape : .portrait
        }
    }
    
}

protocol PageProtocol {}
extension PageProtocol {
    var tag:String {
        get{ "\(String(describing: Self.self))" }
    }
}
protocol PageContentProtocol:PageProtocol {
    
    var childViews:[PageViewProtocol] { get }
    var pageObservable:PageObservable { get }
    func onSetPageObject(_ page:PageObject)
    func onPageReload()
    func onPageEvent(_ pageObject:PageObject?, event:PageEvent)
    func onPageChanged(_ pageObject:PageObject?)
    func onPageAdded(_ pageObject:PageObject?)
    func onPageRemoved(_ pageObject:PageObject?)
    func onCategoryChanged(_ prevPageObject:PageObject?)
    
    func onInitAnimationComplete()
    func onAppear()
    func onDisAppear()
    func onRemoveAnimationStart()
    func onSceneDidBecomeActive()
    func onSceneDidDisconnect()
    func onSceneWillResignActive()
    func onSceneWillEnterForeground()
    func onSceneDidEnterBackground()
    
    func initAnimationComplete()
    func removeAnimationStart()
    func sceneDidBecomeActive(_ scene: UIScene)
    func sceneDidDisconnect(_ scene: UIScene)
    func sceneWillResignActive(_ scene: UIScene)
    func sceneWillEnterForeground(_ scene: UIScene)
    func sceneDidEnterBackground(_ scene: UIScene)
    
    
  
}
extension PageContentProtocol {
    //override func
    var pageObservable:PageObservable { get { PageObservable() } }
    func onSetPageObject(_ page:PageObject){}
    func onPageReload(){}
    func onPageChanged(_ pageObject:PageObject?){}
    func onPageEvent(_ pageObject:PageObject?, event:PageEvent){}
    func onPageAdded(_ pageObject:PageObject?){}
    func onPageRemoved(_ pageObject:PageObject?){}
    func onCategoryChanged(_ prevPageObject:PageObject?){}
    
    func onInitAnimationComplete(){}
    func onRemoveAnimationStart(){}
    func onSceneDidBecomeActive(){}
    func onSceneDidDisconnect(){}
    func onSceneWillResignActive(){}
    func onSceneWillEnterForeground(){}
    func onSceneDidEnterBackground(){}
    func onAppear(){}
    func onDisAppear(){}
    
    //super func
    @discardableResult
    func setPageObject(_ page:PageObject)->PageViewProtocol?{
        pageObservable.pageObject = page
        childViews.forEach{ $0.setPageObject(page)}
        onSetPageObject(page)
        return self as? PageViewProtocol
    }
    func pageReload(){
        childViews.forEach{ $0.pageReload() }
        onPageReload()
    }
    
    func pageEvent(_ pageObject:PageObject?, event:PageEvent){
        childViews.forEach{ $0.pageEvent(pageObject, event:event) }
        onPageEvent(pageObject, event:event)
    }
    func pageChanged(_ pageObject:PageObject?){
        childViews.forEach{ $0.pageChanged(pageObject) }
        onPageChanged(pageObject)
    }
    func pageAdded(_ pageObject:PageObject?){
        childViews.forEach{ $0.pageAdded(pageObject) }
        onPageAdded(pageObject)
    }
    func pageRemoved(_ pageObject:PageObject?){
        childViews.forEach{ $0.pageRemoved(pageObject) }
        onPageRemoved(pageObject)
    }
    
    func categoryChanged(_ prevPageObject:PageObject?){
        childViews.forEach{ $0.categoryChanged(prevPageObject) }
        onCategoryChanged( prevPageObject )
    }
    func appear(){
        childViews.forEach{ $0.appear() }
        pageObservable.status = .appear
        onAppear()
    }
    func disAppear(){
        childViews.forEach{ $0.disAppear() }
        pageObservable.status = .disAppear
        onDisAppear()
    }
    func initAnimationComplete(){
        childViews.forEach{
            $0.initAnimationComplete() }
        pageObservable.isAnimationComplete = true
        pageObservable.status = .transactionComplete
        
        onInitAnimationComplete()
    }
    func removeAnimationStart(){
        childViews.forEach{ $0.removeAnimationStart() }
        pageObservable.isAnimationComplete = false
        onRemoveAnimationStart()
    }
    func sceneDidBecomeActive(_ scene: UIScene){
        childViews.forEach{ $0.sceneDidBecomeActive( scene ) }
        pageObservable.status = .becomeActive
        pageObservable.isBackground = false
        onSceneDidBecomeActive()
    }
    func sceneDidDisconnect(_ scene: UIScene){
        childViews.forEach{ $0.sceneDidDisconnect( scene ) }
        pageObservable.status = .disconnect
        onSceneDidDisconnect()
    }
    func sceneWillResignActive(_ scene: UIScene){
        childViews.forEach{ $0.sceneWillResignActive( scene ) }
        pageObservable.status = .resignActive
        onSceneWillResignActive()
    }
    func sceneWillEnterForeground(_ scene: UIScene){
        childViews.forEach{ $0.sceneWillEnterForeground( scene ) }
        pageObservable.status = .enterForeground
        onSceneWillEnterForeground()
    }
    func sceneDidEnterBackground(_ scene: UIScene){
        childViews.forEach{ $0.sceneDidEnterBackground( scene ) }
        pageObservable.status = .enterBackground
        pageObservable.isBackground = true
        onSceneDidEnterBackground()
    }
}

protocol PageViewProtocol : PageContentProtocol{
    var pageObject:PageObject? { get }
    var pageID:PageID { get }
    var zIndex:Int { get }
    var id:String { get }
    var contentBody:AnyView { get }
}

protocol PageView : View, PageViewProtocol{}
extension PageView {
    var childViews:[PageViewProtocol] {
        get{ [] }
    }
    var pageObject:PageObject?{
        get{ pageObservable.pageObject }
    }
    var pageID:PageID{
        get{ pageObservable.pageObject?.pageID ?? ""}
    }
    var zIndex:Int{
        get{ pageObservable.pageObject?.zIndex ?? 0}
    }
    var id:String{
        get{ pageObservable.pageObject?.id ?? ""}
    }
    var contentBody:AnyView { get{
        return AnyView(self)
    }}
}

protocol PageModel {
    var currentPageObject:PageObject? {get set}
    func getHome(idx:Int) -> PageObject?
    func isHomePage(_ pageObject:PageObject ) -> Bool
    func isHistoryPage(_ pageObject:PageObject ) -> Bool
    func isChangedCategory(prevPage:PageObject?, nextPage:PageObject?) -> Bool
    func isChangePageAble(_ pageObject: PageObject) -> Bool
    func getPageOrientation(_ pageObject:PageObject? ) -> UIInterfaceOrientationMask?
    func getCloseExceptions() -> [PageID]?
}
extension PageModel{
    func getHome(idx:Int) -> PageObject? { return nil }
    func isHomePage(_ pageObject:PageObject ) -> Bool { return false }
    func isHistoryPage(_ pageObject:PageObject ) -> Bool { return true }
    func isChangedCategory(prevPage:PageObject?, nextPage:PageObject?) -> Bool { return false }
    func isChangePageAble(_ pageObject: PageObject) -> Bool { return true }
    func getPageOrientation(_ pageObject:PageObject? = nil ) -> UIInterfaceOrientationMask? { return nil }
    func getCloseExceptions() -> [PageID]? { return nil }
}

typealias PageEventType = String
struct PageEvent {
    private(set) var type:PageEventType = ""
    var data: Any? = nil
}
