//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PagePrivacyAndAgree: PageView {
    
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
                TableBox(
                    datas: [
                        TableBox.Data(title: String.pageText.privacyAndAgreeTitle1, text: String.pageText.privacyAndAgreeText1),
                        TableBox.Data(title: String.pageText.privacyAndAgreeTitle2, text: String.pageText.privacyAndAgreeText2),
                        TableBox.Data(title: String.pageText.privacyAndAgreeTitle3, text: String.pageText.privacyAndAgreeText3)
                    
                    ]
                )
                
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
                        
                        self.pagePresenter.onPageEvent(self.pageObject,
                                                       event: .init(id:self.tag, type: .cancel))
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                    FillButton(
                        text: String.button.agree,
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
struct PagePrivacyAndAgree_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePrivacyAndAgree().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                
                .frame(width: 420, height: 640, alignment: .center)
        }
    }
}
#endif
