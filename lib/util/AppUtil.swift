//
//  AppUtil.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration.CaptiveNetwork

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
    
    static func getYearRange(len:Int , offset:Int = 0 )->[Int]{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: Date())
        let range = 0...len
        let year  = (components.year ?? 2020) - offset
        let ranges = range.map{ (year - $0) }
        return ranges
    }
    
    static func getSSID() -> String? {
        let interfaces = CNCopySupportedInterfaces()
        if interfaces == nil { return nil }
        guard let interfacesArray = interfaces as? [String] else { return nil }
        if interfacesArray.count <= 0 { return nil }
        for interfaceName in interfacesArray where interfaceName == "en0" {
            let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName as CFString)
            if unsafeInterfaceData == nil { return nil }
            guard let interfaceData = unsafeInterfaceData as? [String: AnyObject] else { return nil }
            return interfaceData["SSID"] as? String
        }
        return nil
    }
    
    static func goLocationSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
}

