//
//  PageSynopsisCorner.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/09.
//

import Foundation

extension PageSynopsis {
    func onResetPageCorner(isAllReset:Bool = false, isRedirectPage:Bool = false){
        
    }
    func checkCornerPlay(){
        if let progressTime = self.synopsisData?.progressTime {
            if !self.isPlayAble {
                self.appSceneObserver.alert = .alert(nil, String.pageText.synopsisCornerPlayNotNscreen)
                return
            }
            if self.hasAuthority == true {
                self.playerModel.continuousProgressTime = progressTime
                if self.synopsisData?.isFullScreenProgressTime == true {
                    self.onFullScreenViewMode()
                }
            } else {
                if self.pairing.status == .pairing {
                    if self.synopsisModel?.isOnlyPurchasedBtv == true {
                        self.appSceneObserver.alert = .alert(nil, String.pageText.synopsisCornerPlayOnlyPurchasedBtv)
                    } else {
                        if progressTime == 0 {
                            self.onFullScreenViewMode()
                            return
                        }
                        guard  let model = self.purchaseWebviewModel else { return }
                        self.appSceneObserver.alert = .confirm( String.alert.purchase, String.pageText.synopsisCornerPlayNeedPurchased){ isOk in
                            if isOk {
                                let ani:PageAnimationType = SystemEnvironment.currentPageType == .btv ? .horizontal : .opacity
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.purchase, animationType: ani)
                                        .addParam(key: .data, value: model)
                                )
                            } else {
                                self.synopsisData?.progressTime = nil
                            }
                            
                        }
                    }
                    
                } else {
                    self.appSceneObserver.alert = .needPairing()
                }
            }
        }
    }
}
