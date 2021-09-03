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
        case .nextView : self.nextVod(auto: false)
        default : break
        }
    }
    
    func onEventInside(streamEvent:PlayerStreamEvent){
        switch streamEvent {
        case .completed : self.playCompleted()
        default : break
        }
    }

    @discardableResult
    func nextVod(auto:Bool = true)->Bool{
        guard let prevData = self.synopsisData else { return false}
        guard let playData = self.playerData else { return false}
        if !self.setup.nextPlay && auto { return false}
        if !playData.hasNext { return false}
        
        self.epsdRsluId = ""
        self.synopsisPlayType = .vodNext()
        let nextSynopsisData = SynopsisData(
            srisId: playData.nextSeason ?? prevData.srisId,
            searchType: prevData.searchType,
            epsdId: playData.nextEpisode,
            epsdRsluId: nil,
            prdPrcId: prevData.prdPrcId,
            kidZone: prevData.kidZone,
            synopType: prevData.synopType
        )
        
        self.setupHistory(synopsisData:nextSynopsisData, isHistoryBack: true)
        self.resetPage() 
        return true
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
            if !self.nextVod() {
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
