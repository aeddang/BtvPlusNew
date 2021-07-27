//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageCashChargePrivacyAndAgree: PageView {
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
   
    var body: some View {
        ZStack(alignment: .center) {
            Button(action: {
                self.pagePresenter.closePopup(self.pageObject?.id)
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            VStack(spacing:Dimen.margin.regular){
                Text(String.pageTitle.privacyAndAgree)
                    .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.white))
                    .padding(.top, Dimen.margin.regular)
                VStack(spacing:Dimen.margin.regular){
                    TableBox(
                        datas: [
                            TableBox.Data(
                                title: String.pageText.cashChargeGuideAgreeTitle1,
                                text: String.pageText.cashChargeGuideAgreeText1,
                                axis: .vertical
                                ),
                            TableBox.Data(
                                title: String.pageText.cashChargeGuideAgreeTitle2,
                                text: String.pageText.cashChargeGuideAgreeText2,
                                axis: .vertical
                                ),
                            TableBox.Data(
                                title: String.pageText.cashChargeGuideAgreeTitle3,
                                text: String.pageText.cashChargeGuideAgreeText3,
                                axis: .vertical
                                ),
                            TableBox.Data(
                                title: String.pageText.cashChargeGuideAgreeTitle4,
                                text: String.pageText.cashChargeGuideAgreeText4,
                                axis: .vertical
                                )
                        ]
                    )
                    Text(String.pageText.cashChargeGuideAgreeText)
                        .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.white))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Dimen.margin.thin)
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
                    bgColor:Color.brand.primary
                ){_ in
                    
                    self.pagePresenter.onPageEvent(self.pageObject,
                                                   event: .init(id:self.tag, type: .completed))
                    self.pagePresenter.closePopup(self.pageObject?.id)
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
struct PageCashChargePrivacyAndAgree_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageCashChargePrivacyAndAgree().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                
                .frame(width: 420, height: 640, alignment: .center)
        }
    }
}
#endif
