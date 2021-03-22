//
//  PageContentView.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/19.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class PageControllerObservable: ObservableObject  {
    @Published var pages:[PageViewProtocol] = []
    @Published var popups:[PageViewProtocol] = []
    @Published var overlayView: PageViewProtocol? = nil
    
    func updatePageIndex(){
        
        PageLog.d("updatePageIndex" , tag:"PageController")
        let checkPopups = popups.filter({$0.zIndex == 0}).reversed()
        if checkPopups.isEmpty {
            pages.first?.pageTop()
            return
        }
        
        let top = checkPopups.count
        if top == 1 {
            checkPopups.first?.pageTop()
            pages.first?.pageBelow()
            return
        }
        let below = top - 1
        var idx = top
        checkPopups.forEach{ pop in
            if idx == top {
                pop.pageTop()
            } else if idx == below {
                pop.pageBelow()
            } else {
                pop.pageBottom()
            }
            idx -= 1
        }
        pages.first?.pageBottom()
        
    }
}

struct PageContentController: View{
    var pageID: PageID = "PageContentController"
    var backgroundBody: AnyView = AnyView(PageBackgroundBody())
    @ObservedObject var pageControllerObservable:PageControllerObservable = PageControllerObservable()
    @ObservedObject internal var pageObservable: PageObservable = PageObservable()
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    
    @State var isFullScreen:Bool = false
    var currnetPage:PageViewProtocol?{
        get{
            return pageControllerObservable.pages.first
        }
    }
    
    var currnetView:PageViewProtocol?{
        get{
            if pageControllerObservable.popups.isEmpty { return currnetPage }
            return pageControllerObservable.popups.last
        }
    }
    
    var prevView:PageViewProtocol?{
        get{
            if pageControllerObservable.popups.count <= 1 { return currnetPage }
            return pageControllerObservable.popups[ pageControllerObservable.popups.count-2 ]
        }
    }
    
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
   
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                ForEach(self.pageControllerObservable.pages, id: \.id) { page in page.contentBody }
                ForEach(self.pageControllerObservable.popups, id: \.id) { popup in popup.contentBody }
                self.pageControllerObservable.overlayView?.contentBody
            }
            .onAppear(){
                sceneObserver.update(geometry: geometry)
            }
            .onDisappear(){
                
            }
            .edgesIgnoringSafeArea(.all)
            .statusBar(hidden: self.isFullScreen)
            .background(backgroundBody)
            .onReceive(self.keyboardObserver.$isOn){ _ in
                delaySafeAreaUpdate(geometry: geometry)
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                sceneObserver.update(geometry: geometry)
            }
            .onReceive(self.orientationChanged){ _ in
                sceneObserver.update(geometry: geometry)
            }
            .onReceive(self.pagePresenter.$isFullScreen){ isFullScreen in
                self.isFullScreen = isFullScreen
            }
        }
    }
    
    @State var safeAreaUpdateSubscription:AnyCancellable?
    func delaySafeAreaUpdate(geometry:GeometryProxy) {
        self.safeAreaUpdateSubscription?.cancel()
        self.safeAreaUpdateSubscription = Timer.publish(
            every: 0.01, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.safeAreaUpdateSubscription?.cancel()
                sceneObserver.update(geometry: geometry)
        }
    }
    
    
    func addPage(_ page:PageViewProtocol){
        pageControllerObservable.pages.append(page)
        pageControllerObservable.popups.forEach({ $0.pageChanged(page.pageObject) })
    }
    
    func reloadPage(){
        self.currnetPage?.pageReload()
    }

    func removePage(){
        pageControllerObservable.pages.removeFirst()
        pageControllerObservable.updatePageIndex()
    }
    
    func onPageEvent(_ pageObject: PageObject?, event:PageEvent){
        pageControllerObservable.pages.forEach({ $0.pageEvent(pageObject, event:event) })
        pageControllerObservable.popups.forEach({ $0.pageEvent(pageObject, event:event) })
        pageControllerObservable.overlayView?.pageEvent(pageObject, event: event)
    }
    
    func addPopup(_ page:PageViewProtocol){
        pageControllerObservable.popups.append(page)
        pageControllerObservable.popups.sort{$0.zIndex < $1.zIndex} 
        pageControllerObservable.pages.forEach({ $0.pageAdded( page.pageObject )})
        pageControllerObservable.popups.forEach({ $0.pageAdded( page.pageObject )})
        pageControllerObservable.overlayView?.pageAdded(page.pageObject)
        pageControllerObservable.updatePageIndex()
    }
    
    func getPopup(_ key:String) -> PageViewProtocol? {
        guard let findIdx = pageControllerObservable.popups.firstIndex(where: { $0.id == key }) else { return nil }
        return pageControllerObservable.popups[findIdx]
    }
    
    func removePopup(_ key:String){
        guard let findIdx = pageControllerObservable.popups.firstIndex(where: { $0.id == key }) else { return }
        let pop = pageControllerObservable.popups.remove(at: findIdx)
        pageControllerObservable.pages.forEach({ $0.pageRemoved( pop.pageObject )})
        pageControllerObservable.popups.forEach({ $0.pageRemoved( pop.pageObject )})
        pageControllerObservable.overlayView?.pageRemoved( pop.pageObject )
        pageControllerObservable.updatePageIndex()
    }
    
    func removeAllPopup(_ pageKey:String = "", exceptions:[PageID]? = nil){
        pageControllerObservable.popups.removeAll( where: { pop in
            var remove = true
            if pop.id == pageKey { remove = false }
            if let exps = exceptions {
                if let _ = exps.first(where: { pop.pageID == $0 }) { remove = false }
            }
            return remove
        })
        pageControllerObservable.pages.forEach({ $0.pageRemoved( nil )})
        pageControllerObservable.overlayView?.pageRemoved(nil)
        pageControllerObservable.updatePageIndex()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene){
        pageObservable.status = PageStatus.becomeActive
        pageControllerObservable.pages.forEach({$0.sceneDidBecomeActive(scene)})
        pageControllerObservable.popups.forEach({$0.sceneDidBecomeActive(scene)})
        pageControllerObservable.overlayView?.sceneDidBecomeActive(scene)
    }
    
    func sceneDidDisconnect(_ scene: UIScene){
        pageObservable.status = PageStatus.disconnect
        pageControllerObservable.pages.forEach({$0.sceneDidDisconnect(scene)})
        pageControllerObservable.overlayView?.sceneDidDisconnect(scene)
    }
    
    func sceneWillResignActive(_ scene: UIScene){
        pageObservable.status = PageStatus.resignActive
        pageControllerObservable.pages.forEach({$0.sceneWillResignActive(scene)})
        pageControllerObservable.popups.forEach({$0.sceneWillResignActive(scene)})
        pageControllerObservable.overlayView?.sceneWillResignActive(scene)
    }
    
    func sceneWillEnterForeground(_ scene: UIScene){
        pageObservable.status = PageStatus.enterForeground
        pageControllerObservable.pages.forEach({$0.sceneWillEnterForeground(scene)})
        pageControllerObservable.popups.forEach({$0.sceneWillEnterForeground(scene)})
        pageControllerObservable.overlayView?.sceneWillEnterForeground(scene)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene){
        pageObservable.status = PageStatus.enterBackground
        pageControllerObservable.pages.forEach({$0.sceneDidEnterBackground(scene)})
        pageControllerObservable.popups.forEach({$0.sceneDidEnterBackground(scene)})
        pageControllerObservable.overlayView?.sceneDidEnterBackground(scene)
    }
}



#if DEBUG
struct PageContentController_Previews: PreviewProvider {
    static var previews: some View {
        PageContentController().environmentObject(PagePresenter())
    }
}
#endif
