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
    
    let marginVertical: CGFloat
    let marginHorizontal: CGFloat
    let spacing: CGFloat
   
    init(
        viewModel: InfinityScrollModel,
        axes: Axis.Set = .vertical,
        showIndicators: Bool = false,
        marginVertical: CGFloat = Dimen.margin.regular,
        marginHorizontal: CGFloat = Dimen.margin.regular,
        spacing: CGFloat = Dimen.margin.lightExtra,
        @ViewBuilder content: () -> Content) {
        
        self.viewModel = viewModel
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content()
        self.marginVertical = marginVertical
        self.marginHorizontal = marginHorizontal
        self.spacing = spacing
    }

    var body: some View {
        GeometryReader { outsideProxy in
            if #available(iOS 14.0, *) {
                ScrollView(self.axes, showsIndicators: self.showIndicators) {
                    ZStack(alignment: self.axes == .vertical ? .top : .leading) {
                        if self.isTracking {
                            GeometryReader { insideProxy in
                                Color.clear.preference(
                                    key: OffsetKey.self,
                                    value: self.calculateContentOffset(fromOutsideProxy: outsideProxy, insideProxy: insideProxy))
                            }
                        }
                        if self.axes == .vertical {
                            LazyVStack(alignment: .leading, spacing: self.spacing){
                                self.content
                            }
                            .padding(.vertical, self.marginVertical)
                            .padding(.horizontal, self.marginHorizontal)
                        }else{
                            LazyHStack (alignment: .top, spacing: self.spacing){
                                self.content
                            }
                            .padding(.vertical, self.marginVertical)
                            .padding(.horizontal, self.marginHorizontal)
                        }
                    }
                }
                .coordinateSpace(name: self.tag)
                .onPreferenceChange(OffsetKey.self) { value in
                    self.onPreferenceChange(value: value)
                }
                .onAppear(){
                    self.isTracking = true
                }
                
            }else{
                if self.axes == .vertical {
                    ZStack(alignment: .top){
                        List {
                            if self.isTracking {
                                GeometryReader { insideProxy in
                                    Color.clear.preference(
                                        key: OffsetKey.self,
                                        value: insideProxy.frame(in: .named(self.tag)).minY)
                                }
                            }
                            self.content
                            .padding(.vertical, self.marginVertical)
                            .padding(.horizontal, self.marginHorizontal)
                        }
                    }
                    .coordinateSpace(name: self.tag)
                    .onPreferenceChange(OffsetKey.self) { value in
                        self.onPreferenceChange(value: value)
                    }
                    .onAppear(){
                        self.isTracking = true
                        UITableView.appearance().separatorStyle = .none
                    }
                }else{
                    ScrollView(.horizontal, showsIndicators: false) {
                        ZStack(alignment: .leading) {
                            HStack(spacing:self.spacing){
                                self.content
                            }
                            if self.isTracking {
                                GeometryReader { insideProxy in
                                    Color.clear.preference(
                                        key: OffsetKey.self,
                                        value: insideProxy.frame(in: .named(self.tag)).minX)
                                }
                            }
                        }
                    }
                    .coordinateSpace(name: self.tag)
                    .onPreferenceChange(OffsetKey.self) { value in
                        self.onPreferenceChange(value: value)
                    }
                    .onAppear(){
                        self.isTracking = true
                    }
                }
            }
        }
    }

    private func onPreferenceChange(value:CGFloat){
        if  !self.isTracking { return }
        let contentOffset = value
        self.onMove(pos: contentOffset)
        self.prevPosition = contentOffset
    }
    
    private func calculateContentOffset(fromOutsideProxy outsideProxy: GeometryProxy, insideProxy: GeometryProxy) -> CGFloat {
            if axes == .vertical {
                return insideProxy.frame(in: .named(self.tag)).minY
            } else {
                return insideProxy.frame(in: .named(self.tag)).minX
            }
    }
}


