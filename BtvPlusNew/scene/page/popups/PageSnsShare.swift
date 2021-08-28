//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageSnsShare: PageView {
    enum ShareType {
        case familyInvite
    }
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @State var type:ShareType = .familyInvite
    var body: some View {
        ZStack(alignment: .center) {
            Spacer().modifier(MatchParent())
                .background(Color.transparent.black70)
        }
        .modifier(MatchParent())
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            switch res.type {
            case .getPairingToken :
                guard let pairingToken = res.data as? PairingToken else { return }
                if pairingToken.header?.result == ApiCode.success, let token  = pairingToken.body?.pairing_token {
                    self.share(token : token )
                } else {
                    self.appSceneObserver.alert = .alert(
                        nil ,
                        pairingToken.header?.reason ?? String.alert.apiErrorServer ){
                            self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                }
                
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            switch err.type {
            case .getPairingToken : break
            default: break
            }
        }
        .onAppear(){
            guard let obj = self.pageObject  else { return }
            if let type = obj.getParamValue(key: .type) as? ShareType {
                self.type = type
            }
            
            
            switch type {
            case .familyInvite :
                self.dataProvider.requestData(q: .init(type: .getPairingToken(self.pairing.stbId)))
            }
        }
        
    }//body
    
    private func share(token :String){
        
        let link = ApiPath.getRestApiPath(.WEB)
            + SocialMediaSharingManage.familyInvite
            + "&pairing_token=" + token
            + "&nickname=" + (self.pairing.user?.nickName ?? "")
           
        self.repository.shareManager.share(
            Shareable(
                link:link,
                text: String.share.shareFamilyInvite,
                useDynamiclink:true
            )
        ){ isComplete in
           
        }
        self.pagePresenter.closePopup(self.pageObject?.id)
    }
}



