//
//  PageSynopsisRecommand.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/22.
//

import Foundation

extension PageSynopsis {
    func checkRecommand(obj:PageObject?) {
        guard let obj = self.pageObject  else { return }
        if let params = obj.getParamValue(key: .datas) as? [URLQueryItem] {
            if let rcmdid = params.first(where: {$0.name == "rcmd_id"})?.value,
               let type = params.first(where: {$0.name == "type"})?.value
            {
                
                //let created = params.first(where: {$0.name == "created"})?.value,
                //let from = params.first(where: {$0.name == "from"})?.value,
                let nickname = params.first(where: {$0.name == "rcmd_nickname"})?.value
                let title = self.episodeViewerData?.episodeTitle ?? ""
                let page = PageProvider.getPageObject(.recommandReceive)
                    .addParam(key: .title, value: title)
                    .addParam(key: .text, value: nickname)
                    .addParam(key: .id, value: rcmdid)
                    .addParam(key: .type, value: type)
                
                if self.isPairing == true {
                    self.pagePresenter.openPopup( page )
                } else {
                    self.appSceneObserver.alert = .needPairing(move: self.pageObject)
                }
                
                
               
            }
        }
    }
}

