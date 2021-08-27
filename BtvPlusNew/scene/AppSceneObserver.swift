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
    case initate, toast(String), update(SceneUpdateType),
         floatingBanner([BannerData]? = nil), headerBanner(BannerData? = nil),
         pairingHitch(isOn:Bool = true),  pairingHitchClose,
         debug(String)
}

class AppSceneObserver:ObservableObject{
    @Published var useTop = false
    @Published var useTopImmediately = false
    @Published var useTopFix:Bool? = nil
    @Published var useBottom = false
    @Published var useBottomImmediately = false
    @Published var useGnb:Bool = true
    @Published var useLogCollector:Bool = false
    @Published var isApiLoading = false
    @Published var safeHeaderHeight:CGFloat = 0
    @Published var headerHeight:CGFloat = 0
    @Published var safeBottomHeight:CGFloat = 0  //
    @Published var safeBottomLayerHeight:CGFloat = 0 // layerPlayer 포함
    @Published var safeBottom:CGFloat = 0
    
    @Published var loadingInfo:[String]? = nil
    @Published var alert:SceneAlert? = nil
    @Published var alertResult:SceneAlertResult? = nil {didSet{ if alertResult != nil { alertResult = nil} }}
    @Published var radio:SceneRadio? = nil
    @Published var radioResult:SceneRadioResult? = nil {didSet{ if radioResult != nil { radioResult = nil} }}
    @Published var select:SceneSelect? = nil
    @Published var selectResult:SceneSelectResult? = nil {didSet{ if selectResult != nil { selectResult = nil} }}
    @Published var event:SceneEvent? = nil {didSet{ if event != nil { event = nil} }}
    
    @Published var useLayerPlayer:Bool = false
    var currentPlayer:PageSynopsis? = nil
    func cancelAll(){

    }
}

enum SceneSelect:Equatable {
    case select((String,[String]),Int, ((Int) -> Void)? = nil),
         selectBtn((String,[SelectBtnData]),Int, ((Int) -> Void)? = nil),
         picker((String,[String]),Int, ((Int) -> Void)? = nil),
         datePicker((String, Int), Date, ((Date?) -> Void)? = nil),
         multiPicker((String,[[String]]),[Int], ((Int,Int,Int,Int) -> Void)? = nil)
    
    func check(key:String)-> Bool{
        switch (self) {
        case let .selectBtn(v, _, _): return v.0 == key
        case let .select(v, _, _): return v.0 == key
        case let .picker(v, _, _): return v.0 == key
        case let .datePicker(v, _, _): return v.0 == key
        case let .multiPicker(v, _, _): return v.0 == key
        }
    }
    
    static func ==(lhs: SceneSelect, rhs: SceneSelect) -> Bool {
        switch (lhs, rhs) {
        case (let .selectBtn(lh,_, _), let .selectBtn(rh,_, _)): return lh.0 == rh.0
        case (let .select(lh,_, _), let .select(rh,_, _)): return lh.0 == rh.0
        case (let .picker(lh,_, _), let .picker(rh,_, _)): return lh.0 == rh.0
        case (let .datePicker(lh,_, _), let .datePicker(rh,_, _)): return lh.0 == rh.0
        case (let .multiPicker(lh,_, _), let .multiPicker(rh,_, _)): return lh.0 == rh.0
        default : return false
        }
    }
}
enum SceneSelectResult {
    case complete(SceneSelect,Int)
}

