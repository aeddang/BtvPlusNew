//
//  Voice.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
enum VoiceEvent{
    case ready, error, searchStart, searchEnd, find(String)
}

enum VoiceStatus{
    case initate, ready, searching
}
