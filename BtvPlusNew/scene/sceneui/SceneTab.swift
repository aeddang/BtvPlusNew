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
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    @State var positionTop:CGFloat = -Dimen.app.top
    @State var positionBottom:CGFloat = -Dimen.app.bottom
   
    @State var isDimed:Bool = false
    @State var isLoading:Bool = false
    @State var isPairing:Bool = false
    @State var safeAreaTop:CGFloat = 0
    @State var safeAreaBottom:CGFloat = 0
    
    @State var useBottom:Bool = false
    @State var useTop:Bool = false
    @State var headerHeight:CGFloat = 0
    @State var headerBgHeight:CGFloat = 0
    @State var headerBgTop:CGFloat = 0
    
    @State var headerBannerData:BannerData? = nil
    @State var showAlram:Bool = false
    @State var readShowAlram:Bool = true
    var body: some View {
        ZStack{
            VStack(spacing:Dimen.margin.regular){
                ZStack(alignment: .topLeading){
                    Image(Asset.shape.bgGradientTop)
                        .resizable()
                        .modifier(MatchHorizontal(height: self.headerBgHeight))
                        .padding(.top, self.headerBgTop )
                        .accessibility(hidden: true)
                    VStack(alignment:.leading, spacing:0){
                        if let bannerData = self.headerBannerData {
                            HeaderBanner(data:bannerData) {
                                withAnimation{self.headerBannerData = nil}
                                self.updateTopPos()
                            }
                        }
                        TopTab()
                        if self.showAlram && !self.readShowAlram && self.isPairing {
                            TooltipBottom(text: String.alert.newAlram){
                                self.setup.alramUnvisibleDate = Setup.getDateKey()
                                withAnimation{self.readShowAlram = true}
                            }
                            .padding(.leading, Dimen.margin.thin)
                        }
                    }
                    .padding(.top, self.safeAreaTop)
                    .onReceive(self.repository.alram.$newCount){ count in
                        if self.pairing.status != .pairing {return}
                        let isShow = count>0
                        withAnimation{self.showAlram = isShow}
                        if !isShow {return}
                        if self.setup.isAlramUnvisibleDate() {return}
                        withAnimation{self.readShowAlram = false}
                    }
                    .onReceive(self.repository.alram.$isChangeNotification) { isChange in
                        if isChange {
                            if self.setup.isAlramUnvisibleDate() {return}
                            withAnimation{self.readShowAlram = false}
                        }
                    }
                }
                .opacity(self.useTop ? 1 : 0)
                .padding(.top, self.positionTop)
                Spacer()
                if self.isLoading {
                    ActivityIndicator(isAnimating: self.$isLoading)
                }
                BottomTab()
                .padding(.bottom, self.positionBottom)
                .opacity(self.useBottom ? 1 : 0)
            }
            if self.isDimed {
                Button(action: {
                    self.appSceneObserver.cancelAll()
                }) {
                    Spacer().modifier(MatchParent())
                        .background(Color.transparent.black45)
                }
            }
        }
        .modifier(MatchParent())
        .onReceive (self.appSceneObserver.$isApiLoading) { loading in
            DispatchQueue.main.async {
                withAnimation{
                    self.isLoading = SystemEnvironment.currentPageType == .btv ? loading : false
                }
            }
        }
        .onReceive (self.sceneObserver.$safeAreaTop){ pos in
            if self.safeAreaTop != pos {
                self.safeAreaTop = pos
                self.updateTopPos()
            }
        }
        .onReceive (self.sceneObserver.$safeAreaIgnoreKeyboardBottom){ pos in
            if self.safeAreaBottom != pos {
                self.safeAreaBottom = pos
                self.updateBottomPos()
            }
        }
        
        .onReceive (self.pairing.$status){ stat in
            switch stat {
            case .pairing :
                self.isPairing = true
                if self.headerBannerData != nil {
                    self.headerBannerData = nil
                    self.updateTopPos()
                }
            case .disConnect :
                self.isPairing = false
                if self.headerBannerData == nil {
                    self.headerBannerData = nil
                    //self.headerBannerData = BannerData().setPairing()
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
        .onReceive (self.appSceneObserver.$useTop) { use in
            withAnimation{
                self.useTop = SystemEnvironment.currentPageType == .btv ? use : false
            }
            self.updateTopPos()
        }
        .onReceive (self.appSceneObserver.$useBottom) { use in
            withAnimation{
                self.useBottom = SystemEnvironment.currentPageType == .btv ? use : false
            }
            self.updateBottomPos()
        }
        .onReceive (self.appSceneObserver.$useTopImmediately) { use in
            self.useTop = use
            self.updateTopPos()
        }
        .onReceive (self.appSceneObserver.$useBottomImmediately) { use in
            self.useBottom = use
            self.updateBottomPos()
        }
        .onReceive (self.appSceneObserver.$useLayerPlayer) { _ in
            self.updateBottomPos()
        }
        
    }
    func updateTopPos(){
        if SystemEnvironment.currentPageType != .btv {return}
        var headerHeight = self.headerBannerData == nil ? 0 : HeaderBanner.height
        headerHeight = headerHeight + self.safeAreaTop + Dimen.app.top
        if self.appSceneObserver.useTop {
            self.repository.alram.updateNew()
        }
        
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
            
        }
        self.appSceneObserver.safeBottomHeight = self.appSceneObserver.useBottom
            ? Dimen.app.bottom+self.safeAreaBottom
            : 0
        
        let layer = self.appSceneObserver.useLayerPlayer ? Dimen.app.layerPlayerSize.height : 0
        self.appSceneObserver.safeBottomLayerHeight =
            self.appSceneObserver.safeBottomHeight + layer + Dimen.margin.regular
        
       
    }
    
    
    
}

#if DEBUG
struct SceneTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SceneTab()
            .environmentObject(Repository())
            .environmentObject(AppObserver())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            .environmentObject(PagePresenter())
                .frame(width:340,height:300)
        }
    }
}
#endif
