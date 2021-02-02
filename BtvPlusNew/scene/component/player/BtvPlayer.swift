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

class BtvPlayerModel:PlayerModel{
    @Published fileprivate(set) var brightness:CGFloat = UIScreen.main.brightness
    @Published fileprivate(set) var seeking:Double = 0
    @Published private(set) var currentQuality:Quality? = nil
    private(set) var qualitys:[Quality] = []
    private(set) var header:[String:String]? = nil
    private func appendQuality(name:String, path:String){
        let quality = Quality(name: name, path: path)
        qualitys.append(quality)
    }
    
    func setData(data:PlayInfo, type:BtvPlayType) {
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
    }

}

struct BtvPlayer: PageComponent{
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                CPPlayer( viewModel : self.viewModel)
                PlayerEffect(viewModel: self.viewModel)
            }
            .modifier(MatchParent())
            .gesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onChanged({ value in
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
                        self.dragGestureType = nil
                        
                    })
            )
            
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                switch self.sceneObserver.sceneOrientation{
                case .landscape : self.pagePresenter.fullScreenEnter()
                case .portrait :
                    self.pagePresenter.fullScreenExit()
                    self.viewModel.event = .neetLayoutUpdate
                }
            }
            .onReceive(self.viewModel.$event) { evt in
                guard let evt = evt else { return }
                switch evt {
                case .seeking(let willTime):
                    let diff = self.viewModel.time - willTime
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
                
                self.viewModel.event = .load(path, true, self.viewModel.time, self.viewModel.header)
            }
            .onDisappear(){
                self.pagePresenter.fullScreenExit()
            }
        }//geo
    }//body
    
    
    @State var dragGestureType:DragGestureType? = nil
    func onProgressChange(value:DragGesture.Value){
        let diff = Double(value.translation.width/100)
        self.viewModel.seeking += Double(diff)
    }
    
    func onVolumeChange(value:DragGesture.Value){
        let diff = Float(value.translation.height/5000)
        var targetVolume = self.viewModel.volume - diff
        targetVolume = max(0, targetVolume)
        targetVolume = min(1, targetVolume)
        self.viewModel.event = .volume(targetVolume)
    }
    
    func onBrightnessChange(value:DragGesture.Value){
        let current = UIScreen.main.brightness
        let diff = CGFloat(value.translation.height/5000)
        var targetBrightness  = current - diff
        targetBrightness = max(0, targetBrightness)
        targetBrightness = min(1, targetBrightness)
        UIScreen.main.brightness = targetBrightness
        self.viewModel.brightness = targetBrightness
    }
}

/*
#if DEBUG
struct BtvPlayer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            BtvPlayer()
                .environmentObject(Repository())
                .environmentObject(SceneObserver())
                .environmentObject(PagePresenter())
                .environmentObject(Pairing())
                .modifier(MatchParent())
        }
    }
}
#endif
*/
