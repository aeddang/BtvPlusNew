//
//  PageStyle.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/07.
//

import Foundation
import SwiftUI
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

struct ContentEdges: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding(.all, Dimen.margin.thin)
    }
}
struct ContentHorizontalEdges: ViewModifier {
    
    func body(content: Content) -> some View {
        return content
            .padding(.horizontal, Dimen.margin.thin)
    }
}

struct ContentHorizontalEdgesTablet: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding(.horizontal, SystemEnvironment.isTablet ? Dimen.margin.heavy : Dimen.margin.thin)
    }
}

struct ContentVerticalEdges: ViewModifier {
    var margin:CGFloat = Dimen.margin.thin
    func body(content: Content) -> some View {
        return content
            .padding(.vertical, Dimen.margin.thin)
    }
}

struct PageTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(BlackTextStyle(size: Font.size.bold))
    }
}


struct BlockTitle: ViewModifier {
    var color:Color = Color.app.white
    func body(content: Content) -> some View {
        return content
            .modifier(BoldTextStyle(
                size: Font.size.regular,
                color:color
            ))
    }
}

struct ContentTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(MediumTextStyle( size: Font.size.regular))
    }
}




