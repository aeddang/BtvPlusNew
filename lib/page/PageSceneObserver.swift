//
//  PageSceanOb.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/10/08.
//
import SwiftUI
import Foundation
open class PageSceneObserver: ObservableObject{
    
    @Published private(set) var safeAreaStart:CGFloat = 0
    @Published private(set) var safeAreaEnd:CGFloat = 0
    @Published private(set) var safeAreaBottom:CGFloat = 0
    @Published private(set) var safeAreaIgnoreKeyboardBottom:CGFloat = 0
    @Published private(set) var safeAreaTop:CGFloat = 0
    @Published var willScreenSize:CGSize? = nil
    @Published private(set) var screenSize:CGSize = CGSize()
    @Published var isUpdated:Bool = false
        {didSet{ if isUpdated { isUpdated = false} }}
    
    func update(geometry:GeometryProxy) {
        var willUpdate = false
        if geometry.size != self.screenSize {
            self.screenSize = geometry.size
            willUpdate = true
        }
        
        if geometry.safeAreaInsets.bottom != self.safeAreaBottom{
            self.safeAreaBottom = ceil( geometry.safeAreaInsets.bottom )
            if self.safeAreaBottom < 100 {
                self.safeAreaIgnoreKeyboardBottom = self.safeAreaBottom
            }
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad && self.safeAreaBottom > 300 {
                if #available(iOS 15.0, *) {//  apple....
                    if self.sceneOrientation == .landscape { //12.9
                        if self.safeAreaBottom >= 498 {
                            self.safeAreaBottom = self.safeAreaBottom - 30
                        } else if self.safeAreaBottom == 428 && self.screenSize.width == 1133 { //mini
                            self.safeAreaBottom = self.safeAreaBottom - 138
                        } else if self.safeAreaBottom == 428 && self.screenSize.width == 1194 { //11
                            self.safeAreaBottom = self.safeAreaBottom - 54
                        } else if self.safeAreaBottom >= 422{ // air
                            self.safeAreaBottom = self.safeAreaBottom - 56
                        } else if self.safeAreaBottom == 408 && self.screenSize.width == 1080{ //pad
                            self.safeAreaBottom = self.safeAreaBottom - 50
                        } else { //9.7
                            self.safeAreaBottom = self.safeAreaBottom - 92
                        }
                        
                    }
                }
            }
            willUpdate = true
        }
        if geometry.safeAreaInsets.top != self.safeAreaTop{
            self.safeAreaTop = ceil( geometry.safeAreaInsets.top )
            willUpdate = true
        }
        if geometry.safeAreaInsets.leading != self.safeAreaStart{
            self.safeAreaStart = ceil(geometry.safeAreaInsets.leading)
            willUpdate = true
        }
        if geometry.safeAreaInsets.trailing != self.safeAreaEnd {
            self.safeAreaEnd = ceil(geometry.safeAreaInsets.trailing)
            willUpdate = true
        }
        
        if willUpdate {
            self.isUpdated = true
            ComponentLog.d("safeAreaBottom " + self.safeAreaBottom.description, tag: "SceneObserver")
            ComponentLog.d("resize " + self.screenSize.debugDescription, tag:"SceneObserver")
        }
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
            return self.screenSize.width > (self.screenSize.height + self.safeAreaBottom)
                        ? .landscape
                        : .portrait
            //return UIDevice.current.orientation.isLandscape ? .landscape : .portrait
        }
    }
    
}
