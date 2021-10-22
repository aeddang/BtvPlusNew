//
//  PageSynopsisWatchLog.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/29.
//

import Foundation
import SwiftUI
extension PageSynopsis {
    func onResetPageLog(isAllReset:Bool = false, isRedirectPage:Bool = false){
        self.playNaviLog(action: .clickVodStop, watchType: .watchStop)
        if self.naviLogManager.currentPlayStartTime != nil {
            self.naviLogManager.contentsWatch(isPlay: false)
        }
    }
    func onEventLog(btvUiEvent:BtvUiEvent){
        switch btvUiEvent {
        case .initate :
            self.naviLog(pageID:self.pageLogId, action: .clickContentsPlay, config:self.synopsisPlayType.logConfig)
            self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
            
        default: break
        }
    }
    
    func onEvent(btvLogEvent:BtvLogEvent){
        switch btvLogEvent {
        
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
        case .clickConfigButton(let action, let config) :
            self.naviLog(action: action, config:config)
        case .clickFullScreen(let isFullScreen) :
            self.naviLog(action: .clickVodScreenOption, config:isFullScreen ? "true" : "false")
        }
    }
    
    func onEventLog(btvPlayerEvent:BtvPlayerEvent){
        
        switch btvPlayerEvent {
        case .close :
            self.naviLog(
                action: .clickPlayBackList,
                config: self.type == .btv ? self.sceneOrientation.logConfig : nil)
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
            self.naviLog(pageID: self.pageLogId, action: .clickAdButton, category: "광고정보더보기")
            self.naviLog(pageID: .play, action: .clickAdButton, category: "광고정보더보기")
        case .skipAd :
            self.naviLog(pageID: self.pageLogId, action: .clickAdButton, category: "광고건너뛰기")
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
            self.naviLogKids(action: .clickContentsPlay)
            self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
        case .togglePlay(let isUser) :
            if !isUser {return}
            if self.playerModel.isPlay {
                self.playNaviLog(action: .clickVodPause, watchType: .watchPause)
                self.naviLogManager.contentsWatch(isPlay: false)
            } else {
                self.naviLogManager.contentsWatch(isPlay: true)
                self.playNaviLog(action: .clickVodPlay, watchType: .watchStart)
            }
        case .replay/*(let isReplay)*/ : 
           self.naviLog(action: .clickVodReplay)
       
        default: break
        }
    }
    
    func onEventLog(streamEvent:PlayerStreamEvent){
        switch streamEvent {
        case .stoped:
            
            self.playLog(isPlay: false)
        case .paused:
            self.playLog(isPlay: false)
            //self.log(type: .playBase)
        case .completed:
            self.playLog(isPlay: false)
           
        default: break
        }
    }
    
    func onEventLog(componentEvent:SynopsisViewModelEvent){
        switch componentEvent {
        case .watchBtv:
            if self.type == .kids {
                self.naviLogKids(action: .clickContentsOption, target:"btv로보기")
            } else {
                self.naviLog(
                    pageID: self.pageLogId,
                    action: .clickContentsWatchBtv)
            }
            
        case .purchase:
            if self.type == .kids {
                self.naviLogKids(action: .clickPurchaseButton)
            } else {
                self.naviLog(
                    pageID: self.pageLogId,
                    action: .clickContentsOrder)
            }
        case .bookMark(let isOn):
            if self.type == .kids {
                self.naviLogKids(action: .clickContentsOption, target:"찜")
            } else {
                self.naviLog(
                    pageID: self.pageLogId,
                    action: .clickContentsPick,
                    config: isOn ? "pick" : "un-pick")
            }
           
        case .like(let value):
            self.naviLog(
                pageID: self.pageLogId,
                action: .clickContentsLike,
                config: value)
        case .share(let isRecommand):
            if self.type == .kids {
                self.naviLogKids(action: .clickContentsOption, target:"더보기")
            } else {
                self.naviLog(
                    pageID: self.pageLogId,
                    action: .clickContentsShare,
                    config: isRecommand ? "Y" : "",
                    category: "추천하기"
                )
            }
            
        case .summaryMore:
            if self.type == .kids {
                self.naviLogKids(action: .clickContentsOption, target:"")
            } else {
                self.naviLog(
                    pageID: self.pageLogId,
                    action: .clickViewMore)
            }
           
        case .selectPerson(let data):
            self.naviLog(
                pageID: self.pageLogId,
                action: .clickContentsProductionActor,
                target: (data.name ?? "") + "|" + (data.descriptionRole ?? ""),
                actorId: data.prsId
            )
        case .changeOption(let option):
            self.naviLogKids(action: .clickCaptionOption, target:option?.title)
                
        default: break
        }
    }
    

    func onStatusLog(playerStatus:PlayerStatus){
    }
    
    func onStatusLog(streamStatus:PlayerStreamStatus){
    }
    
    func onDisappearLog(){
        self.playNaviLog(action: .clickVodStop, watchType: .watchStop)
        if self.naviLogManager.currentPlayStartTime != nil {
            self.naviLogManager.contentsWatch(isPlay: false)
        }
        self.naviLogManager.clearSysnopsis() 
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
        //self.synopsisData?.ppmIds = model.purchasedPPMItems.first(where: {$0.prdTypCd == .cbvodppm})?.prdPrcId
            //?? model.purchasedPPMItem?.prdPrcId ?? ""
        let purchaseModels = model.purchasedPPMItems.filter({$0.isPurchase})
        self.synopsisData?.ppmIds = purchaseModels.isEmpty
            ? ""
            : purchaseModels.dropFirst().reduce(purchaseModels.first!.prdPrcId, {$0 + " " + $1.prdPrcId})
        
    }
    
    //page log
    func contentsListTabLog(idx:Int){
        if self.relationContentsModel.relationTabs.count <= idx {return}
        let tab = self.relationContentsModel.relationTabs[idx]
        if tab == String.pageText.synopsisSiris {
            self.naviLog(pageID: self.pageLogId, action: .clickTabSeries, config:"sequence")
        } else if tab.contains("비슷한") {
            self.naviLog(pageID: self.pageLogId, action: .clickTabSeries, config:"similar_contents")
        } else {
            self.naviLog(pageID: self.pageLogId, action: .clickTabSeries, config:"relevance_contents")
        }
    }
    //player watch log

    private func setupContent(){
        self.naviLogManager.setupSysnopsis(
            synopsisModel,
            type:(self.synopsisData?.isDemand == true ? "demand" : "vod") ,
            title: self.episodeViewerData?.episodeTitle
        )
    }
    
    
    func playStartLog(){
        guard let synopsisModel = self.synopsisModel else {return}
        self.checkInsideViewLog(synopsisModel)
        self.pageLogId = self.type == .kids ? .kidsSynopsis : .synopsis
        self.setupContent()
        if self.type == .btv {
            self.naviLog(
                pageID: self.pageLogId,
                action: .pageShow,
                config:self.pushId,
                category: "ppv")
        } else {
            self.naviLogKids(action: .pageShow)
        }
        
        self.naviLog(
            action: .pageShow,
            category: self.synopsisPlayType.logCategory,
            result: self.synopsisData?.synopType.logResult)
        
        if self.isPlayAble && self.setup.autoPlay {
            self.naviLogManager.contentsWatch(isPlay: true)
        }
    }
    
    func playNaviLog( action:NaviLog.Action, watchType:NaviLog.watchType){
        self.naviLog(action: action, watchType: watchType, useMenuName:false)
        
    }
    
    //player log
    func naviLog(pageID:NaviLog.PageId? = nil , action:NaviLog.Action,
                 watchType:NaviLog.watchType? = nil,
                 config:String? = nil,
                 category: String? = nil, result: String? = nil,  target:String? = nil , actorId:String? = nil,
                 useMenuName:Bool = false
                 ){
        if naviLogManager.currentSysnopsisContentsItem?.episode_id != self.epsdId { 
            self.setupContent()
        }
        
        var actionBody = MenuNaviActionBodyItem()
        if useMenuName {
            actionBody.menu_name = synopsisModel?.title
        }
        actionBody.menu_id = synopsisModel?.menuId
        actionBody.category = category ?? ""
        actionBody.result = result ?? ""
        actionBody.config = config ?? ""
        if let t = target { actionBody.target = t }
        
        self.naviLogManager.contentsLog(
            pageId: pageID ?? (self.type == .btv ? .play : .kidsPlay),
            action: action,
            actionBody: actionBody,
            watchType : watchType,
            actorId : actorId
        )
    }
    
    
    func checkInsideViewLog(_ synopsisModel:SynopsisModel){
        if let insideChangeViewId = self.insideChangeViewId {
            var contentsItem = MenuNaviContentsBodyItem()
            contentsItem.type = "vod"
            contentsItem.series_id = synopsisModel.srisId
            contentsItem.title = self.episodeViewerData?.episodeTitle ?? synopsisModel.title ?? ""
            contentsItem.channel = ""
            contentsItem.channel_name = synopsisModel.brcastChnlNm ?? ""
            contentsItem.genre_text = ""  // 장르, ex)영화
            contentsItem.genre_code = synopsisModel.metaTypCd ?? ""
            contentsItem.episode_id = synopsisModel.epsdId ?? ""
            
            contentsItem.paid = !synopsisModel.isFree
            contentsItem.purchase = synopsisModel.curSynopsisItem?.isDirectview ?? false
            contentsItem.episode_resolution_id = synopsisModel.epsdRsluId ?? ""
            contentsItem.episode_id = insideChangeViewId
            //contentsItem.running_time = insideChangeViewRuntime
            
            if let curSynopsisItem = synopsisModel.purchasedPPMItem ?? synopsisModel.curSynopsisItem{
                contentsItem.product_id = curSynopsisItem.prdPrcId
                contentsItem.purchase_type = curSynopsisItem.prd_typ_cd
                contentsItem.monthly_pay = curSynopsisItem.ppm_prd_nm 
                contentsItem.list_price = curSynopsisItem.prd_prc_vat.description
                contentsItem.payment_price = curSynopsisItem.sale_prc_vat.description
            }
            
            if self.type == .btv {  //동일한 케이스인데 키즈와  비티비가 다름 이런일 한두번도 아니고....
                
                var actionBody = MenuNaviActionBodyItem()
                if let count = self.episodeViewerData?.count {
                    actionBody.config = count + String.app.broCount + " " + (self.episodeViewerData?.subTitle ?? "")
                } else {
                    actionBody.config = self.episodeViewerData?.subTitle ?? ""
                }
                actionBody.result = insideChangeViewId
                actionBody.menu_name = synopsisModel.title
                actionBody.menu_id = synopsisModel.srisId
                self.naviLogManager.actionLog(
                    .clickInsidePlayButton, pageId: .playInside,
                     actionBody: actionBody, contentBody: contentsItem)
                
            } else {
                
                var actionBody = MenuNaviActionBodyItem()
                actionBody.target = synopsisModel.title
                actionBody.config = insideChangeViewId
                actionBody.category = self.synopsisData?.synopType.logCategory
                actionBody.result = self.synopsisData?.synopType.logResult
                self.naviLogManager.actionLog(
                    .clickVodNextEpisode, pageId: .kidsPlay, 
                     actionBody: actionBody, contentBody: contentsItem)
            }
        }
    }
    
    //동일한 케이스인데 키즈와  비티비가 다름 이런일 한두번도 아니고....
    func naviLogKids(action:NaviLog.Action,
                target:String? = nil
                 ){
        if self.type != .kids { return }
        if naviLogManager.currentSysnopsisContentsItem?.episode_id != self.epsdId {
            self.setupContent()
        }
        
        var actionBody = MenuNaviActionBodyItem()
        actionBody.category = self.synopsisData?.synopType.logCategory
        actionBody.result = self.synopsisData?.synopType.logResult
        actionBody.config = self.pushId
        if let t = target { actionBody.target = t }
        
        self.naviLogManager.contentsLog(
            pageId: .kidsSynopsis,
            action: action,
            actionBody: actionBody
        )
    }

}
