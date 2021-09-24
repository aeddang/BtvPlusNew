//
//  PageSynopsisHistory.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/09.
//

import Foundation
extension PageSynopsis {
    func getSynopData(obj:PageObject)->SynopsisData {
        self.isAutoPlay = obj.getParamValue(key: .autoPlay) as? Bool
        
        
        if let synopsisData = obj.getParamValue(key: .data) as? SynopsisData {
            return synopsisData
        } else {
            if let json = obj.getParamValue(key: .data) as? SynopsisJson {
                return SynopsisData(
                    srisId: json.srisId, searchType:EuxpNetwork.SearchType.sris, epsdId: json.epsdId,
                    epsdRsluId: json.episodeResolutionId, prdPrcId: json.pid, kidZone: nil,
                    synopType: SynopsisType(value: json.synopType)
                )
            }
            if let qurry = obj.getParamValue(key: .data) as? SynopsisQurry {
                return SynopsisData(
                    srisId:  qurry.srisId, searchType:EuxpNetwork.SearchType.prd, epsdId:  qurry.epsdId,
                    epsdRsluId: nil, prdPrcId: nil, kidZone: nil,
                    synopType: SynopsisType.none
                )
            }
        }
       
        return SynopsisData()
    }
    
    func setupHistory(synopsisData:SynopsisData, isHistoryBack:Bool=true){
        if isHistoryBack , let currentSynop = self.synopsisData {
            if self.historys.last?.epsdId != currentSynop.epsdId {
                if let find = self.historys.firstIndex(where: {$0.epsdId == currentSynop.epsdId}) {
                    self.historys.remove(at: find)
                }
                self.historys.append(currentSynop)
            }
        }
        if let currentSynop = self.synopsisData {
            self.originHistorys.append(currentSynop)
        }
        self.synopsisData = synopsisData
        self.isPosson = synopsisData.isPosson
        self.anotherStb = self.isPosson ? synopsisData.anotherStbId : nil
        
    }
    func historyCancel(){
        if !self.originHistorys.isEmpty {
            let history = self.originHistorys.removeLast()
            self.synopsisData = history
            self.resetPage(isAllReset: true)
        } else {
            self.pagePresenter.closePopup(self.pageObject?.id)
        }
    }
    func historyBack(){
        if self.isFullScreen {
            self.fullScreenCancel()
            return
        }
        
        if !self.historys.isEmpty {
            let history = self.historys.removeLast()
            self.synopsisData = history
            self.resetPage(isAllReset: true)
        } else {
            self.pagePresenter.closePopup(self.pageObject?.id)
        }
    }
    

}
