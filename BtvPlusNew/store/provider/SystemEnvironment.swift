//
//  SystemEnvironment.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/08.
//

import Foundation
import UIKit




struct SystemEnvironment {
    static let model:String = AppUtil.model
    static let systemVersion:String = UIDevice.current.systemVersion
    static let bundleVersion:String = "4.3.5" //AppUtil.version
    static let buildNumber:String = "1024" //AppUtil.build
    private static let deviceId:String = UIDevice.current.identifierForVendor?.uuidString ?? UUID.init().uuidString
    static var firstLaunch :Bool = false
    static var serverConfig: [String:String] = [String:String]()
    static var isReleaseMode = true
    static var isEvaluation = false
    static var needUpdate = false
    static var isTablet = AppUtil.isPad()
    static var isPurchaseAuth = false
    static var currentPageType:PageType = .btv
    
    static var isFirstMemberAuth = false
    static var isAdultAuth = false { didSet { setImageLock()} }
    static var isWatchAuth = false { didSet { setImageLock()} }
    static var watchLv = 0 { didSet {
        isWatchAuth = false
        setImageLock()}
    }
   
    static var isImageLock = false
    
    static func setImageLock(){
        if (watchLv == 0 && isAdultAuth) || isWatchAuth  {
            isImageLock = false
        } else {
            isImageLock = true
        }
    }
    
    static let VMS = "http://mobilebtv.com:9080"
    static let WEB = "http://mobilebtv.com:8080"
    static var isStage:Bool {
        get{
            return ApiPath.getRestApiPath(.VMS) != Self.VMS
        }
    }
    
    static func getGuestDeviceId() -> String{
        return ApiPrefix.device + SystemEnvironment.deviceId
    }
    
    //"cfb87121-4f7b-4d88-99ff-2b446c00e1c4"
    //"8LrhdsQYra5WG/o15zaCpsKz9uyy/WuqT2qTqo2oix340pJIxMFFwx+7smR8iEsL"
}



