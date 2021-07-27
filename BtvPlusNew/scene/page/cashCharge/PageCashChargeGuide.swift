//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageCashChargeGuide: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
   
    @State var isAgree = true
    var body: some View {
        ZStack(alignment: .center) {
            Button(action: {
                self.pagePresenter.closePopup(self.pageObject?.id)
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            VStack(spacing:Dimen.margin.regular){
                Text(String.pageTitle.cashChargeGuide)
                    .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.white))
                    .padding(.top, Dimen.margin.regular)
                VStack(spacing:Dimen.margin.tiny){
                    Text(String.pageText.cashChargeGuideText)
                        .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                        .multilineTextAlignment(.center)
                    Text(String.pageText.cashChargeGuideTip)
                        .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.brand.primary))
                        .multilineTextAlignment(.center)
                }
                CheckBox(
                    style:.small,
                    isChecked: self.isAgree,
                    text:String.pageText.cashChargeGuideAgree,
                
                    more:{
                        self.pagePresenter.openPopup(
                            PageProvider
                                .getPageObject(.cashChargePrivacyAndAgree)
                        )
                    },
                    action:{ ck in
                        self.isAgree = ck
                    }
                )
                .padding(.horizontal, Dimen.margin.regular)
                
                HStack(spacing:0){
                    FillButton(
                        text: String.app.close,
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
                        
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                    FillButton(
                        text: String.pageText.cashChargeGuideButton,
                        isSelected: self.isAgree,
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
                        if !self.isAgree {
                            self.appSceneObserver.event = .toast(String.alert.needAgreePrivacy)
                            return
                        }
                        self.pagePresenter.closePopup(self.pageObject?.id)
                        self.repository.storage.isFirstCashCharge = false
                        self.pagePresenter.openPopup(
                            PageProvider
                                .getPageObject(.cashCharge)
                        )
                        
                    }
                }
                
            }
            .frame(width: Dimen.popup.regular)
            .background(Color.brand.bg)
        }
        .modifier(MatchParent())
        .onAppear(){
           
        }
        
    }//body
    
    
}

#if DEBUG
struct PageCashChargeGuide_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageCashChargeGuide().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .frame(width: 420, height: 640, alignment: .center)
        }
    }
}
#endif
