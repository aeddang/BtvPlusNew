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
    let id:String
    let type:ApiType
    var action:ApiAction? = nil
    var isOptional:Bool = false
    var isLock:Bool = false
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
    case versionCheck
}
