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
        if data.hasDatas { return nil }
        
        switch data.dataType {
        case .cwGrid:
            return .init(
                id: data.id,
                type: .getCWGrid(
                    data.menuId,
                    data.cwCallId),
                isOptional: true)
        case .grid:
            return .init(
                id: data.id,
                type: .getGridEvent(data.menuId), 
                isOptional: true)
        default:
            return nil
        }
        
    }
    
    func onBlank(){ self.data.setBlank() }
    func onError(_ err:ApiResultError?){ self.data.setError(err) }

}
