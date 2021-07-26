//
//  Buzz.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/26.
//

import Foundation
import BuzzAdBenefit

class Buzz {
    static let BAB_SDK_KR_iOS_DEV_APP_ID: String = "126955102496938"
    static let BAB_SDK_KR_iOS_DEV_UNIT_ID: String = "266121639746153"
    static let BAB_SDK_KR_iOS_PRD_APP_ID: String = "42532489130817"
    static let BAB_SDK_KR_iOS_PRD_UNIT_ID: String = "374217246352253"
    private static var isInit = false
    static func initate(){
        if isInit {return}
        isInit = true
        let config = BABConfig(appId: SystemEnvironment.isReleaseMode ? BAB_SDK_KR_iOS_PRD_APP_ID : BAB_SDK_KR_iOS_DEV_APP_ID)
        BuzzAdBenefit.initialize(with: config)
    }
    
    func initate(pairing:Pairing){
        let yyyy = pairing.user?.birth.subString(start: 0, len: 4) ?? "0000"
        let userProfile = BABUserProfile(
            userId:pairing.stbId ?? "",
            birthYear: UInt(yyyy.toInt()),
            gender: pairing.user?.gender == .femail ? BABUserGenderFemale : BABUserGenderMale )
        BuzzAdBenefit.setUserProfile(userProfile)
        NotificationCenter.default.addObserver(self, selector: #selector(loadBABAd), name: NSNotification.Name.BABSessionRegistered, object: nil)
    }
    
    func destory(){
        NotificationCenter.default.removeObserver(self)
        BuzzAdBenefit.setUserProfile(nil)
        BuzzAdBenefit.setUserPreference(nil)
    }
    
    @objc private func loadBABAd() {
        let userPreference = BABUserPreference(autoPlayType: BABVideoAutoPlayEnabled)
        BuzzAdBenefit.setUserPreference(userPreference)
    }
}

open class BuzzViewModel: ComponentObservable {
    @Published var event:BuzzViewEvent? = nil
        {didSet{ if event != nil { event = nil} }}
    
}

enum BuzzViewEvent {
    case close , info(UIViewController)
}
