//
//  PageHostingController.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/04.
//

import Foundation
import SwiftUI

class PageHostingController<ContentView> : UIHostingController<ContentView> where ContentView : View {
    var sceneObserver:PageSceneObserver? = nil
    var isIndicatorAutoHidden = false
    var statusBarStyle:UIStatusBarStyle = .lightContent
    override dynamic open var preferredStatusBarStyle: UIStatusBarStyle {
        self.statusBarStyle
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        PageLog.d("prefersHomeIndicatorAutoHidden " + self.isIndicatorAutoHidden.description , tag: "PageHostingController")
        return self.sceneObserver?.willSceneOrientation == .landscape ? true : self.isIndicatorAutoHidden
    }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
      return UIRectEdge.all
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //PageLog.d("viewWillTransition " + size.debugDescription , tag: "PagePresenter")
        self.sceneObserver?.willScreenSize = size
    }
}
