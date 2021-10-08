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
    private(set) var infoTrailingSub: String? = nil
    private(set) var infoTipTitle: String? = nil
    private(set) var infoTip: String? = nil
    
    private(set) var playerInfo: String? = nil
    private(set) var serviceInfo: String? = nil
    private(set) var serviceInfoDesc: String? = nil
    private(set) var serviceInfoDescBottom: String? = nil
    private(set) var isOption:Bool = false
    private(set) var optionTitle: String? = nil
    private(set) var options: [String] = []
    private(set) var optionValues: [String] = []
    private(set) var purchasBtnTitle:String? = nil
    private(set) var purchasBtnSubTitle:String? = nil
    private(set) var watchOptions:[PurchaseModel]? = nil
    private(set) var isPlayAble:Bool = false
   
    private(set) var isPlayAbleBtv:Bool = false
    private(set) var hasAuthority :Bool = false
    
    var optionIdx = 0
    let type:PageType
    init(type:PageType){
        self.type = type
        
    }
    
    func setData(synopsisModel:SynopsisModel?, isPairing:Bool? , isPosson:Bool = false) -> PurchaseViewerData? {
        guard let synopsisModel = synopsisModel else { return nil }
        let purchas = synopsisModel.curSynopsisItem
        
        let purchasAuthority =  purchas?.hasAuthority ?? false
        let isFree = synopsisModel.isFree
        let watchAll = synopsisModel.isSeasonWatchAll
        let isOnlyPurchasedBtv = synopsisModel.isOnlyPurchasedBtv
        let isOnlyBtvPurchasable = synopsisModel.isOnlyBtvPurchasable
        let holdbackType = synopsisModel.holdbackType
        
        
        self.hasAuthority = false
        if !synopsisModel.isDistProgram {
            serviceInfo = String.alert.bs
            serviceInfoDesc = String.alert.bsText // 서비스중지
            isPlayAble = false
           
           
        } else if synopsisModel.isCancelProgram {
            serviceInfo = String.alert.bc
            serviceInfoDescBottom = String.alert.bcText // 결방
            isPlayAble = false
            
            
        } else if !synopsisModel.isNScreen {
            if isPosson {
                serviceInfo = String.pageText.synopsisTerminationBtv
            } else {
                serviceInfo = purchas?.hasAuthority ?? false
                ? isFree ? String.pageText.synopsisOnlyBtvFree : String.pageText.synopsisWatchOnlyBtv
                : synopsisModel.holdbackType == .holdOut
                        ? String.pageText.synopsisOnlyBtvFree : String.pageText.synopsisOnlyBtv
                
            }
            playerInfo = String.pageText.synopsisDisableNScreen
            isPlayAble = false
            isPlayAbleBtv = true
            
        } else if synopsisModel.isOnlyPurchasedBtv && !(purchas?.isDirectview ?? false) {
            serviceInfo = purchas?.isFree ?? false
                ? String.pageText.synopsisOnlyBtv
                : String.pageText.synopsisOnlyPurchasBtv
            playerInfo = String.pageText.synopsisDisablePurchas
            isPlayAble = false
            isPlayAbleBtv = true
            
        }  else {
            switch synopsisModel.holdbackType {
                /*
                case .holdOut :
                    
                    
                    if purchas?.isDirectview == true{
                        self.setupBtvWatchInfo(synopsisModel: synopsisModel,
                                               isPairing: isPairing, isPosson: isPosson, purchas: purchas)
                        self.setupOption(watchItems: synopsisModel.watchOptionItems, purchas: purchas)
                        self.hasAuthority = true
                        isPlayAble = true
                    } else {
                        serviceInfo = String.pageText.synopsisOnlyBtvFree
                        isPlayAble = false
                    }
                */
            default :
                self.setupBtvWatchInfo(synopsisModel: synopsisModel,
                                       isPairing: isPairing, isPosson: isPosson, purchas: purchas)
                if isPairing == true {
                    self.setupOption(
                        synopsisModel:synopsisModel, purchasableItems: synopsisModel.purchasableItems, purchas: purchas)
                }
                if purchas?.hasAuthority == true{
                    self.setupOption(watchItems: synopsisModel.watchOptionItems, purchas: purchas)
                    self.hasAuthority = true
                }
            }
            
            
        }
        return self
    }
    
    private func setupBtvWatchInfo(synopsisModel:SynopsisModel,
                                   isPairing:Bool? , isPosson:Bool , purchas:PurchaseModel?){
        if isPairing == true || isPosson {
            
            if (purchas?.isDirectview ?? false) {
                if isPosson {
                    infoTrailing = String.pageText.synopsisPossonWatch
                } else if let ppmItem = synopsisModel.purchasedPPMItem {
                    if let name = ppmItem.ppm_prd_nm {
                        infoLeading = name
                        infoTrailing = " " + String.pageText.synopsisWatchPeriod
                    }else{
                        infoTrailing = String.pageText.synopsisWatchPeriod
                    }
                }else{
                    infoTrailing = purchas?.isPossn == true
                        ? String.pageText.synopsisWatchPossn
                        : String.pageText.synopsisWatchRent
                }
                isPlayAble = true
            } else if synopsisModel.isFree {
                infoTrailing = String.pageText.synopsisFreeWatch
                isPlayAble = true
                if synopsisModel.isGstn {
                    hasAuthority = true
                }
            }
            
            else{
                if isPosson {
                    infoTrailing = String.pageText.synopsisTerminationBtv
                }else{
                    if synopsisModel.isContainPPM {
                        infoIcon = self.type == .btv ? Asset.icon.tip : AssetKids.icon.tip
                        infoTrailing = String.pageText.synopsisFreeWatchMonthly
                    }
                }
                isPlayAble = true
            }
        }
        else{
            if synopsisModel.isFree {
                infoTrailing = String.pageText.synopsisFreeWatch
                //infoTrailing = String.pageText.synopsisFreeWatchBtv. 연결후 시청이 가능한대 그냥무료로 노출해달라고해서 3분보여주면서 문구는 무료....
            } else {
                if synopsisModel.isContainPPM {
                    infoIcon = self.type == .btv ? Asset.icon.tip : AssetKids.icon.tip
                    infoTrailing = String.pageText.synopsisFreeWatchMonthly
                }
            }
            isPlayAble = true
        }
        if (synopsisModel.isContainPPM && !synopsisModel.isFree){
            if purchas?.hasAuthority == true, let prdTypCd = purchas?.prdTypCd{
                if !PrdTypCd.isPPM(typCd: prdTypCd, all: true) {
                    self.isInfo = infoIcon != nil || infoLeading != nil || infoTrailing != nil
                    return
                }
            }
            var enablePPMTooltip = false
            var toDday:Int  = 0
            if let purchasedPPMItem = synopsisModel.purchasedPPMItem {
                toDday = purchasedPPMItem.prdPrcToDt.getDDay()
                DataLog.d("purchasedPPMItem 구매. 시작일:" + (purchasedPPMItem.prdPrcFrDt.debugDescription)
                            + ", 종료일:" + (purchasedPPMItem.prdPrcToDt.debugDescription) , tag:self.tag)
                
            } else if let salePPMitem = synopsisModel.salePPMItem {
                self.infoTipTitle = salePPMitem.ppm_prd_nm
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
    
    private func setupOption(watchItems: [PurchaseModel]?, purchas:PurchaseModel?){
        self.watchOptions = watchItems
        guard let watchItems =  watchItems else { return }
        if watchItems.count < 2 { return }
        guard let curIdx = watchItems.firstIndex(where: {$0.prdPrcId == purchas?.prdPrcId}) else { return }
        self.isOption = true
        self.optionIdx = curIdx
        self.optionTitle = String.sort.langTitle
        self.options = watchItems.map({$0.purStateText})
        self.optionValues = watchItems.map({$0.prdPrcId})
        
    }
    private func setupOption(synopsisModel:SynopsisModel, purchasableItems: [PurchaseModel]?, purchas:PurchaseModel?){
        if synopsisModel.isFree {return}
        if purchas?.hasAuthority != true,  let omni = synopsisModel.purchaseOmnipack.first  {
            self.setupOmnipack(omniPack: omni)
        }
        guard let purchasableItems =  purchasableItems else { return }
        guard let purchasableItem =  purchasableItems.first else { return }
        
        let leading = (purchas?.hasAuthority == true) ? String.button.purchasAnother : String.button.purchas
        if purchasableItems.count < 2  {
            if self.type == .btv {
                self.purchasBtnTitle =  leading
                self.purchasBtnSubTitle = "(" + purchasableItem.salePrice + ")"
            } else {
                self.purchasBtnTitle =  leading + "  |  " + purchasableItem.salePrice 
            }
        }else{
            if self.type == .btv {
                self.purchasBtnTitle =  leading 
                self.purchasBtnSubTitle = "(" + purchasableItem.salePrice + "~)"
            } else {
                self.purchasBtnTitle =  leading + "  |  " + purchasableItem.salePrice + "~"
            }
        }
    }
    
    private func setupOmnipack(omniPack:OmnipackData){
        self.infoTrailing = String.pageText.synopsisOmnipack
        var leading:String = ""
        if let data = omniPack.validDate?.toDateFormatter(dateFormat: "MM/dd") {
            leading = data + String.app.untill + " "
        }
        let trailing:String = omniPack.restCount.description + String.pageText.synopsisOmnipackTrailing
        self.infoTrailingSub = "(" + leading + trailing + ")"
        self.infoTip = nil
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
