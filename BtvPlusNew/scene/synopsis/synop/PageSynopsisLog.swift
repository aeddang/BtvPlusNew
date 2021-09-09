//
//  PageSynopsisWatchLog.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/29.
//

import Foundation
import SwiftUI
extension PageSynopsis {
   
    func onEventLog(btvUiEvent:BtvUiEvent){
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
    
    func onEventLog(btvPlayerEvent:BtvPlayerEvent){
        
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
    
    func onEventLog(prerollEvent:PrerollEvent){
        switch prerollEvent {
        case .moveAd :
            self.naviLog(pageID: .play, action: .clickAdButton, category: "광고정보더보기")
        case .skipAd :
            self.naviLog(pageID: .play, action: .clickAdButton, category: "광고건너뛰기")
        default: break
        }
    }
    
    func onEventLog(event:PlayerUIEvent){
        switch event {
        case .pause :
            self.playNaviLog(action: .clickVodPause, watchType: .watchPause)
        case .resume :
            self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
        case .togglePlay :
            if self.playerModel.isPlay {
                self.playNaviLog(action: .clickVodPause, watchType: .watchPause)
            } else {
                self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
            }
        default: break
        }
    }
    
    func onEventLog(streamEvent:PlayerStreamEvent){
        switch streamEvent {
        case .loaded:
            self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
            self.naviLogManager.contentsLog(
                action: .clickContentsPreviewWatching,
                actionBody:.init(category:self.synopsisPlayType.logSynopCategory)
            )
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
    
    func onEventLog(componentEvent:PageSynopsis.ComponentEvent){
        switch componentEvent {
        case .watchBtv:
            self.naviLogManager.contentsLog(action: .clickContentsWatchBtv)
        case .purchase:
            self.naviLogManager.contentsLog(action: .clickContentsOrder)
        default: break
        }
    }
    

    func onStatusLog(playerStatus:PlayerStatus){
    }
    
    func onStatusLog(streamStatus:PlayerStreamStatus){
    }
    
    func onDisappearLog(){
        
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
    
    //page log
    func contentsListTabLog(idx:Int){
        if self.relationContentsModel.relationTabs.count <= idx {return}
        let tab = self.relationContentsModel.relationTabs[idx]
        if tab == String.pageText.synopsisSiris {
            self.naviLogManager.contentsLog(action: .clickContentsOrder, actionBody:.init(config:"sequence"))
        } else if tab.contains("비슷한") {
            self.naviLogManager.contentsLog(action: .clickContentsOrder, actionBody:.init(config:"similar_contents"))
        } else {
            self.naviLogManager.contentsLog(action: .clickContentsOrder, actionBody:.init(config:"relevance_contents"))
        }
    }
    //player watch log

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
    
    func playNaviLog( action:NaviLog.Action, watchType:NaviLog.watchType){
        self.naviLog(action: action, watchType: watchType)
        
    }
    
    //player log
    func naviLog(action:NaviLog.Action,
                 watchType:NaviLog.watchType? = nil,
                 config:String? = nil
                 ){
        let category = self.synopsisPlayType.logCategory
       
        self.naviLog(action: action, watchType: watchType, config: config, category: category, result: nil)
    }
    
    //player log
    func naviLog(pageID:NaviLog.PageId? = nil , action:NaviLog.Action,
                 watchType:NaviLog.watchType? = nil,
                 config:String? = nil,
                 category: String?, result: String? = nil
                 ){
        if pageID == nil && action == .pageShow, let synopsisModel = self.synopsisModel{
            self.naviLogManager.setupSysnopsis(synopsisModel)
        }
        let result = result ?? self.synopsisData?.synopType.logResult
        
        var actionBody = MenuNaviActionBodyItem()
        actionBody.menu_name = synopsisModel?.title
        actionBody.menu_id = synopsisModel?.menuId
        actionBody.category = category ?? ""
        actionBody.result = result ?? ""
        actionBody.config = config
        
        self.naviLogManager.contentsLog(
            pageId: pageID ?? (self.type == .btv ? .play : .zemPlay),
            action: action,
            actionBody: actionBody,
            watchType : watchType
        )
    }

}
