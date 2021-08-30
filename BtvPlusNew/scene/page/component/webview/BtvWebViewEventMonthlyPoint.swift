//
//  BtvWebViewEventAtt.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/29.
//

import Foundation

extension BtvWebView{
    static let alreadyIssuance = "203"
    class EventMonthlyData {
        var requestList:[Any]? = nil
        var callback:String? = nil
        var total:Int = 0
        var success:Int = 0
        var fail:Int = 0
        var errorCode:String? = nil
    }

    func callFuncionEventMonthlyPoint(fn:String, jsonParams:String?, callback:String? ){
        switch fn {
        case WebviewMethod.bpn_eventMonthlyPoint.rawValue :
            if self.pairing.status != .pairing {
                self.appSceneObserver.alert = .needPairing()
                return
            }
            guard let jsonString = jsonParams  else {
                ComponentLog.e("jsonString notfound", tag:"WebviewMethod.bpn_eventMonthlyPoint")
                return
            }
            let requestList = AppUtil.getJsonArray(jsonString:jsonString)
            if requestList?.isEmpty == false {
                let edata = EventMonthlyData()
                edata.callback = callback
                edata.requestList = requestList
                self.eventData = edata
                self.dataProvider.requestData(
                    q: .init(
                        id:self.tag,
                        type:.getPurchaseMonthly()
                    )
                )
            } else {
                ComponentLog.e("jsonArray empty", tag:"WebviewMethod.bpn_eventMonthlyPoint")
            }
            break
        default : break
        }
    }
    
    func respondCallFuncionEventMonthlyPoint(res:ApiResultResponds){
        guard let eventData = self.eventData as? EventMonthlyData else { return }
        switch res.type {
        case .getPurchaseMonthly :
            guard let requestList = eventData.requestList else { return }
            guard let resData = res.data as? MonthlyPurchaseInfo else { return }
            var normalList:[PurchaseFixedChargeItem] = []
            var periodList:[PurchaseFixedChargePeriodItem] = []
            if let purchaseNormalList = resData.purchaseNormalList {
                normalList = purchaseNormalList.filter{$0.expired?.toBool() == true}
            }
            if let purchasePredList = resData.purchasePredList {
                periodList = purchasePredList.filter{$0.expired?.toBool() == true}
            }
            var pointpolicynumList: [String] = []
            requestList.forEach { list in
                guard let event = list as? [String: Any] else { return }
                guard let pid = event["pid"] as? String else { return }
                guard let pointpolicynum = event["pointpolicynum"] as? String else { return }
                if let _ = normalList.first(where:{$0.prod_id == pid}) {
                    pointpolicynumList.append(pointpolicynum)
                    return
                }
                if let _ = periodList.first(where:{$0.prod_id == pid}) {
                    pointpolicynumList.append(pointpolicynum)
                    return
                }
            }
            if pointpolicynumList.isEmpty {
                self.appSceneObserver.alert = .alert(
                    String.alert.eventParticipate, String.alert.eventParticipateMonthlyPoint)
                return
            }
            
            eventData.total = pointpolicynumList.count
            pointpolicynumList.forEach{ num in
                self.dataProvider.requestData(
                    q: .init(
                        id:self.tag,
                        type: .requestBPointIssuance(pointPolicyNum: num, pointAmount: 0)
                    )
                )
            }
            
        case .requestBPointIssuance :
            guard let result = res.data as? BPointIssuance else {
                eventData.fail += 1
                self.checkComplete()
                return
            }
            if result.code == ApiCode.success2 {
                eventData.success += 1
            } else {
                eventData.fail += 1
                if let code = result.code {
                    eventData.errorCode = code
                }
            }
            self.checkComplete()
        default: break
        }
    }
    
    func errorCallFuncionEventMonthlyPoint(err:ApiResultError) {
        guard let eventData = self.eventData as? EventMonthlyData else { return }
        switch err.type {
        case .getPurchaseMonthly:
            guard let callback = eventData.callback else { return }
            self.viewModel.request = .evaluateJavaScriptMethod( callback, nil)
        case .requestBPointIssuance:
            eventData.fail += 1
            self.checkComplete()
        default: break
        }
    }
    
    private func checkComplete(){
        guard let eventData = self.eventData as? EventMonthlyData else { return }
        if eventData.total != eventData.success + eventData.fail { return }
        if let callback = eventData.callback {
            self.viewModel.request = .evaluateJavaScriptMethod( callback, nil)
        }
        if eventData.fail == 0 {
            self.appSceneObserver.alert =
                .alert(String.alert.eventPointIssuanceComplete, String.alert.eventPointIssuanceCompleteText)
            return
        }
        
        if eventData.success == 0 {
            self.appSceneObserver.alert =
                .alert( String.alert.eventPointIssuanceUnable,
                        eventData.errorCode == Self.alreadyIssuance
                            ? String.alert.eventPointIssuanceUnableAlready
                            : String.alert.eventPointIssuanceUnableFail.replace(eventData.errorCode ?? "")
                )
            return
        }
        self.appSceneObserver.alert =
            .alert(String.alert.eventPointIssuancePartComplete, String.alert.eventPointIssuancePartCompleteText)
    
    }
}

