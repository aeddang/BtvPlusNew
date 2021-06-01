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
        }
        .edgesIgnoringSafeArea(.all)
    }
}

extension PageContentBody{
    static let pageMoveAmount:CGFloat = -70.0
    private static var useBelowPageMove:Bool {
        get{
            if #available(iOS 14.0, *) { return true }
            else { return false }
        }
    }
}


struct PageContentBody: PageView  {
    var childViews:[PageViewProtocol] = []
    @EnvironmentObject var pageChanger:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @State var offsetX:CGFloat = 0
    @State var offsetY:CGFloat = 0
    @State var dragOpacity:Double = 0.0
    @State var opacity:Double = 1.0
    @State var pageOffsetX:CGFloat = 0.0
    @State var pageOffsetY:CGFloat = 0.0
    @State var isTop:Bool = true
    @State var isBelow:Bool = false
    @State var topPageType:PageAnimationType = .none
    @State var isReady:Bool = false
    let useBelowPageMove = Self.useBelowPageMove
    var body: some View {
        ZStack(){
            childViews.first!.contentBody
                .offset(
                    x: self.offsetX ,
                    y: self.offsetY)
            //if self.isBelow {
                Spacer().modifier(MatchParent()).background(Color.transparent.black70)
                    .opacity(self.dragOpacity)
                    .onTapGesture {
                        self.pageChanger.goBack()
                    }
            //}
            
        }
        .opacity(self.opacity)
        .offset(x:  self.pageOffsetX, y:  -self.pageOffsetY )
        .onReceive(self.pageChanger.$currentTopPage){ page in
            guard let page = page else { return }
            if !self.isReady  {return}
            //PageLog.log("currentTopPage",tag:self.pageID)
            self.topPageType = page.animationType
            guard let pageObject = self.pageObject else { return }
            if pageObject.zIndex != 0 { return }
            if pageObject.animationType == .opacity { return }
            if self.offsetX != 0 || self.offsetY != 0 { return }
            
            if pageObject == page {
                self.isTop = true
                self.isBelow = false
                withAnimation{
                   
                    self.pageOffsetX = 0.0
                    self.pageOffsetY = 0.0
                    self.dragOpacity = 0
                }
                
            } else {
                self.isTop = false
                
                let below = self.pageChanger.getBelowPage(page: page)
                self.isBelow = below == pageObject
                withAnimation{
                    self.dragOpacity = 1
                }
                if !self.useBelowPageMove {return}
                withAnimation{
                    switch self.topPageType {
                    case .horizontal :
                        self.pageOffsetX = Self.pageMoveAmount
                        self.pageOffsetY = 0
                    
                    case .vertical :
                        self.pageOffsetY = -Self.pageMoveAmount
                        self.pageOffsetX = 0
                    
                    default : do{}
                    }
                }
                
            }
            
        }
        .onReceive(self.pageChanger.$dragOpercity){ opacity in
            
            if !self.isReady  {return}
            if !self.isBelow {return}
            if self.isTop {return}
            
            self.dragOpacity = opacity
            if !self.useBelowPageMove {return}
            //PageLog.log("pagePosition " + self.opacity.description + " " + self.pageID ,tag:self.pageID)
            let amount = Self.pageMoveAmount * CGFloat(opacity)
            switch self.topPageType {
            case .horizontal :  self.pageOffsetX = amount
            case .vertical :  self.pageOffsetY = -amount
            default : do{}
            }
        }
        
        .onReceive(self.pageObservable.$pagePosition){ pos in
            if !self.isReady  {return}
            // PageLog.log("pagePosition",tag:self.pageID)
            if self.pageObservable.status == .initate{
                self.offsetX = pos.x
                self.offsetY = pos.y
            }else{
                if self.pageObject?.isAnimation == true {
                    withAnimation{
                        self.offsetX = pos.x
                        self.offsetY = pos.y
                    }
                }else{
                    self.offsetX = pos.x
                    self.offsetY = pos.y
                }
            }
        }
        .onReceive(self.pageObservable.$pageOpacity){ opacity in
            if !self.isReady {return}
            withAnimation{
                self.opacity = opacity
            }
        }
        .onAppear{
            PageLog.log("onAppear",tag:self.pageID)
            self.offsetX = self.pageObservable.pagePosition.x
            self.offsetY = self.pageObservable.pagePosition.y
            if self.pageObject?.animationType == .opacity { self.opacity = 0 }
            
            DispatchQueue.main.async {
                self.isReady = true
                self.pageObservable.status = .appear
                self.pageObservable.pagePosition.x = 0
                self.pageObservable.pagePosition.y = 0
                self.pageObservable.pageOpacity = 1.0
                self.childViews.forEach({ $0.appear() })
            }
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
