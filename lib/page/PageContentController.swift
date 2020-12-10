//
//  PageContentView.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/19.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

final class PageControllerObservable: ObservableObject  {
    @Published var pages:[PageViewProtocol] = []
    @Published var popups:[PageViewProtocol] = []
    @Published var overlayView: PageViewProtocol? = nil
}

struct PageContentController: View{
    var pageID: PageID = "PageContentController"
    var backgroundBody: AnyView = AnyView(PageBackgroundBody())
    @ObservedObject var pageControllerObservable:PageControllerObservable = PageControllerObservable()
    @ObservedObject internal var pageObservable: PageObservable = PageObservable()
    @EnvironmentObject var pagePresenter:PagePresenter
    
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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                VStack{
                    ZStack( alignment: .top ){
                        ForEach(self.pageControllerObservable.pages, id: \.id) { page in page.contentBody }
                        ForEach(self.pageControllerObservable.popups, id: \.id) { popup in popup.contentBody }
                    }
                    Spacer()
                }
                self.pageControllerObservable.overlayView?.contentBody
            }
            
            .onAppear(){
                PageSceneObserver.safeAreaBottom = geometry.safeAreaInsets.bottom
                PageSceneObserver.safeAreaTop = geometry.safeAreaInsets.top
                PageSceneObserver.screenSize = geometry.size
            }
            .edgesIgnoringSafeArea(.all)
            .background(backgroundBody)
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
    }
    
    func sceneDidBecomeActive(_ scene: UIScene){
        pageObservable.status = SceneStatus.becomeActive
        pageControllerObservable.pages.forEach({$0.sceneDidBecomeActive(scene)})
        pageControllerObservable.popups.forEach({$0.sceneDidBecomeActive(scene)})
        pageControllerObservable.overlayView?.sceneDidBecomeActive(scene)
    }
    
    func sceneDidDisconnect(_ scene: UIScene){
        pageObservable.status = SceneStatus.disconnect
        pageControllerObservable.pages.forEach({$0.sceneDidDisconnect(scene)})
        pageControllerObservable.overlayView?.sceneDidDisconnect(scene)
    }
    
    func sceneWillResignActive(_ scene: UIScene){
        pageObservable.status = SceneStatus.resignActive
        pageControllerObservable.pages.forEach({$0.sceneWillResignActive(scene)})
        pageControllerObservable.popups.forEach({$0.sceneWillResignActive(scene)})
        pageControllerObservable.overlayView?.sceneWillResignActive(scene)
    }
    
    func sceneWillEnterForeground(_ scene: UIScene){
        pageObservable.status = SceneStatus.enterForeground
        pageControllerObservable.pages.forEach({$0.sceneWillEnterForeground(scene)})
        pageControllerObservable.popups.forEach({$0.sceneWillEnterForeground(scene)})
        pageControllerObservable.overlayView?.sceneWillEnterForeground(scene)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene){
        pageObservable.status = SceneStatus.enterBackground
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
