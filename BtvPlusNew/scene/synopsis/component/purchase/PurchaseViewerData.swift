//
//  PurchaseViewerData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/23.
//

import Foundation
class PurchaseViewerData:ObservableObject, PageProtocol{
    private(set) var isInfo:Bool = false
    private(set) var infoIcon: String? = nil
    private(set) var infoLeading: String? = nil
    private(set) var infoTrailing: String? = nil
    private(set) var infoTip: String? = nil
    
    private(set) var serviceInfo: String? = nil
    private(set) var serviceInfoDesc: String? = nil
    
    private(set) var isOption:Bool = false
    private(set) var optionTitle: String? = nil
    private(set) var options: [String] = []
    private(set) var optionValues: [String] = []
    private(set) var purchasBtnTitle:String? = nil
    
    private(set) var watchOptions:[PurchaseModel]? = nil
    private(set) var isPlayAble:Bool = false
    
    var optionIdx = 0
    let type:PageType
    init(type:PageType){
        self.type = type
        
    }
    
    func setData(synopsisModel:SynopsisModel?, isPairing:Bool? ) -> PurchaseViewerData? {
        guard let synopsisModel = synopsisModel else { return nil }
        guard let purchas = synopsisModel.curSynopsisItem else { return nil }
        if !synopsisModel.isDistProgram {
            serviceInfo = String.alert.bs
            serviceInfoDesc = String.alert.bsText
            isPlayAble = false
                       
        } else if synopsisModel.isCancelProgram {
            serviceInfo = String.alert.bc
            serviceInfoDesc = String.alert.bcText
            isPlayAble = false
            
        } else if !synopsisModel.isNScreen {
            serviceInfo = purchas.hasAuthority
                ? String.pageText.synopsisWatchOnlyBtv
                : synopsisModel.holdbackType == .holdOut
                    ? String.pageText.synopsisOnlyBtvFree : String.pageText.synopsisOnlyBtv
            isPlayAble = false
            
        } else if synopsisModel.isOnlyPurchasedBtv && !purchas.hasAuthority {
            serviceInfo = String.pageText.synopsisOnlyPurchasBtv
            isPlayAble = true
            
        } else {
            switch synopsisModel.holdbackType {
            case .holdOut :
                if purchas.hasAuthority == true{
                    self.setupBtvWatchInfo(synopsisModel: synopsisModel, isPairing: isPairing, purchas: purchas)
                    self.setupOption(watchItems: synopsisModel.watchOptionItems, purchas: purchas)
                } else {
                    serviceInfo = String.pageText.synopsisOnlyBtvFree
                }
                isPlayAble = true
            default :
                self.setupBtvWatchInfo(synopsisModel: synopsisModel, isPairing: isPairing, purchas: purchas)
                if isPairing == true {
                    self.setupOption(purchasableItems: synopsisModel.purchasableItems, purchas: purchas)
                }
                if purchas.hasAuthority == true{
                    self.setupOption(watchItems: synopsisModel.watchOptionItems, purchas: purchas)
                }
                isPlayAble = true
            /*
            case .holdIn :
                if purchas.hasAuthority == true{
                    self.setupBtvWatchInfo(synopsisModel: synopsisModel, isPairing: isPairing, purchas: purchas)
                    self.setupOption(watchItems: synopsisModel.watchOptionItems, purchas: purchas)
                } else {
                    serviceInfo = (purchas.isDirectview && purchas.isFree)
                        ? String.pageText.synopsisWatchOnlyBtv
                        : String.pageText.synopsisOnlyBtv
    
                }
                isPlayAble = true
            */
           
            }
            
        }
        return self
    }
    
    private func setupBtvWatchInfo(synopsisModel:SynopsisModel, isPairing:Bool? , purchas:PurchaseModel){
        if isPairing == true || synopsisModel.isPossonVODMode {
            if purchas.isFree {
                infoTrailing = String.pageText.synopsisFreeWatch
            }
            else if purchas.isDirectview {
                if let ppmItem = synopsisModel.purchasedPPMItem {
                    if let name = ppmItem.ppm_prd_nm {
                        infoLeading = name
                        infoTrailing = " " + String.pageText.synopsisWatchPeriod
                    }else{
                        infoTrailing = String.pageText.synopsisWatchPeriod
                    }
                }else{
                    infoTrailing = purchas.isPossn
                        ? String.pageText.synopsisWatchPossn
                        : String.pageText.synopsisWatchRent
                }
            }
            else{
                if synopsisModel.isPossonVODMode {
                    infoTrailing = String.pageText.synopsisTerminationBtv
                }else{
                    if synopsisModel.isContainPPM {
                        infoIcon = self.type == .btv ? Asset.icon.tip : AssetKids.icon.tip
                        infoTrailing = String.pageText.synopsisFreeWatchMonthly
                    }
                }
            }
        }
        else{
            if purchas.isFree {
                infoTrailing = String.pageText.synopsisFreeWatchBtv
            } else {
                if synopsisModel.isContainPPM {
                    infoIcon = self.type == .btv ? Asset.icon.tip : AssetKids.icon.tip
                    infoTrailing = String.pageText.synopsisFreeWatchMonthly
                }
            }
        }
        if synopsisModel.isContainPPM {
            var enablePPMTooltip = false
            var toDday:Int  = 0
            if let purchasedPPMItem = synopsisModel.purchasedPPMItem {
                toDday = purchasedPPMItem.prdPrcToDt.getDDay()
                DataLog.d("purchasedPPMItem 구매. 시작일:" + (purchasedPPMItem.prdPrcFrDt.debugDescription)
                            + ", 종료일:" + (purchasedPPMItem.prdPrcToDt.debugDescription) , tag:self.tag)
                
            } else if let salePPMitem = synopsisModel.salePPMItem {
                toDday = salePPMitem.prdPrcToDt.getDDay()
                DataLog.d("salePPMitem 구매. 시작일:" + (salePPMitem.prdPrcFrDt.debugDescription)
                            + ", 종료일:" + (salePPMitem.prdPrcToDt.debugDescription) , tag:self.tag)
            }
            if 1...7 ~= toDday { enablePPMTooltip = true }
            DataLog.d("enablePPMTooltip:" + enablePPMTooltip.description + ", 종료일Dday:" + toDday.description, tag:self.tag)
            self.infoTip =  enablePPMTooltip ? String.pageText.synopsisDDay + toDday.description : nil
        } else {
            self.infoTip = nil
        }
        self.isInfo = infoIcon != nil || infoLeading != nil || infoTrailing != nil
    }
    
    private func setupOption(watchItems: [PurchaseModel]?, purchas:PurchaseModel){
        self.watchOptions = watchItems
        guard let watchItems =  watchItems else { return }
        if watchItems.count < 2 { return }
        guard let curIdx = watchItems.firstIndex(where: {$0.prdPrcId == purchas.prdPrcId}) else { return }
        self.isOption = true
        self.optionIdx = curIdx
        self.optionTitle = String.sort.langTitle
        self.options = watchItems.map({$0.purStateText})
        self.optionValues = watchItems.map({$0.prdPrcId})
    }
    private func setupOption(purchasableItems: [PurchaseModel]?, purchas:PurchaseModel){
        guard let purchasableItems =  purchasableItems else { return }
        guard let purchasableItem =  purchasableItems.first else { return }
        let leading = purchas.hasAuthority ? String.button.purchasAnother : String.button.purchas
        if purchasableItems.count < 2  {
            if self.type == .btv {
                self.purchasBtnTitle =  leading + "(₩" + purchasableItem.salePrice + ")"
            } else {
                self.purchasBtnTitle =  leading + "  |  " + purchasableItem.salePrice 
            }
        }else{
            if self.type == .btv {
                self.purchasBtnTitle =  leading + "(₩" + purchasableItem.salePrice + "~)"
            } else {
                self.purchasBtnTitle =  leading + "  |  " + purchasableItem.salePrice
            }
        }
    }
    
    func setDummy() -> PurchaseViewerData {
        isInfo = true
        infoIcon = Asset.icon.tip
        infoLeading = "ocean"
        infoTrailing = "시청가능"
        serviceInfo = "결방"
        serviceInfoDesc = "결방"
        isOption = true
        optionTitle = "lang"
        purchasBtnTitle = "purchasBtnTitle"
        return self
    }
}
