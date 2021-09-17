//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI



struct SimplePlayer: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    
    var title:String? = nil
    var thumbImage:String? = nil
    var thumbContentMode:ContentMode = .fit
    var contentID:String? = nil
    var listData:PlayListData = PlayListData()
    var type:BtvPlayerType = .normal
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                ZStack(alignment:.bottom){
                    CPPlayer(
                        viewModel : self.viewModel,
                        pageObservable: self.pageObservable,
                        isSimple: true)
                    
                    //PlayerEffect(viewModel: self.viewModel)
                    PlayerTop(viewModel: self.viewModel, title: self.title, isSimple: true)
                    //PlayerOptionSelectBox(viewModel: self.viewModel)
                    //PlayerGuide(viewModel: self.viewModel)
                }
                .opacity(self.isWaiting == false ? 1.0 : 0)
                PlayerWaiting(
                    pageObservable:self.pageObservable,
                    viewModel: self.viewModel, imgBg: self.thumbImage, contentMode: self.thumbContentMode)
                    .opacity(self.isWaiting == true ? 1.0 : 0)
                
            }
            .modifier(MatchParent())
            .background(Color.app.black)
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                if !self.viewModel.useFullScreenAction { return }
                if self.viewModel.isLock { return }
                if SystemEnvironment.isTablet  { return }
                
                switch self.sceneObserver.sceneOrientation {
                case .landscape : self.pagePresenter.fullScreenEnter(isLock: true, changeOrientation: .landscape)
                case .portrait : self.pagePresenter.fullScreenExit(changeOrientation: .portrait)
                }
            
            }
            
            .onReceive(self.viewModel.$event) { evt in
                guard let evt = evt else { return }
                switch evt {
                case .mute(let isMute) : BtvPlayerModel.isInitMute = isMute
                case .volume : BtvPlayerModel.isInitMute = false
                case .resume :
                    if self.isWaiting != false {
                        self.continuousPlay()
                    }
                    
                case .pause :
                    self.recoveryTime = self.viewModel.time
                default : break
                }
            }
            .onReceive(self.viewModel.$selectQuality){ quality in
                guard let quality = quality else {return}
                self.viewModel.selectedQuality = quality.name
                self.viewModel.currentQuality = quality
            }
            .onReceive(self.viewModel.$currentQuality){ quality in
                if quality == nil { return }
                let autoPlay = self.viewModel.initPlay ?? self.setup.autoPlay
                if self.viewModel.time > 1 { //화질전환 이어보기
                    self.viewModel.continuousTime = self.viewModel.time
                }
                ComponentLog.d("autoPlay " + autoPlay.description, tag: self.tag)
                if autoPlay {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.05){
                        self.initPlayer()
                    }
                } else  {
                    withAnimation{ self.isWaiting = true }
                }
                
            }
            .onReceive(self.viewModel.$btvUiEvent) { evt in
                guard let evt = evt else { return }
                    switch evt {
                    case .initate :
                        self.initPlayer()
                    default : break
                }
            }
            .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
                self.isFullScreen = fullScreen
            }
            
            .onAppear(){
                if BtvPlayerModel.isInitMute {
                    self.viewModel.isMute = true
                }
            }
            .onDisappear(){
               // self.viewModel.event = .stop
            }
        }//geo
    }//body
    
    
    @State var isWaiting:Bool? = nil
    @State var recoveryTime:Double = 0
    @State var isPreroll:Bool = false
    @State var isFullScreen:Bool = false
    
    func initPlayer(){
        if self.setup.dataAlram && self.networkObserver.status == .cellular {
            self.appSceneObserver.event = .toast(String.alert.dataNetwork)
        }
        ComponentLog.d("initPlayer", tag: self.tag)
        withAnimation{ self.isWaiting = false }
        self.initPlay()
    }
    
    func continuousPlay(){
        
        withAnimation{ self.isWaiting = false }
        self.viewModel.continuousTime = self.recoveryTime
        self.initPlay()
    }
    
    func initPlay(){
        ComponentLog.d("initPlay", tag: self.tag)
        if self.isPreroll {
            self.isPreroll = false
            self.viewModel.isPrerollPlay = false
        }
        guard let quality = self.viewModel.currentQuality else {
            self.viewModel.event = .stop
            return
        }
        let find = quality.path.contains("?")
        let leading = find ? "&" : "?"
        let path = quality.path + leading +
            "device_id" + SystemEnvironment.deviceId +
            "&token=" + (repository.getDrmId() ?? "")
       // ComponentLog.d("path : " + path, tag: self.tag)
        let t = self.viewModel.continuousTime
        PageLog.d("initPlay continuousTime " + t.description, tag: self.tag)
        self.viewModel.event = .load(path, true , t, self.viewModel.header)
    }
}




