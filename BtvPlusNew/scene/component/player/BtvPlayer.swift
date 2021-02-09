//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

enum BtvPlayType {
    case preview(String), ad, vod(String, String?)
    var type: String {
        switch self {
        default: return "V"
        }
    }
    var title: String {
        switch self {
        case .preview: return "예고편"
        case .vod( _ , let title): return title ?? ""
        default: return ""
        }
    }
    var cid: String {
        switch self {
        case .preview(let epsdRsluId): return epsdRsluId
        case .vod(let epsdRsluId , _): return epsdRsluId
        default: return ""
        }
    }
}

struct Quality {
    let name:String
    let path:String
}

enum DragGestureType:String {
    case progress, volume, brightness
}

enum SelectOptionType:String {
    case quality, rate, ratio
}
enum BtvUiEvent {
    case more, guide
}


class BtvPlayerModel:PlayerModel{
    @Published fileprivate(set) var brightness:CGFloat = UIScreen.main.brightness
    @Published fileprivate(set) var seeking:Double = 0
    @Published private(set) var message:String? = nil
    
    @Published var currentQuality:Quality? = nil
    @Published var selectFunctionType:SelectOptionType? = nil
    @Published var btvUiEvent:BtvUiEvent? = nil {didSet{ if btvUiEvent != nil { btvUiEvent = nil} }}
    
    private(set) var synopsisPlayerData:SynopsisPlayerData? = nil
    private(set) var synopsisPrerollData:SynopsisPrerollData? = nil
    private(set) var openingTime:Double = 0
    fileprivate(set) var continuousTime:Double = 0
    fileprivate(set) var checkPreroll = true
    private(set) var qualitys:[Quality] = []
    private(set) var header:[String:String]? = nil
    private(set) var initPlay:Bool? = nil
    
    private func appendQuality(name:String, path:String){
        let quality = Quality(name: name, path: path)
        qualitys.append(quality)
    }
    
    override func reset() {
        self.currentQuality = nil
        self.limitedDuration = nil
        self.continuousTime = 0
        self.openingTime = 0
        self.seeking = 0
        self.qualitys = []
        self.header = nil
        self.initPlay = nil
        super.reset()
    }
    
    @discardableResult
    func setData(synopsisPrerollData:SynopsisPrerollData?) -> BtvPlayerModel {
        self.synopsisPrerollData = synopsisPrerollData
        self.checkPreroll = true
        return self
    }
    
    @discardableResult
    func setData(synopsisPlayData:SynopsisPlayerData?) -> BtvPlayerModel {
        self.synopsisPlayerData = synopsisPlayData
        return self
    }
    
    @discardableResult
    func setData(data:PlayInfo, type:BtvPlayType) -> BtvPlayerModel {
        self.reset()
        var header = [String:String]()
        header["x-ids-cinfo"] = type.type + "," + type.cid + "," + type.title
        self.header = header
        if let playData = self.synopsisPlayerData {
            self.playInfo = playData.type.name
            switch playData.type {
            case .preplay:
                if let prevTime = data.PREVIEW_TIME {
                    self.limitedDuration = Double(prevTime.toInt())
                }
            case .preview(let count):
                if count > 0{ self.initPlay = true }
                
            case .vodNext(let t), .vodChange(let t):
                self.openingTime = playData.openingTime ?? 0
                self.continuousTime = t
                self.initPlay = true
            
            case .vod(let t):
                self.openingTime = playData.openingTime ?? 0
                self.continuousTime = t
                
            default: do{}
            }
        }
        
        if let auto = data.CNT_URL_NS_AUTO { self.appendQuality(name: "AUTO", path: auto) }
        if let fhd = data.CNT_URL_NS_FHD { self.appendQuality(name: "FHD", path: fhd) }
        if let hd = data.CNT_URL_NS_HD  { self.appendQuality(name: "HD", path: hd) }
        if let sd = data.CNT_URL_NS_SD  { self.appendQuality(name: "SD", path: sd) }
        if !qualitys.isEmpty {
            currentQuality = qualitys.first{$0.name == "HD"}
        }
        return self
    }
    

}

struct BtvPlayer: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    @ObservedObject var prerollModel: PrerollModel = PrerollModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var title:String? = nil
    var thumbImage:String? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                ZStack{
                    CPPlayer( viewModel : self.viewModel)
                    PlayerEffect(viewModel: self.viewModel)
                    PlayerTop(viewModel: self.viewModel, title: self.title)
                    PlayerBottom(viewModel: self.viewModel)
                    PlayerOptionSelectBox(viewModel: self.viewModel)
                    PlayerGuide(viewModel: self.viewModel)
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged({ value in
                            if self.viewModel.isLock { return }
                            if let type = dragGestureType {
                                switch type {
                                case .brightness: self.onBrightnessChange(value: value)
                                case .volume: self.onVolumeChange(value: value)
                                case .progress: self.onProgressChange(value: value)
                                }
                            }else {
                                let diffX = value.translation.width
                                let diffY = value.translation.height
                                if abs(diffX) > abs(diffY) {
                                    self.dragGestureType = .progress
                                }else{
                                    let half = geometry.size.width/2
                                    let posX = value.startLocation.x
                                    if posX > half {self.dragGestureType = .volume}
                                    else {self.dragGestureType = .brightness}
                                }
                                self.viewModel.playerUiStatus = .hidden
                        
                            }
                        })
                        .onEnded({ value in
                            if self.dragGestureType == .progress {
                                self.viewModel.event = .seekMove(self.viewModel.seeking, false)
                                self.viewModel.seeking = 0
                            }
                            self.resetDragGesture()
                        })
                )
                .gesture(
                    MagnificationGesture(minimumScaleDelta: 0).onChanged { val in
                        if self.viewModel.isLock { return }
                        self.onRatioChange(value: val)
                    }.onEnded { val in
                        self.resetDragGesture()
                        self.isChangeRatioCancel = false
                    }
                )
                
                if self.isPreroll {
                    Preroll(viewModel: self.prerollModel)
                }else if self.isWaiting {
                    PlayerWaiting(
                        pageObservable:self.pageObservable,
                        viewModel: self.viewModel, imgBg: self.thumbImage)
                }
            }
            .modifier(MatchParent())
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                if self.viewModel.isLock { return }
                
                switch self.sceneObserver.sceneOrientation {
                case .landscape : self.pagePresenter.fullScreenEnter()
                case .portrait : self.pagePresenter.fullScreenExit()
                }
            }
            .onReceive(self.viewModel.$playerStatus) { status in
                guard let status = status else { return }
                switch status {
                case .resume:
                    if self.isWaiting {
                        withAnimation{ self.isWaiting = false }
                    }
                default : do{}
                }
            }
            .onReceive(self.viewModel.$event) { evt in
                guard let evt = evt else { return }
                switch evt {
                case .seeking(let willTime):
                    let diff =  willTime - self.viewModel.time
                    self.viewModel.seeking = diff
                default : do{}
                }
            }
            .onReceive(self.viewModel.$currentQuality){ quality in
                if self.viewModel.checkPreroll {
                    self.viewModel.checkPreroll = false
                    if let data = self.viewModel.synopsisPrerollData {
                        self.isPreroll = true
                        self.prerollModel.request = .load(data)
                        return
                    }
                }
                self.initPlayer()
                
            }
            .onReceive(self.prerollModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .finish : self.initPlayer()
                default : do{}
                }
            }
            .onAppear(){
                if !Preroll.isInit { Preroll.initate() }
            }
            .onDisappear(){
                self.pagePresenter.fullScreenExit()
            }
        }//geo
    }//body
    
    func initPlayer(){
        ComponentLog.d("initPlayer", tag: self.tag)
        self.isPreroll = false
        guard let quality = self.viewModel.currentQuality else {
            self.viewModel.event = .stop
            return
        }
        let find = quality.path.contains("?")
        let leading = find ? "&" : "?"
        let path = quality.path + leading +
            "device_id" + SystemEnvironment.getGuestDeviceId() +
            "&token=" + (repository.getDrmId() ?? "")
        ComponentLog.d("path : " + path, tag: self.tag)
        
        let autoPlay = self.viewModel.initPlay ?? self.setup.autoPlay
        withAnimation{ self.isWaiting = !autoPlay }
        let t = self.viewModel.continuousTime > 0 ? self.viewModel.continuousTime : self.viewModel.time
        self.viewModel.continuousTime = 0
        self.viewModel.event = .load(path, autoPlay , t, self.viewModel.header)
    }
    
    @State var isWaiting:Bool = true
    @State var isPreroll:Bool = false
    @State var dragGestureType:DragGestureType? = nil
    @State var startSeeking:Double = -1
    @State var startVolume:Float = -1
    @State var startBrightness:CGFloat = -1
    @State var startRatio:CGFloat = -1
    @State var isChangeRatioCancel = false
    
    func resetDragGesture(){
        self.startSeeking = -1
        self.startVolume = -1
        self.startBrightness = -1
        self.startRatio = -1
        self.dragGestureType = nil
    }
    
    func onRatioChange(value:CGFloat){
        if self.isChangeRatioCancel { return }
        if self.startRatio == -1 {self.startRatio = self.viewModel.screenRatio }
        let diff = value - 2
        var targetRatio = self.startRatio + diff
        //ComponentLog.d("onRatioChange " + targetRatio.description, tag: self.tag)
        if self.viewModel.screenGravity == .resizeAspect {
            if targetRatio > 1.0 {
                self.viewModel.event = .screenRatio(1)
                self.viewModel.event = .screenGravity(.resizeAspectFill)
                self.isChangeRatioCancel = true
                //ComponentLog.d("onRatioChange resizeAspectFil", tag: self.tag)
                return
            }
        }else {
            if targetRatio < 0.0 {
                self.viewModel.event = .screenRatio(1)
                self.viewModel.event = .screenGravity(.resizeAspect)
                self.isChangeRatioCancel = true
                //ComponentLog.d("onRatioChange resizeAspect", tag: self.tag)
                return
            }
        }
        targetRatio = min(3.0, targetRatio)
        targetRatio = max(1.0, targetRatio)
        
        self.viewModel.event = .screenRatio(targetRatio)
    }
    
    func onProgressChange(value:DragGesture.Value){
        if self.startSeeking == -1 {self.startSeeking = self.viewModel.seeking }
        let diff = Double(value.translation.width/1)
        self.viewModel.seeking = self.startSeeking + Double(diff)
    }
    
    func onVolumeChange(value:DragGesture.Value){
        if self.startVolume  == -1 {self.startVolume  = self.viewModel.volume }
        let diff = Float(value.translation.height/200)
        var targetVolume = self.startVolume - diff
        targetVolume = max(0, targetVolume)
        targetVolume = min(1, targetVolume)
        self.viewModel.event = .volume(targetVolume)
    }
    
    func onBrightnessChange(value:DragGesture.Value){
        if self.startBrightness  == -1 {self.startBrightness  = UIScreen.main.brightness }
        let diff = CGFloat(value.translation.height/200)
        var targetBrightness  = self.startBrightness - diff
        targetBrightness = max(0, targetBrightness)
        targetBrightness = min(1, targetBrightness)
        UIScreen.main.brightness = targetBrightness
        self.viewModel.brightness = targetBrightness
    }
}


#if DEBUG
struct BtvPlayer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            BtvPlayer()
                .environmentObject(Repository())
                .environmentObject(Setup())
                .environmentObject(SceneObserver())
                .environmentObject(PagePresenter())
                .environmentObject(Pairing())
                .modifier(MatchParent())
        }
    }
}
#endif

