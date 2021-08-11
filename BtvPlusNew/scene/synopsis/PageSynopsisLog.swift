//
//  PageSynopsisWatchLog.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/29.
//

import Foundation
import SwiftUI
extension PageSynopsis {
   
    func onEvent(btvUiEvent:BtvUiEvent){
        switch btvUiEvent {
        case .guide :
            self.naviLog(pageID: .playTouchGuide, action: .pageShow , category:nil)
        case .clickInsideButton(let action, let title) :
            self.naviLog(pageID: .playInside, action: action, category: title )
        
        case .more :
            self.naviLog(action: self.type == .btv ? .clickVodConfig : .clickVodConfigEtc, config:"etc" )
        default: break
        }
    }
    
    func onEvent(btvPlayerEvent:BtvPlayerEvent){
        
        switch btvPlayerEvent {
        case .close :
            self.naviLog(
                action: .clickPlayBackList,
                config: self.type == .btv ? self.sceneOrientation.logConfig : nil
                )
        /*
        case .play80 :
            self.log(type: .play80)
        case .stopAd :
            self.log(type: .stopAd)
        */
        default: break
        }
        
    }
    
    func onEvent(prerollEvent:PrerollEvent){
        
        switch prerollEvent {
        case .moveAd :
            self.naviLog(pageID: .play, action: .clickAdButton, category: "광고정보더보기")
        case .skipAd :
            self.naviLog(pageID: .play, action: .clickAdButton, category: "광고건너뛰기")
        default: break
        }
        
    }
    
    func onEvent(event:PlayerUIEvent){
        switch event {
        case .pause :
            self.playLog(isPlay: false)
            self.playNaviLog(action: .clickVodPause, watchType: .watchPause)
        case .resume :
            self.playLog(isPlay: true)
            self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
        case .togglePlay :
            if self.playerModel.isPlay {
                self.playLog(isPlay: false)
                self.playNaviLog(action: .clickVodPause, watchType: .watchPause)
            } else {
                self.playLog(isPlay: true)
                self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
            }
        default: break
        }
    }
    
    func onEvent(streamEvent:PlayerStreamEvent){
        switch streamEvent {
        case .loaded:
            self.playLog(isPlay: true)
            self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
        //case .buffer:
            //self.log(type: .buffering)
        case .stoped:
            self.playLog(isPlay: false)
            self.playNaviLog(action: .clickVodStop, watchType: .watchStop)
            //self.log(type: .playBase)
        case .completed:
            self.playLog(isPlay: false)
            self.playNaviLog(action: .clickVodStop, watchType: .watchStop)
            //self.log(type: .playBase)
        default: break
        }
    }
    
    func onStatus(playerStatus:PlayerStatus){
        
    }
    
    func onStatus(streamStatus:PlayerStreamStatus){
       

    }
    
    func bindWatchingData(){
        guard let model = self.synopsisModel else {
            return
        }
        self.synopsisData?.pId = model.curSynopsisItem?.prdPrcId
        self.synopsisData?.contentId = model.epsdRsluId
        self.synopsisData?.cpId = model.cpId ?? ""
        self.synopsisData?.isLimitedWatch = model.isLimitedWatch
        let purchaseModels = model.purchasedPPMItems
        self.synopsisData?.ppmIds = purchaseModels.isEmpty
            ? ""
            :  purchaseModels.dropFirst().reduce(purchaseModels.first!.prdPrcId, {$0 + "," + $1.prdPrcId})
        
    }
    
   
    func playLog(isPlay:Bool){
        switch self.synopsisPlayType {
        case .preplay : self.log(type: isPlay ? .playPreview : .stopPreview)
        default : self.log(type: isPlay ? .play : .stop)
        }
        self.playStartTime = isPlay ? AppUtil.networkTime() : nil
    }
    
   
    func log(type:LgsNetwork.PlayEventType){
        
        self.appSceneObserver.event = .toast(type.rawValue)
        guard let synopsisData = self.synopsisData else { return }
        let d = self.playerModel.duration
        let t = self.playerModel.time
        let rate = d > 0 ? t/d*100 : 0
        
        let playData = SynopsisPlayData(
            start: self.playStartTime == nil ? nil :  AppUtil.getTime(fromInt:self.playStartTime!),
            end: nil,
            position: self.playerModel.time.toTruncateDecimal(n: 0),
            rate: rate.toTruncateDecimal(n: 2))
        
        self.dataProvider.requestData(
            q: .init(type: .postWatchLog( type,
                                          playData,
                                          synopData: synopsisData,
                                          self.pairing,
                                          pcId: self.repository.storage.getPcid(),
                                          isKidZone: self.type == .kids,
                                          gubun: nil), isLog:true))
    
    }
    
    func playStartLog(){
        if self.isPlayViewActive{
            self.naviLog(
                action: .pageShow,
                category: self.synopsisPlayType.logCategory,
                result: self.synopsisData?.synopType.logResult)
        } else {
            if let synopsisModel = self.synopsisModel{
                self.naviLogManager.setupSysnopsis(synopsisModel)
            }
        }
    }
    
    func playNaviLog( action:NaviLog.action, watchType:NaviLog.watchType){
        self.naviLog(action: action, watchType: watchType)
        
    }
    
    func naviLog(pageID:NaviLog.PageId? = nil , action:NaviLog.action,
                 watchType:NaviLog.watchType? = nil,
                 config:String? = nil
                 ){
        let category = self.synopsisPlayType.logCategory
       
        self.naviLog(action: action, watchType: watchType, config: config, category: category, result: nil)
    }
    
    func naviLog(pageID:NaviLog.PageId? = nil , action:NaviLog.action,
                 watchType:NaviLog.watchType? = nil,
                 config:String? = nil,
                 category: String?, result: String? = nil
                 ){
        if action == .pageShow, let synopsisModel = self.synopsisModel{
            self.naviLogManager.setupSysnopsis(synopsisModel)
        }
        let result = result ?? self.synopsisData?.synopType.logResult
        self.naviLogManager.playerLog(
            pageID: pageID ?? (self.type == .btv ? .play : .zemPlay),
            action: action,
            watchType : watchType,
            category: category,
            result: result,
            config:config
        )
    }

}
