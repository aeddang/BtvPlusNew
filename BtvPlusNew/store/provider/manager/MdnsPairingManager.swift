//
//  PairingManager.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//
import Foundation
import Combine
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
    let searchLimitedTime:Double = 3
    private var searchLimitCount = 1
    private var searchRetryCount = 0
    private var searchingTimer:AnyCancellable? = nil
    private var find:[MdnsDevice] = []
    private var found:(([MdnsDevice]) -> Void)? = nil
    private var notFound: (() -> Void)? = nil
    private var delayComplete:AnyCancellable? = nil
    
    private func removeClient(){
        self.searchingTimer?.cancel()
        self.searchingTimer = nil
        self.delayComplete?.cancel()
        self.delayComplete = nil
        self.client?.stopSearching()
        self.client?.delegate = nil
        self.client = nil
        self.find = []
    }
    
    func mdnsServiceFound(_ serviceJsonString: UnsafeMutablePointer<Int8>) {
        
        
        let mdnsData = String(cString: serviceJsonString).replace("\n", with: "")
        guard let data = mdnsData.data(using: .utf8) else {
            ComponentLog.e("foundDevice : jsonString data error", tag: self.tag)
            DispatchQueue.main.async {
                self.notFound?()
            }
            return
        }
        do {
            let findDevice = try JSONDecoder().decode(MdnsDevice.self, from: data)
            ComponentLog.d("stb_mac_address :" + (findDevice.stb_mac_address ?? ""), tag: self.tag)
            ComponentLog.d("stbid :" + (findDevice.stbid ?? ""), tag: self.tag)
            ComponentLog.d("rcu_agent_ver :" + (findDevice.rcu_agent_ver ?? ""), tag: self.tag)
            DispatchQueue.main.async {
                self.find.append(findDevice)
                self.delayFound()
            }
        } catch {
            ComponentLog.e("foundDevice : JSONDecoder " + error.localizedDescription, tag: self.tag)
        }
    }
    private func delayFound() {
        self.delayComplete?.cancel()
        self.delayComplete = Timer.publish(
            every: 0.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                if self.find.isEmpty {
                    self.notFound?()
                } else {
                    self.found?(self.find)
                }
                self.removeClient()
            }
        
    }
    private func mdnsServiceNotFound() {
        self.removeClient()
        self.notFound?()
    }
    
    private func mdnsServiceFindStart(isRetry:Bool = false) {
        self.removeClient()
        let client = MDNSServiceProxyClient()
        client.delegate = self
        self.client = client
        DispatchQueue.global(qos: .background).async {
            if let ip = self.getIPAddress() {
                client.startSearching(
                    ip,
                    serviceName: UnsafeMutablePointer(mutating: (self.serviceName as NSString).utf8String),
                    querytime: self.querytime)
            }
        }
        
        self.searchingTimer = Timer.publish(
            every: self.searchLimitedTime, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
               self.mdnsServiceNotFound()
            }
    }
    
    func requestPairing(_ request:PairingRequest, retryCount:Int = 1,
                        found:(([MdnsDevice]) -> Void)? = nil,
                        notFound: (() -> Void)? = nil){
        removeClient()
        self.searchLimitCount = retryCount
        self.found = found
        self.notFound = notFound
        switch request {
        case .wifi: self.mdnsServiceFindStart()
        case .cancel: self.removeClient()
        default : break
        }
    }
    /*
    func getIPAddress() -> UnsafeMutablePointer<Int8>? {
        let address: String? = AppUtil.getIPAddress()
        guard let add = address else {return nil}
        return UnsafeMutablePointer(mutating: (add as NSString).utf8String)
        
    }
    */
    func getIPAddress() -> UnsafeMutablePointer<Int8>? {
     
        //let address: String? = AppUtil.getIPAddress()
        let address: String? = ApiUtil.getIPAddress(true)
        guard let add = address else {return nil}

        return UnsafeMutablePointer(mutating: (add as NSString).utf8String)
        //return UnsafeMutablePointer(mutating: ("192.168.35.31" as NSString).utf8String)
    }
    
}
