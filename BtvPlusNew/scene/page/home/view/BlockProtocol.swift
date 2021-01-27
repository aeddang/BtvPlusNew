//
//  BlockProtocol.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

protocol BlockProtocol {
    var data:Block { get set }
    func getRequestApi() -> ApiQ?
    func onBlank()
    func onError(_ err:ApiResultError?)
    
}
extension BlockProtocol {
    func getRequestApi() -> ApiQ? {
        if data.status != .initate  { return nil }
        
        switch data.dataType {
        case .cwGrid:
            ComponentLog.d("Request cwGrid" + data.name, tag: "BlockProtocol")
            return .init(
                id: data.id,
                type: .getCWGrid(
                    data.menuId,
                    data.cwCallId),
                isOptional: true)
        case .grid:
            ComponentLog.d("Request grid" + data.name, tag: "BlockProtocol")
            return .init(
                id: data.id,
                type: .getGridEvent(data.menuId), 
                isOptional: true)
            
        case .bookMark:
            ComponentLog.d("Request bookMark" + data.name, tag: "BlockProtocol")
            return .init(
                id: data.id,
                type: .getBookMark(),
                isOptional: true)
        case .watched:
            ComponentLog.d("Request watche" + data.name, tag: "BlockProtocol")
            return .init(
                id: data.id,
                type: .getWatch(false),
                isOptional: true)
        default:
            ComponentLog.d("onRequestFail " + data.name, tag: "BlockProtocol")
            data.setRequestFail() 
            return nil
        }
        
    }
    
    func onBlank(){
        ComponentLog.d("onBlank " + data.name, tag: "BlockProtocol")
        self.data.setBlank() }
    func onError(_ err:ApiResultError?){
        ComponentLog.d("onError " + data.name + " " + err.debugDescription, tag: "BlockProtocol")
        self.data.setError(err)
        
    }

}
