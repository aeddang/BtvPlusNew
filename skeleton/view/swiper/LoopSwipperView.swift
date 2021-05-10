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
extension LoopSwipperView {
    static let duration:Double = 0.35
    static let ani:Animation = Animation.easeOut(duration: duration)
    static let aniBg:Animation = Animation.easeOut(duration: duration)
}
struct LoopSwipperView : View , PageProtocol, Swipper {
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    var pages: [PageViewProtocol]
    @State var index: Int = 0
    var isForground:Bool = true
    var action:(() -> Void)? = nil
    var body: some View {
        GeometryReader { geometry in
            if self.pages.count <= 1 {
                self.pages.first?.contentBody
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    if #available(iOS 14.0, *) {
                        LazyHStack(alignment: .center, spacing: 0) {
                            self.pages.last?.contentBody
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height
                                )
                                .clipped()
                            ForEach(self.pages, id:\.id) { page in
                                page.contentBody
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height
                                )
                                .clipped()
                            }
                            self.pages.first?.contentBody
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height
                                )
                                .clipped()
                        }
                    } else {
                        HStack(alignment: .center, spacing: 0) {
                            self.pages.last?.contentBody
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height
                                )
                                .clipped()
                            ForEach(self.pages, id:\.id) { page in
                                page.contentBody
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height
                                )
                                .clipped()
                            }
                            self.pages.first?.contentBody
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height
                                )
                                .clipped()
                        }
                    }
                }
                .content
                .offset(x: self.isUserSwiping ? self.offset : CGFloat(self.index + 1) * -geometry.size.width)
                .frame(width: geometry.size.width, alignment: .leading)
                .clipped()
                .gesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onChanged({ value in
                        if !self.isForground { return }
                        self.isUserSwiping = true
                        if self.viewModel.status == .stop {
                            self.viewModel.status = .move
                            self.dragOffset = value.translation.width
                        }
                        self.offset = self.getDragOffset(value: value, geometry: geometry, offset: self.dragOffset) - geometry.size.width
                        self.viewModel.request = .drag(self.offset)
                        self.autoReset()
                    })
                    .onEnded({ value in
                        if !self.isForground { return }
                        let willIdx = self.getWillIndex(value: value, minIdx: -1, maxIdx: self.pages.count + 1)
                        self.reset(idx: willIdx)
                        
                    })
                )
                .gesture(
                    LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
                          .simultaneously(with: RotationGesture(minimumAngleDelta:.zero))
                          .simultaneously(with: MagnificationGesture(minimumScaleDelta: 0))
                        .onChanged({_ in
                            if !self.isForground { return }
                            self.reset(idx: self.index)
                        })
                        .onEnded({_ in
                            if !self.isForground { return }
                            self.reset(idx: self.index)
                        })
                )
                .onReceive(self.viewModel.$request){ evt in
                    guard let evt = evt else {return}
        
                    if self.isForground {
                        switch evt{
                        case .reset : if self.isUserSwiping { self.reset(idx:self.index) }
                        case .move(let idx) :
                            withAnimation(Self.ani){ self.index = idx }
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
                    } else {
                        switch evt{
                        case .drag(let pos):
                            self.offset = pos
                        case .draged:
                            self.isUserSwiping = false
                        default : break
                        }
                    }
                    
                    
                }
                .onReceive( self.viewModel.$index ){ idx in
                    if self.index == idx {return}
                    let diff = abs(idx - self.index)
                    if diff > 1 {
                        self.index = idx
                        self.isUserSwiping = false
                        return
                    }
                    withAnimation(self.isForground ? Self.ani : Self.aniBg){
                        self.index = idx
                        if !self.isForground { self.isUserSwiping = false }
                    }
                   
                }
                .onReceive(self.viewModel.$status){ stat in
                    if self.isForground { return }
                    switch stat{
                    case .move : self.isUserSwiping = true
                    default: break
                    }
                }
                .onAppear(){
                    self.index = self.viewModel.index
                }
                .onDisappear(){
                    self.autoResetSubscription?.cancel()
                    self.autoResetSubscription = nil
                }
            }
            
         }//GeometryReader
    }//body
    @State var dragOffset:CGFloat = 0
    @State var offset: CGFloat = 0
    @State var isUserSwiping: Bool = false
   
    func reset(idx:Int) {
        self.autoResetSubscription?.cancel()
        self.autoResetSubscription = nil
        if !self.isUserSwiping {
            self.viewModel.status = .stop
            return
        }
        
        if self.viewModel.status == .stop { self.viewModel.status = .move }
        DispatchQueue.main.async {
            if self.viewModel.index != idx { self.viewModel.index = idx }
            withAnimation(self.isForground ? Self.ani : Self.aniBg){
               self.isUserSwiping = false
               if idx != self.index {
                   self.index = idx
               } else {
                   self.viewModel.request = .draged
               }
           }
        }
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + Self.duration) {
            DispatchQueue.main.async {
                let min = 0
                let max = self.pages.count-1
                if self.index < min {
                    self.index = max
                } else  if self.index > max {
                    self.index = min
                }
                
                self.viewModel.status = .stop
                if self.viewModel.index != self.index { self.viewModel.index = self.index }
            }
        }
        
     }
    
    @State var autoResetSubscription:AnyCancellable?
    func autoReset() {
        //self.autoResetSubscription = self.creatResetTimer()
    }
}


