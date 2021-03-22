//
//  SceneObserver.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/20.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

enum SceneUpdateType {
    case purchase(String, String?, String?), identify(Bool), identifyAdult(Bool, Int)
}

enum SceneEvent {
    case initate, toast(String), update(SceneUpdateType), floatingBanner([BannerData]? = nil), headerBanner(BannerData? = nil)
}

class AppSceneObserver:ObservableObject{
    @Published var useTop = false
    @Published var useTopFix:Bool? = nil
    @Published var useBottom = false
    @Published var isApiLoading = false
    @Published var safeHeaderHeight:CGFloat = 0
    @Published var headerHeight:CGFloat = 0
    
    @Published var loadingInfo:[String]? = nil
    @Published var alert:SceneAlert? = nil
    @Published var alertResult:SceneAlertResult? = nil {didSet{ if alertResult != nil { alertResult = nil} }}
    @Published var radio:SceneRadio? = nil
    @Published var radioResult:SceneRadioResult? = nil {didSet{ if radioResult != nil { radioResult = nil} }}
    @Published var select:SceneSelect? = nil
    @Published var selectResult:SceneSelectResult? = nil {didSet{ if selectResult != nil { selectResult = nil} }}
    @Published var event:SceneEvent? = nil {didSet{ if event != nil { event = nil} }}
    
    func cancelAll(){

    }
}

enum SceneSelect:Equatable {
    case select((String,[String]),Int), selectBtn((String,[SelectBtnData]),Int), picker((String,[String]),Int)
    
    func check(key:String)-> Bool{
        switch (self) {
        case let .selectBtn(v, _): return v.0 == key
        case let .select(v, _): return v.0 == key
        case let .picker(v, _): return v.0 == key
        }
    }
    
    static func ==(lhs: SceneSelect, rhs: SceneSelect) -> Bool {
        switch (lhs, rhs) {
        case (let .selectBtn(lh,_), let .selectBtn(rh,_)): return lh.0 == rh.0
        case (let .select(lh,_), let .select(rh,_)): return lh.0 == rh.0
        case (let .picker(lh,_), let .picker(rh,_)): return lh.0 == rh.0
        default : return false
        }
    }
}
enum SceneSelectResult {
    case complete(SceneSelect,Int)
}

