//
//  InfinityScrollView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/25.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Introspect
struct ScrollLazeStack<Content>: PageView where Content: View {
    var viewModel: InfinityScrollModel
    let axes: Axis.Set
    let showIndicators: Bool
    let content: Content
    var contentSize: CGFloat = -1
    var header:PageViewProtocol? = nil
    var headerSize: CGFloat = 0
    var marginTop: CGFloat
    var marginBottom: CGFloat
    var marginStart: CGFloat
    var marginEnd: CGFloat
    var spacing: CGFloat
    var useTracking:Bool
    var scrollType:InfinityScrollType = .reload(isDragEnd: false)
    var isAlignCenter:Bool = false
    let isRecycle: Bool
    var onTopButton: String? = nil
    var onTopButtonSize: CGSize = CGSize(width: 0, height: 0)
    var onTopButtonMargin:CGFloat = 0
    let onReady:()->Void
    let onMove:(CGFloat)->Void
    
    @State var isTop:Bool = true
    @State var scrollIdx:Int? = nil
    @State var isTracking = false
    @State var anchor:UnitPoint? = nil
    @State var isSmothMove:Bool = false
    @State var isScroll:Bool = true
    @State var progress:Double = 1
    @State var progressMax:Double = 1
 
    init(
        viewModel:InfinityScrollModel,
        axes: Axis.Set,
        scrollType:InfinityScrollType,
        showIndicators: Bool,
        contentSize : CGFloat,
        header:PageViewProtocol?,
        headerSize: CGFloat,
        marginTop: CGFloat,
        marginBottom: CGFloat,
        marginStart: CGFloat,
        marginEnd: CGFloat,
        isAlignCenter:Bool,
        spacing: CGFloat,
        isRecycle:Bool,
        useTracking:Bool,
        onTopButton: String?,
        onTopButtonSize: CGSize,
        onTopButtonMargin:CGFloat,
        onReady:@escaping ()->Void,
        onMove:@escaping (CGFloat)->Void,
        content:Content) {
        
        self.viewModel = viewModel
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content
        self.header = header
        self.headerSize = header != nil ? headerSize : 0
        self.contentSize = contentSize
        self.marginTop = marginTop
        self.marginBottom = marginBottom
        self.marginStart = marginStart
        self.marginEnd = marginEnd
        self.isAlignCenter = isAlignCenter
        self.spacing = spacing
        self.isRecycle = isRecycle
        self.useTracking = useTracking
        self.onReady = onReady
        self.onMove = onMove
       
        self.onTopButton = onTopButton
        self.onTopButtonSize = onTopButtonSize
        self.onTopButtonMargin = onTopButtonMargin
        self.scrollType = scrollType 
    }
        
    var body: some View {
        if #available(iOS 14.0, *) {
            
            ScrollViewReader{ reader in
                ZStack(alignment:.bottomTrailing){
                    ScrollView(self.isScroll ? self.axes : [], showsIndicators: self.showIndicators) {
                        if self.axes == .vertical {
                            ZStack(alignment: self.isAlignCenter ? .top : .topLeading){
                                if self.useTracking {
                                    GeometryReader { insideProxy in
                                        Color.clear
                                            .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(insideProxy: insideProxy)])
                                    }
                                }
                                if self.isRecycle {
                                    LazyVStack(alignment: self.isAlignCenter ? .center : .leading, spacing: self.spacing){
                                        self.content
                                    }
                                    .padding(.top, self.marginTop + self.headerSize)
                                    .padding(.bottom, self.marginBottom + self.onTopButtonSize.height)
                                    .padding(.leading, self.marginStart)
                                    .padding(.trailing, self.marginEnd)
                                } else {
                                    VStack(alignment: self.isAlignCenter ? .center : .leading, spacing: self.spacing){
                                        self.content
                                    }
                                    .padding(.top, self.marginTop + self.headerSize)
                                    .padding(.bottom, self.marginBottom + self.onTopButtonSize.height)
                                    .padding(.leading, self.marginStart)
                                    .padding(.trailing, self.marginEnd)
                                }
                                if let header = self.header {
                                    header.contentBody
                                        .padding(.top, self.marginTop)
                                }
                                Spacer()
                                    .modifier(MatchHorizontal(height: 1))
                                    .background(Color.transparent.clearUi)
                                    .id(self.viewModel.topIdx)
                            }
                            .frame(alignment: .topLeading)
                            
                        } else {
                            ZStack (alignment: self.isAlignCenter ? .leading : .topLeading) {
                                if self.useTracking {
                                    GeometryReader { insideProxy in
                                        Color.clear
                                            .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(insideProxy: insideProxy)])
                                    }
                                }
                                if self.isRecycle {
                                    LazyHStack (alignment: self.isAlignCenter ? .center : .top, spacing: self.spacing){
                                        self.content
                                    }
                                    .padding(.top, self.marginTop + self.headerSize)
                                    .padding(.bottom, self.marginBottom)
                                    .padding(.leading, self.marginStart + self.headerSize)
                                    .padding(.trailing, self.marginEnd)
                                    
                                } else {
                                    HStack (alignment: self.isAlignCenter ? .center : .top, spacing: self.spacing){
                                        self.content
                                    }
                                    .padding(.top, self.marginTop)
                                    .padding(.bottom, self.marginBottom)
                                    .padding(.leading, self.marginStart + self.headerSize)
                                    .padding(.trailing, self.marginEnd)
                                }
                                if let header = self.header {
                                    header.contentBody
                                        .padding(.leading, self.marginStart)
                                        
                                }
                            }
                            .frame(alignment: .topLeading)
                        }
                    }
                   
                    .modifier(MatchParent())
                    if !self.isTop && self.axes == .vertical && self.scrollType != .web(), let onTopButton = self.onTopButton {
                        VStack{
                            Spacer()
                            HStack{
                                Spacer()
                                Button(action: {
                                    if self.isTop {return}
                                    self.isTop = true
                                    self.viewModel.uiEvent = .scrollMove(self.viewModel.topIdx, .top)
                                    
                                }){
                                    Image(onTopButton)
                                        .renderingMode(.original).resizable()
                                        .scaledToFit()
                                        .frame(
                                            width: self.onTopButtonSize.width,
                                            height: self.onTopButtonSize.height)
                                }
                                .padding(.bottom,  self.marginBottom)
                                .padding(.trailing,  self.onTopButtonMargin)
                            }
                            
                        }
                    }
                }
                .modifier(MatchParent())
                .opacity(self.progress / self.progressMax)
                .coordinateSpace(name: self.tag)
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.onPreferenceChange(value: value)
                }
                .onChange(of: self.scrollIdx, perform: { idx in
                    guard let idx = idx else {return}
                    if idx == -1 {return}
                    if self.isSmothMove {
                        withAnimation{ reader.scrollTo(idx, anchor: anchor)}
                    } else {
                        reader.scrollTo(idx, anchor: anchor)
                    }
                    self.scrollIdx = -1
                })
                .onReceive(self.viewModel.$scrollStatus){ stat in
                    if self.scrollType != .web() {return}
                    switch stat {
                    case .pull :
                        self.isScroll = false
                    default: break
                    }
                }
                .onReceive(self.viewModel.$event){ evt in
                    guard let evt = evt else{ return }
                    self.onTopChange(evt: evt)
                    switch evt {
                    case .pullCancel : withAnimation{ self.progress = self.progressMax }
                    case .pullCompleted : withAnimation{ self.progress = self.scrollType == .reload() ? self.progressMax : 0 }
                    default: break
                    }
                    
                    if self.scrollType != .web() {return}
                    switch evt {
                    case .pullCompleted, .pullCancel :
                        self.isScroll = true
                        self.onMove(1)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.onMove(0)
                        }
                    default: break
                    }
                }
                .onReceive(self.viewModel.$pullPosition){ pos in
                    if pos < self.viewModel.pullRange { return }
                    self.progress = self.progressMax - Double(pos - self.viewModel.pullRange)
                }
                .onReceive(self.viewModel.$uiEvent){ evt in
                    guard let evt = evt else{ return }
                    switch evt {
                    case .scrollTo(let idx, let anchor):
                        self.anchor = anchor
                        self.isSmothMove = false
                        self.scrollIdx = idx
                    case .scrollMove(let idx, let anchor):
                        self.anchor = anchor
                        self.isSmothMove = true
                        self.scrollIdx = idx
                    default: break
                    }
                }
                .onAppear(){
                    let max = Double(viewModel.pullRange + viewModel.pullCompletedRange )
                    self.progress = max
                    self.progressMax = max
                    self.isTracking = true
                    self.onReady()
                }
                .onDisappear{
                    self.isTracking = false
                }
            }
        }//available
    }//body
    
    private func onTopChange(evt:InfinityScrollEvent?){
        guard let evt = evt else {return}
        switch evt {
        case .top :
            if !self.isTop { withAnimation{ self.isTop = true }}
        case .down :
            if self.isTop { withAnimation{ self.isTop = false }}
        case .pull :
            if self.isTop { withAnimation{ self.isTop = false }}
        default : break
        }
    }
    
    private func onPreferenceChange(value:[CGFloat]){
        if !self.useTracking {return}
        let contentOffset = value[0]
        self.onMove(contentOffset)
    }
    
    private func calculateContentOffset(insideProxy: GeometryProxy) -> CGFloat {
        if axes == .vertical {
            return insideProxy.frame(in: .named(self.tag)).minY
        } else {
            return insideProxy.frame(in: .named(self.tag)).minX
        }
    }
}


