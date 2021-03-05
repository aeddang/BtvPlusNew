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
    @Binding var index: Int
    
    var useGesture:Bool = true
    @State var offset: CGFloat = 0
    @State var isUserSwiping: Bool = false
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
                        .clipped()
                    }
                }
            }
            .content
            .offset(x: self.isUserSwiping ? self.offset : CGFloat(self.index) * -geometry.size.width)
            .frame(width: geometry.size.width, alignment: .leading)
            .highPriorityGesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onChanged({ value in
                    if !self.useGesture { return }
                    self.isUserSwiping = true
                    self.offset = self.getDragOffset(value: value, geometry: geometry)
                    if self.viewModel.status == .stop { self.viewModel.status = .move }
                    self.viewModel.request = .drag(self.offset)
                    self.autoReset()
                })
                .onEnded({ value in
                    if !self.useGesture { return }
                    let willIdx = self.getWillIndex(value: value, maxIdx: self.pages.count)
                    self.reset(idx: willIdx)
                    
                })
            )
            .onReceive(self.viewModel.$request){ evt in
                if self.useGesture { return }
                guard let evt = evt else {return}
                switch evt{
                case .drag(let pos):
                    self.offset = pos
                case .draged:
                    self.isUserSwiping = false
                    
                default : break
                }
            }
            .onReceive( self.viewModel.$index ){ idx in
                if self.index == idx {return}
                withAnimation{
                    self.index = idx
                    self.isUserSwiping = false
                }
            }
            
            .onReceive(self.viewModel.$status){ stat in
                if self.useGesture { return }
                switch stat{
                case .move : self.isUserSwiping = true
                default: break 
                }
            }
            .onDisappear(){
                self.autoResetSubscription?.cancel()
                self.autoResetSubscription = nil
                
            }
         }//GeometryReader
    }//body
    
    @State var autoResetSubscription:AnyCancellable?
    func autoReset() {
        self.autoResetSubscription = self.creatResetTimer()
    }
    func reset(idx:Int) {
        self.autoResetSubscription?.cancel()
        self.autoResetSubscription = nil
        if self.viewModel.status == .move { self.viewModel.status = .stop }
        if !self.isUserSwiping { return }
        
        DispatchQueue.main.async {
           withAnimation {
               self.isUserSwiping = false
               if idx != self.index {
                   self.index = idx
               } else {
                   self.viewModel.request = .draged
               }
           }
        }
     }
}


