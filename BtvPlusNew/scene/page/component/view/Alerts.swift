//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI

struct InfoAlert: PageView {
    
    let text:String
    var horizontalMargin:CGFloat = 0
    var body: some View {
       HStack(alignment: .center, spacing: Dimen.margin.tinyExtra){
            Image(Asset.icon.alertInfo)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
            Text(text)
                .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyLight))
               
        }
       .padding(.horizontal, self.horizontalMargin )
    }//body
}

struct EmptyMyData: PageView {
    var icon:String = Asset.image.myEmpty
    var text:String = String.alert.dataError
    var tip:String? = nil
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            Image(icon)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.heavyUltra, height: Dimen.icon.heavyUltra)
            Text(text)
                    .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.greyLight))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.mediumExtra)
            
            if let tip = self.tip{
                Text(tip)
                    .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.greyMedium))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.light)
            }
        }
        .padding(.all, Dimen.margin.medium)
        
    }//body
}



struct EmptyAlert: PageView {
    var icon:String = Asset.icon.alert
    var text:String = String.alert.dataError
    var confirm:(() -> Void)? = nil
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            Image(icon)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.mediumUltra, height: Dimen.icon.mediumUltra)
            Text(text)
                .kerning(Font.kern.thin)
                .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.greyLight))
                .multilineTextAlignment(.center)
                .padding(.top, Dimen.margin.mediumExtra)
            if let confirm = self.confirm {
                FillButton(
                    text: String.app.confirm,
                    isSelected: true,
                    size: Dimen.button.regular
                ){_ in
                    confirm()
                }
                .padding(.top, Dimen.margin.regular)
                .frame( width:  Dimen.button.regularHorizontal )
            }
        }
        .padding(.all, Dimen.margin.medium)
    }//body
}

struct AdultAlert: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    var text:String = String.alert.needAdultCertification
    var useCertificationBtn:Bool = true
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            //Spacer().modifier(MatchHorizontal(height:0))
            Image(Asset.icon.lockAlert)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.mediumUltra, height: Dimen.icon.mediumUltra)
            Text(text)
                .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.greyLight))
                .multilineTextAlignment(.center)
                .padding(.top, Dimen.margin.mediumExtra)
            if useCertificationBtn {
                FillButton(
                    text: String.button.adultCertification,
                    isSelected: true,
                    size: Dimen.button.regular
                ){_ in
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.adultCertification)
                    )
                }
                .padding(.top, Dimen.margin.regular)
                .frame( width:  Dimen.button.regularHorizontal )
            }
        }
        .padding(.all, Dimen.margin.medium)        
    }//body
}


#if DEBUG
struct EmptyAlert_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            EmptyAlert(
                
            ){
                
            }
        }
        .frame(width: 350)
        .background(Color.brand.bg)
    }
}
#endif

