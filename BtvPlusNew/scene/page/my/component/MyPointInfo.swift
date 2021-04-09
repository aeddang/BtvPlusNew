//
//  ValueInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/19.
//

import Foundation
import SwiftUI
struct MyPointInfo: View {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    
    var body: some View {
        HStack(spacing: 0){
            ValueInfo(key: String.app.ticket, value: self.ticket)
                .modifier(MatchParent())
                .onTapGesture {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.purchaseTicketList)
                    )
                }
            Spacer().modifier(LineVertical())
                .frame(height:Dimen.button.lightExtra)
            ValueInfo(key: String.app.coupon, value: self.coupon)
                .modifier(MatchParent())
            Spacer().modifier(LineVertical())
                .frame(height:Dimen.button.lightExtra)
            ValueInfo(key: String.app.bpoint, value: self.point)
                .modifier(MatchParent())
            Spacer().modifier(LineVertical())
                .frame(height:Dimen.button.lightExtra)
            ValueInfo(key: String.app.bcash, value: self.cash)
                .modifier(MatchParent())
        }
        .frame(height:Dimen.tab.heavy)
        .background(Color.app.blueLight)
        .onReceive(self.pairing.authority.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .updatedMyinfo : self.updatedMyInfo()
            case .updateMyinfoError(let err) : self.errorMyInfo(err)
            //default : break
            }
        }
        .onReceive(self.pairing.authority.$totalPointInfo){ info in
            if info == nil && !ticket.isEmpty {
                self.pairing.authority.requestAuth(.updateMyinfo(isReset:true))
            }
        }
        .onAppear(){
            self.pairing.authority.requestAuth(.updateMyinfo(isReset:true))
        }
    }//body
    
    @State var ticket:String = ""
    @State var coupon:String = ""
    @State var point:String = ""
    @State var cash:String = ""
    
    func updatedMyInfo(){
        self.updateMonthlyPurchase()
        self.updateTotalInfo()
    }
    
    func errorMyInfo(_ err:ApiResultError?){
        if let apiError = err?.error as? ApiError {
            self.appSceneObserver.alert = .alert(String.alert.connect, ApiError.getViewMessage(message: apiError.message))
        }else{
            self.appSceneObserver.alert = .alert(String.alert.connect, String.alert.needConnectStatus)
        }
    }
    
    private func updateMonthlyPurchase(){
        var total:Int  = 0
        if let data = self.pairing.authority.monthlyPurchaseInfo {
            total += (data.purchaseList?.count ?? 0)
        }
        if let data = self.pairing.authority.periodMonthlyPurchaseInfo {
            total += (data.purchaseList?.count ?? 0)
        }
        self.ticket = total.description + String.app.count
    }
    
    private func updateTotalInfo(){
        if let data = self.pairing.authority.totalPointInfo {
            self.coupon = (data.coupon?.usableCount ?? 0).description + String.app.count
            self.point = (data.NewBpoint?.usableNewBpoint?.formatted(style: .decimal) ?? "0").description + "P"
            self.cash = (data.bcash?.usableBcash?.totalBalance?.formatted(style: .decimal) ?? "0").description + "P"
        }
    }
    
}


#if DEBUG
struct MyPointInfo_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            MyPointInfo()
        }
    }
}
#endif
