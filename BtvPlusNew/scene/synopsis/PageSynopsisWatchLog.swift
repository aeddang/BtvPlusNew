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
        
    }
    
    func onEvent(btvPlayerEvent:BtvPlayerEvent){
        /*
        switch btvPlayerEvent {
        case .play80 :
            self.log(type: .play80)
        case .stopAd :
            self.log(type: .stopAd)
        default: break
        }
        */
    }
    
    func onEvent(event:PlayerUIEvent){
        switch event {
        case .pause :
            self.playLog(isPlay: false)
        case .resume :
            self.playLog(isPlay: true)
        case .togglePlay :
            if self.playerModel.isPlay {
                self.playLog(isPlay: false)
            } else {
                self.playLog(isPlay: true)
            }
        default: break
        }
    }
    
    func onEvent(streamEvent:PlayerStreamEvent){
        switch streamEvent {
        case .loaded:
            self.playLog(isPlay: true)
        //case .buffer:
            //self.log(type: .buffering)
        case .stoped:
            self.playLog(isPlay: false)
            //self.log(type: .playBase)
        case .completed:
            self.playLog(isPlay: false)
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

}
