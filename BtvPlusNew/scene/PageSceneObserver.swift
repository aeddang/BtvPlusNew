//
//  SceneObserver.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/20.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

enum SceneEvent:String {
    case activePlayer, passivePlayer
}

class PageSceneObserver:ObservableObject{
    @Published var useTop = false
    @Published var useBottom = false
    @Published var isApiLoading = false
    
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


