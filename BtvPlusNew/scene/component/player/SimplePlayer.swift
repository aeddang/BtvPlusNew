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
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    @ObservedObject var prerollModel: PrerollModel = PrerollModel()
    
    var title:String? = nil
    var thumbImage:String? = nil
    var thumbContentMode:ContentMode = .fit
    var contentID:String? = nil
    var listData:PlayListData = PlayListData()
    var type:BtvPlayerType = .full
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                ZStack(alignment:.bottom){
                    CPPlayer( viewModel : self.viewModel, isSimple: true)
                    PlayerEffect(viewModel: self.viewModel)
                    PlayerTop(viewModel: self.viewModel, title: self.title, isSimple: true)
                    PlayerOptionSelectBox(viewModel: self.viewModel)
                    PlayerGuide(viewModel: self.viewModel)
                }
                .opacity(self.isWaiting == false ? 1.0 : 0)
                if self.isPreroll {
                    Preroll(viewModel: self.prerollModel)
                }
                PlayerWaiting(
                    pageObservable:self.pageObservable,
                    viewModel: self.viewModel, imgBg: self.thumbImage, contentMode: self.thumbContentMode)
                    .opacity(self.isWaiting == true ? 1.0 : 0)
                
            }
            .modifier(MatchParent())
            .background(Color.app.black)
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                if self.viewModel.isLock { return }
                switch self.sceneObserver.sceneOrientation {
                case .landscape : self.pagePresenter.fullScreenEnter()
                case .portrait : self.pagePresenter.fullScreenExit()
                }
            }
            
            .onReceive(self.viewModel.$event) { evt in
                guard let evt = evt else { return }
                switch evt {
                    
                case .resume :
                    if self.isPrerollPause {
                        self.isPrerollPause = false
                        self.initPlayer()
                    }
                    if self.isWaiting != false {
                        self.continuousPlay()
                    }
                    
                case .pause :
                    if self.isPreroll {
                        self.isPrerollPause = true
                        self.isPreroll = false
                        self.viewModel.isPrerollPlay = false
                        withAnimation{ self.isWaiting = true }
                    }else{
                        self.recoveryTime = self.viewModel.time
                    }
                default : do{}
                }
            }
            .onReceive(self.viewModel.$currentQuality){ quality in
                self.viewModel.event = .stop
                if self.isPreroll {
                    self.isPreroll = false
                    self.viewModel.isPrerollPlay = false
                    if self.viewModel.initPlay == nil {
                        ComponentLog.d("auto setup initPlay preroll" , tag: self.tag)
                        self.viewModel.initPlay = true
                    }
                }
                if quality == nil { return }
                let autoPlay = self.viewModel.initPlay ?? self.setup.autoPlay
                ComponentLog.d("autoPlay " + autoPlay.description, tag: self.tag)
                if autoPlay {
                    self.initPlayer()
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
            .onReceive(self.prerollModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .finish :
                    self.initPlay()
                default : do{}
                }
            }
            .onAppear(){
                if !Preroll.isInit { Preroll.initate() }
            }
            .onDisappear(){
    
            }
        }//geo
    }//body
    
    
    @State var isWaiting:Bool? = nil
    @State var isPrerollPause:Bool = false
    @State var recoveryTime:Double = 0
    @State var isPreroll:Bool = false
    @State var isFullScreen:Bool = false
    
    func initPlayer(){
        ComponentLog.d("initPlayer", tag: self.tag)
        withAnimation{ self.isWaiting = false }
        if self.viewModel.checkPreroll {
            self.viewModel.checkPreroll = false
            if let data = self.viewModel.synopsisPrerollData {
                if !self.isPreroll {
                    self.isPreroll = true
                    self.viewModel.isPrerollPlay = true
                }
                ComponentLog.d("initPreroll", tag: self.tag)
                self.prerollModel.request = .load(data)
                return
            }
        }
       
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
            "device_id" + SystemEnvironment.getGuestDeviceId() +
            "&token=" + (repository.getDrmId() ?? "")
       // ComponentLog.d("path : " + path, tag: self.tag)
        let t = self.viewModel.continuousTime > 0 ? self.viewModel.continuousTime : self.viewModel.time
        self.viewModel.event = .load(path, true , t, self.viewModel.header)
    }
}




