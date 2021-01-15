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
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    @State var prevPosition: CGFloat = 0
    @State var isTracking = false
    let axes: Axis.Set
    let showIndicators: Bool
    let content: Content
    
    @Binding var marginVertical: CGFloat
    @Binding var marginHorizontal: CGFloat
    @Binding var spacing: CGFloat
    var useTracking:Bool
    var parentProxy:GeometryProxy? = nil
    let isRecycle: Bool
    
    init(
        viewModel: InfinityScrollModel,
        axes: Axis.Set = .vertical,
        showIndicators: Bool = false,
        marginVertical: CGFloat = Dimen.margin.regular,
        marginHorizontal: CGFloat = Dimen.margin.regular,
        spacing: CGFloat = Dimen.margin.lightExtra,
        parentProxy:GeometryProxy? = nil,
        isRecycle:Bool = true,
        useTracking:Bool = true,
        @ViewBuilder content: () -> Content) {
        
        self.viewModel = viewModel
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content()
        self._marginVertical = .constant(marginVertical)
        self._marginHorizontal = .constant(marginHorizontal)
        self._spacing = .constant(spacing)
        self.parentProxy = parentProxy
        self.isRecycle = isRecycle
        self.useTracking = useTracking
    }
    
    init(
        viewModel: InfinityScrollModel,
        axes: Axis.Set = .vertical,
        showIndicators: Bool = false,
        marginVertical: Binding<CGFloat> = .constant(Dimen.margin.regular),
        marginHorizontal: Binding<CGFloat> = .constant(Dimen.margin.regular),
        spacing: Binding<CGFloat> = .constant(Dimen.margin.lightExtra),
        parentProxy:GeometryProxy? = nil,
        isRecycle:Bool = true,
        useTracking:Bool = true,
        @ViewBuilder content: () -> Content) {
        
        self.viewModel = viewModel
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content()
        self._marginVertical = marginVertical
        self._marginHorizontal = marginHorizontal
        self.parentProxy = parentProxy
        self._spacing = spacing
        self.isRecycle = isRecycle
        self.useTracking = useTracking
    }
    
    init(
        viewModel: InfinityScrollModel,
        parentProxy:GeometryProxy? = nil,
        useTracking:Bool = true,
        @ViewBuilder content: () -> Content) {
        self.viewModel = viewModel
        
        self.axes = .vertical
        self.showIndicators = false
        self.content = content()
        self.parentProxy = parentProxy
        self._marginVertical = .constant(0)
        self._marginHorizontal = .constant(0)
        self._spacing = .constant(0)
        self.isRecycle = false
        self.useTracking = useTracking
    }
    var body: some View {
        if #available(iOS 14.0, *) {
            ScrollView(self.axes, showsIndicators: self.showIndicators) {
                ZStack(alignment: self.axes == .vertical ? .top : .leading) {
                    if self.isTracking {
                        GeometryReader { insideProxy in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(insideProxy: insideProxy)])
                        }
                    }
                    if self.axes == .vertical {
                        if self.isRecycle {
                            LazyVStack(alignment: .leading, spacing: self.spacing){
                                self.content
                            }
                            .padding(.vertical, self.marginVertical)
                            .padding(.horizontal, self.marginHorizontal)
                        } else {
                            VStack(alignment: .leading, spacing: self.spacing){
                                self.content
                            }
                            .padding(.vertical, self.marginVertical)
                            .padding(.horizontal, self.marginHorizontal)
                        }
                    }else{
                        if self.isRecycle {
                            LazyHStack (alignment: .top, spacing: self.spacing){
                                self.content
                            }
                            .padding(.vertical, self.marginVertical)
                            .padding(.horizontal, self.marginHorizontal)
                        } else {
                            HStack (alignment: .top, spacing: self.spacing){
                                self.content
                            }
                            .padding(.vertical, self.marginVertical)
                            .padding(.horizontal, self.marginHorizontal)
                        }
                    }
                }
            }
            .coordinateSpace(name: self.tag)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                self.onPreferenceChange(value: value)
            }
            .onAppear(){
                self.isTracking = true
            }
        }else{
            GeometryReader { outsideProxy in
            if self.axes == .vertical {
               if self.isRecycle {
                    List {
                        if self.isTracking {
                            GeometryReader { insideProxy in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self,
                                        value: [self.calculateContentOffset(
                                            insideProxy: insideProxy,outsideProxy: outsideProxy)])
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
                }else{
                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack(alignment: .topLeading) {
                            if self.isTracking {
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
                    }
                    .onDisappear{
                        self.isTracking = false
                    }
                }
            }else{
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack(alignment: .leading) {
                        if self.isTracking {
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
                }
                .onDisappear{
                    self.isTracking = false
                }
            }
            
        }//if
        }
    }//body
    
    /*
    @GestureState private var dragOffset: CGFloat = -100
    var drag: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            
            .updating($dragOffset) { (value, gestureState, transaction) in
                let delta = value.location.x - value.startLocation.x
                if delta > 10 { // << some appropriate horizontal threshold here
                    gestureState = delta
                }
            }
            
            .onChanged { state in
                print("changing")
            }
            .onEnded { state in
                print("ended")
            }
      }
    */
    private func onPreferenceChange(value:[CGFloat]){
        if  !self.useTracking { return }
        let contentOffset = value[0]
        //ComponentLog.d("onPreferenceChange " + contentOffset.description, tag: self.tag)
        //if self.prevPosition ==  contentOffset { return }
        self.onMove(pos: contentOffset)
        self.prevPosition = contentOffset
        //ComponentLog.d("onPreferenceChange " + contentOffset.description, tag: "onPreferenceChange")
    }
    
    private func calculateContentOffset(insideProxy: GeometryProxy) -> CGFloat {
        if axes == .vertical {
            return insideProxy.frame(in: .named(self.tag)).minY
        } else {
            return insideProxy.frame(in: .named(self.tag)).minX
        }
    }
    private func calculateContentOffset(insideProxy: GeometryProxy, outsideProxy: GeometryProxy?) -> CGFloat {
        if  !self.useTracking { return 0 }
        let proxy = self.parentProxy ?? outsideProxy
        if let outProxy = proxy?.frame(in: .global) {
            if axes == .vertical {
                return  insideProxy.frame(in: .global).minY - outProxy.minY
            } else {
                return insideProxy.frame(in: .global).minX - outProxy.minX
            }
        }else{
            return self.calculateContentOffset(insideProxy: insideProxy)
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