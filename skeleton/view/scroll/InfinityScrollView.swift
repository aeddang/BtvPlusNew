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
    var contentNum: Int = -1
    var header:PageViewProtocol? = nil
    var headerSize: CGFloat = 0
    var marginTop: CGFloat
    var marginBottom: CGFloat
    var marginStart: CGFloat
    var marginEnd: CGFloat
    var spacing: CGFloat
    var useTracking:Bool
    var useTopButton:Bool
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
        showIndicators: Bool = true,
        contentSize : CGFloat = -1,
        contentNum :Int = -1,
        header:PageViewProtocol? = nil,
        headerSize: CGFloat = 0,
        marginVertical: CGFloat = 0,
        marginTop: CGFloat = 0,
        marginBottom: CGFloat = 0,
        marginHorizontal: CGFloat = 0,
        marginStart: CGFloat = 0,
        marginEnd: CGFloat = 0,
        isAlignCenter:Bool = false,
        spacing: CGFloat = 0,
        isRecycle:Bool = true,
        useTracking:Bool = true,
        useTopButton:Bool = true,
        bgColor:Color = SystemEnvironment.currentPageType == .btv ? Color.brand.bg : Color.kids.bg,
        @ViewBuilder content: () -> Content) {
        
        self.viewModel = viewModel
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content()
        self.header = header
        self.headerSize = header != nil ? headerSize : 0
        self.contentSize = contentSize
        self.contentNum = contentNum
        self.marginTop = marginTop + marginVertical
        self.marginBottom = marginBottom + marginVertical
        self.marginStart = marginStart + marginHorizontal
        self.marginEnd = marginEnd + marginHorizontal
        self.isAlignCenter = isAlignCenter
        self.spacing = spacing
        self.isRecycle = isRecycle
        self.useTracking = useTracking
        self.bgColor = bgColor
        self.useTopButton = useTopButton
        self.scrollType = scrollType ?? ( self.axes == .vertical ? .vertical(isDragEnd: false) : .horizontal(isDragEnd: false) )
        if !viewModel.isSetup {
            viewModel.setup(type: self.scrollType)
        }
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
        self.marginStart = 0
        self.marginEnd = 0
        self.spacing = 0
        self.isRecycle = false
        self.useTracking = false
        self.useTopButton = false
        self.bgColor = bgColor
        self.scrollType = scrollType ?? ( self.axes == .vertical ? .vertical(isDragEnd: false) : .horizontal(isDragEnd: false) )
        if !viewModel.isSetup {
            viewModel.setup(type: self.scrollType)
        }
    }
    
    var body: some View {
        if self.viewModel.limitedScrollIndex != -1
            && self.contentNum <= self.viewModel.limitedScrollIndex
            && self.header == nil
        {
            ZStack(alignment: .leading){
                LazyVStack(alignment: self.isAlignCenter ? .center : .leading, spacing: self.spacing){
                    self.content
                }
                .padding(.top, self.marginTop)
            }
            .frame(alignment: .leading)
            .modifier(MatchParent())
            .onReceive(self.sceneObserver.$isUpdated){update in
                if update {
                    self.viewModel.setup(scrollSize: self.sceneObserver.screenSize)
                }
            }
            .onAppear{
                self.viewModel.setup(scrollSize: self.sceneObserver.screenSize)
            }
                    
        } else {
            if #available(iOS 14.0, *) {
                ScrollLazeStack(
                    viewModel: self.viewModel,
                    axes: self.axes,
                    scrollType: self.scrollType,
                    showIndicators: self.showIndicators,
                    contentSize: self.contentSize,
                    header: self.header,
                    headerSize: self.headerSize,
                    marginTop: self.marginTop,
                    marginBottom: self.marginBottom,
                    marginStart: self.marginStart,
                    marginEnd: self.marginEnd,
                    isAlignCenter: self.isAlignCenter,
                    spacing: self.spacing,
                    isRecycle: self.isRecycle,
                    useTracking: self.useTracking,
                    onTopButton:
                        self.useTopButton
                        ? SystemEnvironment.currentPageType == .btv ? Asset.icon.onTop : AssetKids.icon.onTop
                        : nil,
                    onTopButtonSize : SystemEnvironment.currentPageType == .btv
                        ? InfinityScrollModel.onTopSize
                        : InfinityScrollModel.onTopSizeKids,
                    
                    onTopButtonMargin : SystemEnvironment.currentPageType == .btv ? Dimen.margin.light : 0,
                    onReady: {self.onReady()},
                    onMove: {pos in self.onMove(pos:pos)},
                    content: self.content)
                    .onReceive(self.sceneObserver.$isUpdated){update in
                        if update {
                            self.viewModel.setup(scrollSize: self.sceneObserver.screenSize)
                        }
                    }
                    .onAppear{
                        self.viewModel.setup(scrollSize: self.sceneObserver.screenSize)
                    }
            }else{
                ScrollList(
                    viewModel: self.viewModel,
                    axes: self.axes,
                    scrollType: self.scrollType,
                    showIndicators: self.showIndicators,
                    contentSize: self.contentSize,
                    header: self.header,
                    headerSize: self.headerSize,
                    marginTop: self.marginTop,
                    marginBottom: self.marginBottom,
                    marginStart: self.marginStart,
                    marginEnd: self.marginEnd,
                    isAlignCenter: self.isAlignCenter,
                    spacing: self.spacing,
                    isRecycle: self.isRecycle,
                    useTracking: self.useTracking,
                    bgColor: self.bgColor,
                    onReady: {self.onReady()},
                    onMove: {pos in self.onMove(pos:pos)},
                    content: self.content)
            }
        }
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
