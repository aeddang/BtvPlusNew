//
//  PageStyle.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/07.
//

import Foundation
import SwiftUI
enum PageType:String{
    case btv, kids
    static func getType(_ value:String?) -> PageType{
        switch value {
        case PageType.kids.rawValue : return .kids
        default : return .btv
        }
    }
}


enum PageStyle{
    case dark, white, normal, kids, kidsLight, kidsWhite
    var textColor:Color {
        get{
            switch self {
            case .normal: return Color.app.white
            case .dark: return Color.app.white
            case .white: return Color.app.black
            case .kids: return Color.app.brownDeep
            case .kidsLight : return Color.app.brownDeep
            case .kidsWhite : return Color.app.brownDeep
            }
        }
    }
    var bgColor:Color {
        get{
            switch self {
            case .normal: return Color.brand.bg
            case .dark: return Color.app.blueDeep
            case .white: return Color.app.white
            case .kids: return Color.kids.bg
            case .kidsLight: return Color.app.ivoryLight
            case .kidsWhite : return Color.app.white
            }
        }
    }
}

struct PageFull: ViewModifier {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var style:PageStyle = .normal
    @State var marginStart:CGFloat = 0
    @State var marginEnd:CGFloat = 0

    func body(content: Content) -> some View {
        return content
            .padding(.leading, self.marginStart)
            .padding(.trailing, self.marginEnd)
            .background(self.style.bgColor)
            .onAppear(){
                self.marginStart = self.sceneObserver.safeAreaStart
                self.marginEnd = self.sceneObserver.safeAreaEnd
            }
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                if self.pagePresenter.isFullScreen {
                    self.marginStart = 0
                    self.marginEnd = 0
                }else{
                    self.marginStart = self.sceneObserver.safeAreaStart
                    self.marginEnd = self.sceneObserver.safeAreaEnd
                }
                
            }
    }
}

struct PageFullScreen: ViewModifier {
    var style:PageStyle = .normal
    func body(content: Content) -> some View {
        return content
            .background(self.style.bgColor)
    }
}

struct PageBody: ViewModifier {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var style:PageStyle = .normal
    func body(content: Content) -> some View {
        return content
            .frame(
                width: self.sceneObserver.screenSize.width,
                height: self.sceneObserver.screenSize.height - self.sceneObserver.safeAreaTop - Dimen.app.top - self.sceneObserver.safeAreaBottom)
            .background(self.style.bgColor)
            
    }
}


struct PageDraging: ViewModifier {
    var geometry:GeometryProxy
    var pageDragingModel:PageDragingModel
   
    func body(content: Content) -> some View {
        return content
            .highPriorityGesture(
                DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                    .onChanged({ value in
                        self.pageDragingModel.uiEvent = .drag(geometry, value)
                    })
                    .onEnded({ value in
                        self.pageDragingModel.uiEvent = .draged(geometry, value)
                    })
            )
            
            .gesture(
                self.pageDragingModel.cancelGesture
                    .onChanged({_ in self.pageDragingModel.uiEvent = .dragCancel})
                    .onEnded({_ in self.pageDragingModel.uiEvent = .dragCancel})
            )
    }
}

struct PageDragingSecondPriority: ViewModifier {
    var geometry:GeometryProxy
    var pageDragingModel:PageDragingModel
   
    func body(content: Content) -> some View {
        return content
            .gesture(
                DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                    .onChanged({ value in
                       self.pageDragingModel.uiEvent = .drag(geometry, value)
                    })
                    .onEnded({ value in
                        self.pageDragingModel.uiEvent = .draged(geometry, value)
                    })
            )
            
            .gesture(
                self.pageDragingModel.cancelGesture
                    .onChanged({_ in self.pageDragingModel.uiEvent = .dragCancel})
                    .onEnded({_ in self.pageDragingModel.uiEvent = .dragCancel})
            )
    }
}

