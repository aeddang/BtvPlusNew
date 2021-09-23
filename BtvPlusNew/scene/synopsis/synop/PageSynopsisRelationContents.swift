//
//  PageSynopsisRelationContents.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/09.
//

import Foundation
extension PageSynopsis {
    func onResetPageRelationContent(isAllReset:Bool = false){
        if isAllReset { self.resetRelationVod() }
    }
    
    func resetRelationVod(){
        self.relationTab = []
        self.seris = []
        self.relationDatas = []
        self.hasRelationVod = nil
    }
    
    func setupRelationContent (_ data:RelationContents?){
        self.relationContentsModel.setData(data: data)
        if self.relationContentsModel.unavailableSeris && self.isRedirectPage,
            let epsdId = self.relationContentsModel.getAvailableSeris()?.epsdId {
            self.changeVod( epsdId: epsdId)  // 방영종료 시리즈 자동 이동
            return
        }
        self.setupRelationContentCompleted ()
    }
    
    func setupRelationContentCompleted (){
        self.updateRelationTabButtons(idx: self.tabNavigationModel.index)
            
        if self.relationTab.isEmpty {
            self.hasRelationVod = false
        }else{
            self.hasRelationVod = true
            self.selectedRelationContent(idx:0)
        }
        self.onAllProgressCompleted() 
    }
    
    
    var relationRow:Int {
       get {
           return
            self.type == .kids
            ? 1
            :  self.sceneOrientation == .landscape ? 2
               : SystemEnvironment.isTablet ? 4 : 3
       }
    }
    
    func selectedRelationContent (idx:Int){
        
        self.updateRelationTabButtons(idx: idx)
        self.tabNavigationModel.index = idx
        self.selectedRelationTabIdx = idx
       
        PageLog.d("selectedRelationContent", tag: self.tag)
        self.seris = []
        self.relationDatas = []
        var relationContentsIdx = self.selectedRelationTabIdx
        if self.relationContentsModel.hasSris {
            if self.selectedRelationTabIdx == 0 {
                let sorted = self.relationContentsModel.getSerisDatas()
                self.seris = sorted
                if self.sceneOrientation == .landscape {
                    if let find = self.seris.first(where: {$0.epsdId == self.relationContentsModel.selectedEpsdId }) {
                        self.relationBodyModel.uiEvent = .scrollTo(find.hashId)
                    } else {
                        self.relationBodyModel.uiEvent = .scrollTo(self.relationBodyModel.topIdx, .top)
                    }
                }
                
                return
            }else{
                relationContentsIdx = self.selectedRelationTabIdx-1
            }
        }
        if self.relationContentsModel.relationContents.isEmpty { return }
        if relationContentsIdx >= self.relationContentsModel.relationContents.count  { return }
        
        let relationDatas = self.relationContentsModel.getRelationContentSets(idx: relationContentsIdx, row: self.relationRow)
        self.relationDatas = relationDatas
        if self.sceneOrientation == .landscape {
            self.relationBodyModel.uiEvent = .scrollTo(self.relationBodyModel.topIdx, .top)
        }
        self.contentsListTabLog(idx: idx)
    }
    
    func updateRelationTabButtons(idx:Int){
        self.relationTab = NavigationBuilder(
            index:idx,
            marginH:Dimen.margin.regular)
            .getNavigationButtons(texts:self.relationContentsModel.relationTabs)
    }
}
