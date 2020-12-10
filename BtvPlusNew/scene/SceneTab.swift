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
    @State var positionTop:CGFloat = 0
    @State var positionBottom:CGFloat = Dimen.app.bottom
    @State var positionLoading:CGFloat = -Dimen.app.bottom
    @State var isDimed:Bool = false
    @State var isLoading:Bool = false
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                TopTab()
                    .modifier(
                        LayoutTop(
                            geometry: geometry,
                            height:Dimen.app.top,
                            margin: self.positionTop )
                    )
                
                BottomTab()
                    .modifier(
                        LayoutBotttom(
                            geometry: geometry,
                            height:Dimen.app.bottom,
                            margin: self.positionBottom )
                    )
                
                if self.isDimed {
                    Button(action: {
                        self.sceneObserver.cancelAll()
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
            .onAppear(){
                PageLog.d("safeAreaTop " + PageSceneObserver.safeAreaTop.description , tag:self.tag)
                PageLog.d("safeAreaBottom " + PageSceneObserver.safeAreaBottom.description , tag:self.tag)
                
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                PageSceneObserver.screenSize = geometry.size
            }
            
            .onReceive (self.sceneObserver.$isApiLoading) { loading in
                DispatchQueue.main.async {
                    withAnimation{
                        self.isLoading = loading
                    }
                }
            }
            .onReceive (self.sceneObserver.$useTop) { use in
                withAnimation{
                    self.positionTop = use ? PageSceneObserver.safeAreaTop : -(Dimen.app.top + Dimen.margin.heavy)
                }
            }
            .onReceive (self.sceneObserver.$useBottom) { use in
                withAnimation{
                    self.positionBottom = use
                        ? -(PageSceneObserver.safeAreaBottom * 2)
                        : (Dimen.app.bottom - PageSceneObserver.safeAreaBottom + 70)
                    
                    self.positionLoading = use
                        ? -(Dimen.app.bottom + Dimen.margin.heavy + PageSceneObserver.safeAreaBottom)
                        : -PageSceneObserver.safeAreaBottom
                }
            }
        }//geometry
        
    }
}

#if DEBUG
struct SceneTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SceneTab()
            .environmentObject(AppObserver())
            .environmentObject(PageSceneObserver())
            .environmentObject(PagePresenter())
                .frame(width:340,height:300)
        }
    }
}
#endif
