//
//  Voice.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
enum VoiceEvent{
    case ready, error, permissionError, searchStart, searchEnd, find(String)
}

enum VoiceStatus:String{
    case initate, ready, searching, analysis
}
