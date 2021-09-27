//
//  BtvWebViewEventAtt.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/29.
//

import Foundation

extension BtvWebView{

    func callFuncionRemocon(fn:String, jsonParams:String?, callback:String? ){
        switch fn {
        case WebviewMethod.setAutoRemoconInfo.rawValue :
            guard let jsonData = getRemoteData(jsonParams:jsonParams) else { return }
            guard let isShowAutoRemocon = jsonData["isShowAutoRemocon"] as? Bool else { return }
            self.setup.autoRemocon = isShowAutoRemocon
        
        case WebviewMethod.requestRemoconFunction.rawValue :
            guard let jsonData = getRemoteData(jsonParams:jsonParams) else { return }
            //let transactionId = jsonData["transactionId"] as? String ?? ""
            let contentId = jsonData["contentId"] as? String ?? ""
            let playTime = jsonData["playTime"] as? Double ?? 0
            let isShowRemocon = jsonData["isShowRemocon"] as? Bool ?? false
            let serviceId = jsonData["serviceId"] as? String ?? ""
            //let isPackageSynopsis = jsonData["isPackageSynopsis"] as? String ?? ""
            if !contentId.isEmpty {
                let msg:NpsMessage = NpsMessage().setPlayVodMessage(
                    contentId: contentId ,
                    playTime: playTime)
                self.dataProvider.requestData(
                    q: .init(
                        id:self.tag,
                        type:.sendMessage(msg)
                    )
                )
               
            } else if !serviceId.isEmpty {
                let msg:NpsMessage = NpsMessage().setMessage(type: .CHNumInput, value: serviceId)
                self.dataProvider.requestData(
                    q: .init(id: self.tag, type: .sendMessage(msg))
                )
            
            }
            if isShowRemocon || self.setup.autoRemocon {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.remotecon)
                )
            }
            
            
        case WebviewMethod.requestSendMessage.rawValue :
            guard let jsonData = getRemoteData(jsonParams:jsonParams) else { return }
            let msg = jsonData["msg"] as? String ?? ""
            let phone = "01000000000"
            let value = "mob_no=" + phone + ";msg=" + ApiUtil.string(byUrlEncoding:msg)
            let npsMessage:NpsMessage = NpsMessage().setMessage(type: .SendMsg, value: value)
            self.dataProvider.requestData(
                q: .init(id: self.tag, type: .sendMessage(npsMessage))
            )
            
        case WebviewMethod.requestNPSPush.rawValue :
            self.dataProvider.requestData(
                q: .init(id: self.tag, type: .pushMessage(NpsMessage()))
            )
            
        case WebviewMethod.requestLimitTV.rawValue :
            if self.pairing.status != .pairing {
                self.appSceneObserver.alert = .needPairing()
            }
            let npsMessage:NpsMessage = NpsMessage().setMessage(type: .LimitTV, value: nil)
            self.dataProvider.requestData(
                q: .init(id: self.tag, type: .sendMessage(npsMessage))
            )
            
        default : break
        }
    }
    
    private func getRemoteData(jsonParams:String?)->[String: Any]?{
        if self.pairing.status != .pairing {
            self.appSceneObserver.alert = .needPairing()
            return nil
        }
        guard let jsonString = jsonParams  else {
            ComponentLog.e("jsonString notfound", tag:"WebviewMethod.requestRemoconFunction")
            return nil
        }
        guard let jsonData = AppUtil.getJsonParam(jsonString:jsonString) else {
            ComponentLog.e("jsonData notfound", tag:"WebviewMethod.requestRemoconFunction")
            return nil
        }
        return jsonData
    }
    
    func respondCallFuncionRemocon(res:ApiResultResponds){
        switch res.type {
        case .sendMessage (let msg) :
            guard let data = res.data as? ResultMessage else { return }
            let isSuccess = data.header?.result == ApiCode.success
            switch msg?.ctrlType {
            case .CHNumInput :
                self.watchBtvCompleted(isSuccess: isSuccess )
            case .SendMsg :
                self.sendMsgBtvCompleted(isSuccess: isSuccess )
            default : break
            }
        case .pushMessage (_) :
            guard let data = res.data as? ResultMessage else { return }
            //let isSuccess = data.header?.result == ApiCode.success
            var dic:[String : Any] = [:]
            dic["result"] = data.header?.result?.toInt() ?? ""
            self.viewModel.request = .evaluateJavaScriptMethod("responseNPSPush", dic)
            
        default: break
        }
    }
    
    func errorCallFuncionRemocon(err:ApiResultError) {
        switch err.type {
        case .sendMessage (let msg) :
            switch msg?.ctrlType {
            case .CHNumInput :
                self.watchBtvCompleted(isSuccess: false)
            case .SendMsg :
                self.sendMsgBtvCompleted(isSuccess: false)
            default : break
            }
        case .pushMessage (_) :
            var dic:[String : Any] = [:]
            dic["result"] = ""
            self.viewModel.request = .evaluateJavaScriptMethod("responseNPSPush", dic)
        default: break
        }
    }
    
    func watchBtvCompleted(isSuccess:Bool){
        if isSuccess {
            self.appSceneObserver.event = .toast(String.alert.btvplaySuccess)
        } else {
            self.appSceneObserver.event = .toast(String.alert.btvplayFail)
        }
    }
    
    func sendMsgBtvCompleted(isSuccess:Bool){
        
        if isSuccess {
            self.dataProvider.requestData(
                q: .init(id: self.tag, type: .pushMessage(NpsMessage()))
            )
        } 
    }
    
}
