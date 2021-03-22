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
    var isFullScreen = false
    override dynamic open var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        //PageLog.d("prefersHomeIndicatorAutoHidden " + self.isFullScreen.description , tag: "PagePresenter")
        return self.sceneObserver?.willSceneOrientation == .landscape ? true : false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //PageLog.d("viewWillTransition " + size.debugDescription , tag: "PagePresenter")
        self.sceneObserver?.willScreenSize = size
    }
}
