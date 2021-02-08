//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


class PurchaseViewerData {
    private(set) var isInfo:Bool = false
    private(set) var infoIcon: String? = nil
    private(set) var infoLeading: String? = nil
    private(set) var infoTailing: String? = nil
    
    private(set) var serviceInfo: String? = nil
    private(set) var serviceInfoDesc: String? = nil
    
    private(set) var isOption:Bool = false
    private(set) var optionTitle: String? = nil
    private(set) var options: [String] = []
    private(set) var optionValues: [String] = []
    var optionIdx = 0
    private(set) var purchasBtnTitle:String? = nil

    func setData(synopsisModel:SynopsisModel?, isPairing:Bool? ) -> PurchaseViewerData? {
        guard let synopsisModel = synopsisModel else { return nil }
        guard let purchas = synopsisModel.curSynopsisItem else { return nil }
        if !synopsisModel.isDistProgram {
            serviceInfo = String.alert.bs
            serviceInfoDesc = String.alert.bsText
                       
        } else if synopsisModel.isCancelProgram {
            serviceInfo = String.alert.bc
            serviceInfoDesc = String.alert.bcText
            
        } else if !synopsisModel.isNScreen {
            serviceInfo = purchas.hasAuthority
                ? String.pageText.synopsisWatchOnlyBtv
                : String.pageText.synopsisOnlyBtv
            
            
        } else if synopsisModel.isOnlyPurchasedBtv && !purchas.hasAuthority {
            serviceInfo = String.pageText.synopsisOnlyPurchasBtv
            
        } else {
            switch synopsisModel.holdbackType {
            case .none :
                self.setupBtvWatchInfo(synopsisModel: synopsisModel, isPairing: isPairing, purchas: purchas)
                if isPairing == true {
                    self.setupOption(purchasableItems: synopsisModel.purchasableItems, purchas: purchas)
                }
                if purchas.hasAuthority == true{
                    self.setupOption(watchItems: synopsisModel.watchOptionItems, purchas: purchas)
                }
                
            case .holdIn :
                serviceInfo = (purchas.isDirectview && purchas.isFree)
                    ? String.pageText.synopsisWatchOnlyBtv
                    : String.pageText.synopsisOnlyBtv
                
            case .holdOut : serviceInfo = String.pageText.synopsisOnlyBtvFree
            }
        }
        return self
    }
    
    private func setupBtvWatchInfo(synopsisModel:SynopsisModel, isPairing:Bool? , purchas:PurchaseModel){
        if isPairing == true || synopsisModel.isPossonVODMode {
            if purchas.isFree {
                infoTailing = String.pageText.synopsisFreeWatch
            }
            else if purchas.isDirectview {
                if let ppmItem = synopsisModel.purchasedPPMItem {
                    if let name = ppmItem.ppm_prd_nm {
                        infoLeading = name + " "
                        infoTailing = String.pageText.synopsisWatchPeriod
                    }else{
                        infoTailing = String.pageText.synopsisWatchPeriod
                    }
                }else{
                    infoTailing = purchas.isPossn
                        ? String.pageText.synopsisWatchPossn
                        : String.pageText.synopsisWatchRent
                }
            }
            else{
                if synopsisModel.isPossonVODMode {
                    infoTailing = String.pageText.synopsisTerminationBtv
                }else{
                    if synopsisModel.isContainPPM {
                        infoIcon = Asset.icon.tip
                        infoTailing = String.pageText.synopsisFreeWatchMonthly
                    }
                }
            }
        }
        else{
            if purchas.isFree {
                infoTailing = String.pageText.synopsisFreeWatchBtv
            } else {
                if synopsisModel.isContainPPM {
                    infoIcon = Asset.icon.tip
                    infoTailing = String.pageText.synopsisFreeWatchMonthly
                }
            }
        }
        self.isInfo = infoIcon != nil || infoLeading != nil || infoTailing != nil
    }
    
    private func setupOption(watchItems: [PurchaseModel]?, purchas:PurchaseModel){
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
        infoTailing = "시청가능"
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
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    var data:PurchaseViewerData
    @State var option:String = ""
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
                HStack(){
                    if self.data.infoIcon != nil {
                        Image( self.data.infoIcon! )
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.medium)
                    }
                    if self.data.infoLeading != nil && self.data.infoTailing != nil{
                        Text(self.data.infoLeading!)
                            .font(.custom(Font.family.bold, size: Font.size.light))
                            .foregroundColor(Color.brand.primary)
                        + Text(self.data.infoTailing!)
                            .font(.custom(Font.family.bold, size: Font.size.light))
                            .foregroundColor(Color.app.white)
                    }
                    else if self.data.infoLeading != nil {
                        Text(self.data.infoLeading!)
                            .modifier(BoldTextStyle( size: Font.size.light, color:Color.brand.primary ))
                            .lineLimit(1)
                            
                    }
                    else if self.data.infoTailing != nil {
                        Text(self.data.infoTailing!)
                            .modifier(BoldTextStyle( size: Font.size.light ))
                            .lineLimit(1)
                    }
                }
            }//info
            if self.data.isOption {
                SortButton(
                    title: self.data.optionTitle,
                    text: self.option,
                    isFocus: false,
                    isFill: true,
                    bgColor: Color.app.blueDeep){
                    
                    self.pageSceneObserver.select = .select((self.tag, self.data.options), self.data.optionIdx)
                }
                .onReceive(self.pageSceneObserver.$selectResult){ result in
                    guard let result = result else { return }
                    switch result {
                        case .complete(let type, let idx) : do {
                            if type.check(key: self.tag){
                                self.data.optionIdx = idx
                                self.option = self.data.options[idx]
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
                    /*
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.pairing)
                    )*/
                }
            }
        }
        .modifier(ContentHorizontalEdges())
        .padding(.top, Dimen.margin.regularExtra)
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
                data:PurchaseViewerData().setDummy()
            )
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(Pairing())
        }.background(Color.brand.bg)
    }
}
#endif

