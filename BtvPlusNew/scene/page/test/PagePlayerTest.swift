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
    @EnvironmentObject var setup:Setup
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel = PlayerModel()
   
    @State var title:String = "PLAYER TEST"
    @State var listURL:String = "https://ecdn-fairplay.digicaps.dev/player/2021_mig/resource.json"
    @State var ckcURL:String = ""
    @State var contentId:String = ""
    @State var videoPath:String = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8"
    
    @State var currentInfo:AssetPlayerInfo? = nil
    @State var selectedResolution:String? = nil
    @State var selectedCaption:String? = nil
    @State var selectedAudio:String? = nil
    
    @State var debugingInfo:String? = "test debuging"
    @State var debugInfo:String? = "test debug"
    
    var body: some View {
        VStack(alignment: .leading, spacing:10)
        {
            PageTab( isClose: true)
            Text(self.debugingInfo ?? "")
                .lineLimit(1).onTapGesture {
                    UIPasteboard.general.string = self.debugingInfo
                    self.appSceneObserver.event = .toast("복사되었습니다")
                }
                .multilineTextAlignment(.leading)
                .padding(.all, 10)
                .modifier(MatchHorizontal(height: 30))
                .background(Color.app.white)
                
            Text(self.debugInfo ?? "")
                .lineLimit(1).onTapGesture {
                    UIPasteboard.general.string = self.debugInfo
                    self.appSceneObserver.event = .toast("복사되었습니다")
                }
                .multilineTextAlignment(.leading)
                .padding(.all, 10)
                .modifier(MatchHorizontal(height: 30))
                .background(Color.app.white)
            
            CPPlayer(
                viewModel : self.playerModel ,
                pageObservable : self.pageObservable)
            HStack{
                InputCell(
                    title: "List",
                    input: self.$listURL
                )
                FillButton(text: "go") { _ in
                    self.setup.listApi = self.listURL
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.playerTestList)
                            .addParam(key: .data, value: self.listURL)
                    )
                    
                }.frame(width: 100)
            }
            .padding(.all, 10)
            .background(Color.app.blueDeep)
            
            VStack{
                InputCell(
                    title: "DRM API",
                    input: self.$ckcURL
                )
                InputCell(
                    title: "DRM ID",
                    input: self.$contentId
                )
                HStack{
                    InputCell(
                        title: "Path",
                        input: self.$videoPath
                    )
                    FillButton(text: "go") { _ in
                        self.playVideo()
                    }.frame(width: 100)
                }
            }
            .padding(.all, 10)
            .background(Color.app.blueDeep)
            
            if let info = self.currentInfo {
                HStack{
                    FillButton(
                        text: self.selectedResolution ?? "Resolution",
                        isSelected: self.selectedResolution != nil
                    ) { _ in
                        
                        self.appSceneObserver.select = .select((self.tag, info.resolutions), 0){ select in
                            if info.resolutions.isEmpty {return}
                            self.selectedResolution = info.resolutions[select]
                            info.selectedResolution = self.selectedResolution
                            self.playerModel.event = .load(self.videoPath, true)
                        }
                    }
                    FillButton(
                        text: self.selectedCaption ?? "Caption",
                        isSelected: self.selectedCaption != nil
                    ) { _ in
                        self.appSceneObserver.select = .select((self.tag, info.captions), 0){ select in
                            if info.captions.isEmpty {return}
                            self.selectedCaption = info.captions[select]
                            info.selectedCaption = self.selectedCaption
                            self.playerModel.event = .load(self.videoPath, true)
                        }
                    }
                    FillButton(
                        text: self.selectedAudio ?? "Audio",
                        isSelected: self.selectedAudio != nil
                    ) { _ in
                        self.appSceneObserver.select = .select((self.tag, info.audios), 0){ select in
                            if info.audios.isEmpty {return}
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
        .onReceive(self.playerModel.$error){ error in
            guard let error = error else {return}
            switch error { 
            case .connect(let msg) :
                self.debugInfo = "connect error : " + msg
            case .illegalState(let evt) :
                self.debugingInfo = "illegalState : " + evt.decription
            case .stream(let err) :
                self.debugInfo = "stream error : " + err.getDescription()
            case .drm(let err):
                self.debugInfo = "drm error : " + err.getDescription()
            }
        }
        .onReceive(self.pagePresenter.$event){ evt in
            guard let evt = evt else {return}
            if evt.id != "PagePlayerTestList" {return}
            switch evt.type {
            case .selected :
                guard let item = evt.data as? VideoListData else { return } 
                self.contentId = item.contentId ?? ""
                self.ckcURL = item.ckcURL ?? ""
                self.videoPath = item.videoPath
                self.playVideo()
            default : break
            }
        }
        .onAppear{
            
             
        }
    }//body
    
   
    
    func playVideo(){
        self.debugingInfo = nil
        self.debugInfo = nil
        
        if !self.contentId.isEmpty && !self.ckcURL.isEmpty {
            let drm = FairPlayDrm(
                ckcURL: self.ckcURL,
                certificateURL:self.ckcURL
            )
            drm.certificate = self.playerModel.drm?.certificate
            self.playerModel.drm = drm
        } else {
            self.playerModel.drm = nil
        }

        self.setup.drmApi = self.ckcURL
        self.setup.videoPath = self.videoPath
        
        self.playerModel.event = .load(self.videoPath, true)
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

