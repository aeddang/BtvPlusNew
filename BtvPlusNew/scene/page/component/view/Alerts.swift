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
       HStack(alignment: .top, spacing: Dimen.margin.tinyExtra){
            Image(Asset.icon.alertInfo)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                .padding(.top, -Dimen.margin.micro)
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
                .modifier(BoldTextStyle(size: SystemEnvironment.isTablet ? Font.size.thin : Font.size.regular, color: Color.app.greyLight))
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
    @EnvironmentObject var sceneObserver:PageSceneObserver
    
    var icon:String = Asset.icon.alert
    var title:String? = nil
    var text:String = String.alert.dataError
    var textHorizontal:String? = nil
    var confirm:(() -> Void)? = nil
    
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            Image(icon)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.mediumUltra, height: Dimen.icon.mediumUltra)
                .padding(.bottom, Dimen.margin.regular)
            if let title = self.title {
                Text(title)
                    .kerning(Font.kern.thin)
                    .modifier(BoldTextStyle(size: SystemEnvironment.isTablet ? Font.size.regular : Font.size.mediumExtra, color: Color.app.white))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, Dimen.margin.light)
            }
          
            Text(self.sceneOrientation == .landscape ? self.textHorizontal ?? self.text : self.text)
                .kerning(Font.kern.thin)
                .modifier(MediumTextStyle(size: SystemEnvironment.isTablet ? Font.size.thin : Font.size.regular, color: Color.app.greyLight))
                .multilineTextAlignment(.center)
                .padding(.bottom, Dimen.margin.light)
            if let confirm = self.confirm {
                FillButton(
                    text: String.app.confirm,
                    isSelected: true,
                    size: Dimen.button.regular
                ){_ in
                    confirm()
                }
                
                .frame( width:  Dimen.button.regularHorizontal )
            }
        }
        .padding(.all, SystemEnvironment.isTablet ? Dimen.margin.regularExtra : Dimen.margin.medium)
        .onReceive(self.sceneObserver.$isUpdated){ update in
            if !update {return}
            self.sceneOrientation  = self.sceneObserver.sceneOrientation
        }
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

