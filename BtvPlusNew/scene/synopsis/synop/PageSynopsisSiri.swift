//
//  PageSynopsisSiri.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/15.
//

import Foundation
import Intents

extension PageSynopsis {
    func onSiri(){
        let activity = NSUserActivity(activityType: Self.shortcutType)
        guard let epsdId = self.epsdId  else { return }
        let isExistContentId = activity.externalMediaContentIdentifier == nil
            ? false
            : activity.externalMediaContentIdentifier?.contains(epsdId) ?? false 
                  
        if isExistContentId {
            activity.resignCurrent()
        }
        activity.externalMediaContentIdentifier = epsdId
        activity.becomeCurrent()
        
    }
    
    func onAllProgressCompletedSiri(){
        guard let epsdId = self.epsdId else {return}
        if !self.setup.autoPlay || !self.isPlayAble {
            let activity = NSUserActivity(activityType: Self.shortcutType)
            activity.externalMediaContentIdentifier = epsdId 
        }
    }
    
    func onDurationSiri(duration:Double){
        guard let epsdId = self.epsdId else {return}
        if duration > 1 {
            self.universalSearchManager.updateMetaData(
                contentId: epsdId,
                title: self.episodeViewerData?.episodeTitle ?? "",
                endCredit: self.playerData?.endingTime
            )
            self.universalSearchManager.updatePlayNow(
                duration: duration,
                initTime: 0,
                isPlay: false)
        }
    }
    
    func onEventSiri(streamEvent:PlayerStreamEvent){
        switch streamEvent {
        
        case .paused:
            self.universalSearchManager.updatePlay(
                time: self.playerModel.time,
                isPlay: false,
                rate: self.playerModel.rate)
            break
        case .resumed:
            self.universalSearchManager.updatePlay(
                time: self.playerModel.time,
                isPlay: true,
                rate: self.playerModel.rate)
            break
        case .seeked:
            self.universalSearchManager.updatePlay(
                time: self.playerModel.time,
                isPlay: self.playerModel.isPlay,
                rate: self.playerModel.rate)
            break
        case .stoped:
            self.universalSearchManager.updateStop()
            break
        case .completed:
            break
        default: break
        }
    }
}
