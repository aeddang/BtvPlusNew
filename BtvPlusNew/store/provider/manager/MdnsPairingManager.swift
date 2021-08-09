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
    let serviceName:String = "com.skb.btvplus"
    let querytime:Int32 = 60
    let searchLimitedTime:Int = 5
        
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
       
    }
    
    private func mdnsServiceNotFound() {
        removeClient()
        notFound?()
    }

    private var retryCount:Int = 0
    private var searchLimited:DispatchWorkItem?? = nil
    private func mdnsServiceFindStart(isRetry:Bool = false) {
        if !isRetry {self.retryCount = 0}
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
                if self.retryCount == 1 {
                    self.mdnsServiceNotFound()
                } else {
                    self.retryCount += 1
                    self.removeClient()
                    self.mdnsServiceFindStart(isRetry: true)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(self.searchLimitedTime), execute: self.searchLimited!!)
    }
    
    func requestPairing(_ request:PairingRequest,
                        found:(([MdnsDevice]) -> Void)? = nil,
                        notFound: (() -> Void)? = nil){
        removeClient()
        self.found = found
        self.notFound = notFound
        switch request {
        case .wifi: self.mdnsServiceFindStart()
        case .cancel: self.removeClient()
        default : do{}
        }
    }
    
    func getIPAddress() -> UnsafeMutablePointer<Int8>? {
        let address: String? = AppUtil.getIPAddress()
        
        guard let add = address else {return nil}
        return UnsafeMutablePointer(mutating: (add as NSString).utf8String)
    }
    
}
