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

struct ScrollList<Content>: PageView where Content: View {
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
    var bgColor:Color //List only
    var isAlignCenter:Bool = false
    let isRecycle: Bool
    let onReady:()->Void
    let onMove:(CGFloat)->Void
    
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
        bgColor:Color,
        onReady:@escaping ()->Void,
        onMove:@escaping (CGFloat)->Void,
        content: Content) {
        
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
        self.bgColor = bgColor
        self.onReady = onReady
        self.onMove = onMove
        self.scrollType = scrollType
    }
    
    private func getHeader()-> some View {
        return VStack( spacing: 0){
            if self.marginTop > Dimen.margin.regular {
                Spacer()
                    .modifier(MatchHorizontal(height: self.marginTop))
                    
            }
            if let header = self.header {
                header.contentBody
                    .modifier(MatchHorizontal(height: self.headerSize))
            }
        }
    }
    
   
    var body: some View {
        if self.axes == .vertical {
            if self.isRecycle {
                List{
                    self.getHeader().modifier(ListRowInset(spacing: 0))
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
                .background(self.bgColor)
                .padding(.leading, self.marginStart)
                .padding(.trailing, self.marginEnd)
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
                            .padding(.leading, self.marginStart)
                            .padding(.trailing, self.marginEnd)
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
                    .padding(.leading, self.marginStart)
                    .padding(.trailing, self.marginEnd)
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
        self.onMove(contentOffset) 
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


