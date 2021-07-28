import Foundation
//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI


struct RecommandReceive: PageComponent {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
   
    var mgmId:String? = nil
    var srisTypeCd:String? = nil
    var recommandFriend:String = "???"
    var recommandTitle:String = "???"
    var action: () -> Void
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
                
                VStack(alignment: .center, spacing: Dimen.margin.tinyExtra) {
                    Text(String.share.synopsisRecommandReceiveText)
                        .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.black))
                        .multilineTextAlignment(.center)
                        
                    Text(String.share.synopsisRecommandReceiveTip)
                        .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.grey))
                        .multilineTextAlignment(.center)
                }
                
            }
            .padding(.all, SystemEnvironment.isTablet ? Dimen.margin.light : Dimen.margin.regular)
            FillButton(
                text: String.share.synopsisRecommandReceiveButton,
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
                self.action()
            }
        }
        .background(Color.app.white)
        
       
    }//body
    
    
    
    
}




#if DEBUG
struct RecommandReceive_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            RecommandReceive(){
                
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
