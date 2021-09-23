//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupAlram: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    var isInitate:Bool = false
    var isPairing:Bool = false
   
    @Binding var isPush:Bool
    @State var willPush:Bool? = nil
    
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupAlram).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: self.$isPush,
                    title: String.pageText.setupAlramMarketing ,
                    subTitle: String.pageText.setupAlramMarketingText,
                    tips: [
                        String.pageText.setupAlramMarketingTip1,
                        String.pageText.setupAlramMarketingTip2,
                        String.pageText.setupAlramMarketingTip3,
                        String.pageText.setupAlramMarketingTip4,
                        String.pageText.setupAlramMarketingTip5
                    ]
                )
            }
            .background(Color.app.blueLight)
        }
        .onReceive( [self.isPush].publisher ) { value in
            if !self.isInitate { return }
            if self.willPush != nil { return }
            
            if self.pairing.user?.isAgree3 == self.isPush { return }
            if self.isPairing == false {
                if value {
                    self.appSceneObserver.alert = .needPairing()
                    self.isPush = false
                }
                return
            }
            self.setupPush(value)
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .updateAgreement(let isAgree, _) : self.onUpdatedPush(res, isAgree: isAgree)
            default: do{}
            }
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else { return }
            switch err.type {
            case .updateAgreement : self.onUpdatePushError()
            default: do{}
            }
        }
    }//body
    
    private func setupPush(_ select:Bool){
        if self.isPairing == false { return }
        self.willPush = select
        self.dataProvider.requestData(q: .init(type: .updateAgreement(select)))
        self.sendLog(category: String.pageText.setupAlramMarketing, config: select)
    }
    
    private func onUpdatedPush(_ res:ApiResultResponds, isAgree:Bool){
        guard let data = res.data as? NpsResult  else { return onUpdatePushError() }
        guard let resultCode = data.header?.result else { return onUpdatePushError() }
        if resultCode == NpsNetwork.resultCode.success.code {
            //self.repository.updatePush(isAgree)
            self.isPush = isAgree
            let today = Date().toDateFormatter(dateFormat: "yy.MM.dd")
            self.appSceneObserver.event = .toast(
                isAgree ? today+"\n"+String.alert.pushOn : today+"\n"+String.alert.pushOff
            )
            self.willPush = nil
        } else {
            onUpdatePushError()
        }
    }
    
    private func onUpdatePushError(){
        self.appSceneObserver.event = .toast( String.alert.pushError )
        self.willPush = nil
    }
    
    private func sendLog(category:String, config:Bool) {
        let actionBody = MenuNaviActionBodyItem( config: config ? "on" : "off", category: category)
        self.naviLogManager.actionLog(.clickCardRegister, actionBody: actionBody)
    }
}

#if DEBUG
struct SetupAlram_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupAlram(isPush: .constant(false))
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
