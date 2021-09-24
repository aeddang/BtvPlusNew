//
//  PageSynopsisWatchLv.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/09.
//

import Foundation
extension PageSynopsis {
    func onResetPageWatchLv(isAllReset:Bool = false, isRedirectPage:Bool = false){
        
    }
    
    func onEventWatchLv(evt :PageEvent){
        if evt.id != self.tag { return }
        switch evt.type {
        case .completed :
           self.pageDataProviderModel.requestProgressResume()
        case .cancel :
           self.historyCancel()
           break
            
        default : break
        }
    }
    
    func checkWatchLvAuth() -> Bool{
        guard let model = self.synopsisModel else {return false}
        guard let episodeViewerData = self.episodeViewerData else { return false}
        if self.isPairing == true {
            
            if episodeViewerData.isAdult == true && !SystemEnvironment.isAdultAuth{
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.adultCertification)
                        .addParam(key: .id, value: self.tag)
                )
                /*
                if self.originHistorys.isEmpty {
                    self.historyCancel()
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.adultCertification)
                            .addParam(key: .id, value: self.tag)
                            .addParam(key: .data, value: self.pageObject)
                    )
                } else {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.adultCertification)
                            .addParam(key: .id, value: self.tag)
                    )
                }*/
                return false
            }
            if !SystemEnvironment.isAdultAuth ||
                ( !SystemEnvironment.isWatchAuth && SystemEnvironment.watchLv != 0 )
            {
                let watchLv = model.watchLevel
                if SystemEnvironment.watchLv != 0 && SystemEnvironment.watchLv <= watchLv {
                    if SystemEnvironment.currentPageType == .btv {
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.confirmNumber)
                                .addParam(key: .id, value: self.tag)
                                .addParam(key: .type, value: ScsNetwork.ConfirmType.adult)
                        )
                    } else {
                        self.pagePresenter.openPopup(
                            PageKidsProvider.getPageObject(.kidsConfirmNumber)
                                .addParam(key: .id, value: self.tag)
                                .addParam(key: .type, value: PageKidsConfirmType.watchLv)
                        )
                    }
                    return false
                }
            }
        }else{
            if episodeViewerData.isAdult == true {
                if self.originHistorys.isEmpty {
                    self.historyCancel()
                    self.appSceneObserver.alert = .needPairing(nil, move: self.pageObject)
                } else {
                    self.appSceneObserver.alert = .needPairing(){
                        self.historyCancel()
                    }
                }
                return false
            }
        }
        return true
    }

    /*
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
    }*/
}
