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
        }
    }//body
}

struct EmptyMyData: PageView {
    var icon:String = Asset.source.myEmpty
    var text:String = String.alert.dataError
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            Image(icon)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 157, height: 157)
            Text(text)
                .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.greyLight))
                .multilineTextAlignment(.center)
                .padding(.top, Dimen.margin.mediumExtra)
        }
        .padding(.all, Dimen.margin.medium)
    }//body
}

struct EmptyAlert: PageView {
    var icon:String = Asset.icon.alert
    var text:String = String.alert.dataError
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
                .frame(width: 247)
            }
        }
        .padding(.all, Dimen.margin.medium)        
    }//body
}


#if DEBUG
struct EmptyAlert_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            InfoAlert(
                text: "편성 종료 D-7"
            )
        }
        .frame(width: 320)
        .background(Color.brand.bg)
    }
}
#endif

