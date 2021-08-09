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
extension PagePlayerTest{
    static let videoPath:String = "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
    static let listURL:String = "http://1.255.85.174:9093/api/playlist/json/30"
}


struct PagePlayerTest: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var setup:Setup
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel = PlayerModel()
   
    @State var title:String = "PLAYER TEST"
    @State var rate:Float = 1.0
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
            
            
            HStack{
                InputCell(
                    title: "List",
                    input: self.$listApi
                )
                FillButton(text: "play") { _ in
                    self.setup.listApi = self.listApi
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.playerTestList)
                            .addParam(key: .data, value: self.listApi)
                    )
                    
                }.frame(width: 100)
            }
            .padding(.all, 10)
            .background(Color.app.blueDeep)
            
            HStack{
                InputCell(
                    title: "Path",
                    input: self.$videoPath
                )
                FillButton(text: "play") { _ in
                    self.videoListData = nil
                    self.playVideo()
                }.frame(width: 100)
                
            }
            .padding(.all, 10)
            .background(Color.app.blueDeep)
            ZStack(alignment: .topTrailing){
                
                CPPlayer(
                    viewModel : self.playerModel ,
                    pageObservable : self.pageObservable)
                Text(self.bitrate ?? "")
                    .modifier(MediumTextStyle(size: Font.size.light, color: Color.app.white))
                    .padding(.all, Dimen.margin.thin)
            }
            
            HStack{
                FillButton(
                    text: "X0.5",
                    isSelected: self.rate == 0.5
                ) { _ in
                    self.rate = 0.5
                    self.playerModel.event = .rate(0.5)
                }
                FillButton(
                    text: "X1.0",
                    isSelected: self.rate == 1.0
                ) { _ in
                    self.rate = 1.0
                    self.playerModel.event = .rate(1.0)
                }
                FillButton(
                    text: "X2.0",
                    isSelected: self.rate == 2.0
                ) { _ in
                    self.rate = 2.0
                    self.playerModel.event = .rate(2.0)
                }
                FillButton(
                    text: "X3.0",
                    isSelected: self.rate == 3.0
                ) { _ in
                    self.rate = 3.0
                    self.playerModel.event = .rate(3.0)
                }
            }
            
            
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
                            self.playVideo()
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
                            self.playVideo()
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
                            self.playVideo()
                        }
                    }
                    
                }
            }
            /*
            FillButton(text: "reset") { _ in
                self.reset()
            }.frame(width: 100)
            */
            
        }//VStack
        .padding(.vertical, Dimen.margin.medium)
        .modifier(ContentEdges())
        .background(Color.brand.bg)
        .onReceive(self.playerModel.$assetInfo){ info in
            self.currentInfo = info
        }
        .onReceive(self.playerModel.$bitrate){ bitrate in
            guard let bitrate = bitrate else {return}
            self.bitrate = "res : " + bitrate.description
        }
        .onReceive(self.playerModel.$error){ error in
            guard let error = error else {return}
            switch error { 
            case .connect(let msg) : self.debugInfo = "Connect : " + msg
            case .illegalState(let evt) : self.debugingInfo = "IllegalState : " + evt.decription
            case .stream(let err) : self.debugInfo = "Stream : " + err.getDescription()
            case .drm(let err): self.debugInfo = "Drm : " + err.getDescription()
            case .asset(let e) : self.debugInfo = "Asset : " + e.getDescription()
            }
        }
        .onReceive(self.pagePresenter.$event){ evt in
            guard let evt = evt else {return}
            if evt.id != "PagePlayerTestList" {return}
            switch evt.type {
            case .selected :
                guard let item = evt.data as? VideoListData else { return }
                self.videoListData = item
                self.playVideo()
            default : break
            }
        }
        .onAppear{
            if !setup.listApi.isEmpty {
                let api = setup.listApi
                self.setuplistApi = api
                self.listApi = api
            }
            if !setup.videoPath.isEmpty {
                let video = setup.videoPath
                self.setupVideoPath = video
                self.videoPath = video
            }
            setup.drmTestUser = true
        }
        .onDisappear{
            setup.listApi = self.listApi
            setup.videoPath = self.videoPath
            setup.drmTestUser = false
            
        }
    }//body
    @State var bitrate:String? = nil
    @State var setuplistApi:String? = nil
    @State var setupVideoPath:String? = nil
    @State var videoPath:String = Self.videoPath
    @State var listApi:String = Self.listURL
    @State var currentInfo:AssetPlayerInfo? = nil
    @State var selectedResolution:String? = nil
    @State var selectedCaption:String? = nil
    @State var selectedAudio:String? = nil
    
    @State var videoListData:VideoListData? = nil
    @State var debugingInfo:String? = "test debuging"
    @State var debugInfo:String? = "test debug"
    
    func reset(){
        self.currentInfo?.reset()
        self.selectedResolution = nil
        self.selectedCaption = nil
        self.selectedAudio = nil
        self.videoPath = self.setupVideoPath ?? Self.videoPath
        self.listApi = self.setuplistApi ?? Self.listURL
    }
    func playVideo(){
        self.debugingInfo = nil
        self.debugInfo = nil
        
        var playVideoPath:String = ""
        if let data = self.videoListData {
            if let ckcURL = data.ckcURL {
                let drm = FairPlayDrm(
                    ckcURL: ckcURL,
                    certificateURL: ckcURL
                )
                drm.certificate = self.playerModel.drm?.certificate
                playVideoPath = data.videoPath
                self.playerModel.drm = drm
                
            } else {
                self.playerModel.drm = nil
                playVideoPath = data.videoPath
            }
        } else {
            self.playerModel.drm = nil
            playVideoPath = self.videoPath
            self.setup.videoPath = playVideoPath
        }
        
        self.playerModel.event = .load(playVideoPath, true)
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

