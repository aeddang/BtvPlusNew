//
//  HostDevice.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/12.
//

import Foundation


enum AuthRequest{
    case updateMyinfo(isReset:Bool), updateTicket, updateTotalPoint, updateMonthlyPurchase(isPeriod:Bool)
}

enum AuthEvent{
    case updatedMyinfo, updateMyinfoError(ApiResultError?)
}


class Authority:ObservableObject, PageProtocol {
    @Published private(set) var request:AuthRequest? = nil
    @Published private(set) var event:AuthEvent? = nil {didSet{ if event != nil { event = nil} }}
    
    @Published private(set) var purchaseTicketList: [MonthlyInfoItem]? = nil
    @Published private(set) var purchaseLowLevelTicketList: [MonthlyInfoItem]? = nil
    @Published private(set) var totalPointInfo:TotalPointInfo? = nil
    @Published private(set) var monthlyPurchaseInfo:MonthlyPurchaseInfo? = nil
    @Published private(set) var periodMonthlyPurchaseInfo:PeriodMonthlyPurchaseInfo? = nil
  
    private var isMyInfoUpdate:Bool = false
    
    func reset() {
        purchaseTicketList = nil
        purchaseLowLevelTicketList = nil
        totalPointInfo = nil
        monthlyPurchaseInfo = nil
        periodMonthlyPurchaseInfo = nil
    }
    
    func requestAuth(_ request:AuthRequest){
        switch request{
        case .updateMyinfo(let isReset):
            if isReset {self.reset()}
            self.isMyInfoUpdate = false
            var needUpdate = false
            if self.totalPointInfo == nil {
                needUpdate = true
                self.request = .updateTotalPoint
            }
            if self.monthlyPurchaseInfo == nil {
                needUpdate = true
                self.request = .updateMonthlyPurchase(isPeriod: false)
            }
            if self.periodMonthlyPurchaseInfo == nil {
                needUpdate = true
                self.request = .updateMonthlyPurchase(isPeriod: true)
            }
            if !needUpdate { self.completedMyInfo() }
            else { self.isMyInfoUpdate = true }
        default : self.request = request
        }
    }
    
    func updatedPurchaseTicket(_ purchases: [MonthlyInfoItem], lowLevelPpm:Bool){
        if lowLevelPpm {
            self.purchaseLowLevelTicketList = purchases
        } else {
            self.purchaseTicketList = purchases
        }
    }
    
    func updatedTotalPointInfo(_ totalPointInfo:TotalPointInfo){
        self.totalPointInfo = totalPointInfo
        self.checkMyInfoUpdate()
    }
    
    func updatedMonthlyPurchaseInfo(_ monthlyPurchaseInfo:MonthlyPurchaseInfo){
        self.monthlyPurchaseInfo = monthlyPurchaseInfo
        self.checkMyInfoUpdate()
    }
    
    func updatedMonthlyPurchaseInfo(_ monthlyPurchaseInfo:PeriodMonthlyPurchaseInfo){
        self.periodMonthlyPurchaseInfo = monthlyPurchaseInfo
        self.checkMyInfoUpdate()
    }
    func errorMyInfo(_ err:ApiResultError?){
        if !self.isMyInfoUpdate { return }
        self.isMyInfoUpdate = false
        self.event = .updateMyinfoError(err)
    }
    
    private func completedMyInfo(){
        self.isMyInfoUpdate = false
        self.event = .updatedMyinfo
    }
    
    
    
    private func checkMyInfoUpdate(){
        if !self.isMyInfoUpdate { return }
        if self.totalPointInfo == nil { return }
        if self.monthlyPurchaseInfo == nil { return }
        if self.periodMonthlyPurchaseInfo == nil { return }
        self.completedMyInfo()
    }
}
