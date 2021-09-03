//
//  PageStyle.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/07.
//

import Foundation
import SwiftUI
import Combine
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
    case dark, white, normal, kids, kidsLight, kidsWhite, kidsClear, kidsPupple
    var textColor:Color {
        get{
            switch self {
            case .normal: return Color.app.white
            case .dark: return Color.app.white
            case .white: return Color.app.black
            case .kids: return Color.app.brownDeep
            case .kidsPupple : return Color.app.white
            case .kidsLight : return Color.app.brownDeep
            case .kidsWhite : return Color.app.brownDeep
            case .kidsClear : return Color.app.brownDeep
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
            case .kidsPupple : return Color.app.pupple
            case .kidsLight: return Color.app.ivoryLight
            case .kidsWhite : return Color.app.white
            case .kidsClear : return Color.transparent.clear
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
                if self.pagePresenter.isFullScreen {
                    self.marginStart = 0
                    self.marginEnd = 0
                }else{
                    self.marginStart = self.sceneObserver.safeAreaStart
                    self.marginEnd = self.sceneObserver.safeAreaEnd
                }
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

struct PageFullMargin: ViewModifier {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @State var marginStart:CGFloat = 0
    @State var marginEnd:CGFloat = 0
    func body(content: Content) -> some View {
        return content
            .padding(.leading, self.marginStart)
            .padding(.trailing, self.marginEnd)
            .onAppear(){
                if self.pagePresenter.isFullScreen {
                    self.marginStart = 0
                    self.marginEnd = 0
                }else{
                    self.marginStart = self.sceneObserver.safeAreaStart
                    self.marginEnd = self.sceneObserver.safeAreaEnd
                }
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
                height: self.sceneObserver.screenSize.height - self.sceneObserver.safeAreaTop - Dimen.app.top - self.sceneObserver.safeAreaIgnoreKeyboardBottom)
            .background(self.style.bgColor)
    }
}

struct ContentScrollPull: ViewModifier {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var tag:String? = nil
    var infinityScrollModel:InfinityScrollModel
    var pageDragingModel:PageDragingModel
    
    @State var anyCancellable = Set<AnyCancellable>()
    private func setScrollList(){
        self.infinityScrollModel.$event.sink(receiveValue: { evt in
            guard let evt = evt else {return}
            switch evt {
            case .ready : self.infinityScrollModel.setup(scrollSize: sceneObserver.screenSize)
            case .pullCompleted : self.pageDragingModel.updateNestedScroll(evt: .pullCompleted)
            case .pullCancel : self.pageDragingModel.updateNestedScroll(evt: .pullCancel)
            default : break
            }
        })
        .store(in: &anyCancellable)
        self.infinityScrollModel.$pullPosition.sink(receiveValue: { pos in
            self.pageDragingModel.updateNestedScroll(evt: .pull(pos))
        })
        .store(in: &anyCancellable)
    }
   
    func body(content: Content) -> some View {
        return content
            .onAppear(){
                self.setScrollList()
                if let tag = self.tag { 
                    ComponentLog.d("onAppear " + tag,tag: "ContentScrollPull")
                }
            }
            .onDisappear{
                self.anyCancellable.forEach{$0.cancel()}
                self.anyCancellable.removeAll()
                if let tag = self.tag {
                    ComponentLog.d("onDisappear " + tag,tag: "ContentScrollPull")
                }
            }
    }
}

struct PageDraging: ViewModifier {
    var geometry:GeometryProxy
    var pageDragingModel:PageDragingModel
    var useGesture:Bool = true
    @State var isInitDrag = true
    func body(content: Content) -> some View {
        return content
            .highPriorityGesture(
                self.useGesture ?
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                        .onChanged({ value in
                            if self.isInitDrag {
                                AppUtil.hideKeyboard()
                                self.isInitDrag = false
                            }
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ value in
                            self.isInitDrag = true
                            self.pageDragingModel.uiEvent = .draged(geometry, value)
                        })
                : nil
            )
            .gesture(
                self.useGesture ?
                    self.pageDragingModel.cancelGesture
                        .onChanged({_ in
                                    self.isInitDrag = true
                                    self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in
                                    self.isInitDrag = true
                                    self.pageDragingModel.uiEvent = .dragCancel})
                : nil
            )
            
    }
}

struct PageDragingSecondPriority: ViewModifier {
    var geometry:GeometryProxy
    var pageDragingModel:PageDragingModel
    var useGesture:Bool = true
    @State var isInitDrag = true
    func body(content: Content) -> some View {
        return content
            .gesture(
                self.useGesture ?
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                        .onChanged({ value in
                            if self.isInitDrag {
                                AppUtil.hideKeyboard()
                                self.isInitDrag = false
                            }
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ value in
                            self.isInitDrag = true
                            self.pageDragingModel.uiEvent = .draged(geometry, value)
                        })
                : nil
            )
            .gesture(
                self.useGesture ?
                    self.pageDragingModel.cancelGesture
                        .onChanged({_ in
                                    self.isInitDrag = true
                                    self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in
                                    self.isInitDrag = true
                                    self.pageDragingModel.uiEvent = .dragCancel})
                : nil
            )
    }
}

