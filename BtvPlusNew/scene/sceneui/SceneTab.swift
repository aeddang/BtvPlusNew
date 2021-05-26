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
    @State var positionTop:CGFloat = -Dimen.app.top
    @State var positionBottom:CGFloat = -Dimen.app.bottom
   
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
    @State var showAlram:Bool = false
    @State var readShowAlram:Bool = false
    var body: some View {
        ZStack{
            VStack(spacing:Dimen.margin.regular){
                ZStack(alignment: .topLeading){
                    Image(Asset.shape.bgGradientTop)
                        .resizable()
                        .modifier(MatchHorizontal(height: self.headerBgHeight))
                        .padding(.top, self.headerBgTop )
                    
                    VStack(alignment:.leading, spacing:0){
                        if let bannerData = self.headerBannerData {
                            HeaderBanner(data:bannerData) {
                                self.headerBannerData = nil
                                self.updateTopPos()
                            }
                        }
                        TopTab()
                        if self.showAlram && !self.readShowAlram {
                            TooltipBottom(text: String.alert.newAlram){
                                withAnimation{self.readShowAlram = true}
                            }
                            .padding(.leading, Dimen.margin.thin)
                        }
                    }
                    .padding(.top, self.safeAreaTop)
                    .onReceive(self.repository.alram.$newCount){ count in
                        if self.pairing.status != .pairing {return}
                        withAnimation{self.showAlram = count>0}
                    }
                    .onReceive(self.repository.alram.$isChangeNotification) { isChange in
                        if isChange {
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
        .onReceive (self.appSceneObserver.$useTopImmediately) { use in
            self.useTop = use
            self.updateTopPos()
        }
        .onReceive (self.appSceneObserver.$useBottomImmediately) { use in
            self.useBottom = use
            self.updateBottomPos()
        }
        
    }
    func updateTopPos(){
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
