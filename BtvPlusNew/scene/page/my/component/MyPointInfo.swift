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
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    
    var body: some View {
        HStack(spacing: 0){
            ValueInfo(key: String.app.ticket, value: self.ticket)
                .modifier(MatchParent())
                .onTapGesture {
                    if self.pairing.authority.useAbleTicket == 0 {
                        guard let blocksData = self.dataProvider.bands.getData(gnbTypCd: EuxpNetwork.GnbTypeCode.GNB_MONTHLY.rawValue)?.blocks else {return}
                        guard let allData = blocksData.first(where: {$0.prd_prc_id == nil}) else {return}
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.monthlyTicket)
                                .addParam(key: .id, value: allData.menu_id)
                                .addParam(key: .title, value: allData.menu_nm)
                                .addParam(key: .data, value: allData.blocks)
                                .addParam(key: .type, value: BlockData.ThemaType.ticket)
                        )
                        
                    } else {
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.myPurchaseTicketList)
                        )
                    }
                    
                }
            Spacer().modifier(LineVertical())
                .frame(height:Dimen.button.lightExtra)
            ValueInfo(key: String.app.coupon, value: self.coupon)
                .modifier(MatchParent())
                .onTapGesture {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.myBenefits)
                            .addParam(key: .id, value: PageMyBenefits.MenuType.coupon.rawValue)
                    )
                }
            Spacer().modifier(LineVertical())
                .frame(height:Dimen.button.lightExtra)
            ValueInfo(key: String.app.bpoint, value: self.point)
                .modifier(MatchParent())
                .onTapGesture {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.myBenefits)
                            .addParam(key: .id, value: PageMyBenefits.MenuType.point.rawValue)
                    )
                }
            if self.pairing.pairingStbType == .btv {
                Spacer().modifier(LineVertical())
                    .frame(height:Dimen.button.lightExtra)
                ValueInfo(key: String.app.bcash, value: self.cash)
                    .modifier(MatchParent())
                    .onTapGesture {
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.myBenefits)
                                .addParam(key: .id, value: PageMyBenefits.MenuType.cash.rawValue)
                        )
                    }
            }
        }
        .frame(height:SystemEnvironment.isTablet ? Dimen.tab.heavyExtra : Dimen.tab.heavy)
        .background(Color.app.blueLight)
        .onReceive(self.pairing.authority.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .updateMyinfoError(let err) : self.errorMyInfo(err)
            default : break
            }
        }
        .onReceive(self.pairing.authority.$useAbleBPoint){ point in
            self.point = point.formatted(style: .decimal).description + String.app.point
        }
        .onReceive(self.pairing.authority.$useAbleBCash){ cash in
            self.cash = cash.formatted(style: .decimal).description + String.app.point
        }
        .onReceive(self.pairing.authority.$useAbleCoupon){ coupon in
            self.coupon = coupon.description + String.app.count
        }
        .onReceive(self.pairing.authority.$useAbleTicket){ ticket in
            self.ticket = ticket > 0
            ? ticket.description + String.app.count
            : String.pageText.myTicketMore
        }
        .onAppear(){
            self.pairing.authority.requestAuth(.updateMyinfo(isReset:true))
        }
    }//body
    
    @State var ticket:String = ""
    @State var coupon:String = ""
    @State var point:String = ""
    @State var cash:String = ""
    
    
    func errorMyInfo(_ err:ApiResultError?){
        if let apiError = err?.error as? ApiError {
            self.appSceneObserver.alert = .alert(String.alert.connect, ApiError.getViewMessage(message: apiError.message))
        }else{
            self.appSceneObserver.alert = .alert(String.alert.connect, String.alert.needConnectStatus)
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
