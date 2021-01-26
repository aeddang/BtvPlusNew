//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


class PurchasViewerData {
    private(set) var isInfo:Bool = false
    private(set) var infoIcon: String? = nil
    private(set) var infoLeading: String? = nil
    private(set) var infoTailing: String? = nil
    
    private(set) var serviceInfo: String? = nil
    private(set) var serviceInfoDesc: String? = nil
    
    private(set) var isOption:Bool = false
    private(set) var optionTitle: String? = nil
    private(set) var options: [String] = []
    private(set) var purchasBtnTitle:String? = nil

    func setData(synopsisModel:SynopsisModel?, isPairing:Bool? ) -> PurchasViewerData? {
        guard let synopsisModel = synopsisModel else { return nil }
        guard let purchas = synopsisModel.curSynopsisItem else { return nil }
        if !synopsisModel.isDistProgram {
            serviceInfo = String.alert.bs
            serviceInfoDesc = String.alert.bsText
            
        } else if synopsisModel.isCancelProgram {
            serviceInfo = String.alert.bc
            serviceInfoDesc = String.alert.bcText
            
        } else if synopsisModel.isPossonVODMode {
            serviceInfo = String.pageText.synopsisTerminationBtv
        
        } else if !synopsisModel.isNScreen {
            serviceInfo = String.pageText.synopsisOnlyBtv
            
        } else if synopsisModel.isOnlyPurchasedBtv {
            serviceInfo = String.pageText.synopsisOnlyPurchasBtv
        
        } else if isPairing == true{
            if purchas.isFree {
                infoTailing = String.pageText.synopsisFreeWatch
            } else if purchas.isDirectview {
                
                
            } else{
                
                
            }
            
        } else{
            if purchas.isFree {
                infoTailing = String.pageText.synopsisFreeWatchBtv
            } else {
                if synopsisModel.isContainPPM {
                    
                }
            }
        }
        self.isInfo = infoIcon != nil || infoLeading != nil || infoTailing != nil
        
        return self
    }
    
    func setDummy() -> PurchasViewerData {
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


struct PurchasViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    var data:PurchasViewerData
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
                            .padding(.top, Dimen.margin.regularExtra)
                    }
                    else if self.data.infoTailing != nil {
                        Text(self.data.infoTailing!)
                            .modifier(BoldTextStyle( size: Font.size.light ))
                            .lineLimit(1)
                            .padding(.top, Dimen.margin.regularExtra)
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
        .onAppear{
            
        }
    }//body
}



#if DEBUG
struct PurchasViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PurchasViewer(
                data:PurchasViewerData().setDummy()
            )
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(Pairing())
        }.background(Color.brand.bg)
    }
}
#endif

