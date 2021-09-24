//
//  PageSynopsisLayer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/12.
//

import Foundation
import SwiftUI

extension PageSynopsis {
    func onLayerPlayerAppear(){
        if self.type == .kids  {return}
        self.appSceneObserver.currentPlayer = self
        if !Self.useLayer {return}
        self.playerModel.useFullScreenAction = self.type == .kids
        
    }
    func onLayerPlayerDisappear(){
        if self.type == .kids  {return}
        if self.appSceneObserver.currentPlayer?.pageObject?.id == self.pageObject?.id {
            self.appSceneObserver.currentPlayer = nil
            self.appSceneObserver.useLayerPlayer = false
        }
    }
    
    func activePlayer(){
        if !Self.useLayer {return}
        if self.type == .kids  {return}
        if self.isBottom {
            self.pageDragingModel.uiEvent = .dragEnd(false)
        }
    }
    func passivePlayer(){
        if !Self.useLayer {return}
        if self.type == .kids  {return}
        if !self.isBottom {
            self.pageDragingModel.uiEvent = .dragEnd(true)
        }
    }
    
    func onFullScreenControl(){
        if self.uiType == .simple {
            self.pageDragingModel.uiEvent = .dragEnd(false)
        } else {
            if self.isFullScreen {
                self.onDefaultViewMode()
            } else {
                self.onFullScreenViewMode()
            }
        }
    }
    func onDrag(evt:PageDragingEvent) {
        if !Self.useLayer {return}
        if self.type == .kids  {return}
        guard let page = self.pageObject  else { return }
        switch evt {
        case .dragInit :
            self.pagePresenter.setLayerPopup(pageObject: page, isLayer: false)
            withAnimation{
                self.dragOffset = 0
            }
        case .drag(_, let dragOpacity) :
            self.dragOpacity = dragOpacity
        case .draged: break
        }
    }
    
    func onDragEndAction(isBottom: Bool, geometry:GeometryProxy) {
        if self.isBottom && isBottom {
            self.pagePresenter.closePopup(self.pageObject?.id)
            return
        }
        
        self.isBottom = isBottom
        if let page  = self.pageObject {
            PageLog.d("onDragEndAction setLayerPopup " + isBottom.description, tag: self.tag)
            self.pagePresenter.setLayerPopup(pageObject: page, isLayer: isBottom)
        }
        if isBottom {
            self.appSceneObserver.useLayerPlayer = true
            self.updateBottomPos(geometry: geometry)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation{ 
                self.uiType = isBottom ? .simple : .normal 
                self.dragOffset = isBottom ? self.appSceneObserver.safeBottomHeight : 0
                self.dragOpacity = isBottom ? 0 : 1
            }
        }
    }
    
    func updateBottomPos(geometry:GeometryProxy){
        if !self.isBottom {return}
        let offset = geometry.size.height - self.appSceneObserver.safeBottomHeight - Dimen.app.layerPlayerSize.height
        self.pageDragingModel.uiEvent = .setBodyOffset( offset )
    }
    
}