//
//  KidsPlay.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/17.
//

import Foundation

enum KidsPlayType:Equatable{
    case play, english , tale, create, subject, unknown(String? = nil)
    static func getType(_ value:String?)->KidsPlayType{
        switch value {
        case "512": return .play
        case "513": return .english
        case "514": return .tale
        case "515": return .create
        case "516": return .subject
        default : return .unknown(value)
        }
    }
    var noImage:String {
        get{
            switch self {
            case .play: return AssetKids.image.homeCardBg1
            case .english: return AssetKids.image.homeCardBg2
            case .tale: return AssetKids.image.homeCardBg3
            case .create: return AssetKids.image.homeCardBg4
            case .subject: return AssetKids.image.homeCardBg5
            default : return  AssetKids.image.homeCardBg1
            }
        }
    }
    
    static func ==(lhs: KidsPlayType, rhs: KidsPlayType) -> Bool {
        switch (lhs, rhs) {
        case ( .play, .play): return true
        case ( .english, .english): return true
        case ( .tale, .tale): return true
        case ( .create, .create): return true
        case ( .subject, .subject): return true
        default : return false
        }
    }
}
