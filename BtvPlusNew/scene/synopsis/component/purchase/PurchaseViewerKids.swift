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
    var componentViewModel:PageSynopsis.ComponentViewModel = PageSynopsis.ComponentViewModel()
    var data:PurchaseViewerData
    
    @State var optionIdx:Int = 0
    var body: some View {
        HStack(alignment:.center , spacing:DimenKids.margin.light) {
            if self.data.serviceInfo != nil {
                HStack(spacing:DimenKids.margin.thin){
                    Image( AssetKids.icon.warn )
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
            }//option
            Spacer()
            
            if let title = self.data.purchasBtnTitle{
                RectButtonKids(
                    text: title,  isSelected: true, isFixSize: false){_ in
                    self.componentViewModel.uiEvent = .purchase
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

