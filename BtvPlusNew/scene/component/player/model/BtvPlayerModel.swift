//
//  BtvPlayerModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/09.
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
    case progress, volume, brightness, playList
}

enum SelectOptionType:String {
    case quality, rate, ratio
}
enum BtvUiEvent {
    case more, guide, initate, closeList
}

enum BtvPlayerEvent {
    case nextView, continueView, changeView(String), close
}

enum BtvPlayerType {
    case full, simple
}

class BtvPlayerModel:PlayerModel{
    @Published var brightness:CGFloat = UIScreen.main.brightness
    @Published var seeking:Double = 0
    @Published private(set) var message:String? = nil
    
    @Published var currentQuality:Quality? = nil
    @Published var selectFunctionType:SelectOptionType? = nil
    @Published var btvUiEvent:BtvUiEvent? = nil {didSet{ if btvUiEvent != nil { btvUiEvent = nil} }}
    @Published var btvPlayerEvent:BtvPlayerEvent? = nil {didSet{ if btvPlayerEvent != nil { btvPlayerEvent = nil} }}
    
    private(set) var synopsisPlayerData:SynopsisPlayerData? = nil
    private(set) var synopsisPrerollData:SynopsisPrerollData? = nil
    private(set) var openingTime:Double = 0
    var continuousTime:Double = 0
    var checkPreroll = true
    var isPrerollPlay = false
    
    private(set) var playData:PlayInfo? = nil
    private(set) var btvPlayType:BtvPlayType? = nil
    private(set) var qualitys:[Quality] = []
    private(set) var header:[String:String]? = nil
    var initPlay:Bool? = nil
    var isFirstPlay:Bool = true
    
    var currentEpsdRsluId:String? = nil
    var currentIdx:Int? = nil
    
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
        self.playData = nil
        self.btvPlayType = nil
        super.reset()
    }
    
    func resetCurrentPlayer() {
        self.currentEpsdRsluId = nil
        self.currentIdx = nil
        self.playData = nil
        self.btvPlayType = nil
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
    func setData(data:PlayInfo, type:BtvPlayType, autoPlay:Bool? = nil, continuousTime:Double? = nil) -> BtvPlayerModel {
        let isPrevPlay = self.isPlay
        self.reset()
        self.playData = data
        self.btvPlayType = type
        var header = [String:String]()
        header["x-ids-cinfo"] = type.type + "," + type.cid + "," + type.title
        self.header = header
        if let playData = self.synopsisPlayerData {
            self.playInfo = playData.type.name
            switch playData.type {
            case .preplay(let autoPlay):
                if let prevTime = data.PREVIEW_TIME {
                    let limited = Double(prevTime.toInt())
                    self.limitedDuration = limited
                    self.playInfo = limited.secToMin() + String.app.min + " " + (playData.type.name ?? "")
                }
                self.initPlay = autoPlay
            case .preview(_, let autoPlay):
                self.initPlay = autoPlay
            case .vodNext(let t, let autoPlay), .vodChange(let t, let autoPlay):
                self.openingTime = playData.openingTime ?? 0
                self.continuousTime = t
                self.initPlay = autoPlay
            case .vod(let t, let autoPlay):
                self.openingTime = playData.openingTime ?? 0
                self.continuousTime = t
                self.initPlay = autoPlay
            default: do{}
            }
        }
        if let autoPlay = autoPlay {
            ComponentLog.d("force setup initPlay " + autoPlay.description , tag: self.tag)
            self.initPlay = autoPlay
        }
        if let continuousTime = continuousTime {
            ComponentLog.d("force setup continuousTime " + continuousTime.description , tag: self.tag)
            self.continuousTime = continuousTime
        }
        
        if self.isFirstPlay {
            self.isFirstPlay = false
            ComponentLog.d("first setup initPlay " + self.initPlay.debugDescription , tag: self.tag)
        }else if self.initPlay == nil{
            self.initPlay = isPrevPlay
            ComponentLog.d("auto setup initPlay " + self.initPlay.debugDescription , tag: self.tag)
        } else {
            ComponentLog.d("setup initPlay " + self.initPlay.debugDescription , tag: self.tag)
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
struct PlayListData{
    var listTitle:String? = nil
    var title:String? = nil
    var datas:[VideoData] = []
    var kidsDatas:[VideoPlayerData] = []
}