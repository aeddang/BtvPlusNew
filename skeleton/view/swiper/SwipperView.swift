//
//  SwipperView.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
extension SwipperView{
    static var MIN_DRAG_RANGE:CGFloat = 30
    static var PULL_RANGE:CGFloat = 80
    static var PULL_COMPLETE_RANGE:CGFloat = 160
}

struct SwipperView : View , PageProtocol, Swipper {
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    var pages: [PageViewProtocol]
    var coordinateSpace:CoordinateSpace = .local
    var usePull: Axis? = nil
    @State var offset: CGFloat = 0
    @State var isUserSwiping: Bool = false
    @State var index: Int = 0
    @State var progress:Double = 1
    @State var progressMax:Double = 1
    var action:(() -> Void)? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(self.pages, id:\.id) { page in
                        page.contentBody
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .onTapGesture(){
                            guard let action = self.action else {return}
                            action()
                        }
                    }
                }
            }
            .content
            .offset(x: self.isUserSwiping ? self.offset : CGFloat(self.index) * -geometry.size.width)
            .frame(width: geometry.size.width, alignment: .leading)
            .opacity(max(0.2,self.progress/self.progressMax))
            .highPriorityGesture(
                DragGesture(minimumDistance: Self.MIN_DRAG_RANGE, coordinateSpace: self.coordinateSpace)
                .onChanged({ value in
                    self.isUserSwiping = true
                    let willOffset = self.getDragOffset(value: value, geometry: geometry)
                    if let pull = self.usePull {
                        if pull == .horizontal {
                            if willOffset > Self.PULL_RANGE || self.viewModel.status == .pull {
                                self.viewModel.event = .pull(willOffset/4.0)
                                self.viewModel.status = .pull
                                self.progress = self.progressMax - Double(willOffset-Self.PULL_RANGE)
                            } else {
                                self.viewModel.status = .move
                                self.offset = willOffset
                            }
                        } else {
                            let pullOffset = value.translation.height
                            if pullOffset > Self.PULL_RANGE || self.viewModel.status == .pull {
                                self.viewModel.event = .pull(pullOffset/2.0)
                                self.viewModel.status = .pull
                                self.progress = self.progressMax - Double(pullOffset-Self.PULL_RANGE)
                            } else {
                                self.viewModel.status = .move
                                self.offset = willOffset
                            }
                           
                        }
                    } else {
                        self.viewModel.status = .move
                        self.offset = willOffset
                    }
                    self.autoReset()
                })
                .onEnded({ value in
                    switch self.viewModel.status {
                    case .pull :
                        let willPullOffset = self.usePull == .horizontal ? value.predictedEndTranslation.width : value.predictedEndTranslation.height
                        ComponentLog.d("self.offset " + willPullOffset.description, tag: self.tag)
                        if willPullOffset > Self.PULL_COMPLETE_RANGE{
                            self.viewModel.event = .pullCompleted
                            withAnimation{self.progress = 0}
                        } else {
                            self.viewModel.event = .pullCancel
                            withAnimation{self.progress = self.progressMax}
                        }
                    default : break
                    }
                    self.viewModel.status = .stop
                    self.reset(idx: self.getWillIndex(value: value, maxIdx: self.pages.count) )
                })
            )
            .onReceive( self.viewModel.$index ){ idx in
                if self.index == idx {return}
                withAnimation{ self.index = idx }
            }
            .onReceive(self.viewModel.$request){ evt in
                guard let evt = evt else {return}
                switch evt{
                case .reset : if self.isUserSwiping { self.reset(idx:self.index) }
                case .move(let idx) :
                    withAnimation{ self.index = idx }
                    self.viewModel.index = idx
                case .jump(let idx) :
                    self.index = idx
                    self.viewModel.index = idx
                case .prev:
                    let willIdx = self.index == 0 ? self.pages.count : self.index - 1
                    self.offset = CGFloat(willIdx) * -geometry.size.width
                    self.viewModel.status = .move
                    self.viewModel.request = .drag(self.offset)
                    self.isUserSwiping = true
                    self.reset(idx: willIdx)
                case .next:
                    let willIdx = self.index >= self.pages.count ? 0 : self.index + 1
                    self.offset = CGFloat(willIdx) * -geometry.size.width
                    self.viewModel.status = .move
                    self.viewModel.request = .drag(self.offset)
                    self.isUserSwiping = true
                    self.reset(idx: willIdx)
                default : break
                }
            }
            .onDisappear(){
                DispatchQueue.main.async {
                    self.autoResetSubscription?.cancel()
                    self.autoResetSubscription = nil
                }
            }
            .onAppear(){
                self.index = self.viewModel.index
                self.progressMax = Double(Self.PULL_COMPLETE_RANGE - Self.PULL_RANGE)
                self.progress = self.progressMax
            }
         }//GeometryReader
    }//body
    
    func reset(idx:Int) {
       self.autoResetSubscription?.cancel()
       self.autoResetSubscription = nil
       if !self.isUserSwiping { return }
       DispatchQueue.main.async {
           if self.viewModel.index != idx { self.viewModel.index = idx }
           withAnimation {
               self.isUserSwiping = false
               if idx != self.index {
                   self.index = idx
               }
           }
       }
    }
    
    @State var autoResetSubscription:AnyCancellable?
    func autoReset() {
       // self.autoResetSubscription = self.creatResetTimer()
    }
}


