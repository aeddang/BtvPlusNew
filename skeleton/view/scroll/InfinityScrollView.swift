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

struct InfinityScrollView<Content>: PageView, InfinityScrollViewProtocol where Content: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var viewModel: InfinityScrollModel
    let axes: Axis.Set 
    let showIndicators: Bool
    let content: Content
    var contentSize: CGFloat = -1
    var header:PageViewProtocol? = nil
    var headerSize: CGFloat = 0
    var marginTop: CGFloat
    var marginBottom: CGFloat
    var marginHorizontal: CGFloat
    var spacing: CGFloat
    var useTracking:Bool
    var scrollType:InfinityScrollType = .reload(isDragEnd: false)
    var bgColor:Color //List only
    var isAlignCenter:Bool = false
    let isRecycle: Bool
    
    @State var isTop:Bool = true
    @State var scrollPos:Float? = nil
    @State var scrollIdx:Int? = nil
    @State var isTracking = false
    @State var anchor:UnitPoint? = nil
    @State var isScroll:Bool = true
    
    @State var progress:Double = 1
    @State var progressMax:Double = 1
     
    init(
        viewModel: InfinityScrollModel,
        axes: Axis.Set = .vertical,
        scrollType:InfinityScrollType? = nil,
        showIndicators: Bool = false,
        contentSize : CGFloat = -1,
        header:PageViewProtocol? = nil,
        headerSize: CGFloat = 0,
        marginVertical: CGFloat = 0,
        marginTop: CGFloat = 0,
        marginBottom: CGFloat = 0,
        marginHorizontal: CGFloat = 0,
        isAlignCenter:Bool = false,
        spacing: CGFloat = 0,
        isRecycle:Bool = true,
        useTracking:Bool = true,
        bgColor:Color = SystemEnvironment.currentPageType == .btv ? Color.brand.bg : Color.kids.bg,
        @ViewBuilder content: () -> Content) {
        
        self.viewModel = viewModel
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content()
        self.header = header
        self.headerSize = header != nil ? headerSize : 0
        self.contentSize = contentSize
        self.marginTop = marginTop + marginVertical
        self.marginBottom = marginBottom + marginVertical
        self.marginHorizontal = marginHorizontal
        self.isAlignCenter = isAlignCenter
        self.spacing = spacing
        self.isRecycle = isRecycle
        self.useTracking = useTracking
        self.bgColor = bgColor
        self.scrollType = scrollType ?? ( self.axes == .vertical ? .vertical(isDragEnd: false) : .horizontal(isDragEnd: false) )
        viewModel.setup(type: self.scrollType)
    }
    
    init(
        viewModel: InfinityScrollModel,
        axes: Axis.Set = .vertical,
        scrollType:InfinityScrollType? = nil,
        bgColor:Color = SystemEnvironment.currentPageType == .btv ? Color.brand.bg : Color.kids.bg,
        @ViewBuilder content: () -> Content) {
        
        self.viewModel = viewModel
        self.axes = axes
        self.showIndicators = false
        self.content = content()
        self.marginTop = 0
        self.marginBottom = 0
        self.marginHorizontal = 0
        self.spacing = 0
        self.isRecycle = false
        self.useTracking = false
        self.bgColor = bgColor
        self.scrollType = scrollType ?? ( self.axes == .vertical ? .vertical(isDragEnd: false) : .horizontal(isDragEnd: false) )
        viewModel.setup(type: self.scrollType)

    }
    var body: some View {
        if #available(iOS 14.0, *) {
            ScrollViewReader{ reader in
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
                                .padding(.bottom, self.marginBottom)
                                .padding(.horizontal, self.marginHorizontal)
                            } else {
                                VStack(alignment: self.isAlignCenter ? .center : .leading, spacing: self.spacing){
                                    self.content
                                }
                                .padding(.top, self.marginTop + self.headerSize)
                                .padding(.bottom, self.marginBottom)
                                .padding(.horizontal, self.marginHorizontal)
                            }
                            if let header = self.header {
                                header.contentBody
                                    .padding(.top, self.marginTop)
                                    
                            }
                        }
                        //.frame(alignment: .topLeading)
                        
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
                                .padding(.leading, self.marginHorizontal + self.headerSize)
                                .padding(.trailing, self.marginHorizontal)
                                
                            } else {
                                HStack (alignment: self.isAlignCenter ? .center : .top, spacing: self.spacing){
                                    self.content
                                }
                                .padding(.top, self.marginTop)
                                .padding(.bottom, self.marginBottom)
                                .padding(.leading, self.marginHorizontal + self.headerSize)
                                .padding(.trailing, self.marginHorizontal)
                            }
                            if let header = self.header {
                                header.contentBody
                                    .padding(.leading, self.marginHorizontal)
                                    
                            }
                        }
                        //.frame(alignment: .topLeading)
                        
                    }
                }
                .modifier(MatchParent())
                .opacity(self.progress / self.progressMax)
                .coordinateSpace(name: self.tag)
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.onPreferenceChange(value: value)
                }
                .onChange(of: self.scrollPos, perform: { pos in
                    guard let pos = pos else {return}
                    reader.scrollTo(pos)
                })
                .onChange(of: self.scrollIdx, perform: { idx in
                    guard let idx = idx else {return}
                    reader.scrollTo(idx, anchor: anchor)
                })
                .onReceive(self.viewModel.$scrollStatus){ stat in
                    if self.scrollType != .web() {return}
                    switch stat  {
                    case .pull :
                        self.isScroll = false
                    default: break
                    }
                }
                .onReceive(self.viewModel.$event){ evt in
                    guard let evt = evt else{ return }
                    self.onTopChange(evt: evt)
                    
                    switch evt  {
                    case .pullCancel : withAnimation{ self.progress = self.progressMax }
                    case .pullCompleted : withAnimation{ self.progress = self.scrollType == .reload() ? self.progressMax : 0 }
                    default: break
                    }
                    
                    if self.scrollType != .web() {return}
                    switch evt  {
                    case .pullCompleted, .pullCancel :
                        self.isScroll = true
                        self.onMove(pos: 1)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.onMove(pos: 0)
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
                        self.scrollIdx = idx
                    case .scrollMove(let pos, let anchor):
                        self.anchor = anchor
                        self.scrollPos = pos
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
            
        }else{
            if self.axes == .vertical {
                if self.isRecycle {
                    List{
                        if self.marginTop > Dimen.margin.regular {
                            Spacer()
                                .modifier(MatchHorizontal(height: self.marginTop))
                                .modifier(ListRowInset(spacing: 0))
                        }
                        if let header = self.header {
                            header.contentBody
                                .modifier(MatchHorizontal(height: self.headerSize))
                                .modifier(ListRowInset(spacing: 0))
                        }
                        if self.isAlignCenter {
                            self.content
                                .modifier(LayoutCenter())
                        } else {
                            self.content
                        }
                        Spacer()
                            .modifier(MatchHorizontal(height: self.marginBottom))
                            .modifier(ListRowInset(spacing: 0))
                    }
                    .padding(.horizontal, self.marginHorizontal)
                    .listStyle(PlainListStyle())
                    .background(self.bgColor)
                    .modifier(MatchParent())
                    .onReceive(self.viewModel.$event){evt in
                        self.onTopChange(evt: evt)
                    }
                    .onAppear(){
                        UITableView.appearance().allowsSelection = false
                        UITableViewCell.appearance().selectionStyle = .none
                        UITableView.appearance().backgroundColor = self.bgColor.uiColor()
                        UITableView.appearance().separatorStyle = .none
                        UITableView.appearance().separatorColor = .clear
                        self.onReady()
                    }
                    
                } else{
                    GeometryReader { outsideProxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            ZStack(alignment: self.isAlignCenter ? .top : .topLeading) {
                                if self.useTracking && self.isTracking{
                                    GeometryReader { insideProxy in
                                        Color.clear
                                            .preference(key: ScrollOffsetPreferenceKey.self,
                                                value: [self.calculateContentOffset(
                                                    insideProxy: insideProxy, outsideProxy: outsideProxy)])
                                    }
                                }
                                VStack (alignment:self.isAlignCenter ? .center : .leading, spacing:self.spacing){
                                    if let header = self.header {
                                        header.contentBody
                                    }
                                    self.content
                                }
                                .padding(.top, self.marginTop)
                                .padding(.bottom, self.marginBottom)
                                .padding(.horizontal, self.marginHorizontal)
                                
                                
                            }
                        }
                        .frame(width:outsideProxy.size.width)
                        .coordinateSpace(name: self.tag)
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            self.onPreferenceChange(value: value)
                        }
                        .onReceive(self.viewModel.$event){evt in
                            self.onTopChange(evt: evt)
                        }
                        .onAppear(){
                            self.isTracking = true
                            self.onReady()
                            
                        }
                        .onDisappear{
                            self.isTracking = false
                        }
                    }
                }
                
                
            }else{
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack(alignment: .leading) {
                        HStack(alignment:self.isAlignCenter ? .center : .top, spacing:self.spacing){
                            if let header = self.header {
                                header.contentBody
                            }
                            self.content
                        }
                        .padding(.top, self.marginTop)
                        .padding(.bottom, self.marginBottom)
                        .padding(.leading, self.marginHorizontal)
                        .padding(.trailing, self.marginHorizontal)
                    }
                }
                .coordinateSpace(name: self.tag)
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.onPreferenceChange(value: value)
                }
                .onAppear(){
                    self.onReady()
                }
            }
        }//if
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
        //ComponentLog.d("onPreferenceChange " + self.viewModel.idstr, tag: "InfinityScrollViewProtocol" + self.viewModel.idstr)
        self.onMove(pos: contentOffset)
    }
    
    private func calculateContentOffset(insideProxy: GeometryProxy) -> CGFloat {
        if axes == .vertical {
            return insideProxy.frame(in: .named(self.tag)).minY
        } else {
            return insideProxy.frame(in: .named(self.tag)).minX
        }
    }
    private func calculateContentOffset(insideProxy: GeometryProxy, outsideProxy: GeometryProxy) -> CGFloat {
        let outProxy = outsideProxy.frame(in: .global)
        if axes == .vertical {
            return insideProxy.frame(in: .global).minY - outProxy.minY
        } else {
            return insideProxy.frame(in: .global).minX - outProxy.minX
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]
    static var defaultValue: [CGFloat] = [0]
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

