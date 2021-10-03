//
//  BtvPlayerModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/09.
//

import Foundation
import SwiftUI

enum BtvPlayType {
    case preview(String, isList:Bool = false),  vod(String, String?)
    var type: String {
        switch self {
        default: return "V"
        }
    }
    var title: String {
        switch self {
        case .preview: return "예고편"
        case .vod( _ , let title): return title ?? ""
        }
    }
    var cid: String {
        switch self {
        case .preview(let epsdRsluId, _): return epsdRsluId
        case .vod(let epsdRsluId , _): return epsdRsluId
        }
    }
    
}

struct Quality {
    var name:String
    let path:String
    let drmLicense:String?
}

enum DragGestureType:String {
    case progress, volume, brightness, playList
}

enum SelectOptionType:String {
    case quality, rate, ratio
}
enum BtvUiEvent {
    case more, guide, initate, closeList, watchBtv, syncListScroll,
         prevPlay
}

enum BtvLogEvent {
    case clickInsideButton(NaviLog.Action,
                           BtvPlayerEvent?,
                           config:String? = nil, result:String? = nil),
         
         clickConfigButton(NaviLog.Action,
                           config:String? = nil)
}

enum BtvPlayerEvent {
    case nextView(isAuto:Bool = false), nextViewCancel, nextViewSeason,
         continueView, changeView(String), cookieView, fullVod(SynopsisData),
         close, stopAd, play80, disablePreview
}

enum BtvPlayerType {
    case normal, simple
}

class BtvPlayerModel:PlayerModel{
   
    
    @Published var brightness:CGFloat = UIScreen.main.brightness
    @Published private(set) var message:String? = nil
    @Published var selectQuality:Quality? = nil
    @Published var willCurrentQuality:Quality? = nil
    @Published var currentQuality:Quality? = nil
    
    @Published var selectFunctionType:SelectOptionType? = nil
    @Published var btvUiEvent:BtvUiEvent? = nil {didSet{ if btvUiEvent != nil { btvUiEvent = nil} }}
    @Published var btvLogEvent:BtvLogEvent? = nil {didSet{ if btvLogEvent != nil { btvLogEvent = nil} }}
    @Published var btvPlayerEvent:BtvPlayerEvent? = nil {didSet{ if btvPlayerEvent != nil { btvPlayerEvent = nil} }}
    @Published var isPrerollPlay = false
    
    private(set) var synopsisPlayerData:SynopsisPlayerData? = nil
    private(set) var synopsisPrerollData:SynopsisPrerollData? = nil
    private(set) var openingTime:Double = 0
    private(set) var endingTime:Double = -1
    private(set) var useInside:Bool = false
    
    var continuousTime:Double = 0
    var continuousProgress:Float? = nil
    var continuousProgressTime:Double? = nil
    var isContinuous:Bool {
        if continuousTime > 0 {return true}
        if continuousProgress != nil {return true}
        if continuousProgressTime != nil {return true}
        return false
    }
    
    
    
    private(set) var playData:PlayInfo? = nil
    private(set) var fullVod:SynopsisData? = nil
    private(set) var btvPlayType:BtvPlayType? = nil
    private(set) var qualitys:[Quality] = []
    private(set) var isFullVod:Bool = false
    
    var checkPreroll = true
   
    var pageType:PageType = .btv
    var initPlay:Bool? = nil
    var isFirstPlay:Bool = true
    var isPlay80:Bool = false
    var selectedQuality:String? = nil
    
    static var isInitMute:Bool = true
    
    override func reset() {
        self.willCurrentQuality = nil
        self.currentQuality = nil
        self.limitedDuration = nil
        self.continuousTime = 0
        self.openingTime = 0
        self.endingTime = 0
        self.seeking = 0
        self.qualitys = []
        
        //self.initPlay = nil
        self.playData = nil
        self.btvPlayType = nil
        self.isPlay80 = false
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
    func setData(data:PlayInfo,
                 type:BtvPlayType,
                 autoPlay:Bool? = nil,
                 continuousTime:Double? = nil,
                 isAutoStart:Bool = true
    ) -> BtvPlayerModel {
        
        let isPrevPlay = self.isUserPlay
        ComponentLog.d("isUserPlay " + self.isUserPlay.description  , tag: self.tag)
        self.reset()
        self.playData = data
        self.btvPlayType = type
        
        var useDrm:Bool = false
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
                
            case .clip( let autoPlay, let fullVod):
                self.initPlay = autoPlay
                self.fullVod = fullVod
                //self.useInside = true
                
            case .vod(let t, let autoPlay), .vodChange(let t, let autoPlay):
                self.openingTime = playData.openingTime ?? -1
                self.endingTime = playData.endingTime ?? -1
                self.continuousTime = t
                self.initPlay = autoPlay
                self.useInside = true
                self.isFullVod = true
                useDrm = true
            case .vodNext(let t, let autoPlay):
                self.openingTime = playData.openingTime ?? -1
                self.endingTime = playData.endingTime ?? -1
                self.continuousTime = t == 0 ? self.openingTime : t
                self.isFullVod = true
                self.initPlay = autoPlay
                self.useInside = true
                useDrm = true
            default: break
            }
        }
        if useDrm {
            var header = [String:String]()
            header["x-ids-cinfo"] = type.type + "," + type.cid + "," + type.title
            self.header = header
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
        ComponentLog.d("setup continuousTime " + self.continuousTime.debugDescription , tag: self.tag)
        if let auto = data.CNT_URL_NS_AUTO {
            self.appendQuality(name: "AUTO", path: auto, drmLicense:data.HLS_AUTO_LICENSE_URL ) }
        if let sd = data.CNT_URL_NS_SD  {
            self.appendQuality(name: "SD", path: sd, drmLicense:data.HLS_SD_LICENSE_URL) }
        if let hd = data.CNT_URL_NS_HD  {
            self.appendQuality(name: "HD", path: hd, drmLicense:data.HLS_HD_LICENSE_URL) }
        if let fhd = data.CNT_URL_NS_FHD {
            self.appendQuality(name: "FHD", path: fhd, drmLicense:data.HLS_FHD_LICENSE_URL) }
       
        if !qualitys.isEmpty {
            var lowQuality = "SD"
            if qualitys.count == 1 && qualitys.first?.name == "SD"{
                qualitys[0].name = "HD"
                lowQuality = "HD"
            }
            var selectQuality = self.selectedQuality ?? "AUTO"
            switch self.btvPlayType {
            case .preview(_, let isList) :
                selectQuality = isList ? lowQuality : selectQuality
            default : break
            }
            willCurrentQuality = qualitys.first{$0.name == selectQuality}
            if willCurrentQuality == nil {
                willCurrentQuality = qualitys.first
                ComponentLog.d("firstQuality " + selectQuality, tag:self.tag)
            } else {
                ComponentLog.d("selectQuality " + selectQuality, tag:self.tag)
            }
            
            if isAutoStart {
                self.currentQuality = willCurrentQuality
            }
            /*
            if qualitys.count > 1 {
                self.recoveryPath = qualitys.first(where: {$0.name != selectQuality})?.path
            }*/
        }
        return self
    }
    func start(){
        if let q = willCurrentQuality {
            self.currentQuality = q
        } else{
            ComponentLog.e("willCurrentQuality nil", tag:self.tag)
        }
        
    }
    
    private func appendQuality(name:String, path:String, drmLicense:String?){
        if path.isEmpty {return}
        if SystemEnvironment.isStage {
            let quality = Quality(name: name, path: path, drmLicense:drmLicense)
            qualitys.append(quality)
        } else {
            let quality = Quality(name: name, path: path, drmLicense:nil)
            qualitys.append(quality)
        }
      
        
    }
}
struct PlayListData{
    var listTitle:String? = nil
    var title:String? = nil
    var datas:[PlayerListData] = []
}
