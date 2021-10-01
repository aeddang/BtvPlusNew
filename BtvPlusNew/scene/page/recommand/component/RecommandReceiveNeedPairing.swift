import Foundation
//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI


struct RecommandReceiveNeedPairing: PageComponent {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var vsManager:VSManager
   
    var mgmId:String? = nil
    var recommandFriend:String = "???"
    var recommandTitle:String = "???"
    var close: () -> Void
    
    var body: some View {
        VStack(spacing:0){
            VStack(alignment: .center, spacing:SystemEnvironment.isTablet ? Dimen.margin.light : Dimen.margin.regular){
                VStack(alignment: .center, spacing: Dimen.margin.micro) {
                    Text(self.recommandFriend + String.share.synopsisRecommandReceiveTitleLeading)
                        .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.black))
                        
                    Text(self.recommandTitle)
                        .modifier(BoldTextStyle(size: Font.size.regular, color: Color.brand.primary))
                        
                    Text(String.share.synopsisRecommandReceiveTitleTrailing)
                        .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.black))
                }
                
                Text(String.share.synopsisRecommandReceiveNeedPairing)
                    .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.black))
                    .multilineTextAlignment(.center)
                
            }
            .padding(.all, SystemEnvironment.isTablet ? Dimen.margin.light : Dimen.margin.regular)
            HStack(spacing:0){
                FillButton(
                    text: String.app.cancel,
                    isSelected: true ,
                    textModifier: TextModifier(
                        family: Font.family.bold,
                        size: Font.size.lightExtra,
                        color: Color.app.white,
                        activeColor: Color.app.white
                    ),
                    size: Dimen.button.regular,
                    bgColor:Color.brand.secondary
                ){_ in
                    
                    self.close()
                }
                FillButton(
                    text: String.button.connectBtv,
                    isSelected: true,
                    textModifier: TextModifier(
                        family: Font.family.bold,
                        size: Font.size.lightExtra,
                        color: Color.app.white,
                        activeColor: Color.app.white
                    ),
                    size: Dimen.button.regular,
                    margin: 0,
                    bgColor:Color.brand.primary
                ){_ in
                    
                    if self.vsManager.isGranted {
                        self.vsManager.accountPairingAlert()
                        return
                    }
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.pairing)
                            .addParam(key: PageParam.subType, value: "mob-com-popup")
                    )
                }
            }
        }
        .background(Color.app.white)
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            switch res.type {
            case .getRecommendBenefit : break
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            switch err.type {
            case .getRecommendBenefit : break
            default: break
            }
        }
       
    }//body
    
    private func getRecommandCode(){
      
        //self.dataProvider.requestData(q: .init(type: .registRecommend(user, data)))
    }
    
    
}




#if DEBUG
struct RecommandReceiveNeedPairing_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            RecommandReceiveNeedPairing(){
                
            }
        }
        .environmentObject(PagePresenter())
        .environmentObject(DataProvider())
        .environmentObject(Pairing())
        .frame(width: 360)
        .background(Color.brand.bg)
    }
}
#endif
