//
//  PageContentBody.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/20.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct PageBackgroundBody: View {
    @EnvironmentObject var pageChanger:PagePresenter
    var body: some View {
        ZStack{
            Rectangle().fill(pageChanger.bodyColor)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct PageContentBody: PageView  {
    var childViews:[PageViewProtocol] = []
    @EnvironmentObject var pageChanger:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @State var offsetX:CGFloat = 0
    @State var offsetY:CGFloat = 0
    @State var opacity:Double = 1.0
    var body: some View {
        ZStack(){
            if self.pageObject?.isDimed == true{
                Spacer().modifier(MatchParent()).background(Color.transparent.black70)
                    .opacity(self.opacity)
                    .onTapGesture {
                        self.pageChanger.goBack()
                    }
            }
            ForEach(childViews, id: \.pageID) { page in
                page.contentBody
                .offset(x:  self.offsetX, y:self.offsetY)
            }
        }
        .frame(alignment: .topLeading)
        .onReceive(self.pageObservable.$pagePosition){ pos in
            if self.pageObservable.status == .initate{
                self.offsetX = pos.x
                self.offsetY = pos.y
                //PageLog.log("onInitate " + pos.debugDescription,tag:self.pageID)
            }else{
                if self.pageObject?.isAnimation == true {
                    withAnimation{
                        self.offsetX = pos.x
                        self.offsetY = pos.y
                        //PageLog.log("onAppear " + pos.debugDescription,tag:self.pageID)
                    }
                }else{
                    self.offsetX = pos.x
                    self.offsetY = pos.y
                }
            }
        }
        .onReceive(self.pageObservable.$pageOpacity){ opacity in
            withAnimation{
                self.opacity = opacity
            }
        }
        .onAppear{
            PageLog.log("onAppear",tag:self.pageID)
            //PageLog.d("onAppear " + self.pageObservable.pagePosition.debugDescription, tag: self.tag)
            self.childViews.forEach({ $0.appear() })
            self.offsetX = self.pageObservable.pagePosition.x
            self.offsetY = self.pageObservable.pagePosition.y
            self.opacity = 0
            self.pageObservable.status = .appear

            self.pageObservable.pagePosition.x = 0
            self.pageObservable.pagePosition.y = 0
            self.pageObservable.pageOpacity = 1.0
            
        }
        .onDisappear{
            self.childViews.forEach({ $0.disAppear() })
            self.pageObservable.status = .disAppear
            PageLog.log("onDisappear",tag:self.pageID)
        }
    }
}

struct PageContent: PageView  {
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @EnvironmentObject var pageChanger:PagePresenter
    @State var bodyColor:Color = Color.red
    static internal var index = 0
    
    var body: some View {
        ZStack(){
            Rectangle().fill(bodyColor)
            VStack{
                Button<Text>(action: {
                    //self.pageChanger.changePage("Next" + PageContent.index.description)
                    PageContent.index += 1
                }) {
                    Text(pageObservable.isAnimationComplete ? pageID : "Loading")
                }
                Button<Text>(action: {
                    self.pageChanger.openPopup("Popup" + PageContent.index.description)
                    PageContent.index += 1
                }) {
                    Text("openPopup")
                }
                
                Button<Text>(action: {
                    self.pageChanger.closePopup(self.id)
                }) {
                    Text("closePopup")
                }
                
                Button<Text>(action: {
                    self.pageChanger.closeAllPopup()
                }) {
                    Text("closeAllPopup")
                }
                
                Button<Text>(action: {
                    self.pageChanger.goBack()
                }) {
                    Text("back")
                }
                if pageObservable.status == .becomeActive {
                    Text("BecomeActive")
                }
            }
            
        }
    }
}

#if DEBUG
struct PageContentBody_Previews: PreviewProvider {
    static var previews: some View {
        PageBackgroundBody()
    }
}
#endif
