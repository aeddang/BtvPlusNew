import Foundation
//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI


struct RecommandReceiveError: PageComponent {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
   
    var error:MgmRpsNetwork.MgmError = .etc
    var close: () -> Void
    
    var body: some View {
        VStack(spacing:0){
            VStack(alignment: .center, spacing:SystemEnvironment.isTablet ? Dimen.margin.light : Dimen.margin.regular){
                Text(String.share.synopsisRecommandReceiveError)
                    .modifier(BoldTextStyle(size: Font.size.regular, color: Color.brand.primary))
                    
                
                VStack(alignment: .center, spacing: Dimen.margin.tinyExtra) {
                    if let errMsg = self.error.msg {
                        Text(errMsg)
                            .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.black))
                            .multilineTextAlignment(.center)
                    }
                    if let errMsgTip = self.error.tip {
                        Text(errMsgTip)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.grey))
                            .multilineTextAlignment(.center)
                    }
                }
                
            }
            .padding(.all, SystemEnvironment.isTablet ? Dimen.margin.light : Dimen.margin.regular)
            FillButton(
                text: String.app.confirm,
                isSelected: true,
                textModifier: TextModifier(
                    family: Font.family.bold,
                    size: Font.size.lightExtra,
                    color: Color.app.white,
                    activeColor: Color.app.white
                ),
                size: Dimen.button.regular,
                bgColor:Color.brand.primary
            ){_ in
                self.close()
            }
        }
        .background(Color.app.white)
        
       
    }//body
    
}




#if DEBUG
struct RecommandReceiveError_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            RecommandReceiveError(){
                
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
