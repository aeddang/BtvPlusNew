//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


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
    fileprivate(set) var optionIdx = 0
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
        guard let curIdx = watchItems.firstIndex(where: {$0.prd_prc_id == purchas.prd_prc_id}) else { return }
        self.isOption = true
        self.optionIdx = curIdx
        self.optionTitle = String.sort.langTitle
        self.options = watchItems.map({$0.purStateText})
        self.optionValues = watchItems.map({$0.prd_prc_id})
    }
    private func setupOption(purchasableItems: [PurchaseModel]?, purchas:PurchaseModel){
        guard let purchasableItems =  purchasableItems else { return }
        guard let purchasableItem =  purchasableItems.first else { return }
        let leading = purchas.hasAuthority ? String.button.purchasAnother : String.button.purchas
        if purchasableItems.count < 2  {
            self.purchasBtnTitle =  leading + "(" + purchasableItem.salePrice + ")"
        }else{
            self.purchasBtnTitle =  leading + "(" + purchasableItem.salePrice + "~)"
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

struct PurchaseViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var componentViewModel:PageSynopsis.ComponentViewModel = PageSynopsis.ComponentViewModel()
    var data:PurchaseViewerData
    @State var option:String = ""
    @State var showInfo:Bool = false
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.light) { 
            if self.data.serviceInfo != nil {
                HStack{
                    Text(self.data.serviceInfo!)
                        .modifier(BoldTextStyle( size: Font.size.light, color:Color.app.white ))
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal,  Dimen.margin.thin)
                .modifier( MatchHorizontal(height:Dimen.button.medium))
                .overlay(Rectangle().stroke( Color.app.greyExtra , lineWidth: 1 ))
                if self.data.serviceInfoDesc != nil {
                    Text(self.data.serviceInfoDesc!)
                        .modifier(MediumTextStyle( size: Font.size.light, color:Color.app.white ))
                }
               
            }
            if self.data.isInfo || self.data.isOption {
                Spacer().modifier(LineHorizontal())
            }
            if self.data.isInfo {
                HStack(spacing:Dimen.margin.thinExtra){
                    if self.data.infoIcon != nil {
                        Image( self.data.infoIcon! )
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.medium)
                    }
                    if self.data.infoLeading != nil && self.data.infoTrailing != nil{
                        Text(self.data.infoLeading!)
                            .font(.custom(Font.family.bold, size: Font.size.light))
                            .foregroundColor(Color.brand.primary)
                        + Text(self.data.infoTrailing!)
                            .font(.custom(Font.family.bold, size: Font.size.light))
                            .foregroundColor(Color.app.white)
                    }
                    else if self.data.infoLeading != nil {
                        Text(self.data.infoLeading!)
                            .modifier(BoldTextStyle( size: Font.size.light, color:Color.brand.primary ))
                            .lineLimit(1)
                            
                    }
                    else if self.data.infoTrailing != nil {
                        Text(self.data.infoTrailing!)
                            .modifier(BoldTextStyle( size: Font.size.light ))
                            .lineLimit(1)
                    }
                    if self.data.infoTip != nil {
                        if SystemEnvironment.isTablet {
                            HStack(spacing:Dimen.margin.tiny){
                                Button(action: {
                                    withAnimation { self.showInfo.toggle() }
                                }){
                                    Image( Asset.icon.info )
                                        .renderingMode(.original).resizable()
                                        .scaledToFit()
                                        .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Tooltip(
                                    title: self.data.infoLeading,
                                    text: self.data.infoTip
                                )
                                .opacity( self.showInfo ? 1.0 : 0)
                            }
                        } else {
                            VStack(spacing:0){
                                Tooltip(
                                    title: self.data.infoLeading,
                                    text: self.data.infoTip
                                )
                                .opacity( self.showInfo ? 1.0 : 0)
                                .padding(.top, -(Tooltip.size.height+Dimen.margin.thinExtra))
                                //.padding(.leading, -(Tooltip.size.width - Dimen.icon.tiny)/2)
                                Button(action: {
                                    withAnimation { self.showInfo.toggle() }
                                }){
                                    Image( Asset.icon.info )
                                        .renderingMode(.original).resizable()
                                        .scaledToFit()
                                        .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                        }
                        
                    }
                }
                
            }//info
            if self.data.isOption {
                SortButton(
                    title: self.data.optionTitle,
                    text: self.option,
                    isFocus: false,
                    isFill: true,
                    bgColor: Color.brand.bg){
                    
                    self.appSceneObserver.select = .select((self.tag, self.data.options), self.data.optionIdx)
                }
                .buttonStyle(BorderlessButtonStyle())
                .onReceive(self.appSceneObserver.$selectResult){ result in
                    guard let result = result else { return }
                    switch result {
                        case .complete(let type, let idx) : do {
                            if type.check(key: self.tag){
                                self.data.optionIdx = idx
                                self.option = self.data.options[idx]
                                if let watchOptions = self.data.watchOptions {
                                    self.componentViewModel.uiEvent = .changeOption(watchOptions[idx])
                                }
                            }
                        }
                    }
                }
            }//option
            
            if self.data.isInfo || self.data.isOption {
                Spacer().modifier(LineHorizontal())
            }
            
            if self.data.purchasBtnTitle != nil {
                FillButton(
                    text: self.data.purchasBtnTitle!
                ){_ in
                    self.componentViewModel.uiEvent = .purchase
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .modifier(ContentHorizontalEdges())
        .onAppear{
            if self.data.isOption {
                self.option = self.data.options[self.data.optionIdx]
            }
        }
    }//body
}



#if DEBUG
struct PurchaseViewer_Previews: PreviewProvider {

    static var previews: some View {
        VStack{
            PurchaseViewer(
                data:PurchaseViewerData(type: .btv).setDummy()
            )
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter())
            .environmentObject(AppSceneObserver())
            .environmentObject(Pairing())
        }.background(Color.brand.bg)
    }
}
#endif

