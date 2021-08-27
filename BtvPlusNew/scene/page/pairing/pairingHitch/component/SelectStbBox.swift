//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI


struct SelectStbBox: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var datas:[StbData] = []
    let action: (StbData, Bool) -> Void
   
    @State var selected:StbData? = nil
    @State var isAgree1:Bool = true
    @State var isAgree2:Bool = true
    @State var isAgree3:Bool = true
    var body: some View {
        VStack(spacing: 0){
            Image( Asset.image.pairingHitchText01 )
                .renderingMode(.original).resizable()
                .scaledToFit()
                .modifier(MatchHorizontal(height: SystemEnvironment.isTablet ? 33 : 27))
                .padding(.top, Dimen.margin.medium)
            Text(self.datas.count == 1 ? String.pairingHitch.auto : String.pairingHitch.autoSelect)
                .modifier( MediumTextStyle(
                        size: Font.size.lightExtra,
                        color: Color.app.blackExtra)
                )
                .multilineTextAlignment(.center)
                .padding(.top, Dimen.margin.light)
            if self.datas.count > 1 {
                HStack( spacing: Dimen.margin.tiny){
                    ForEach( self.datas[0..<min(self.datas.count,3)]) { data in
                        HitchStbItem(
                            data: data,
                            isSelected:self.selected?.id == data.id)
                        .frame(
                            width: SystemEnvironment.isTablet ? 122 : 105,
                            height: SystemEnvironment.isTablet ? 122 : 105)
                        .onTapGesture {
                            self.selected = data
                        }
                    }
                }
                .padding(.top, Dimen.margin.regularExtra)
            }
            VStack(spacing: Dimen.margin.thin){
                CheckBox(
                    style: .white,
                    isChecked: self.isAgree1,
                    isCheckAble: false,
                    text:String.pairingHitch.userAgreement1,
                    more:{
                        self.pagePresenter.openPopup(
                            PageProvider
                                .getPageObject(.webview)
                                .addParam(key: .data, value: BtvWebView.serviceTerms)
                                .addParam(key: .title , value: String.pageTitle.serviceTerms)
                        )
                    }
                )
                
                CheckBox(
                    style: .white,
                    isChecked: self.isAgree2,
                    isCheckAble: false,
                    text:String.pairingHitch.userAgreement2,
                    more:{
                        self.pagePresenter.openPopup(
                            PageProvider
                                .getPageObject(.privacyAndAgree)
                        )
                    }
                )
                
                
                CheckBox(
                    style: .white,
                    isChecked: self.isAgree3,
                    text:String.pairingHitch.userAgreement3,
                    action:{ ck in
                        self.isAgree3 = ck
                    }
                )
            }
            .padding(.all, SystemEnvironment.isTablet ? Dimen.margin.light : Dimen.margin.regular)
            .background(Color.app.whiteDeep)
            .padding(.top, Dimen.margin.regularExtra)
            FillButton(
                text: String.app.confirm,
                isSelected:
                    self.datas.count > 1
                    ? self.selected != nil && (self.isAgree1 && self.isAgree2)
                    : (self.isAgree1 && self.isAgree2)
            ){_ in
                if !self.isAgree1 {
                    self.appSceneObserver.event = .toast(String.alert.needAgreeTermsOfService)
                    return
                }
                if !self.isAgree2 {
                    self.appSceneObserver.event = .toast(String.alert.needAgreePrivacy)
                    return
                }
                
                if self.datas.isEmpty {return}
                if self.datas.count > 1 {
                    if let selected = self.selected {
                        self.action(selected, self.isAgree3)
                    }
                } else {
                    self.action(self.datas.first!, self.isAgree3)
                }
            }
            if !SystemEnvironment.isTablet {
                Spacer().modifier(MatchHorizontal(height: self.sceneObserver.safeAreaBottom))
                    .background(Color.brand.primary)
            }
        }
        //.padding(.bottom, SystemEnvironment.isTablet ? Dimen.margin.thin : 0)
        
    }//body
}


#if DEBUG
struct SelectStbBox_Previews: PreviewProvider { 
    
    static var previews: some View {
        Form{
            SelectStbBox(
                datas: [StbData()]
            ){ _, _ in
                
            }
            .frame( width: 300)
        }
    }
}
#endif

