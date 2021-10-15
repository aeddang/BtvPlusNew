//
//  PageTest.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
import Combine
import Firebase


struct PageSetupApi: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var setup:Setup
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    @State var marginBottom:CGFloat = 0
    @State var webPath:String = ""
   
    var body: some View {
        VStack(alignment: .leading, spacing:10)
        {
            PageTab(
                title:"필요한서버 요청하시면 넣어드립니다",
                isClose: true)
                .padding(.top, self.sceneObserver.safeAreaTop)
            HStack{
                InputCell(
                    title: "WEB",
                    input: self.$webPath
                )
                FillButton(text: "confirm") { _ in
                    
                    SystemEnvironment.FORCE_WEB = self.webPath
                    
                }.frame(width: 100)
            }
            .padding(.all, 10)
            Spacer().modifier(MatchParent())
        }//VStack
        .padding(.bottom, self.marginBottom)
        .modifier(PageFull())
        .background(Color.brand.bg)
        .onReceive(self.sceneObserver.$safeAreaBottom){ bottom in
            self.marginBottom = bottom
        }
        .onAppear{
            self.webPath =  ApiPath.getRestApiPath(.WEB)
        }
        .onDisappear{
           
        }
    }//body
    
}



