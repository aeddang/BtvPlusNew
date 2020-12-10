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

struct SwipperPageHighPriority : View , PageProtocol, Swipper {
    @ObservedObject var pageObservable: PageObservable
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    let pages: [PageObject]
    @Binding var index: Int
    var useGesture = true
    @State var offset: CGFloat = 0
    @State var isUserSwiping: Bool = false
    
    private let sensitivity:CGFloat = 100
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(self.pages) { page in
                        PageFactory.getPage(page).setPageObject(page)?.contentBody
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                    }
                }
            }
            .content
            .offset(x: self.isUserSwiping ? self.offset : CGFloat(self.index) * -geometry.size.width)
            .frame(width: geometry.size.width, alignment: .leading)
            .highPriorityGesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onChanged({ value in
                        if !self.useGesture {return}
                        self.isUserSwiping = true
                        self.offset = self.getDragOffset(value: value, geometry: geometry)
                        self.autoReset()
                    })
                    .onEnded({ value in
                        if !self.useGesture {return}
                        withAnimation{
                            self.index = self.getWillIndex(value: value, maxIdx: self.pages.count)
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
    
    @State  var autoResetSubscription:AnyCancellable?
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


struct SwipperPage : View , PageProtocol, Swipper {
    @ObservedObject var pageObservable: PageObservable
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    let pages: [PageObject]
    @Binding var index: Int
    var useGesture = true
    @State var offset: CGFloat = 0
    @State var isUserSwiping: Bool = false
    
    private let sensitivity:CGFloat = 100
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(self.pages) { page in
                        PageFactory
                            .getPage(page)
                            .setPageObject(page)?
                            .contentBody
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                    }
                }
            }
            .content
            .offset(x: self.isUserSwiping ? self.offset : CGFloat(self.index) * -geometry.size.width)
            .frame(width: geometry.size.width, alignment: .leading)
            .gesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onChanged({ value in
                        if !self.useGesture {return}
                        self.isUserSwiping = true
                        self.offset = self.getDragOffset(value: value, geometry: geometry)
                        self.autoReset()
                    })
                    .onEnded({ value in
                        if !self.useGesture {return}
                        withAnimation{
                            self.index = self.getWillIndex(value: value, maxIdx: self.pages.count)
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
    
    @State  var autoResetSubscription:AnyCancellable?
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
