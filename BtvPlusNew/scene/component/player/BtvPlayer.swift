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
    @Published var synopsisPlayerData:SynopsisPlayerData? = nil
    
    private(set) var qualitys:[Quality] = []
    private(set) var header:[String:String]? = nil
    private func appendQuality(name:String, path:String){
        let quality = Quality(name: name, path: path)
        qualitys.append(quality)
    }
    @discardableResult
    func setData(data:PlayInfo, type:BtvPlayType) -> BtvPlayerModel {
        var header = [String:String]()
        header["x-ids-cinfo"] = type.type + "," + type.cid + "," + type.title
        self.header = header
        self.qualitys = []
        self.currentQuality = nil
        if let auto = data.CNT_URL_NS_AUTO { self.appendQuality(name: "AUTO", path: auto) }
        if let fhd = data.CNT_URL_NS_FHD { self.appendQuality(name: "FHD", path: fhd) }
        if let hd = data.CNT_URL_NS_HD  { self.appendQuality(name: "HD", path: hd) }
        if let sd = data.CNT_URL_NS_SD  { self.appendQuality(name: "SD", path: sd) }
        if !qualitys.isEmpty {
            currentQuality = qualitys.first{$0.name == "HD"}
        }
        return self
    }
    @discardableResult
    func setData(synopsisPlayData:SynopsisPlayerData?) -> BtvPlayerModel {
        guard let data = synopsisPlayData else {
            return self
        }
        self.synopsisPlayerData = data
        self.playInfo = data.type.name
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
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var title:String? = nil
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                CPPlayer( viewModel : self.viewModel)
                PlayerEffect(viewModel: self.viewModel)
                PlayerBottom(viewModel: self.viewModel)
                PlayerTop(viewModel: self.viewModel, title: self.title)
                PlayerOptionSelectBox(viewModel: self.viewModel)
                PlayerGuide(viewModel: self.viewModel)
            }
            .modifier(MatchParent())
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
                case .seeking(let willTime):
                    let diff =  willTime - self.viewModel.time
                    self.viewModel.seeking = diff
                default : do{}
                }
            }
            .onReceive(self.viewModel.$currentQuality){ quality in
                guard let quality = quality else {
                    self.viewModel.event = .stop
                    return
                }
                let find = quality.path.contains("?")
                let leading = find ? "&" : "?"
                let path = quality.path + leading +
                    "device_id" + SystemEnvironment.getGuestDeviceId() +
                    "&token=" + (repository.getDrmId() ?? "")
                ComponentLog.d("path : " + path, tag: self.tag)
                
                self.viewModel.event = .load(path, self.setup.autoPlay , self.viewModel.time, self.viewModel.header)
            }
            .onDisappear(){
                self.pagePresenter.fullScreenExit()
            }
        }//geo
    }//body
    
    
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

