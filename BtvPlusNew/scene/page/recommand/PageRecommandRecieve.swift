//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageRecommandReceive: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    var body: some View {
        ZStack(alignment: .center) {
            Button(action: {
                self.pagePresenter.closePopup(self.pageObject?.id)
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            ZStack{
                if !self.isPairing {
                    RecommandReceiveNeedPairing(
                        recommandFriend: self.recommandFriend,
                        recommandTitle: self.recommandTitle){
                        
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                } else {
                    if self.isCompleted {
                        RecommandReceiveCompleted(
                            recommandTitle: self.recommandTitle){
                            
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                    } else if let error = self.error {
                        RecommandReceiveError(
                            error:error){
                            
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                        
                    } else {
                        RecommandReceive(
                            mgmId:self.mgmId,
                            srisTypeCd: self.srisTypeCd,
                            recommandFriend: self.recommandFriend,
                            recommandTitle: self.recommandTitle){
                            
                            self.getRecommandCoupon()
                        }
                    }
                }
                
            }
            .frame(width: Dimen.popup.regular)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.heavy))
        }
        .modifier(MatchParent())
        .onReceive(self.pairing.$status){ status in
            withAnimation{
                self.isPairing = status == .pairing
            }
        }
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            switch res.type {
            case .getRecommendCoupon :
                guard let coupon = res.data as? RecommandCoupon else { return }
                self.onRecommandCoupon( coupon)
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            switch err.type {
            case .getRecommendCoupon :
                self.error = .etc
            default: break
            }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                //self.dataProvider.requestData(q: .init(type: .getRecommendHistory))
            }
        }
        .onAppear(){
            guard let obj = self.pageObject  else { return }
            self.mgmId = obj.getParamValue(key: .id) as? String
            self.recommandFriend = obj.getParamValue(key: .text) as? String ?? ""
            self.recommandTitle = obj.getParamValue(key: .title) as? String ?? ""
            self.srisTypeCd = obj.getParamValue(key: .type) as? String
        }
        
    }//body
    
    @State var mgmId:String? = nil
    @State var srisTypeCd:String? = nil
    @State var isCompleted:Bool = false
    @State var error:MgmRpsNetwork.MgmError? = nil
 
    @State var isPairing:Bool = false
    
    @State var recommandFriend:String = ""
    @State var recommandTitle:String = ""
    
    private func getRecommandCoupon(){
        guard let mgmId = self.mgmId else {return}
        self.dataProvider.requestData(q: .init(type:
                                                .getRecommendCoupon(
                                                    mgmId: mgmId,
                                                    srisTypeCd: self.srisTypeCd)))
    }
    
    private func onRecommandCoupon(_ coupon:RecommandCoupon){
        guard let result = coupon.result else {
            self.error = .etc
            return
        }
        if result == ApiCode.ok || result == ApiCode.success || result == ApiCode.success2{
            self.isCompleted = true
        } else {
            self.error = MgmRpsNetwork.MgmError.getType(result)
        }
    }
}



#if DEBUG
struct PageRecommandReceive_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageRecommandReceive().contentBody
                .environmentObject(DataProvider())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .frame(width: 420, height: 640, alignment: .center)
        }
    }
}
#endif
