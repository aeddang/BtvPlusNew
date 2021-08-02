//
//  CardData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/02.
//

import Foundation

struct RegistCardData{
    let no:String
    var masterSequence:Int = 1
    var isMaster:Bool = false
    var isForeigner:Bool = false
    var gender:Gender = .mail
    var birth:String = ""
    var password:String = ""
}
