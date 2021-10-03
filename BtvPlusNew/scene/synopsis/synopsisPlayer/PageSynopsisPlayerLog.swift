//
//  PageSynopsisWatchLog.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/29.
//

import Foundation
import SwiftUI
extension PageSynopsisPlayer {
    func onEventLog(btvUiEvent:BtvUiEvent){
        switch btvUiEvent {
        case .initate :
            self.naviLog(pageID:self.pageLodId, action: .clickContentsPlay, config:self.synopsisPlayType.logConfig)
            self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
        default: break
        }
    }
    
    func onEventLog(btvLogEvent:BtvLogEvent){
        switch btvLogEvent {
        case .clickInsideButton(let action, let btvPlayerEvent, let config, let result) :
            switch btvPlayerEvent {
            case .nextView :
                self.naviLog(pageID: .playInside, action: action, config:config, category: "다음클립", result:result )
            default : break
            }
        case .clickConfigButton(let action, let config) :
            self.naviLog(action: action, config:config )

        }
    }
    
    func onEventLog(btvPlayerEvent:BtvPlayerEvent){
        switch btvPlayerEvent {
        case .changeView(let epsdId) :
            self.insideChangeViewId = epsdId
            self.insideChangeViewRuntime = self.naviLogManager.getContentsWatchTime()
            
        case .fullVod (let synopsisData):
            self.goOriginVodLog(synopsisData)
           
        case .close :
            self.naviLog(
                action: .clickPlayBackList,
                config: self.sceneObserver.sceneOrientation.logConfig
                )
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
        case .pause(let isUser) :
            if !isUser {return}
            self.playNaviLog(action: .clickVodPause, watchType: .watchPause)
            self.naviLogManager.contentsWatch(isPlay: false)
        case .resume(let isUser) :
            if !isUser {return}
            self.naviLogManager.contentsWatch(isPlay: true)
            self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
            self.pagePresenter.closePopup(self.pageObject?.id)
        case .togglePlay(let isUser) :
            if !isUser {return}
            if self.playerModel.isPlay {
                self.playNaviLog(action: .clickVodPause, watchType: .watchPause)
                self.naviLogManager.contentsWatch(isPlay: false)
            } else {
                self.naviLogManager.contentsWatch(isPlay: true)
                self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
            }
        default: break
        }
    }
    
    func onDisappearLog(){
        self.naviLogManager.clearSysnopsis()
    }
    
    func playStartLog(){
        self.pageLodId = .synopsis
        guard let synopsisModel = self.synopsisModel else {return}
        self.checkInsideViewLog(synopsisModel)
        self.naviLogManager.setupSysnopsis(synopsisModel, type:self.synopsisData?.isDemand == true ? "demand" : "clip")
        self.naviLog(
            pageID: self.pageLodId,
            action: .pageShow,
            config:self.pushId,
            category: "ppv")
        self.naviLog(
            action: .pageShow,
            category: self.synopsisPlayType.logCategory,
            result: self.synopsisData?.synopType.logResult)
        if self.isPlayAble {
            self.naviLogManager.contentsWatch(isPlay: true)
        }
    }
    
    
    func playNaviLog( action:NaviLog.Action, watchType:NaviLog.watchType){
        self.naviLog(action: action, watchType: watchType,
                     result:self.synopsisModel?.title)
    }
    
    
    func naviLog(pageID:NaviLog.PageId? = nil , action:NaviLog.Action,
                 watchType:NaviLog.watchType? = nil,
                 config:String? = nil,
                 category: String? = nil , result: String? = nil
                 ){
        
        var actionBody = MenuNaviActionBodyItem()
        actionBody.menu_name = synopsisModel?.title
        actionBody.menu_id = synopsisModel?.menuId
        actionBody.category = category ?? ""
        actionBody.result = result ?? ""
        actionBody.config = config ?? ""
        
        self.naviLogManager.contentsLog(
            pageId: pageID ?? .play,
            action: action,
            actionBody: actionBody,
            watchType : watchType
        )
    }
    
    func checkInsideViewLog(_ synopsisModel:SynopsisModel){
        if let insideChangeViewId = self.insideChangeViewId {
            var contentsItem = MenuNaviContentsBodyItem()
            contentsItem.type = self.synopsisData?.isDemand == true ? "demand" : "clip"
            contentsItem.series_id = synopsisModel.srisId
            contentsItem.title = synopsisModel.title ?? ""
            contentsItem.channel = ""
            contentsItem.channel_name = synopsisModel.brcastChnlNm ?? ""
            contentsItem.genre_text = ""  // 장르, ex)영화
            contentsItem.genre_code = synopsisModel.metaTypCd ?? ""
            contentsItem.paid = !synopsisModel.isFree
            contentsItem.purchase = synopsisModel.curSynopsisItem?.isDirectview ?? false
            contentsItem.episode_resolution_id = synopsisModel.epsdRsluId ?? ""
            contentsItem.episode_id = insideChangeViewId
            contentsItem.running_time = insideChangeViewRuntime
            
            if let curSynopsisItem = synopsisModel.curSynopsisItem {
                contentsItem.product_id = curSynopsisItem.prdPrcId
                contentsItem.purchase_type = curSynopsisItem.prd_typ_cd
                contentsItem.monthly_pay = curSynopsisItem.ppm_prd_typ_cd
                contentsItem.list_price = curSynopsisItem.prd_prc_vat.description
                contentsItem.payment_price = curSynopsisItem.sale_prc_vat.description
            }
            
            var actionBody = MenuNaviActionBodyItem()
            actionBody.config = synopsisModel.title
            actionBody.result = insideChangeViewId
            actionBody.menu_name = synopsisModel.seasonTitle
            actionBody.menu_id = synopsisModel.srisId
            
            self.naviLogManager.actionLog(
                .clickInsidePlayButton, pageId: .playInside,
                 actionBody: actionBody, contentBody: contentsItem)
        }
    }
    
    func goOriginVodLog(_ synopsisData:SynopsisData){
        var contentsItem = MenuNaviContentsBodyItem()
        
        contentsItem.title = self.synopsisModel?.title
        contentsItem.episode_id = self.synopsisModel?.epsdId
        contentsItem.episode_resolution_id = self.synopsisModel?.epsdRsluId
    
        var actionBody = MenuNaviActionBodyItem()
        actionBody.target = synopsisData.epsdId
        
        self.naviLogManager.actionLog(
            .clickWatchOriginalButton, pageId: .play,
             actionBody: actionBody, contentBody: contentsItem)
    }


}
