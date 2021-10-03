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
            self.naviLog( action: .clickContentsOrder) 
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
        self.pageLodId = self.type == .kids ? .kidsSynopsis : .synopsis
        self.setupContent()
        self.naviLog(
            action: .pageShow,
            config:self.pushId,
            category: "ppp")
    }
    
    func previewLog(data:PosterData){
        if data.hasLogKids {
            self.naviLogManager.actionLog(
                .clickContentsPreviewWatching,
                pageId:data.logPage,
                actionBody: .init(category:"미리보기"), contentBody: data.contentLog)
        }else if data.hasLog {
            self.naviLogManager.actionLog(
                .clickContentsPreviewWatching,
                pageId:data.logPage,
                actionBody: .init(category:"미리보기"), contentBody: data.contentLog)
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
            pageId: self.pageLodId ,
            action: action,
            actionBody: actionBody
        )
    }
}
