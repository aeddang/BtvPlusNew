//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Foundation
import SwiftUI
struct SceneTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @State var positionTop:CGFloat = -Dimen.app.top
    @State var positionBottom:CGFloat = -Dimen.app.bottom
    @State var positionLoading:CGFloat = -Dimen.app.bottom
    @State var isDimed:Bool = false
    @State var isLoading:Bool = false
    
    @State var safeAreaTop:CGFloat = 0
    @State var safeAreaBottom:CGFloat = 0
    
    @State var useBottom:Bool = false
    @State var useTop:Bool = false
    @State var headerHeight:CGFloat = 0
    @State var headerBgHeight:CGFloat = 0
    @State var headerBgTop:CGFloat = 0
    
    @State var headerBannerData:BannerData? = nil
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                ZStack{
                    Image(Asset.shape.bgGradientTop)
                        .resizable()
                        .modifier(MatchHorizontal(height: self.headerBgHeight))
                        .padding(.top, self.headerBgTop )
                    
                    VStack(spacing:0){
                        if let bannerData = self.headerBannerData {
                            HeaderBanner(data:bannerData) {
                                self.headerBannerData = nil
                                self.updateTopPos()
                            } 
                        }
                        TopTab()
                    }
                }
                .modifier(
                    LayoutTop(
                        geometry: geometry,
                        height: self.headerHeight,
                        margin: self.positionTop)
                )
                .opacity(self.useTop ? 1 : 0)
                
                BottomTab()
                    .modifier(
                        LayoutBotttom(
                            geometry: geometry,
                            height:Dimen.app.bottom + self.safeAreaBottom,
                            margin: self.positionBottom )
                    )
                    .opacity(self.useBottom ? 1 : 0)
                
                if self.isDimed {
                    Button(action: {
                        self.appSceneObserver.cancelAll()
                    }) {
                        Spacer().modifier(MatchParent())
                            .background(Color.transparent.black45)
                    }
                }
    
                if self.isLoading {
                    ActivityIndicator(isAnimating: self.$isLoading)
                        .modifier(
                            LayoutBotttom(
                                geometry: geometry,
                                height:50,
                                margin: self.positionLoading )
                        )
                }
                
            }
            .modifier(MatchParent())
            .onReceive (self.appSceneObserver.$isApiLoading) { loading in
                DispatchQueue.main.async {
                    withAnimation{
                        self.isLoading = loading
                    }
                }
            }
            .onReceive (self.sceneObserver.$safeAreaTop){ pos in
                if self.safeAreaTop != pos {
                    self.safeAreaTop = pos
                    self.updateTopPos()
                }
            }
            .onReceive (self.sceneObserver.$safeAreaBottom){ pos in
                if self.safeAreaBottom != pos {
                    self.safeAreaBottom = pos
                    self.updateBottomPos()
                }
            }
            .onReceive (self.pairing.$status){ stat in
                switch stat {
                case .pairing :
                    if self.headerBannerData != nil {
                        self.headerBannerData = nil
                        self.updateTopPos()
                    }
                case .disConnect :
                    if self.headerBannerData == nil {
                        self.headerBannerData = BannerData().setPairing()
                        self.updateTopPos()
                    }
                default : break
                }
            }
            .onReceive(self.appSceneObserver.$event){ evt in
                guard let evt = evt else { return }
                switch evt  {
                case .headerBanner(let data):
                    self.headerBannerData = data
                    self.updateTopPos()
                default: break
                }
            }
            .onReceive (self.appSceneObserver.$useTopFix) { use in
                guard let use = use else {return}
                self.appSceneObserver.useTop = use
            }
            
            .onReceive (self.appSceneObserver.$useTop) { use in
                withAnimation{
                    self.useTop = use
                }
                self.updateTopPos()
            }
            .onReceive (self.appSceneObserver.$useBottom) { use in
                withAnimation{
                    self.useBottom = use
                }
                self.updateBottomPos()
            }
        }//geometry
    }
    func updateTopPos(){
        var headerHeight = self.headerBannerData == nil ? 0 : HeaderBanner.height
        headerHeight = headerHeight + self.safeAreaTop + Dimen.app.top
        
        let top = self.appSceneObserver.useTop
            ? 0
            : -headerHeight
        
        self.appSceneObserver.headerHeight = headerHeight
        self.appSceneObserver.safeHeaderHeight = self.headerBannerData == nil
            ? 0
            : self.safeAreaTop + HeaderBanner.height
        
        withAnimation{
            self.positionTop = top
            self.headerHeight = headerHeight
            self.headerBgHeight = self.headerBannerData == nil
                ? self.safeAreaTop + Dimen.app.top
                : Dimen.app.top
            self.headerBgTop = self.headerBannerData == nil
                ? -self.safeAreaTop
                : Dimen.app.top
            
        }
    }
    func updateBottomPos(){
        withAnimation{
            self.positionBottom = self.appSceneObserver.useBottom
                ? 0
                : -(Dimen.app.bottom+self.safeAreaBottom)
            
            self.positionLoading = self.appSceneObserver.useBottom
                ? (Dimen.app.bottom + Dimen.margin.heavy + self.safeAreaBottom)
                : self.safeAreaBottom
        }
    }
    
    
    
}

#if DEBUG
struct SceneTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SceneTab()
            .environmentObject(AppObserver())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            .environmentObject(PagePresenter())
                .frame(width:340,height:300)
        }
    }
}
#endif
