//
//  BtvWebViewEventAtt.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/29.
//

import Foundation


extension BtvWebView{

    func callFuncionEventAttendance(fn:String, jsonParams:String?, callback:String? ){
        switch fn {
        case WebviewMethod.bpn_getAttendanceInfo.rawValue :
            if self.pairing.status != .pairing {
                self.appSceneObserver.alert = .needPairing()
                return
            }
            
            self.dataProvider.requestData(
                q: .init(
                    id:self.tag,
                    type:.getAttendance(pcid: self.repository.namedStorage?.getPcid() ?? "",callback:callback)
                )
            )
            
            
        case WebviewMethod.bpn_reqAttendance.rawValue:
            if self.pairing.status != .pairing {
                self.appSceneObserver.alert = .needPairing()
                return
            }
            guard let jsonString = jsonParams  else {
                ComponentLog.e("jsonString notfound", tag:"WebviewMethod.bpn_reqAttendance")
                return
            }
            let jsonData = AppUtil.getJsonParam(jsonString:jsonString)
            guard let pointPolicyNum = jsonData?["pointpolicynum"] as? String else {
                ComponentLog.e("pointPolicyNum notfound", tag:"WebviewMethod.bpn_reqAttendance")
                return
            }
            self.dataProvider.requestData(
                q: .init(
                    id:self.tag,
                    type: .requestBPointIssuance(pointPolicyNum: pointPolicyNum, pointAmount: 0, callback:callback)
                )
            )
         
                   
        default : break
        }
    }
    
    func respondCallFuncionEventAttendance(res:ApiResultResponds){
        switch res.type {
        case .getAttendance(let pcid , let callback) :
            guard let callback = callback else { return }
            guard let result = res.data as? Attendance else {
                self.errorCallbackEventAttendance(callback)
                return
            }
            var dic:[String : Any] = [:]
            dic["event_month"] = result.event_month ?? ""
            dic["total_event_cnt"] = result.total_event_cnt ?? ""
            dic["check_cnt"] = result.check_cnt ?? ""
            dic["today_check_yn"] = result.today_check_yn ?? ""
            dic["result"] = result.result ?? ""
            dic["reason"] = result.reason ?? ""
            dic["pcid"] = pcid
            dic["stb_id"] = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
            dic["dvc_id"] = SystemEnvironment.deviceId
            self.eventData = dic
            self.viewModel.request = .evaluateJavaScriptMethod( callback, dic)
            
        case .requestBPointIssuance( _ , _ , let callback) :
            guard let callback = callback else { return }
            guard let result = res.data as? BPointIssuance else { return }
            if result.code == ApiCode.success2 {
                self.dataProvider.requestData(
                    q: .init(
                        id:self.tag,
                        type: .postAttendance(pcid: self.repository.namedStorage?.getPcid() ?? "",callback:callback)
                    )
                )
            } else {
                //self.errorCallbackEventAttendance(callback)
                var dic:[String : Any] = [:]
                dic["result"] = result.code ?? ""
                dic["reason"] = result.msg ?? ""
                self.viewModel.request = .evaluateJavaScriptMethod( callback, dic)
            }
            
        case .postAttendance( _ , let callback) :
            guard let callback = callback else { return }
            guard let result = res.data as? UpdateMetv else { return }
            var dic:[String : Any] = [:]
            dic["result"] = result.result ?? ""
            dic["reason"] = result.reason ?? ""
            self.viewModel.request = .evaluateJavaScriptMethod( callback, dic)
        
        default: break
        }
    }
    
    func errorCallFuncionEventAttendance(err:ApiResultError) {
        switch err.type {
        case .getAttendance( _ , let callback) :
            guard let callback = callback else { return }
            self.errorCallbackEventAttendance(callback)
        case .requestBPointIssuance( _ , _ , let callback) :
            guard let callback = callback else { return }
            self.errorCallbackEventAttendance(callback)
        case .postAttendance( _ , let callback) :
            guard let callback = callback else { return }
            self.errorCallbackEventAttendance(callback)
        default: break
        }
    }
    
    private func errorCallbackEventAttendance(_ callback:String){
        var dic:[String : Any] = [:]
        dic["result"] = ""
        dic["reason"] = ""
        self.viewModel.request = .evaluateJavaScriptMethod( callback, dic)
    }
    
    
}
