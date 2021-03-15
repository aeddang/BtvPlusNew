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
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @State var positionTop:CGFloat = -Dimen.app.top
    @State var positionBottom:CGFloat = -Dimen.app.bottom
    @State var positionLoading:CGFloat = -Dimen.app.bottom
    @State var isDimed:Bool = false
    @State var isLoading:Bool = false
    
    @State var safeAreaTop:CGFloat = 0
    @State var safeAreaBottom:CGFloat = 0
    
    @State var useBottom:Bool = false
    @State var useTop:Bool = false
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                TopTab()
                    .modifier(
                        LayoutTop(
                            geometry: geometry,
                            height:Dimen.app.top + self.safeAreaTop,
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
                        self.pageSceneObserver.cancelAll()
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
            .onReceive (self.pageSceneObserver.$isApiLoading) { loading in
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
            .onReceive (self.pageSceneObserver.$useTopFix) { use in
                guard let use = use else {return}
                self.pageSceneObserver.useTop = use
            }
            
            .onReceive (self.pageSceneObserver.$useTop) { use in
                withAnimation{
                    self.useTop = use
                }
                self.updateTopPos()
            }
            .onReceive (self.pageSceneObserver.$useBottom) { use in
                withAnimation{
                    self.useBottom = use
                }
                self.updateBottomPos()
            }
        }//geometry
    }
    func updateTopPos(){
        withAnimation{
            withAnimation{
                self.positionTop = self.pageSceneObserver.useTop
                    ? 0
                    : -(Dimen.app.top+self.safeAreaTop)
            }
        }
    }
    func updateBottomPos(){
        withAnimation{
            self.positionBottom = self.pageSceneObserver.useBottom
                ? 0
                : -(Dimen.app.bottom+self.safeAreaBottom)
            
            self.positionLoading = self.pageSceneObserver.useBottom
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
            .environmentObject(SceneObserver())
            .environmentObject(PageSceneObserver())
            .environmentObject(PagePresenter())
                .frame(width:340,height:300)
        }
    }
}
#endif
