//
//  AppUtil.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit
struct AppUtil{
    static var version: String {
        guard let dictionary = Bundle.main.infoDictionary,
            let v = dictionary["CFBundleShortVersionString"] as? String
            else {return ""}
            return v
    }
    
    static var build: Int {
        guard let dictionary = Bundle.main.infoDictionary,
            let b = dictionary["CFBundleVersion"] as? Int else {return 1}
            return b
    }
    
    static var model: String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorModelIdentifier
        }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    static func openURL(_ path:String) {
        guard let url = URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? path) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    static func openEmail(_ email:String) {
        if let url = URL(string: "mailto:\(email)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }
}

