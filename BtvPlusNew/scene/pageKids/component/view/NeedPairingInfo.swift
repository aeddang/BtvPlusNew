//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI

struct NeedPairingInfo: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var vsManager:VSManager
    @EnvironmentObject var naviLogManager:NaviLogManager
    var title:String? = nil
    var text:String? = nil
    var body: some View {
        VStack(spacing:0){
            if let title = self.title {
                Text(title)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.light, color: Color.app.brownDeep))
                   
            }
            if let text = self.text {
                Text(text)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.sepia))
                    .padding(.top, DimenKids.margin.micro)
                    
            }
            Image( AssetKids.image.needPairing )
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame( height: SystemEnvironment.isTablet ? 154 : 80)
                .padding(.top, DimenKids.margin.thin)
            Text(String.alert.needPairingMoveBtv)
                .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.sepia))
                .padding(.top, DimenKids.margin.thin)
            RectButtonKids(
                text: String.button.connectBtv,  isFixSize: true
            ){ _ in
                self.naviLogManager.actionLog(.clickConnectStbButton)
                if self.vsManager.isGranted {
                    self.vsManager.accountPairingAlert()
                    return
                }
                self.appSceneObserver.event = .toast(String.alert.moveBtvPairing)
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.pairing, animationType: .opacity)
                            .addParam(key: PageParam.subType, value: "mob-com-popup")
                    )
                }
            }
            .padding(.top, DimenKids.margin.thin)
        }
        
    }//body
}


#if DEBUG
struct NeedPairingInfo_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            NeedPairingInfo(
               title: "키즈톡톡플러스월",
                text: "편성 종료 D-7"
            )
            .environmentObject(PagePresenter())
        }.background(Color.app.ivory)
    }
}
#endif

