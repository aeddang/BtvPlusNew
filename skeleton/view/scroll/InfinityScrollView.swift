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
    @EnvironmentObject var sceneObserver:SceneObserver
    var viewModel: InfinityScrollModel
    let axes: Axis.Set 
    let showIndicators: Bool
    let content: Content
    
    var contentSize: CGFloat = -1
    var marginTop: CGFloat
    var marginBottom: CGFloat
    var marginHorizontal: CGFloat
    var spacing: CGFloat
    var useTracking:Bool
    let isRecycle: Bool
    
    @State var scrollPos:Float? = nil
    @State var scrollIdx:Int? = nil
    
    @State var prevPosition: CGFloat = 0
    @State var isTracking = false
    @State var anchor:UnitPoint? = nil
    init(
        viewModel: InfinityScrollModel,
        axes: Axis.Set = .vertical,
        showIndicators: Bool = false,
        contentSize : CGFloat = -1,
        marginVertical: CGFloat = 0,
        marginTop: CGFloat = 0,
        marginBottom: CGFloat = 0,
        marginHorizontal: CGFloat = 0,
        spacing: CGFloat = 0,
        isRecycle:Bool = true,
        useTracking:Bool = true,
        @ViewBuilder content: () -> Content) {
        
        self.viewModel = viewModel
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content()
        self.contentSize = contentSize
        self.marginTop = marginTop + marginVertical
        self.marginBottom = marginBottom + marginVertical
        self.marginHorizontal = marginHorizontal
        self.spacing = spacing
        self.isRecycle = isRecycle
        self.useTracking = useTracking
    }
    
    init(
        viewModel: InfinityScrollModel,
        @ViewBuilder content: () -> Content) {
        self.viewModel = viewModel
        self.axes = .vertical
        self.showIndicators = false
        self.content = content()
        self.marginTop = 0
        self.marginBottom = 0
        self.marginHorizontal = 0
        self.spacing = 0
        self.isRecycle = false
        self.useTracking = false

    }
    var body: some View {
        if #available(iOS 14.0, *) {
            ScrollView(self.axes, showsIndicators: self.showIndicators) {
                ScrollViewReader{ reader in
                    if self.axes == .vertical {
                        ZStack(alignment: .top) {
                            if self.useTracking {
                                GeometryReader { insideProxy in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(insideProxy: insideProxy)])
                                }
                            }
                            if self.isRecycle {
                                LazyVStack(alignment: .leading, spacing: self.spacing){
                                    self.content
                                }
                                .padding(.top, self.marginTop)
                                .padding(.bottom, self.marginBottom)
                                .padding(.horizontal, self.marginHorizontal)
                            } else {
                                VStack(alignment: .leading, spacing: self.spacing){
                                    self.content
                                }
                                .padding(.top, self.marginTop)
                                .padding(.bottom, self.marginBottom)
                                .padding(.horizontal, self.marginHorizontal)
                            }
                        }
                        .frame(alignment: .top)
                        .onChange(of: self.scrollPos, perform: { pos in
                            guard let pos = pos else {return}
                            reader.scrollTo(pos)
                        })
                        .onChange(of: self.scrollIdx, perform: { idx in
                            guard let idx = idx else {return}
                            reader.scrollTo(idx, anchor: anchor)
                        })
                    
                    } else {
                        ZStack(alignment: .leading) {
                            if self.useTracking {
                                GeometryReader { insideProxy in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(insideProxy: insideProxy)])
                                }
                            }
                            if self.isRecycle {
                                LazyHStack (alignment: .top, spacing: self.spacing){
                                    self.content
                                }
                                .padding(.top, self.marginTop)
                                .padding(.bottom, self.marginBottom)
                                .padding(.horizontal, self.marginHorizontal)
                            } else {
                                HStack (alignment: .top, spacing: self.spacing){
                                    self.content
                                }
                                .padding(.top, self.marginTop)
                                .padding(.bottom, self.marginBottom)
                                .padding(.horizontal, self.marginHorizontal)
                            }
                        }
                        .frame(alignment: .leading)
                        .onChange(of: self.scrollPos, perform: { pos in
                            guard let pos = pos else {return}
                            reader.scrollTo(pos)
                        })
                        .onChange(of: self.scrollIdx, perform: { idx in
                            guard let idx = idx else {return}
                            reader.scrollTo(idx, anchor: anchor)
                        })
                    }
                    
                }
                
            }
            .modifier(MatchParent())
            .coordinateSpace(name: self.tag)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                DispatchQueue.main.async {
                    self.onPreferenceChange(value: value)
                }
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
                DispatchQueue.main.async {
                    self.isTracking = true
                    self.onReady()
                }
            }
            .onDisappear{
                DispatchQueue.main.async {
                    self.isTracking = false
                }
                
            }
        }else{
            GeometryReader { outsideProxy in
                if self.axes == .vertical {
                    if self.isRecycle {
                        List {
                            self.content
                                .padding(.top, self.marginTop)
                            Spacer().modifier(MatchHorizontal(height: self.marginBottom))
                                .modifier(ListRowInset(spacing: 0))
                        }
                        .padding(.horizontal, self.marginHorizontal)
                        .coordinateSpace(name: self.tag)
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            self.onPreferenceChange(value: value)
                        }
                        .listStyle(PlainListStyle())
                        .onAppear(){
                            self.isTracking = true
                            UITableView.appearance().allowsSelection = false
                            UITableView.appearance().backgroundColor = Color.brand.bg.uiColor()
                            UITableView.appearance().separatorStyle = .none
                        }
                        .onDisappear{
                            self.isTracking = false
                        }
                    } else{
                        ScrollView(.vertical, showsIndicators: false) {
                            ZStack(alignment: .topLeading) {
                                if self.useTracking{
                                    GeometryReader { insideProxy in
                                        Color.clear
                                            .preference(key: ScrollOffsetPreferenceKey.self,
                                                value: [self.calculateContentOffset(
                                                    insideProxy: insideProxy, outsideProxy: outsideProxy)])
                                    }
                                }
                                VStack (alignment:.leading, spacing:self.spacing){
                                    self.content
                                }
                                .padding(.top, self.marginTop)
                                .padding(.bottom, self.marginBottom)
                                .padding(.horizontal, self.marginHorizontal)
                            }
                        }
                        .modifier(MatchParent())
                        .coordinateSpace(name: self.tag)
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            self.onPreferenceChange(value: value)
                        }
                        .onAppear(){
                            DispatchQueue.main.async {
                                self.isTracking = true
                                self.onReady()
                            }
                        }
                        .onDisappear{
                            DispatchQueue.main.async {
                                self.isTracking = false
                            }
                            
                        }
                    }
                    
                    
                }else{
                    ScrollView(.horizontal, showsIndicators: false) {
                        ZStack(alignment: .leading) {
                            if self.useTracking{
                                GeometryReader { insideProxy in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self,
                                            value: [self.calculateContentOffset(
                                                insideProxy: insideProxy, outsideProxy: outsideProxy)])
                                }
                            }
                            HStack(spacing:self.spacing){
                                self.content
                            }
                            .padding(.top, self.marginTop)
                            .padding(.bottom, self.marginBottom)
                            .padding(.horizontal, self.marginHorizontal)
                        }
                    }
                    .modifier(MatchParent())
                    .coordinateSpace(name: self.tag)
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        self.onPreferenceChange(value: value)
                    }
                    .onAppear(){
                        DispatchQueue.main.async {
                            self.isTracking = true
                            self.onReady()
                        }
                    }
                    .onDisappear{
                        DispatchQueue.main.async {
                            self.isTracking = false
                        }
                        
                    }
                }
            }//if
        }
    }//body
    
    private func onPreferenceChange(value:[CGFloat]){
        if !self.useTracking {return}
        let contentOffset = value[0]
        if self.prevPosition == contentOffset {return}
        
        DispatchQueue.main.async {
            self.onMove(pos: contentOffset)
            self.prevPosition = contentOffset
        }
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

/*
 List {
     if self.isTracking {
         GeometryReader { insideProxy in
             Color.clear
                 .preference(key: ScrollOffsetPreferenceKey.self,
                     value: [self.calculateContentOffset(
                         insideProxy: insideProxy, outsideProxy: outsideProxy)])
         }
     }
     self.content
     
 }
 .padding(.vertical, self.marginVertical)
 .padding(.horizontal, self.marginHorizontal)
 .coordinateSpace(name: self.tag)
 .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
     self.onPreferenceChange(value: value)
 }
 .onAppear(){
     self.isTracking = true
     UITableView.appearance().separatorStyle = .none
     UITableView.appearance().separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
 }
 .onDisappear{
     self.isTracking = false
 }
 
 
 
 ScrollView(.vertical, showsIndicators: false) {
     ZStack(alignment: .topLeading) {
         if self.isTracking && self.useTracking{
             GeometryReader { insideProxy in
                 Color.clear
                     .preference(key: ScrollOffsetPreferenceKey.self,
                         value: [self.calculateContentOffset(
                             insideProxy: insideProxy, outsideProxy: outsideProxy)])
             }
         }
         VStack (alignment:.leading, spacing:self.spacing){
             self.content
         }
         .padding(.vertical, self.marginVertical)
         .padding(.horizontal, self.marginHorizontal)
     }
 }
 .coordinateSpace(name: self.tag)
 .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
     self.onPreferenceChange(value: value)
     
 }
 .onAppear(){
     self.isTracking = true
     self.onReady()
 }
 .onDisappear{
     self.isTracking = false
 }
 */
