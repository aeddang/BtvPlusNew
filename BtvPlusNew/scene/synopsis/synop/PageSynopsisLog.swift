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
        case .initate :
            self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
        case .guide :
            self.naviLog(pageID: .playTouchGuide, action: .pageShow , category:nil)
        case .clickInsideButton(let action, let btvPlayerEvent, let config, let result) :
            switch btvPlayerEvent {
            case .nextView :
                self.naviLog(pageID: .playInside, action: action, config:config, category: "다음화", result:result )
            case .cookieView :
                self.naviLog(pageID: .playInside, action: action, category: "쿠키영상")
            case .continueView:
                self.naviLog(pageID: .playInside, action: action, category: "계속시청" )
            case .nextViewSeason :
                self.naviLog(pageID: .playInside, action: action, config:config, category: "다음시즌보기", result:result )
            default :
                self.naviLog(pageID: .playInside, action: action, category: "도입부건너뛰기" )
            }
        
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
        case .changeView(let epsdId):
            self.insideChangeViewId = epsdId
            self.insideChangeViewRuntime = self.naviLogManager.getContentsWatchTime()
            
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
        case .pause(let isUser) :
            if !isUser {return}
            self.playNaviLog(action: .clickVodPause, watchType: .watchPause)
        case .resume(let isUser) :
            if !isUser {return}
            self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
        case .togglePlay(let isUser) :
            if !isUser {return}
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
        case .resumed:
            self.naviLogManager.contentsWatch(isPlay: true)
        case .stoped, .paused:
            self.playLog(isPlay: false)
            self.naviLogManager.contentsWatch(isPlay: false)
            //self.log(type: .playBase)
        case .completed:
            self.playLog(isPlay: false)
           
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
        self.naviLogManager.setupSysnopsis(nil)
    }
    
    func bindWatchingData(){
        guard let model = self.synopsisModel else {
            return
        }
        self.synopsisData?.pId = model.curSynopsisItem?.prdPrcId
        self.synopsisData?.contentId = model.epsdRsluId
        self.synopsisData?.cpId = model.cpId ?? ""
        self.synopsisData?.metaTypCd = model.metaTypCd
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
        guard let synopsisModel = self.synopsisModel else {return}
        self.checkInsideViewLog(synopsisModel)
        
        self.naviLog(
            action: .pageShow,
            category: self.synopsisPlayType.logCategory,
            result: self.synopsisData?.synopType.logResult)
        
        /*
        if self.isPlayViewActive{
            self.naviLog(
                action: .pageShow,
                category: self.synopsisPlayType.logCategory,
                result: self.synopsisData?.synopType.logResult)
        } else {
            self.naviLogManager.setupSysnopsis(synopsisModel)
        }*/
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
                 category: String? = nil, result: String? = nil
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
        actionBody.config = config ?? ""
        
        self.naviLogManager.contentsLog(
            pageId: pageID ?? (self.type == .btv ? .play : .zemPlay),
            action: action,
            actionBody: actionBody,
            watchType : watchType
        )
    }
    
    
    func checkInsideViewLog(_ synopsisModel:SynopsisModel){
        if let insideChangeViewId = self.insideChangeViewId {
            var contentsItem = MenuNaviContentsBodyItem()
            contentsItem.type = "vod"
            contentsItem.series_id = synopsisModel.srisId
            contentsItem.title = synopsisModel.title ?? ""
            contentsItem.channel = ""
            contentsItem.channel_name = synopsisModel.brcastChnlNm ?? ""
            contentsItem.genre_text = ""  // 장르, ex)영화
            contentsItem.genre_code = synopsisModel.metaTypCd ?? ""
            contentsItem.episode_id = synopsisModel.epsdId ?? ""
            
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

}
