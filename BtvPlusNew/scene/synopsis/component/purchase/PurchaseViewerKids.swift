//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

struct PurchaseViewerKids: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var vsManager:VSManager
    var componentViewModel:SynopsisViewModel = SynopsisViewModel()
    var data:PurchaseViewerData
    var synopsisModel:SynopsisModel?
    var isPairing:Bool?
    @State var optionIdx:Int = 0
    var body: some View {
        HStack(alignment:.center , spacing:DimenKids.margin.light) {
            if self.data.serviceInfo != nil {
                HStack(spacing:DimenKids.margin.thin){
                    Image( self.data.isPlayAbleBtv ? AssetKids.icon.btv : AssetKids.icon.warn )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: DimenKids.icon.thin)
                    Text(self.data.serviceInfo!)
                        .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.thin,
                                    color: Color.app.brownDeep ))
                        .lineLimit(1)
                }
            
            }
            if self.data.isOption {
                TabSwitch(
                    tabs: self.data.options,
                    selectedIdx:  self.optionIdx){ idx in
                    
                    self.data.optionIdx = idx
                    self.optionIdx = idx
                    if let watchOptions = self.data.watchOptions {
                        self.componentViewModel.uiEvent = .changeOption(watchOptions[idx])
                    }
                }
                .frame(width: SystemEnvironment.isTablet ? 242 : 134)
            }//option
            Spacer()
                .frame( height: DimenKids.button.mediumRect.height)
            if let title = self.data.purchasBtnTitle{
                RectButtonKids(
                    text: title,
                    isSelected: true,
                    isFixSize: false){_ in
                    self.componentViewModel.uiEvent = .purchase
                }
                .buttonStyle(BorderlessButtonStyle())
            } else  if self.isPairing == false && self.synopsisModel?.isRecommandAble == true {
                RectButtonKids(
                    text: String.button.connectBtv,
                    isSelected: true,
                    isFixSize: false
                ){_ in
                    
                    self.appSceneObserver.event = .toast(String.alert.moveBtvPairing)
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.pairing, animationType: .opacity)
                                .addParam(key: PageParam.subType, value: "mob-uixp-synop")
                        )
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .onAppear{
            if self.data.isOption {
                self.optionIdx = self.data.optionIdx
            }
        }
    }//body
}



#if DEBUG
struct PurchaseViewerKids_Previews: PreviewProvider {

    static var previews: some View {
        VStack{
            PurchaseViewerKids(
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

