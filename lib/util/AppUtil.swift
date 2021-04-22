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
import NetworkExtension
import TrueTime
import AdSupport

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
    
    static var idfa: String {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            let identifier = ASIdentifierManager.shared().advertisingIdentifier
            return identifier.uuidString
        }
        return ""
    }
    
    static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    static func isPad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            return true
        }
        return false
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
    
    static func networkTimeDate() -> Date {
        let client = TrueTimeClient.sharedInstance
        return client.referenceTime?.now() ?? Date()
    }
    
    static func goLocationSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
    
    static func getNetworkInfo(compleationHandler: @escaping ([String: Any])->Void){
        var currentWirelessInfo: [String: Any] = [:]
        if #available(iOS 14.0, *) {
            NEHotspotNetwork.fetchCurrent { network in
                guard let network = network else {
                    compleationHandler([:])
                    return
                }
                let bssid = network.bssid
                let ssid = network.ssid
                currentWirelessInfo = ["BSSID ": bssid, "SSID": ssid, "SSIDDATA": "<54656e64 615f3443 38354430>"]
                compleationHandler(currentWirelessInfo)
            }
        }
        else {
            #if !TARGET_IPHONE_SIMULATOR
            guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
                compleationHandler([:])
                return
            }
            guard let name = interfaceNames.first, let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String: Any] else {
                compleationHandler([:])
                return
            }
            currentWirelessInfo = info
            #else
            currentWirelessInfo = ["BSSID ": "c8:3a:35:4c:85:d0", "SSID": "Tenda_4C85D0", "SSIDDATA": "<54656e64 615f3443 38354430>"]
            #endif
            compleationHandler(currentWirelessInfo)
        }
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
    
    static func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name: String = String(cString: (interface.ifa_name))
                    if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address 
    }
    
    static func getSafeString(_ s:String?,  defaultValue:String = "") -> String {
        guard let s = s else { return defaultValue }
        return s.isEmpty ? defaultValue : s
    }
    static func getSafeInt(bool:Bool?,  defaultValue:Int = 1) -> Int {
        guard let v = bool else { return defaultValue }
        return v ? 1 : 0
    }
    
    static func getJsonString(dic:[String:Any])->String?{
        if JSONSerialization.isValidJSONObject(dic) {
            do{
                let data =  try JSONSerialization.data(withJSONObject: dic , options: [])
                let jsonString = String(decoding: data, as: UTF8.self)
                DataLog.d("stringfy : " + jsonString, tag: "getJsonString")
                return jsonString
            } catch {
                DataLog.e("stringfy : JSONSerialization " + error.localizedDescription, tag: "getJsonString")
                return nil
            }
        }
        DataLog.e("stringfy : JSONSerialization isValidJSONObject error", tag: "getJsonString")
        return nil
    }
    
    static func getJsonParam(jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else {
            DataLog.e("parse : jsonString data error", tag: "getJsonParam")
            return nil
        }
        do{
            let value = try JSONSerialization.jsonObject(with: data , options: [])
            guard let dictionary = value as? [String: Any] else {
                DataLog.e("parse : dictionary error", tag: "getJsonParam")
                return nil
            }
            return dictionary
        } catch {
           DataLog.e("parse : JSONSerialization " + error.localizedDescription, tag: "getJsonParam")
           return nil
        }
    }
    
    static func getQurry(url: String, key:String) -> String? {
        if let components = URLComponents(string: url) {
            if let queryItems = components.queryItems {
                if let item = queryItems.first(where: {$0.name == key}) {
                    return item.value 
                } else {
                    return nil
                }
            }
        }
        return nil
    }

    
}

