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
    init(
        viewModel: InfinityScrollModel,
        axes: Axis.Set = .vertical,
        showIndicators: Bool = false,
        @ViewBuilder content: () -> Content) {
        
        self.viewModel = viewModel
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content()
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
                            LazyVStack(alignment: .leading, spacing: 0){
                                self.content
                            }
                        }else{
                            LazyHStack (alignment: .top, spacing: 0){
                                self.content
                            }
                        }
                    }
                }
                .coordinateSpace(name: self.tag)
                .onPreferenceChange(OffsetKey.self) { value in
                    if  !self.isTracking { return }
                    let contentOffset = value
                    self.onMove(pos: contentOffset)
                    self.prevPosition = contentOffset
                }
                .onAppear(){
                    self.isTracking = true
                }
                
            }else{
                ZStack(alignment: self.axes == .vertical ? .top : .leading) {
                    List{
                       self.content
                    }
                    if self.isTracking {
                        GeometryReader { insideProxy in
                            Color.clear.preference(
                                key: OffsetKey.self,
                                value: insideProxy.frame(in: .named(self.tag)).minY)
                        }
                    }
                }
                .coordinateSpace(name: self.tag)
                .onPreferenceChange(OffsetKey.self) { value in
                    if  !self.isTracking { return }
                    let contentOffset = value
                    self.onMove(pos: contentOffset)
                    self.prevPosition = contentOffset
                }
                .onAppear(){
                    self.isTracking = true
                }
            }
        }
    }

    private func calculateContentOffset(fromOutsideProxy outsideProxy: GeometryProxy, insideProxy: GeometryProxy) -> CGFloat {
            if axes == .vertical {
                return insideProxy.frame(in: .named(self.tag)).minY
            } else {
                return insideProxy.frame(in: .named(self.tag)).minX
            }
    }
}


