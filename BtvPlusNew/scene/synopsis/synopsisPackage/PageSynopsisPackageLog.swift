//
//  PageSynopsisPackageLog.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/10/03.
//

import Foundation
extension PageSynopsisPackage {
    func onEventLog(componentEvent:SynopsisViewModelEvent){
        switch componentEvent {
        case .purchase:
            if self.type == .kids {
                self.naviLogKids(action: .clickPurchaseButton)
            } else {
                self.naviLog( action: .clickContentsOrder)
            }
        case .selectPerson(let data):
            self.naviLog(
                action: .clickContentsProductionActor,
                target: (data.name ?? "") + "|" + (data.descriptionRole ?? "")
            )
        default: break
        }
    }
    
    
    func onDisappearLog(){
        self.naviLogManager.clearSysnopsis()
    }
    private func setupContent(){
        self.naviLogManager.setupSysnopsis(synopsisPackageModel, type:self.synopsisData?.isDemand == true ? "demand" : "vod")
    }
    func pageStartLog(){
        self.pageLogId = self.type == .kids ? .kidsSynopsis : .synopsis
        self.setupContent()
        if self.type == .btv {
            self.naviLog(
                action: .pageShow,
                config:self.pushId,
                category: "ppp")
        } else {
            self.naviLogKids(action: .pageShow)
        }
       
    }
    
    func previewLog(data:PosterData){
        if self.type == .btv {
            self.naviLogManager.actionLog(
                .clickContentsPreviewWatching,
                pageId:data.logPage,
                actionBody: .init(category:"미리보기"), contentBody: data.contentLog)
        } else {
            self.naviLogManager.actionLog(
                .clickRelatedContentsOption,
                pageId:data.logPage,
                actionBody: data.actionLog, contentBody: data.contentLog)
        }
    }
    
    
    func naviLog(pageID:NaviLog.PageId? = nil , action:NaviLog.Action,
                 config:String? = nil,
                 category: String? = nil , result: String? = nil, target:String? = nil
                 ){
        if naviLogManager.currentSysnopsisContentsItem?.series_id != self.synopsisData?.srisId {
            self.setupContent()
        }
        var actionBody = MenuNaviActionBodyItem()
        actionBody.menu_name = synopsisModel?.title
        actionBody.menu_id = synopsisModel?.menuId
        actionBody.category = category ?? ""
        actionBody.result = result ?? ""
        actionBody.config = config ?? ""
        if let t = target { actionBody.target = t }
        self.naviLogManager.contentsLog(
            pageId: self.pageLogId ,
            action: action,
            actionBody: actionBody
        )
    }
    
    //동일한 케이스인데 키즈와  비티비가 다름 이런일 한두번도 아니고....
    func naviLogKids(action:NaviLog.Action,
                target:String? = nil
                 ){
        
        if self.type != .kids { return }
        if naviLogManager.currentSysnopsisContentsItem?.series_id != self.synopsisData?.srisId {
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
