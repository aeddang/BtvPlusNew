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
    static let bundleVersion:String = "4.2.3" //AppUtil.version
    static let deviceId:String = UIDevice.current.identifierForVendor?.uuidString ?? UUID.init().uuidString
    
    static var firstLaunch :Bool = false
    static var serverConfig: [String:String] = [String:String]()
    
    //"cfb87121-4f7b-4d88-99ff-2b446c00e1c4"
    //"8LrhdsQYra5WG/o15zaCpsKz9uyy/WuqT2qTqo2oix340pJIxMFFwx+7smR8iEsL"
}

