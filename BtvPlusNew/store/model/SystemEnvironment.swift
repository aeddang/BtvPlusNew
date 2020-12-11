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
    static let bundleVersion:String = AppUtil.version
    static let deviceId:String = UIDevice.current.identifierForVendor?.uuidString ?? UUID.init().uuidString
    
    static var firstLaunch :Bool = false
    static var serverConfig: [String:String] = [String:String]()
}

