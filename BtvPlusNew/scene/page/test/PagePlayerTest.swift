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
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel = PlayerModel()
   
    @State var ckcURL:String = ""
    @State var contentId:String = ""
    @State var videoPath:String = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8"
    
    @State var currentInfo:AssetPlayerInfo? = nil
    @State var selectedResolution:String? = nil
    @State var selectedCaption:String? = nil
    @State var selectedAudio:String? = nil
    
    @State var debugingInfo:String? = nil
    @State var debugInfo:String? = nil
    
    var body: some View {
        VStack(alignment: .center, spacing:10)
        {
            PageTab( isClose: true)
            Text(self.debugingInfo ?? "")
                .lineLimit(1).onTapGesture {
                    UIPasteboard.general.string = self.debugingInfo
                }
            Text(self.debugInfo ?? "")
                .lineLimit(1).onTapGesture {
                    UIPasteboard.general.string = self.debugInfo
                }
            CPPlayer(
                viewModel : self.playerModel ,
                pageObservable : self.pageObservable)
            InputCell(
                title: "DRM API",
                input: self.$ckcURL
            )
            InputCell(
                title: "DRM ID",
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
            if let info = self.currentInfo {
                VStack{
                    FillButton(
                        text: "resolution " + (self.selectedResolution ?? "Auto"),
                        isSelected: self.selectedResolution != nil
                    ) { _ in
                        
                        self.appSceneObserver.select = .select((self.tag, info.resolutions), 0){ select in
                            self.selectedResolution = info.resolutions[select]
                            info.selectedResolution = self.selectedResolution
                            self.playerModel.event = .load(self.videoPath, true)
                        }
                    }
                    FillButton(
                        text: "caption " + (self.selectedCaption ?? "Auto"),
                        isSelected: self.selectedCaption != nil
                    ) { _ in
                        self.appSceneObserver.select = .select((self.tag, info.captions), 0){ select in
                            self.selectedCaption = info.captions[select]
                            info.selectedCaption = self.selectedCaption
                            self.playerModel.event = .load(self.videoPath, true)
                        }
                    }
                    FillButton(
                        text: "audio " + (self.selectedAudio ?? "Auto"),
                        isSelected: self.selectedAudio != nil
                    ) { _ in
                        self.appSceneObserver.select = .select((self.tag, info.audios), 0){ select in
                            self.selectedAudio = info.audios[select]
                            info.selectedAudio = self.selectedAudio
                            self.playerModel.event = .load(self.videoPath, true)
                        }
                    }
                }
            }
            
        }//VStack
        .padding(.vertical, Dimen.margin.medium)
        .modifier(ContentEdges())
        .background(Color.brand.bg)
        .onReceive(self.playerModel.$assetInfo){ info in
            self.currentInfo = info
        }
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

