//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PagePairingFamilyInvite: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
   
    @State var isAgree1:Bool = true
    @State var isAgree2:Bool = true
    @State var isAgree3:Bool = true
    var body: some View {
        ZStack(alignment: .center) {
            Button(action: {
                self.pagePresenter.closePopup(self.pageObject?.id)
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            VStack(spacing:0){
                Image(Asset.image.pairindPopup)
                    .renderingMode(.original)
                    .resizable()
                    .frame(
                        height: SystemEnvironment.isTablet ? 125 : 104)
                Text(self.inviteNick + String.pageText.pairingFamilyInviteText1)
                    .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.white))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.microExtra)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(String.pageText.pairingFamilyInviteText2)
                    .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.regular)
                    .fixedSize(horizontal: false, vertical: true)
                
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
                        self.sendLog(action: .clickPopupButton, category:  String.app.cancel )
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
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
                        
                        self.sendLog(action: .clickPopupButton, category: String.app.confirm)
                        if self.pairing.status == .pairing {
                            if self.pairing.stbId == self.inviteHostDeviceid {
                                self.appSceneObserver.alert = .alert(
                                    String.alert.api,
                                    String.pageText.pairingFamilyInviteErrorAlreadyPairing)
                            } else {
                                self.appSceneObserver.alert = .alert(
                                    String.alert.api,
                                    String.pageText.pairingFamilyInviteErrorAnotherPairing,
                                    String.pageText.pairingFamilyInviteErrorAnotherPairingSub)
                            }
                            return
                        }
                        
                        if !self.isAgree1 {
                            self.appSceneObserver.event = .toast(String.alert.needAgreeTermsOfService)
                            return
                        }
                        if !self.isAgree2 {
                            self.appSceneObserver.event = .toast(String.alert.needAgreePrivacy)
                            return
                        }
                        self.dataProvider.requestData(q: .init(type: .validatePairingToken(pairingToken: self.pairingToken)))
                    }
                }
                .padding(.top, Dimen.margin.regular)
                
            }
            .frame(width: Dimen.popup.regular)
            .background(Color.brand.bg)
        }
        .modifier(MatchParent())
        
        .onReceive(self.pairing.$event){ evt in
           
            guard let evt = evt else {return}
            switch evt {
            case .pairingCompleted :
                self.pagePresenter.closePopup(self.pageObject?.id)
            case .connectError(let header) :
                if header?.result == NpsNetwork.resultCode.pairingLimited.code {
                    self.pairing.requestPairing(.hostInfo(auth: nil, device:inviteHostDeviceid, prevResult: header))
                } else {
                    self.appSceneObserver.alert = .pairingError(header)
                    self.pagePresenter.closePopup(self.pageObject?.id)
                }
            case .connectErrorReason(let info) :
                self.appSceneObserver.alert = .limitedDevice(info)
                
            default : break
            }
        }
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            switch res.type {
            case .validatePairingToken :
                guard let pairing = res.data as? DevicePairing else { return }
                if pairing.header?.result == ApiCode.success, let deviceid  = pairing.body?.guest_deviceid {
                    self.inviteHostDeviceid = deviceid
                    self.pairing.user = User().setDefault(isAgree: self.isAgree3)
                    self.pairing.requestPairing(.token(self.pairingToken))
                } else {
                    switch pairing.header?.result {
                    case "1004":
                        self.appSceneObserver.alert = .alert(
                            String.alert.api,
                            String.pageText.pairingFamilyInviteErrorHost)
                    case "1033":
                        self.appSceneObserver.alert = .alert(
                            String.alert.api,
                            String.pageText.pairingFamilyInviteErrorExpired)
                    default:
                        self.appSceneObserver.alert = .alert(
                            String.alert.api,
                            String.pageText.pairingFamilyInviteError)
                    }
                    self.pagePresenter.closePopup(self.pageObject?.id)
                }
                
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            switch err.type {
            case .validatePairingToken :
                self.pagePresenter.closePopup(self.pageObject?.id)
            default: break
            }
        }
        .onAppear(){
            guard let obj = self.pageObject  else { return }
            self.inviteNick = obj.getParamValue(key: .title) as? String ?? ""
            self.pairingToken = obj.getParamValue(key: .id) as? String ?? ""
            self.sendLog(action: .pageShow, category: !self.inviteNick.isEmpty ? "mobile_invitation" : "etc" )
            
            
        }
        
    }//body
    
    @State var inviteNick:String = ""
    @State var pairingToken:String = ""
    @State var inviteHostDeviceid:String? = nil
    
    private func sendLog(action:NaviLog.Action, category:String){
       
        var actionBody = MenuNaviActionBodyItem()
        actionBody.menu_id = ""
        actionBody.menu_name = "연결초대"
        actionBody.category = category
        self.naviLogManager.actionLog(action, pageId: .popup, actionBody: actionBody)
    }
    
}

#if DEBUG
struct PagePairingFamilyInvite_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingFamilyInvite().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .frame(width: 420, height: 640, alignment: .center)
        }
    }
}
#endif
