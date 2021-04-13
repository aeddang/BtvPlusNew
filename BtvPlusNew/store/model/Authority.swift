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
    
    @Published var useAbleTicket:Int = 0
    @Published var useAbleCoupon:Int = 0
    @Published var useAbleBPoint:Double = 0
    @Published var useAbleBCash:Double = 0
  
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
        
        self.useAbleCoupon = totalPointInfo.coupon?.usableCount ?? 0
        self.useAbleBPoint = totalPointInfo.newBpoint?.usableNewBpoint ?? 0
        self.useAbleBCash = totalPointInfo.bcash?.usableBcash?.totalBalance ?? 0
        self.totalPointInfo = totalPointInfo
        self.checkMyInfoUpdate()
    }
    
    func updatedMonthlyPurchaseInfo(_ monthlyPurchaseInfo:MonthlyPurchaseInfo){
        self.monthlyPurchaseInfo = monthlyPurchaseInfo
        self.updateTicketCount()
        self.checkMyInfoUpdate()
    }
    
    func updatedMonthlyPurchaseInfo(_ monthlyPurchaseInfo:PeriodMonthlyPurchaseInfo){
        self.periodMonthlyPurchaseInfo = monthlyPurchaseInfo
        self.updateTicketCount()
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
    
    private func updateTicketCount(){
        var total:Int  = 0
        if let data = self.monthlyPurchaseInfo {
            total += (data.purchaseList?.count ?? 0)
        }
        if let data = self.periodMonthlyPurchaseInfo {
            total += (data.purchaseList?.count ?? 0)
        }
        self.useAbleTicket = total
    }
    
    
    private func checkMyInfoUpdate(){
        if !self.isMyInfoUpdate { return }
        if self.totalPointInfo == nil { return }
        if self.monthlyPurchaseInfo == nil { return }
        if self.periodMonthlyPurchaseInfo == nil { return }
        self.completedMyInfo()
    }
}
