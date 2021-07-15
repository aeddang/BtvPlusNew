//
//  SoundBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/15.
//

import Foundation
import SwiftUI
import UIKit
import AudioToolbox

class SoundToolBox {
    private static var registSound:[String: SystemSoundID] = [:]
    
    func play(snd:String, ext:String = "wav") {
        if let sid = Self.registSound[snd] {
            AudioServicesPlayAlertSoundWithCompletion(sid){
                AudioServicesPlayAlertSound(sid)
            }
        } else {
           
            guard let url = Bundle.main.url(forResource: snd, withExtension: ext) else {return}
            var sound: SystemSoundID = SystemSoundID(Self.registSound.count)
            let result = AudioServicesCreateSystemSoundID(url as CFURL, &sound)
            let id = SystemSoundID(result)
            Self.registSound[snd] = id
            AudioServicesPlayAlertSoundWithCompletion(sound){
                AudioServicesPlayAlertSound(sound)
            }
        }
        
    }

}
