//
//  PageSynopsisInside.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/03.
//

import Foundation
import SwiftUI
extension PageSynopsis {

    func onEventInside(btvPlayerEvent:BtvPlayerEvent){
        switch btvPlayerEvent {
        case .continueView: self.continueVod()
        case .nextView(let isAuto) : self.nextVod(auto: isAuto)
        default : break
        }
    }
    
    func onEventInside(streamEvent:PlayerStreamEvent){
        switch streamEvent {
        case .completed : self.playCompleted()
        default : break
        }
    }
    
    func onInsideRespond(res:ApiResultResponds){
        if res.id.hasPrefix( SingleRequestType.changeSeasonFirst.rawValue ) {
            guard let data = res.data as? Synopsis else { return }
            self.onChangeSeasonFirst(synopsis: data)
        }
    }
    
    func onInsideRespondErroe(err:ApiResultError){
        if err.id.hasPrefix( SingleRequestType.changeSeasonFirst.rawValue ) {
            PageLog.e("error changeSeasonFirst", tag: self.tag)
            self.changeSeasonFirst(synopsisData: nil)
        }
    }

    @discardableResult
    func nextVod(auto:Bool = true)->Bool{
        guard let playData = self.playerData else { return false}
        if !playData.hasNext { return false}
        if !self.setup.nextPlay && auto {
            self.appSceneObserver.alert = .confirm(
                String.pageText.synopsisNextPlay, String.pageText.synopsisNextPlayConfirm) { isOk in
                if isOk {
                    nextVod(auto:false)
                }
            }
            return false
        }
        if let find = playData.nextEpisode {
            self.changeVod(epsdId: find.epsdId)
            return true
        }
        if let season = playData.nextSeason {
            self.changeSeasonFirst(synopsisData: season.synopsisData)
            return true
        }
        return false
    }
    
    func changeSeasonFirst(synopsisData:SynopsisData?){
        guard let synopsisData = synopsisData else { return }
        self.pageDataProviderModel.request = .init(
            id: SingleRequestType.changeSeasonFirst.rawValue,
            type: .getSynopsis(synopsisData)
        )
    }
    func onChangeSeasonFirst(synopsis:Synopsis? = nil){
        guard let synopsis = synopsis else {
            self.appSceneObserver.event = .toast(String.pageText.synopsisNextPlayFail)
            return
        }
        let model = SynopsisModel().setData(data: synopsis)
        let relationContentsModel = RelationContentsModel()
        relationContentsModel.setData(synopsis: model)
        if relationContentsModel.playList.isEmpty {
            self.appSceneObserver.event = .toast(String.pageText.synopsisNextPlayFail)
            return
        }
        self.changeVod(epsdId:relationContentsModel.playList.first?.epsdId)
       
    }
    
    func playCompleted(){
        switch playerData?.type {
        case .preplay:
            self.preplayCompleted()
        case .preview(let count, _):
            if !self.nextPreview(count: count) {
                self.previewCompleted()
            }
        case .vod:
            if !self.nextVod(auto: true) {
                self.vodCompleted()
            }
        default:do{}
        }
    }
    
    func nextPreview(count:Int)->Bool{
        guard let playData = self.playerData else { return false}
        guard let previews = playData.previews else { return false}
        if !self.setup.nextPlay { return false}
        let next = count + 1
        if previews.count <= next { return false}
        self.synopsisPlayType = .preview(next)
        if self.isPairing == true {
            let item = previews[next]
            self.epsdRsluId = item.epsd_rslu_id ?? ""
            self.pageDataProviderModel.request = .init(
                id: SingleRequestType.preview.rawValue,
                type: .getPreview(item.epsd_rslu_id,  self.pairing.hostDevice))
           
        }else{
            let item = previews[next]
            self.epsdRsluId = item.epsd_rslu_id ?? ""
            self.pageDataProviderModel.request = .init(
                id: SingleRequestType.preview.rawValue,
                type: .getPreplay(item.epsd_rslu_id,  false))
        }
        return true
    }
    
    private func preplayCompleted(){
        PageLog.d("prevplayCompleted", tag: self.tag)
        self.continueVod()
    }
    
    private func previewCompleted(){
        PageLog.d("previewCompleted", tag: self.tag)
    }
    
    private func vodCompleted(){
        PageLog.d("vodCompleted", tag: self.tag)
    }
    
    private func continueVod(){
        if self.hasAuthority == true {
            return
        }
        self.onDefaultViewMode()
        if self.pairing.status != .pairing {
            self.appSceneObserver.alert = .needPairing(String.alert.needConnectForView)
            return
        }
        if self.hasAuthority == false {
            guard  let model = self.purchaseWebviewModel else { return }
            self.appSceneObserver.alert = .needPurchase(model)
        }
    }
}
