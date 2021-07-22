//
//  TicketPurchase.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/22.
//

import Foundation
/*
struct TicketPurchase:PageComponent {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    var data: TipBlockData
    var body :some View {
        HStack(spacing:Dim){
            
        }
        .modifier( ContentHorizontalEdges() )
        .onTapGesture {
            if !self.data.isMore {return}
            
            let status = self.pairing.status
            if status != .pairing {
                self.appSceneObserver.alert = .needPairing()
                return
            }
            
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.purchase)
                    .addParam(key: .data, value: self.data.data)
            )
        }
    }

}
*/
