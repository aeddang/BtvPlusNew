//
//  BlockProtocol.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI


protocol BlockProtocol {
    var data:BlockData { get set }
  
    func getRequestApi(pairing:PairingStatus) -> ApiQ?
    func onBlank()
    func onError(_ err:ApiResultError?)
    
}
extension BlockProtocol {

    func getRequestApi(pairing:PairingStatus) -> ApiQ? {
        ComponentLog.d("getRequestApi " + data.status.rawValue , tag: "BlockProtocol")
        if data.status != .initate  { return nil }
        return data.getRequestApi(pairing: pairing)
    }
    
    func onDataBinding(){
        ComponentLog.d("onDataBinding " + data.name, tag: "BlockProtocol")
        self.data.setDatabindingCompleted()
    }
    
    func onBlank(){
        ComponentLog.d("onBlank " + data.name, tag: "BlockProtocol")
        self.data.setBlank()
    }
    
    func onError(_ err:ApiResultError?){
        ComponentLog.d("onError " + data.name + " " + err.debugDescription, tag: "BlockProtocol")
        self.data.setError(err)
    }
    
    func sendLog(_ naviLogManager:NaviLogManager){
        if self.data.logType == .list {
            naviLogManager.actionLog(.clickContentsViewAll, actionBody: self.data.getActionLog())
        } else {
            naviLogManager.actionLog(.clickViewMore, actionBody: self.data.getActionLog())
        }
       
    }
}
