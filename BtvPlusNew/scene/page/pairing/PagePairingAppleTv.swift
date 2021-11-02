//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PagePairingAppleTv: PageView {
    @EnvironmentObject var vsManager:VSManager
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
   
    @State var isAgree1:Bool = true
    @State var isAgree2:Bool = true
    @State var isAgree3:Bool = true
    var body: some View {
        ZStack(alignment: .center) {
            Button(action: {
                //self.pagePresenter.closePopup(self.pageObject?.id)
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black45)
            }
            VStack(spacing:0){
                Image(Asset.image.pairindPopup)
                    .renderingMode(.original)
                    .resizable()
                    .frame(
                        height: SystemEnvironment.isTablet ? 125 : 104)
                Text(String.pageText.pairingAppletvText1)
                    .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.white))
                    .padding(.top, Dimen.margin.microExtra)
                
                Text(String.pageText.pairingAppletvText2)
                    .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.regular)
                Text(String.pageText.pairingAppletvTip)
                    .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.brand.primary))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.thin)
                
                Spacer().modifier(LineHorizontal(height: Dimen.line.light, margin: Dimen.margin.regular))
                    .padding(.top, Dimen.margin.thin)
                
                AgreementBody(
                    pageObservable : self.pageObservable,
                    isAgree1: self.$isAgree1,
                    isAgree2:  self.$isAgree2,
                    isAgree3:  self.$isAgree3
                )
                .padding(.top, Dimen.margin.thin)
                .padding(.horizontal, Dimen.margin.regular)
                
                HStack(spacing:0){
                    /*
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
                        self.sendLog(category: String.app.cancel)
                        self.pagePresenter.closePopup(self.pageObject?.id)
                        
                    }*/
                    FillButton(
                        text: String.app.confirm,
                        isSelected: (self.isAgree1 && self.isAgree2),
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
                        self.sendLog(category: String.app.confirm)
                        if !self.isAgree1 {
                            self.appSceneObserver.event = .toast(String.alert.needAgreeTermsOfService)
                            return
                        }
                        if !self.isAgree2 {
                            self.appSceneObserver.event = .toast(String.alert.needAgreePrivacy)
                            return
                        }
                        self.setupPush()
                        
                    }
                }
                .padding(.top, Dimen.margin.regular)
                
            }
            .frame(width: Dimen.popup.regular)
            .background(Color.brand.bg)
        }
        .modifier(MatchParent())
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            if res.id != self.tag { return }
            switch res.type {
            case .updateAgreement : self.onUpdatedPush(res)
            default: break
            }
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else { return }
            if err.id != self.tag { return }
            switch err.type {
            case .updateAgreement : self.onUpdatePushError()
            default: break
            }
        }
        .onAppear(){
           
        }
        .onDisappear(){
            self.pagePresenter.onPageEvent(
                self.pageObject, event: .init(id: self.tag, type: .completed))
        }
    }//body
    
    private func sendLog(category:String? = nil) {
        let actionBody = MenuNaviActionBodyItem( category: category)
        self.naviLogManager.actionLog(.clickConfirmButton, actionBody: actionBody)
    }
    
    private func setupPush(){
        let select = self.isAgree3
        self.dataProvider.requestData(q: .init(id:self.tag, type: .updateAgreement(select)))
        //self.sendLog(category: String.pageText.setupAlramMarketing, config: select)
    }
    
    private func onUpdatedPush(_ res:ApiResultResponds){
        guard let data = res.data as? NpsResult  else { return onUpdatePushError() }
        guard let resultCode = data.header?.result else { return onUpdatePushError() }
        if resultCode == NpsNetwork.resultCode.success.code {
            let today = Date().toDateFormatter(dateFormat: "yy.MM.dd")
            self.appSceneObserver.event = .toast(
                self.isAgree3 ? today+"\n"+String.alert.pushOn : today+"\n"+String.alert.pushOff
            )
            self.pagePresenter.closePopup(self.pageObject?.id)
        } else {
            onUpdatePushError()
        }
    }
    
    private func onUpdatePushError(){
        self.appSceneObserver.event = .toast( String.alert.pushError )
    }
    
    private func sendLog(category:String, config:Bool) {
        let actionBody = MenuNaviActionBodyItem( config: config ? "on" : "off", category: category)
        self.naviLogManager.actionLog(.clickCardRegister, actionBody: actionBody)
    }
}

#if DEBUG
struct PagePairingAppleTv_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingAppleTv().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .frame(width: 420, height: 640, alignment: .center)
        }
    }
}
#endif
