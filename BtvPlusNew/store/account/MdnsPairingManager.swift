//
//  PairingManager.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//
import Foundation
struct MdnsDevice : Codable {
    private(set) var stb_mac_address:String? = nil
    private(set) var ui_app_ver:String? = nil
    private(set) var adult:String? = nil
    private(set) var stb_patch_ver:String? = nil
    private(set) var rcu_agent_ver:String? = nil
    private(set) var eros:String? = nil
    private(set) var stbid:String? = nil
    private(set) var stb_mac_view:String? = nil
    private(set) var restricted_age:String? = nil
    private(set) var port:String? = nil
    private(set) var address:String? = nil
    private(set) var isAdultSafetyMode:Bool? = nil
    init(json: [String:Any]) throws {}
}

class MdnsPairingManager : NSObject, MDNSServiceProxyClientDelegate, PageProtocol{
    private var client:MDNSServiceProxyClient? = nil
    let serviceName = "com.skb.btvplus"
    let querytime:Int32 = 60
    let searchLimitedTime:Int = 10
        
    private var found:(([MdnsDevice]) -> Void)? = nil
    private var notFound: (() -> Void)? = nil
    
    private func removeClient(){
        searchLimited??.cancel()
        searchLimited = nil
        client?.stopSearching()
        client?.delegate = nil
        client = nil
    }
    
    func mdnsServiceFound(_ serviceJsonString: UnsafeMutablePointer<Int8>) {
        removeClient()
        let mdnsData = String(cString: serviceJsonString)
        guard let data = mdnsData.data(using: .utf8) else {
            ComponentLog.e("foundDevice : jsonString data error", tag: self.tag)
            notFound?()
            return
        }
        do {
            let findDevice = try JSONDecoder().decode(MdnsDevice.self, from: data)
            ComponentLog.d("stb_mac_address :" + (findDevice.stb_mac_address ?? ""), tag: self.tag)
            ComponentLog.d("stbid :" + (findDevice.stbid ?? ""), tag: self.tag)
            ComponentLog.d("rcu_agent_ver :" + (findDevice.rcu_agent_ver ?? ""), tag: self.tag)
            found?([findDevice])
        } catch {
            ComponentLog.e("foundDevice : JSONDecoder " + error.localizedDescription, tag: self.tag)
        }
        /*
        do{
            let value = try JSONSerialization.jsonObject(with: data , options: [])
            guard let dictionary = value as? [String: Any] else {
                ComponentLog.e("foundDevice : dictionary error", tag: self.tag)
                notFound?()
                return
            }
             ComponentLog.d("foundDevice :" + dictionary.debugDescription, tag: self.tag)
   
        } catch {
            ComponentLog.e("foundDevice : JSONSerialization " + error.localizedDescription, tag: self.tag)
            notFound?()
            return
        }
        */
        
    }
    
    private func mdnsServiceNotFound() {
        removeClient()
        notFound?()
    }
    
   
    private var searchLimited:DispatchWorkItem?? = nil
    private func mdnsServiceFindStart() {
        let client = MDNSServiceProxyClient()
        client.delegate = self
        if let ip = self.getIPAddress() {
            client.startSearching(
                ip,
                serviceName: UnsafeMutablePointer(mutating: (serviceName as NSString).utf8String),
                querytime: querytime)
            
        }
        self.client = client
        self.searchLimited = DispatchWorkItem { // Set the work item with the block you want to execute
            DispatchQueue.main.async {
               self.mdnsServiceNotFound()
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(self.searchLimitedTime), execute: self.searchLimited!!)
    }
    
    func requestPairing(_ request:PairingRequest,
                        found:(([MdnsDevice]) -> Void)? = nil,
                        notFound: (() -> Void)? = nil){
        removeClient()
        self.found = found
        self.notFound = notFound
        switch request {
        case .wifi: self.mdnsServiceFindStart()
        case .cancel: do{}
        default : do{}
        }
    }
    
    func getIPAddress() -> UnsafeMutablePointer<Int8>? {
        var address: String? = AppUtil.getIPAddress()
        /*
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { return nil }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    // wifi = ["en0"]
                    // wired = ["en2", "en3", "en4"]
                    // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
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
        */
        guard let add = address else {return nil}
        return UnsafeMutablePointer(mutating: (add as NSString).utf8String)
    }
    
}
