//
//  HostDevice.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/12.
//

import Foundation


enum AuthRequest:Equatable{
    case updateTicket
    
}


class Authority:ObservableObject, PageProtocol {
    @Published private(set) var request:AuthRequest? = nil
    
    @Published private(set) var purchaseTicketList: [MonthlyInfoItem]? = nil
    @Published private(set) var purchaseLowLevelTicketList: [MonthlyInfoItem]? = nil
  
    func reset() {
        purchaseTicketList = nil
        purchaseLowLevelTicketList = nil
    }
    
    func requestAuth(_ request:AuthRequest){
        self.request = request
    }
    
    func updatePurchaseTicket(_ purchases: [MonthlyInfoItem], lowLevelPpm:Bool){
        if lowLevelPpm {
            self.purchaseLowLevelTicketList = purchases
        } else {
            self.purchaseTicketList = purchases
        }
    }
}
