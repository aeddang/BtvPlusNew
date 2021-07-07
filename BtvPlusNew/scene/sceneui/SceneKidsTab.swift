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

struct SceneKidsTab: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @State var positionTop:CGFloat = -(DimenKids.app.gnbTop+DimenKids.app.top)
    @State var isDimed:Bool = false
    @State var isLoading:Bool = false
    @State var safeAreaTop:CGFloat = 0
    @State var safeAreaBottom:CGFloat = 0
    @State var useTop:Bool = false
    var body: some View {
        ZStack{
            VStack(spacing:Dimen.margin.regular){
                KidsTop()
                .opacity(self.useTop ? 1 : 0)
                .padding(.top, self.positionTop)
                .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if self.isLoading {
                    ActivityIndicator(isAnimating: self.$isLoading)
                }
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
                    self.isLoading = SystemEnvironment.currentPageType == .kids ? loading : false
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
            }
        }
        .onReceive (self.appSceneObserver.$useTop) { use in
            withAnimation{
                self.useTop = SystemEnvironment.currentPageType == .kids ? use : false
            }
            self.updateTopPos()
        }
        .onReceive (self.appSceneObserver.$useTopImmediately) { use in
            self.useTop = use
            self.updateTopPos()
        }
        
    }
    func updateTopPos(){
        if SystemEnvironment.currentPageType != .kids{return}
        let top = self.appSceneObserver.useTop
            ? self.safeAreaTop
            : -(DimenKids.app.gnbTop + DimenKids.app.top)
        self.appSceneObserver.headerHeight = top + KidsTop.marginTop
        self.appSceneObserver.safeHeaderHeight
            = self.safeAreaTop + DimenKids.app.gnbTop + KidsTop.marginTop
        withAnimation{
            self.positionTop = top
        }
    }
}

#if DEBUG
struct SceneKidsTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SceneKidsTab()
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
