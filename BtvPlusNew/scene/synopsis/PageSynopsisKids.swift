//
//  PageSynopsisKids.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/27.
//

import Foundation
extension PageSynopsis {
    func onCheckKidsProfile(){
        if self.type != .kids {return}
        self.pairing.requestPairing(.updateKids)
    }
    
    func onEvent(pairingEvent:PairingEvent){
        if self.type != .kids {return}
        switch pairingEvent {
        case .notFoundKid :
            if self.pagePresenter.currentTopPage?.pageID != self.pageID {return}
            self.appSceneObserver.alert = .confirm(nil, String.alert.kidsProfileNotfound ,nil) { isOk in
                if isOk {
                    if self.pagePresenter.currentTopPage?.pageID == .kidsProfileManagement { return }
                    self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsProfileManagement))
                }
            }
        default : break
        }
    }
}
