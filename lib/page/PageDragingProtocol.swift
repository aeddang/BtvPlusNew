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
    var isScrolling:Bool {get set}
    var isBottom:Bool {get set}
    var bodyOffset:CGFloat {get set}
    var scrollOffset: CGFloat {get set}
    var gestureOffset: CGFloat {get set}
    var contentRange: CGFloat {get set}
    var scrollBodyOffset: CGFloat {get set}
    var isBodyDraging:Bool {get set}
    var scrollStartTime:TimeInterval {get set}
    
    func onScrollTop()
    func onScrollBottom()
    func onScrolling(geometry:GeometryProxy, value:DragGesture.Value)
    func onScrollEnd(geometry:GeometryProxy)
    
    func onScrollTransaction()
    func onScrollInit()
    func onScrollingAction(offset:CGFloat)
    func onScrollEndAction(verticalOffset:CGFloat, gestureOffset:CGFloat)
    
    func onPull(geometry:GeometryProxy, value:CGFloat, modifyOffset:CGFloat)
    func onPulled(geometry:GeometryProxy)
    
    func onDraging(geometry:GeometryProxy, value:DragGesture.Value, modifyOffset:CGFloat)
    func onDragEnd(geometry:GeometryProxy)
    
    func onDragInit()
    func onDragingAction(offset:CGFloat, dragOpacity:Double)
    func onDragEndAction(isBottom:Bool, offset:CGFloat)
}

protocol PageDragingView : PageView, PageDragingProtocol {}

extension PageDragingView{
    var axis: Axis.Set {get{.vertical} set{axis = .vertical}}
    var isBottom:Bool {get{false} set{isBottom = false}}
    var gestureOffset: CGFloat {get{0} set{gestureOffset = 0.0}}
    var contentRange: CGFloat {get{0} set{contentRange = 0.0}}
    var scrollOffset: CGFloat {get{0} set{scrollOffset = 0.0}}
    var scrollBodyOffset: CGFloat {get{0} set{scrollBodyOffset = 0.0}}
    var isBodyDraging:Bool {get{false} set{isBodyDraging = false}}
    var isScrolling:Bool {get{false} set{isBodyDraging = false}}
    var scrollStartTime:Double {get{0} set{scrollStartTime = 0.0}}
    
    func onScrolling(geometry:GeometryProxy,  value:DragGesture.Value) {
        if !self.isScrolling {self.onScrollInit()}
        let movePos = value.translation.height
        let willPos = movePos + self.scrollOffset
        if willPos > 60 && self.axis == .vertical {
            self.onScrollTransaction()
        }
        if self.isBodyDraging{
            self.onDraging(geometry: geometry, value: value, modifyOffset: self.gestureOffset)
        }else{
            self.onScrollingAction( offset: movePos )
        }
    }
    
    func onScrollEnd(geometry:GeometryProxy) {
        if self.isBodyDraging {
           self.onDragEnd(geometry: geometry)
        }
        let range = -self.contentRange - self.scrollBodyOffset
        let t = Date().timeIntervalSince1970 - self.scrollStartTime
        
        var spd = t > 0.2
            ? 0
            : abs(self.gestureOffset) / CGFloat(t) / 200
        
        spd = min(spd, 5.0)
        //ComponentLog.d("onScrollEnd " + spd.description)
        let inertia = self.gestureOffset * spd
        var willPos = self.isBodyDraging ? 0 :  (self.scrollOffset + self.gestureOffset)
        willPos += inertia
        willPos = willPos < range ? range : willPos
        willPos = willPos > 0 ? 0 : willPos
        let verticalOffset:CGFloat = willPos
        let gestureOffset:CGFloat = 0
        self.onScrollEndAction(verticalOffset: verticalOffset, gestureOffset: gestureOffset)
    }
    func onScrollTop(){
        self.onScrollEndAction(verticalOffset: 0, gestureOffset: 0)
    }
    func onScrollBottom(){
        let range = -self.contentRange - self.scrollBodyOffset
        if range > 0 {  return }
        self.onScrollEndAction(verticalOffset: range, gestureOffset: 0)
    }
    func onScrollInit(){}
    func onScrollTransaction(){}
    func onScrollingAction(offset:CGFloat){}
    func onScrollEndAction(verticalOffset:CGFloat, gestureOffset:CGFloat){}
   
    private func moveOffset(_ value:CGFloat, geometry:GeometryProxy) {
        var offset = value
        if offset < 0 { offset = 0 }
        let opc = (self.axis == .vertical)
            ? Double((geometry.size.height - self.bodyOffset)/geometry.size.height)
            : Double((geometry.size.width - self.bodyOffset)/geometry.size.width)
        
        //ComponentLog.d("opc " + opc.description, tag: "opc")
        self.onDragingAction(offset: offset, dragOpacity:opc)
    }
    
    func onPull(geometry:GeometryProxy, value:CGFloat, modifyOffset:CGFloat = 0) {
        if self.pageObject?.isPopup == false { return }
        if !self.isDraging { self.onDragInit() }
        let offset = self.bodyOffset + value - modifyOffset
        self.moveOffset(offset, geometry:geometry)
    }
    
    func onPulled(geometry:GeometryProxy) {
        self.onDragEnd(geometry:geometry)
    }
    
    func onDraging(geometry:GeometryProxy, value:DragGesture.Value, modifyOffset:CGFloat = 0) {
        if self.pageObject?.isPopup == false { return }
        if !self.isDraging { self.onDragInit() }
        let offset = (self.axis == .vertical)
            ? self.bodyOffset + value.translation.height - modifyOffset
            : self.bodyOffset + value.translation.width - modifyOffset
        self.moveOffset(offset, geometry:geometry)
        
    }
    
    func onDragEnd(geometry:GeometryProxy) {
        if self.pageObject?.isPopup == false { return }
        let half = (self.axis == .vertical)
            ? (self.isBottom ? geometry.size.height*0.66 : geometry.size.height*0.2)
            : (self.isBottom ? geometry.size.width*0.66 : geometry.size.width*0.2)
        var offset = self.bodyOffset
        var isBottom = false
        //ComponentLog.d("half " + half.description , tag: self.tag)
        //ComponentLog.d("offset " + offset.description , tag: self.tag)
        if offset > half {
            offset =  (self.axis == .vertical) ? geometry.size.height : geometry.size.width
            isBottom = true
        }else{
            offset = 0
            isBottom = false
        }
        ComponentLog.d("onDragEnd " + isBottom.description, tag: "PageDragingProtocol")
        self.onDragEndAction(isBottom:isBottom, offset: offset)
    }
}



class PageDragingModel: ObservableObject, PageProtocol, Identifiable{
    static var MIN_DRAG_RANGE:CGFloat = 20
    @Published var uiEvent:PageDragingUIEvent? = nil
    @Published var event:PageDragingEvent? = nil
    @Published var status:PageDragingStatus = .none
    
}
enum PageDragingUIEvent {
    case scroll(GeometryProxy, DragGesture.Value),
         scrolled(GeometryProxy),
         pull(GeometryProxy, CGFloat, CGFloat? = nil),
         pulled(GeometryProxy),
         drag(GeometryProxy, DragGesture.Value, CGFloat? = nil), 
         draged(GeometryProxy),
         dragCancel(GeometryProxy),
         scrollBodyOffset(CGFloat),
         scrollContentRange(CGFloat),
         scrollTop,
         scrollBottom
}
enum PageDragingEvent {
    case scrollInit,
         scroll(CGFloat),
         scrolled(CGFloat),
         dragInit,
         drag(CGFloat, Double),
         draged(Bool,CGFloat)
}
enum PageDragingStatus:String {
    case none,drag,pull
}



struct PageDragingBody<Content>: PageDragingView  where Content: View{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDragingModel = PageDragingModel()

    let content: Content
    var axis:Axis.Set
    
    var minPullAmount:CGFloat
    @State var bodyOffset: CGFloat = 0.0
    @State var isScrollInit = false
    @State var scrollOffset: CGFloat = 0.0
    @State var gestureOffset: CGFloat = 0.0
    @State var isBodyDraging:Bool = false
    @State var scrollStartTime:Double = 0
    @State var contentRange: CGFloat = 0
    @State var scrollBodyOffset:CGFloat = 0
    @State var pullOffset:CGFloat = 0
    @State var isDraging: Bool = false
    @State var isScrolling = false
    @State var isBottom = false
    @State var isDragingCompleted = false
    
    init(
        viewModel: PageDragingModel,
        axis:Axis.Set = .vertical,
        minPullAmount:CGFloat = 60,
        @ViewBuilder content: () -> Content) {
        self.viewModel = viewModel
        self.axis = axis
        self.content = content()
        self.minPullAmount = minPullAmount
        self.pullOffset = minPullAmount
    }
    
    private let pullInitDelay = 0.2
    @State var isPullInit: Bool = false
    var body: some View {
        ZStack(alignment: .topLeading){
            self.content.modifier(MatchParent())
        }//z
        .offset(
            x:self.axis == .horizontal ? self.bodyOffset : 0,
            y:self.axis == .vertical ? self.bodyOffset : 0)
        .onReceive(self.viewModel.$uiEvent){evt in
            switch evt {
            case .scroll(let geo, let value) : self.onScrolling(geometry: geo, value: value)
            case .scrolled(let geo) : self.onScrollEnd(geometry: geo)
            case .pull(let geo, let value, let offset) :
                if #available(iOS 14.0, *) {
                    if value < self.minPullAmount { return }
                    if self.pullOffset == self.minPullAmount {
                        withAnimation(.easeOut(duration: self.pullInitDelay )){
                            self.bodyOffset = self.axis == .vertical ? self.minPullAmount * 2 : self.minPullAmount
                        }
                    } else {
                        let diff =  value - self.pullOffset
                        self.onPull(geometry: geo, value: diff, modifyOffset: offset ?? 0)
                    }
                    self.pullOffset = value
                    self.viewModel.status = .pull
                    //ComponentLog.d("pull " +  self.viewModel.status.rawValue + " " + self.bodyOffset.description, tag: "dragCancel")
                }
            case .pulled(let geo) :
                if #available(iOS 14.0, *) {
                    if self.viewModel.status == .drag { return }
                    self.pullOffset = self.minPullAmount
                    self.onPulled(geometry: geo)
                    self.viewModel.status = .none
                    //ComponentLog.d("pulled " +  self.viewModel.status.rawValue + " " + self.bodyOffset.description, tag: "dragCancel")
                    if self.bodyOffset != 0 {
                        self.onDragInit()
                        self.onDragEnd(geometry: geo)
                        return
                    }
                }
                
            case .drag(let geo, let value, let offset) :
                self.onDraging(geometry: geo, value: value, modifyOffset: offset ?? 0)
            case .draged(let geo) : self.onDragEnd(geometry: geo)
            case .dragCancel(let geo) :
                if self.viewModel.status == .none && self.bodyOffset != 0 {
                    self.onDragInit()
                    self.onDragEnd(geometry: geo)
                    return
                }
                if self.viewModel.status != .drag { return }
                self.onDragEnd(geometry: geo)
                
            case .scrollContentRange(let range) :
                self.contentRange = range 
            case .scrollBodyOffset(let offset) :
                self.scrollBodyOffset = offset
            case .scrollTop : self.onScrollTop()
            case .scrollBottom : self.onScrollBottom()
            default : do {}
            }
        }
        .onAppear(){
            self.pullOffset = self.minPullAmount
        }
        .onDisappear(){
            
        }
    }//body
    

    func onScrollInit() {
        self.isScrollInit = true
        self.isScrolling = true
        self.scrollStartTime = Date().timeIntervalSince1970
        self.viewModel.event = .scrollInit
    }
    
    func onScrollTransaction() {
        self.isBodyDraging = true
    }
    
    func onScrollingAction(offset: CGFloat) {
        self.gestureOffset = offset
        self.viewModel.event = .scroll(offset + self.scrollOffset)
    }
    
    func onScrollEndAction(verticalOffset: CGFloat, gestureOffset: CGFloat) {
        self.isScrolling = false
        self.scrollOffset = verticalOffset
        self.gestureOffset = gestureOffset
        self.isBodyDraging = false
        self.viewModel.event = .scrolled(verticalOffset + gestureOffset)
    }
    
    func onDragInit() {
        if self.isDragingCompleted {return}
        self.isDraging = true
        self.viewModel.event = .dragInit
        self.viewModel.status = .drag
    }
    
    func onDragingAction(offset: CGFloat, dragOpacity: Double) {
        if self.isDragingCompleted {return}
        let diff = abs(self.bodyOffset - offset)
        //DataLog.d("diff " + diff.description, tag: "DIFF")
        if abs(diff) > 100 { return }
        //if abs(diff) < PageDragingModel.MIN_DRAG_RANGE { self.bodyOffset = offset }
        //else { withAnimation{ self.bodyOffset = offset } }
        self.bodyOffset = offset
        self.viewModel.event = .drag(offset, dragOpacity)
        self.pagePresenter.dragOpercity = dragOpacity
    }

    func onDragEndAction(isBottom: Bool, offset: CGFloat) {
        if self.isDragingCompleted {return}
        if !self.isDraging { return }
        self.viewModel.status = .none
        self.isDraging = false
        withAnimation{
            if !isBottom {
                self.bodyOffset = 0
                self.scrollOffset = 0
                self.gestureOffset = 0
            }
        }
        self.viewModel.event = .draged(isBottom, offset)
        if isBottom {
            self.isDragingCompleted = true
            self.pagePresenter.goBack()
        }
    }
    
            
}








