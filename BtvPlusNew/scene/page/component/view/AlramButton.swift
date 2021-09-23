
//
//  Banner.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct AlramButton: PageView {
   
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var naviLogManager:NaviLogManager
    var data:NotificationData
    @Binding var isAlram:Bool?
    var action: ((_ ac:Bool) -> Void)? = nil
    
    var body: some View {
        Button(action: {
            let status = self.pairing.status
            if status != .pairing {
                self.appSceneObserver.alert = .needPairing()
            }
            else{
                self.requestToggle()
            }
        }) {
            VStack(spacing:0){
                Image( self.isAlram == true ? Asset.icon.alarmOn
                        : Asset.icon.alarmOff )
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(
                        width: Dimen.icon.regular,
                        height: Dimen.icon.regular)
                
            }
        }//btn
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .postNotificationVod(let data): self.regist(data, res:res)
            case .deleteNotificationVod(let srisId): self.delete(srisId, res:res)
            case .updateAgreement(let isAgree, _) : self.onUpdatedPush(res, isAgree: isAgree)
            default: break
            }
            
        }
        .onReceive(self.dataProvider.$error){ err in
            //guard let err = err else { return }
            
        }
        .onAppear{
           
        }
        
    }//body
    
    func requestToggle(){
        if self.isAlram == true {
            dataProvider.requestData(q: .init( type: .deleteNotificationVod(self.data.srisId)))
        } else {
            if self.pairing.user?.isAgree3 == true {
                self.requestrRegist()
                return
            }
            
            self.appSceneObserver.alert = .confirm(
                String.alert.vodUpdate,
                String.alert.vodUpdateText,
                confirmText: String.alert.vodUpdateButton){ isOk in
                
                if isOk {
                    self.dataProvider.requestData(q: .init(type: .updateAgreement(true)))
                    self.sendLog(category: String.pageText.setupAlramMarketing, config: true)
                }
            }
        }
    }
    
    private func onUpdatedPush(_ res:ApiResultResponds, isAgree:Bool){
        guard let data = res.data as? NpsResult  else { return onUpdatePushError() }
        guard let resultCode = data.header?.result else { return onUpdatePushError() }
        if resultCode == NpsNetwork.resultCode.success.code {
            let today = Date().toDateFormatter(dateFormat: "yy.MM.dd")
            self.appSceneObserver.event = .toast(
                isAgree ? today+"\n"+String.alert.pushOn : today+"\n"+String.alert.pushOff
            )
            self.requestrRegist()
        } else {
            onUpdatePushError()
        }
    }
    private func onUpdatePushError(){
        self.appSceneObserver.event = .toast( String.alert.pushError )
    }
    
    private func requestrRegist(){
        self.dataProvider.requestData(q: .init( type: .postNotificationVod(self.data)))
    }
        
    private func regist(_ data:NotificationData?, res:ApiResultResponds){
        if self.data.srisId == data?.srisId && self.data.epsdId == data?.epsdId {
            if !checkResult(res:res) { return }
            self.isAlram = true
            action?(true)
            self.appSceneObserver.event = .toast(String.alert.updateRegistAlram)
        }
    }
    private func delete(_ srisId:String?, res:ApiResultResponds){
        if self.data.srisId == srisId {
            if !checkResult(res:res) { return }
            self.isAlram = false
            action?(false)
            self.appSceneObserver.event = .toast(String.alert.updateUnregistAlram)
        }
    }
    
    private func checkResult(res:ApiResultResponds)->Bool{
        guard let result = res.data as? RegistNotificationVod else {
            self.appSceneObserver.event = .toast(String.alert.apiErrorServer)
            return false
        }
        if result.result != ApiCode.success {
            self.appSceneObserver.event = .toast(result.reason ?? String.alert.apiErrorServer)
            return false
        }
        return true
    }
    
    
    
    private func sendLog(category:String, config:Bool) {
        let actionBody = MenuNaviActionBodyItem( config: config ? "on" : "off", category: category)
        self.naviLogManager.actionLog(.clickCardRegister, actionBody: actionBody)
    }
}

#if DEBUG
struct AlramButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            AlramButton (
                data: NotificationData(),
                isAlram: .constant(true)
            ){ ac in
                
            }
            .environmentObject(DataProvider())
            .environmentObject(AppSceneObserver())
            .environmentObject(Pairing())
        }
    }
}
#endif

