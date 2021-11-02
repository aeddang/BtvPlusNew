//
//  PageSynopsisCorner.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/09.
//

import Foundation

extension PageSynopsis {
    static let ProhibitionSimultaneous = "ProhibitionSimultaneous"
    func onResetPageProhibitionSimultaneous(){
        self.isProhibitionCheckComplete = false
        self.isProhibitionChecking = false
    }
    func onProhibitionSimultaneous(_ data:ProhibitionSimultaneous){
        self.isProhibitionChecking = false
        PageLog.d("onProhibitionSimultaneous " + (data.has_authority ?? ""), tag: Self.ProhibitionSimultaneous)
        if data.has_authority?.toBool() == false {
            let reason = VlsNetwork.ProhibitionReason.getType(data.has_authority_reason)
            self.playerModel.event = .pause()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.playerModel.event = .pause()
            }
            self.appSceneObserver.alert = .alert(String.alert.playProhibitionSimultaneous, reason.reason){
                self.playerModel.event = .pause()
            }
            self.prohibitionSimultaneousLog(reason: reason)
        } else {
            self.isProhibitionCheckComplete = true
            self.playLog(isPlay: true)
        }
    }
    func checkProhibitionSimultaneous(){
        if self.isProhibitionChecking {return}
        self.isProhibitionChecking = true
        PageLog.d("checkProhibitionSimultaneous" , tag: Self.ProhibitionSimultaneous)
        self.isProhibitionCheckComplete = false
        if self.pairing.status == .pairing && self.hasAuthority == true , let synopsisData = self.synopsisData {
            //동시시청체크
            self.pageDataProviderModel.request = .init(
                id: SingleRequestType.prohibitionSimultaneous.rawValue,
                type: .checkProhibitionSimultaneous(
                    synopsisData ,
                    self.pairing,
                    pcId: self.repository.namedStorage?.getPcid() ?? "" ), isOptional:true
            )
        }
    }
    
    func onDisappearProhibition(){
        self.playLog(isPlay: false, isForce: true)
    }
    
    func onEventProhibition(event:PlayerUIEvent){
        switch event {
        case .resume :
            self.checkProhibitionSimultaneous()
        case .togglePlay :
            if !self.playerModel.isPlay {
                self.checkProhibitionSimultaneous()
            }
        default: break
        }
    }
    func onDurationProhibition(duration:Double){
        if duration > 1 {
            self.checkProhibitionSimultaneous()
        }
    }
    func onEventProhibition(streamEvent:PlayerStreamEvent){
        switch streamEvent {
        case .loaded:
            self.checkProhibitionSimultaneous()
        case .paused:
            self.playLog(isPlay: false)
        case .completed:
            self.playLog(isPlay: false)
        default: break
        }
    }
    
    func onEventProhibition(pageStatus:PageStatus){
        switch pageStatus {
        case .enterForeground : break
            //self.log(type:.play )
        case .enterBackground :
            self.playLog(isPlay: false, isForce: true)
        default: break
        }
    }
    
    func playLog(isPlay:Bool, isForce:Bool = false){
        if self.playerModel.isPreroll {return}
        if !self.isProhibitionCheckComplete && !isForce {return}
        PageLog.d("playLog "  + isPlay.description, tag: Self.ProhibitionSimultaneous)
        switch self.synopsisPlayType {
        case .preplay : self.watchLog(type: isPlay ? .playPreview : .stopPreview)
        default : self.watchLog(type: isPlay ? .play : .stop)
        }
        self.playStartTime = isPlay ? AppUtil.networkTime() : nil
    }
    
    //page log
    func prohibitionSimultaneousLog(reason:VlsNetwork.ProhibitionReason){
        PageLog.d("prohibitionSimultaneousLog", tag: Self.ProhibitionSimultaneous)
        var actionBody = MenuNaviActionBodyItem()
        actionBody.menu_id = synopsisModel?.menuId
        actionBody.config = reason.config
      
        self.naviLogManager.contentsLog(
            pageId: .prohibitionSimultaneous,
            action: .pageShow,
            actionBody: actionBody
        )
    }
    
    private func watchLog(type:LgsNetwork.PlayEventType){
        guard let synopsisData = self.synopsisData else { return }
        let d = self.playerModel.duration
        let t = self.playerModel.time
        let rate = d > 0 ? t/d*100 : 0
        
        let playData = SynopsisPlayData(
            start: self.playStartTime == nil ? nil :  AppUtil.getTime(fromInt:self.playStartTime!),
            end: nil,
            position: self.playerModel.time.toTruncateDecimal(n: 0),
            rate: rate.toTruncateDecimal(n: 0))
        
        self.dataProvider.requestData(
            q: .init(type: .postWatchLog( type,
                                          playData,
                                          synopData: synopsisData,
                                          self.pairing,
                                          pcId: self.repository.namedStorage?.getPcid() ?? "",
                                          isKidZone: self.type == .kids,
                                          gubun: nil), isLog:true))
    
    }
}
