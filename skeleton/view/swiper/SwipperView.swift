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

struct SwipperView : View , PageProtocol, Swipper {
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    var pages: [PageViewProtocol]

    @State var offset: CGFloat = 0
    @State var isUserSwiping: Bool = false
    @State var index: Int = 0
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
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onChanged({ value in
                    self.isUserSwiping = true
                    self.offset = self.getDragOffset(value: value, geometry: geometry)
                    self.autoReset()
                })
                .onEnded({ value in
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
        //self.autoResetSubscription = self.creatResetTimer()
    }
}


