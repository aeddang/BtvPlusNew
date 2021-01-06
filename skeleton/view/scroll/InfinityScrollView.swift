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
    let isRecycle: Bool
   
    init(
        viewModel: InfinityScrollModel,
        axes: Axis.Set = .vertical,
        showIndicators: Bool = false,
        marginVertical: CGFloat = Dimen.margin.regular,
        marginHorizontal: CGFloat = Dimen.margin.regular,
        spacing: CGFloat = Dimen.margin.lightExtra,
        isRecycle:Bool = true,
        @ViewBuilder content: () -> Content) {
        
        self.viewModel = viewModel
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content()
        self._marginVertical = .constant(marginVertical)
        self._marginHorizontal = .constant(marginHorizontal)
        self._spacing = .constant(spacing)
        self.isRecycle = isRecycle
    }
    
    init(
        viewModel: InfinityScrollModel,
        axes: Axis.Set = .vertical,
        showIndicators: Bool = false,
        marginVertical: Binding<CGFloat> = .constant(Dimen.margin.regular),
        marginHorizontal: Binding<CGFloat> = .constant(Dimen.margin.regular),
        spacing: Binding<CGFloat> = .constant(Dimen.margin.lightExtra),
        isRecycle:Bool = true,
        @ViewBuilder content: () -> Content) {
        
        self.viewModel = viewModel
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content()
        self._marginVertical = marginVertical
        self._marginHorizontal = marginHorizontal
        self._spacing = spacing
        self.isRecycle = isRecycle
    }
    
    init(
        viewModel: InfinityScrollModel,
        @ViewBuilder content: () -> Content) {
        self.viewModel = viewModel
        self.axes = .vertical
        self.showIndicators = false
        self.content = content()
        self._marginVertical = .constant(0)
        self._marginHorizontal = .constant(0)
        self._spacing = .constant(0)
        self.isRecycle = false
    }
    var body: some View {
       //GeometryReader { outsideProxy in
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
                
                if self.axes == .vertical {
                   if self.isRecycle {
                        List {
                            if self.isTracking {
                                GeometryReader { insideProxy in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset( insideProxy: insideProxy)])
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
                    }else{
                        ScrollView(.vertical, showsIndicators: false) {
                            ZStack(alignment: .topLeading) {
                                if self.isTracking {
                                    GeometryReader { insideProxy in
                                        Color.clear
                                            .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset( insideProxy: insideProxy)])
                                    }
                                }
                                VStack (spacing:self.spacing){
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
                    }
                }else{
                    ScrollView(.horizontal, showsIndicators: false) {
                        ZStack(alignment: .leading) {
                            if self.isTracking {
                                GeometryReader { insideProxy in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(insideProxy: insideProxy)])
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
                }
            }
        //}
    }
    
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
        if  !self.isTracking { return }
        let contentOffset = value[0]
        //ComponentLog.d("onPreferenceChange " + contentOffset.description, tag: self.tag)
        self.onMove(pos: contentOffset)
        self.prevPosition = contentOffset
    }
    
    private func calculateContentOffset(insideProxy: GeometryProxy) -> CGFloat {
        if axes == .vertical {
            return insideProxy.frame(in: .named(self.tag)).minY
        } else {
            return insideProxy.frame(in: .named(self.tag)).minX
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
