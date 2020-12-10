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
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    @Binding var pages: [PageViewProtocol]
    @Binding var index: Int
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
            .highPriorityGesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged({ value in
                        self.isUserSwiping = true
                        self.offset = self.getDragOffset(value: value, geometry: geometry)
                        self.autoReset()
                    })
                    .onEnded({ value in
                        self.index = self.getWillIndex(value: value, maxIdx: self.pages.count)
                        withAnimation{
                            self.viewModel.index = self.index
                        }
                        self.viewModel.selected = self.pages[self.index].pageID
                    })
                
            )
            .onReceive(self.viewModel.$index){ idx in
                self.reset(idx: idx)
            }
            .onDisappear(){
                DispatchQueue.main.async {
                    self.autoResetSubscription?.cancel()
                    self.autoResetSubscription = nil
                }
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
       if !self.isUserSwiping { return }
       DispatchQueue.main.async {
           withAnimation {
               self.isUserSwiping = false
               if idx != self.index {
                   self.index = idx
               }
           }
       }
    }
}


