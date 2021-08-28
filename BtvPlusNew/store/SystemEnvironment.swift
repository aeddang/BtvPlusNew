//
//  SystemEnvironment.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/08.
//

import Foundation
import UIKit
import CoreTelephony

struct SystemEnvironment {
    static let model:String = AppUtil.model
    static let systemVersion:String = UIDevice.current.systemVersion
    static let bundleVersion:String = AppUtil.version
    static let bundleVersionKey:String = "443" //AppUtil.version
    static let buildNumber:String = AppUtil.build.description
    static let deviceId:String = Self.getDeviceId()
    static var firstLaunch :Bool = false
    static var serverConfig: [String:String] = [String:String]()
    static var isReleaseMode:Bool? = nil
    static var isEvaluation = false
    static var needUpdate = false
    static var isTablet = AppUtil.isPad()
    static var isPurchaseAuth = false
    static var currentPageType:PageType = .btv
    
    static var isFirstMemberAuth = false
    static var isInitKidsPage:Bool = false
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
    
    private static func getDeviceId() -> String{
        let wrapper = SkbKeychainItemWrapper(identifier: "UUID", accessGroup: nil)
        
        if let prevUUID = wrapper?.object(forKey: Security.kSecAttrAccount) as? String {
            if !prevUUID.isEmpty {
            DataLog.d( "exist UUID " + prevUUID, tag: "getDeviceId")
                return prevUUID
            }
        }
        let newId = UIDevice.current.identifierForVendor?.uuidString ?? UUID.init().uuidString
        wrapper?.setObject(newId, forKey:  Security.kSecAttrAccount)
        DataLog.d("new UUID " + newId, tag: "getDeviceId")
        return "I" + newId
    }
    
    static func getPlmn() -> String?{
        let netinfo = CTTelephonyNetworkInfo()
        if let info = netinfo.serviceSubscriberCellularProviders, let carrier = info.first(where: {$0.value.mobileCountryCode?.isEmpty == false})?.value {
            return (carrier.mobileCountryCode ?? "") + (carrier.mobileNetworkCode ?? "")
        }
        return ""
    }
    
    
    
    static var isLegacy:Bool = false
    //"cfb87121-4f7b-4d88-99ff-2b446c00e1c4"
    //"8LrhdsQYra5WG/o15zaCpsKz9uyy/WuqT2qTqo2oix340pJIxMFFwx+7smR8iEsL"
}



