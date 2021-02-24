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
    func getRequestApi() -> ApiQ?
    func onBlank()
    func onError(_ err:ApiResultError?)
    
}
extension BlockProtocol {
    func getRequestApi() -> ApiQ? {
        if data.status != .initate  { return nil }
        return data.getRequestApi()
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

}
