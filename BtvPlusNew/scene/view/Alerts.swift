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
   
    var body: some View {
       HStack(alignment: .top, spacing: Dimen.margin.tinyExtra){
            Image(Asset.icon.alert)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
            Text(text)
                .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyLight))
                .padding(.top, Dimen.margin.microExtra)
        }
    }//body
}

struct EmptyMyData: PageView {
    var icon:String = Asset.source.myEmpty
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
                .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.greyLight))
                .multilineTextAlignment(.center)
                .padding(.top, Dimen.margin.mediumExtra)
            if let tip = self.tip{
                Text(tip)
                    .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyLight))
                    .multilineTextAlignment(.leading)
                    .padding(.top, Dimen.margin.tiny)
            }
        }
        .padding(.all, Dimen.margin.medium)
        
    }//body
}

struct EmptyCard: PageView {
    var icon:String = Asset.source.myEmpty
    var text:String = String.alert.dataError
    var tip:String? = nil
    var body: some View {
        ZStack(alignment: .bottom){
            Spacer()
                .frame(
                    width: ListItem.card.size.width,
                    height: ListItem.card.size.height)
                .background(Color.app.blueLight)
                .clipShape( RoundedRectangle(cornerRadius: Dimen.radius.light))
            VStack(alignment: .center, spacing: 0){
                Image(icon)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.heavyUltra, height: Dimen.icon.heavyUltra)
                Text(text)
                    .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.white))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.mediumExtra)
                if let tip = self.tip{
                    Text(tip)
                        .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyLight))
                        .multilineTextAlignment(.center)
                        .padding(.top, Dimen.margin.tiny)
                }
            }
            .padding(.all, Dimen.margin.regular)
        }
        
        
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
                .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.greyLight))
                .multilineTextAlignment(.center)
                .padding(.top, Dimen.margin.mediumExtra)
            if let confirm = self.confirm {
                FillButton(
                    text: String.app.corfirm,
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
            EmptyCard(
                text: String.pageText.myBenefitsDiscountTvEmpty,
                tip: String.pageText.myBenefitsDiscountTvEmptyTip
            )
        }
        .frame(width: 350)
        .background(Color.brand.bg)
    }
}
#endif

