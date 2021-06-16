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

struct PagePlayerTest: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel = PlayerModel()
   
    @State var ckcURL:String = ""
    @State var contentId:String = ""
    @State var videoPath:String = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8"
    
    var body: some View {
        VStack(alignment: .center, spacing:10)
        {
            PageTab( isClose: true)
            CPPlayer(
                viewModel : self.playerModel ,
                pageObservable : self.pageObservable)
            InputCell(
                title: "Api",
                input: self.$ckcURL
            )
            InputCell(
                title: "ContentId",
                input: self.$contentId
            )
            InputCell(
                title: "Path",
                input: self.$videoPath
            )
            FillButton(text: "go") { _ in
                self.playerModel.drm = FairPlayDrm(
                    contentId: self.contentId,
                    ckcURL: self.ckcURL)
                self.playerModel.event = .load(self.videoPath, true)
            }
            .padding(.bottom, 20)
            
            
        }//VStack
        .modifier(ContentEdges())
        .background(Color.brand.bg)
        
        .onAppear{
            
             
        }
    }//body
    
    func onPageReload() {
        PageLog.log("PAGE  VIEW EVENT")
    }
    
}


#if DEBUG
struct PagePlayerTest_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePlayerTest().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

