//
//  PageSynopsisWatchLv.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/09.
//

import Foundation
extension PageSynopsis {
    func onResetPageRedirect(isAllReset:Bool = false, isRedirectPage:Bool = false){
        
    }
    
    func checkeRedirect() -> Bool{
        if self.synopsisData?.searchType == .prd {return false}
        guard let model = self.synopsisModel else {return false}
        if self.currentRedirectSris == model.srisId {return false}
        let dataEpsdId = self.synopsisData?.epsdId ?? ""
        let synopsisEpsdId = model.epsdId ?? ""
        DataLog.d("checkeRedirect", tag: self.tag)
        DataLog.d("data epsdId  : " + dataEpsdId, tag: self.tag)
        DataLog.d("synopsisModel epsdId  : " + synopsisEpsdId, tag: self.tag)
        
        if model.srisTypCd == .season {
            self.currentRedirectSris = model.srisId
            let playList = self.relationContentsModel.playList
            if playList.count < 2 { return false }
            guard  let redirectEpsdId = model.isSrisCompleted ? playList.first?.epsdId : playList.last?.epsdId else {return false}
            if synopsisEpsdId == redirectEpsdId { return false }
            DataLog.d("checkeRedirect epsdId  : " + redirectEpsdId, tag: self.tag)
            self.changeVod(epsdId: redirectEpsdId)
            return true
        }
        
        return false
    }

    private func redirectPage(watchLv:Int){
        guard let currentPage = self.pageObject else {return}
        let redirectPage = PageProvider
            .getPageObject(currentPage.pageID)
            .addParam(key: .data, value: currentPage.getParamValue(key:.data))
            .addParam(key: .watchLv, value: watchLv)
        self.onLayerPlayerDisappear()
        self.pagePresenter.closePopup(currentPage.id)
        DispatchQueue.main.async {
            self.pagePresenter.openPopup(redirectPage)
        }
    }
}
