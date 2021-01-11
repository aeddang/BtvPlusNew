//
//  Api.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
struct ApiError :Error,Identifiable{
    let id = UUID().uuidString
    var message:String? = nil
    static func getViewMessage(message:String?)->String{
        return message ?? String.alert.apiErrorServer
    }
}

struct ApiQ :Identifiable{
    var id:String = UUID().uuidString
    let type:ApiType
    var action:ApiAction? = nil
    var isOptional:Bool = false
    var isLock:Bool = false
    
    func copy(newId:String? = nil) -> ApiQ {
        let nid = newId ?? id
        return ApiQ(id: nid, type: type, action: action, isOptional: isOptional, isLock: isLock)
    }
}

struct ApiResultResponds:Identifiable{
    let id:String
    let type:ApiType
    let data:Any
}
struct ApiResultError :Identifiable{
    let id:String
    let type:ApiType
    let error:Error
    var isOptional:Bool = false
}


enum ApiType{
    // VMS
    case versionCheck
    
    //EUXP
    case getGnb,
         getCWGrid(String?, String?),
         getGridEvent(String?, EuxpNetwork.SortType? = Optional.none, Int? = nil, Int? = nil) //EUXP
    
    //METV
    case getBookMark(Int? = nil , Int? = nil)
    
    //NPS
    case postHello,
         postDevicePairingInfo(String?, String?),
         postDevicePairing(User?, MdnsDevice?),
         postAuthPairing(User?, String?),
         postHostDeviceInfo
        
    func coreDataKey() -> String? {
        switch self {
        case .getGnb : return "getGnb"
        default : return nil
        }
    }
    func transitionKey() -> String {
        switch self {
        case .postHello : return "postHello"
        default : return ""
        }
    }
}
