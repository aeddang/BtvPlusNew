//
//  PageDragingProtocol.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
protocol PageDragingProtocol {
    var axis: Axis.Set {get set}
    var isDraging:Bool {get set}
    var isBottom:Bool {get set}
    var bodyOffset:CGFloat {get set}
    var dragInitOffset:CGFloat {get set}
    
    func onPull(geometry:GeometryProxy, value:CGFloat)
    func onPulled(geometry:GeometryProxy)
    
    func onDraging(geometry:GeometryProxy, value:DragGesture.Value)
    func onDragEnd(geometry:GeometryProxy, value:DragGesture.Value?)
    func onDragCancel()
    
    func onDragInit(offset:CGFloat)
    func onDragingAction(offset:CGFloat, dragOpacity:Double)
    func onDragEndAction(isBottom:Bool, offset:CGFloat)
}

protocol PageDragingView : PageView, PageDragingProtocol {}

extension PageDragingView{
    var axis: Axis.Set {get{.vertical} set{axis = .vertical}}
    var isBottom:Bool {get{false} set{isBottom = false}}
    
    private func moveOffset(_ value:CGFloat, geometry:GeometryProxy) {
        var offset = value
        if offset < 0 { offset = 0 }
        let opc = (self.axis == .vertical)
            ? Double((geometry.size.height - self.bodyOffset)/geometry.size.height)
            : Double((geometry.size.width - self.bodyOffset)/geometry.size.width)
        
        //ComponentLog.d("opc " + opc.description, tag: "opc")
        self.onDragingAction(offset: offset, dragOpacity:opc)
    }
    
    func onPull(geometry:GeometryProxy, value:CGFloat) {
        if self.pageObject?.isPopup == false { return }
        if !self.isDraging { self.onDragInit(offset: 0) }
        let offset = self.bodyOffset + value
        self.moveOffset(offset, geometry:geometry)
    }
    
    func onPulled(geometry:GeometryProxy) {
        self.onDragEnd(geometry:geometry)
    }
    
    func onDraging(geometry:GeometryProxy, value:DragGesture.Value) {
        if self.pageObject?.isPopup == false { return }
        let offset = (self.axis == .vertical)
            ? value.translation.height
            : value.translation.width
        if !self.isDraging { self.onDragInit(offset:offset) }
        self.moveOffset(offset + self.bodyOffset, geometry:geometry)
        
    }
    
    func onDragEnd(geometry:GeometryProxy, value:DragGesture.Value? = nil) {
        if self.pageObject?.isPopup == false { return }
        let range = self.axis == .vertical ? geometry.size.height: geometry.size.width
        let diffMin =  self.isBottom ? range*0.66 : range*0.2
        var offset:CGFloat = self.bodyOffset
        if let value = value {
            let predictedOffset = self.axis == .vertical
                            ? value.predictedEndTranslation.height
                            : max(0,value.predictedEndTranslation.width)
            //ComponentLog.d("predictedOffset " + value.predictedEndTranslation.width.description , tag: "onDragEnd")
            offset = offset + predictedOffset
        }
        //ComponentLog.d("offset " + offset.description , tag: "onDragEnd")
        
        var isBottom = false
        if offset > diffMin {
            offset =  range
            isBottom = true
        }else{
            offset = 0
            isBottom = false
        }
        self.onDragEndAction(isBottom:isBottom, offset: offset)
    }
    
    func onDragCancel() {
        if self.pageObject?.isPopup == false { return }
        self.onDragEndAction(isBottom: false, offset: 0)
    }
}

class PageDragingModel: ObservableObject, PageProtocol, Identifiable{
    static var MIN_DRAG_RANGE:CGFloat = 30

    @Published var uiEvent:PageDragingUIEvent? = nil {didSet{ if uiEvent != nil { uiEvent = nil} }}
    @Published var event:PageDragingEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published var status:PageDragingStatus = .none
    @Published private(set) var nestedScrollEvent:PageNestedScrollEvent? = nil {didSet{ if nestedScrollEvent != nil { nestedScrollEvent = nil} }}
    private(set) var nestedScrollPos:CGFloat = 0
    private(set) var nestedPullPos:CGFloat = 0
    func updateNestedScroll(evt:PageNestedScrollEvent) {
        switch evt {
        case .pullCompleted :
            self.nestedScrollEvent = .pullCompleted
        case .pullCancel :
            self.nestedScrollEvent = .pullCancel
        case .pull(let pos) :
            if nestedPullPos != pos {
                nestedPullPos = pos
                self.nestedScrollEvent = .pull(pos)
            }
        case .scroll(let pos) :
            if nestedScrollPos != pos {
                self.nestedScrollPos = pos
                self.nestedScrollEvent = .scroll(pos)
            }
        }
    }
    
    let cancelGesture =  LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
          .simultaneously(with: RotationGesture(minimumAngleDelta:.zero))
          .simultaneously(with: MagnificationGesture(minimumScaleDelta: 0))
    
      
}

enum PageDragingUIEvent {
    case pull(GeometryProxy, CGFloat),
         pullCompleted(GeometryProxy? = nil),
         pullCancel(GeometryProxy? = nil),
         drag(GeometryProxy, DragGesture.Value),
         draged(GeometryProxy, DragGesture.Value),
         dragCancel
}
enum PageDragingEvent {
    case dragInit, drag(CGFloat, Double), draged(Bool,CGFloat)
}
enum PageDragingStatus:String {
    case none,drag,pull
}

enum PageNestedScrollEvent {
    case scroll(CGFloat), pull(CGFloat),pullCompleted ,pullCancel
}


struct PageDragingBody<Content>: PageDragingView  where Content: View{
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
   
    @ObservedObject var viewModel:PageDragingModel = PageDragingModel()

    let content: Content
    var axis:Axis.Set
    var initPullRange:CGFloat
    @State var bodyOffset:CGFloat = 0.0
    @State var dragInitOffset:CGFloat = 0.0
    @State var pullOffset:CGFloat = 0
    
    @State var isDraging: Bool = false
    @State var isBottom = false
    @State var isDragingCompleted = false
    
    private let minDiff:CGFloat = 1.0
    private let maxDiff:CGFloat = 600
    init(
        viewModel: PageDragingModel,
        axis:Axis.Set = .vertical,
        minPullAmount:CGFloat? = nil,
        @ViewBuilder content: () -> Content) {
        self.viewModel = viewModel
        self.axis = axis
        self.content = content()
        self.initPullRange = minPullAmount ?? ( axis == .vertical ? 0 : 0 )
        self.pullOffset = self.initPullRange
    }
    

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading){
                self.content.modifier(MatchParent())
                Spacer()
                    .modifier(MatchVertical(width: 15, margin: 0))
                    .background(Color.transparent.clearUi)
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 5, coordinateSpace: .local)
                            .onChanged({ value in
                                self.viewModel.uiEvent = .drag(geometry, value)
                            })
                            .onEnded({ value in
                                self.viewModel.uiEvent = .draged(geometry, value)
                            })
                    )
                    .gesture(
                        self.viewModel.cancelGesture
                            .onChanged({_ in
                                self.viewModel.uiEvent = .dragCancel})
                            .onEnded({_ in
                                self.viewModel.uiEvent = .dragCancel})
                    )
                
            }
            .offset(
                x:self.axis == .horizontal ? self.bodyOffset : 0,
                y:self.axis == .vertical ? self.bodyOffset : 0)
            .onReceive(self.viewModel.$uiEvent){evt in
                switch evt {
                case .pull(let geo, let value) :
                    if #available(iOS 14.0, *) {
                        if value < self.initPullRange { return }
                        if self.pullOffset == self.initPullRange {
                            self.viewModel.status = .pull
                        } else {
                            let diff = value - self.pullOffset
                            let dr:CGFloat = diff > 0 ? 1 : -1
                            var d = dr * max(abs(diff),minDiff)
                            let m:CGFloat = self.axis == .horizontal ? 2.0 : 1.0
                            if dr == 1 {d = d * m}
                            //ComponentLog.d("pull value " + value.description , tag: "InfinityScrollViewProtocol")
                            if self.viewModel.status != .drag && self.viewModel.status != .pull  {return}
                            self.onPull(geometry: geo, value: d)

                        }
                        self.pullOffset = value
                    }
                case .pullCompleted:
                    if #available(iOS 14.0, *) {
                        //ComponentLog.d("pullCompleted " + self.viewModel.status.rawValue , tag: "InfinityScrollViewProtocol")
                        self.onDragEndAction(isBottom: true, offset: self.bodyOffset)
                        self.viewModel.status = .none
                    }
                case .pullCancel :
                    if #available(iOS 14.0, *) {
                        //ComponentLog.d("pullCancel " + self.viewModel.status.rawValue , tag: "InfinityScrollViewProtocol")
                        self.pullOffset = self.initPullRange
                        self.onDragCancel()
                        self.viewModel.status = .none
                    }
                    
                case .drag(let geo, let value) :
                    if self.keyboardObserver.isOn {
                        AppUtil.hideKeyboard()
                    }
                    self.onDraging(geometry: geo, value: value)
                case .draged(let geo, let value) : self.onDragEnd(geometry: geo, value:value)
                case .dragCancel :
                    if self.keyboardObserver.isOn {
                        AppUtil.hideKeyboard()
                    }
                    if self.viewModel.status != .drag { return }
                    self.onDragCancel()
                default : do {}
                }
            }
            .onAppear(){
                self.pullOffset = self.initPullRange
            }
            .onDisappear(){
                
            }
        }//geo
    }//body
    
    func onDragInit(offset:CGFloat = 0) {
        if offset < 0 {return}
        self.isDragingCompleted = false
        self.isDraging = true
        self.dragInitOffset = offset
        self.viewModel.event = .dragInit
        self.viewModel.status = .drag
    }
    
    func onDragingAction(offset: CGFloat, dragOpacity: Double) {
        if self.isDragingCompleted {return}
        if !self.isDraging {return}
        let diff = abs(self.bodyOffset - offset)
        //ComponentLog.d("Draging diff " + offset.description , tag: "InfinityScrollViewProtocol")
        if abs(diff) > maxDiff { return }
        if abs(diff) < minDiff { return }
        let bodyOffset = max( 0, offset - self.dragInitOffset)
        //ComponentLog.d("self.dragInitOffset " + self.dragInitOffset.description , tag: "DIFF")
        self.bodyOffset = ceil(bodyOffset)
        self.viewModel.event = .drag(offset, dragOpacity)
        self.pagePresenter.dragOpercity = dragOpacity
    }

    func onDragEndAction(isBottom: Bool, offset: CGFloat) {
        self.viewModel.status = .none
        self.isDraging = false
        withAnimation{
            if !isBottom {
                self.bodyOffset = 0
            }
        }
        self.viewModel.event = .draged(isBottom, offset)
        
        //ComponentLog.d("onDragEndAction " + self.isDragingCompleted.description , tag: "InfinityScrollViewProtocol")
        if self.isDragingCompleted {return}
        if isBottom {
            self.isDragingCompleted = true
            self.pagePresenter.goBack()
        }
    }
    
    @State var autoResetSubscription:AnyCancellable?
    func autoReset(){
        self.autoResetSubscription?.cancel()
        self.autoResetSubscription = Timer.publish(
            every: 0.05, on: .current, in: .tracking)
            .autoconnect()
            .sink() {_ in
                self.reset()
            }
    }
    
    func reset() {
       self.autoResetSubscription?.cancel()
       self.autoResetSubscription = nil
       DispatchQueue.main.async {
            self.onDragInit()
            self.onDragCancel()
       }
    }
    
    
    
            
}








