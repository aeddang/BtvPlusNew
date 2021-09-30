//
//  AudioMirror.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/05/18.
//

import Foundation
enum AudioMirrorStatus:String{
    case connecting, call,  mirroring, none
}

enum AudioMirrorEvent:String{
    case connected, dicconnected, notFound, pause, resume, interruption
}
