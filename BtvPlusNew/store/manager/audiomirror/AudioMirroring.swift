//
//  AudioMirrorManager.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/05/18.
//

import Foundation
import SwiftUI
import Combine
import AVKit
import CallKit
import MediaPlayer


class AudioMirroring : NSObject, ObservableObject, AudioMirrorServiceProxyClientDelegate, CXCallObserverDelegate, PageProtocol{
    
    private let pairing:Pairing
    private var client:AudioMirrorServiceProxyClient? = nil
    private var callObserver:CXCallObserver? = nil
    private var searchLimited:DispatchWorkItem?? = nil
    private let searchLimitedTime:Int = 10
    private let connectLimitedTime:Int = 10
    @Published private(set) var status:AudioMirrorStatus = .none
    @Published private(set) var event:AudioMirrorEvent? = nil {didSet{ if event != nil { event = nil} }}

    init(pairing:Pairing) {
        self.pairing = pairing
    }
    
    private(set) var isConnected:Bool = false
    
    var isAudioOutEnabled:Bool {
        get{
            if !isConnected {return false}
            return client?.hasAudioOutEnabled() ?? false
        }
    }
    private(set) var enableAudioOut:Bool = false {
        didSet{
            self.event = enableAudioOut ? .resume : .pause
            client?.enableAudioOut(enableAudioOut)
        }
    }
    private(set) var enableTVAudioOut:Bool = false {
        didSet{
            client?.enableAudioOut(enableTVAudioOut)
        }
    }
    var isAudioMirrorSupported:Bool {
        get{
            if pairing.status != .pairing { return false }
            guard let ver = pairing.hostDevice?.patchVersion else { return false }
            let verA = ver.split(separator: ".")
            if !verA.isEmpty {
                let major = String(verA.first ?? "").toInt()
                if major >= 8 { return true }
                return false
                
            } else { return false }
        }
    }
    var isSkWifi:Bool {
        get{
            guard let ssid = AppUtil.getSSID() else { return false }
            if ssid.contains("SK_WiFi") || ssid.contains("SK_WLAN") {
                return true
            } else {
                return false
            }
        }
    }
    
    func close(){
        self.removeClient()
    }
    
    @discardableResult
    func startSearching() -> Bool{
        self.stopSearching()
        if client == nil {
            self.initClient()
        }
        if self.status == .connecting { return false }
        guard let localIp = AppUtil.getIPAddress() else {return false}
        guard let client = self.client else {return false}
        self.status = .connecting
        client.startSearching(UnsafeMutablePointer(mutating: (localIp as NSString).utf8String))
        self.searchLimited = DispatchWorkItem { // Set the work item with the block you want to execute
            DispatchQueue.main.async {
                self.event = .notFound
                self.stopSearching()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(self.searchLimitedTime), execute: self.searchLimited!!)
        DataLog.d("startSearching ", tag: self.tag)
        return true
    }

    func stopSearching() {
        self.isConnectng = false
        DataLog.d("stopSearching ", tag: self.tag)
        if self.status == .connecting {
            self.status = .none
        }
        client?.stopSearching()
        searchLimited??.cancel()
        searchLimited = nil
    }
    
    private func initClient(){
        client = AudioMirrorServiceProxyClient()
        client?.delegate = self
        let center = NotificationCenter.default
        NotificationCenter.default.removeObserver(self)
        center.addObserver(self, selector:#selector(onAudioInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        center.addObserver(self, selector:#selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        callObserver = CXCallObserver()
        callObserver?.setDelegate(self, queue: nil)
    }
    
    private func removeClient(){
        if self.status == .mirroring {
            self.event = .dicconnected
        }
        self.stopSearching()
        self.stopMirroring()
        self.isConnected = false
        self.status = .none
        client?.close()
        client?.delegate = nil
        client = nil
        callObserver?.setDelegate(nil, queue: nil)
        callObserver = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    private func startMirroring() {
        self.stopSearching()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
            DataLog.e("Setting category to AVAudioSessionCategoryPlayback failed." , tag: self.tag)
        }
     
        let playingInfoCenter = MPNowPlayingInfoCenter.default()
        let image = UIImage(named: Asset.appIcon)!
        let artwork = MPMediaItemArtwork.init(
            boundsSize: image.size,
            requestHandler: { (size) -> UIImage in return image}
        )
        var info:[String:Any] = [:]
        info[MPMediaItemPropertyTitle] = String.remote.titleMirroring
        info[MPMediaItemPropertyArtwork] = artwork
        playingInfoCenter.nowPlayingInfo = info
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            if self.status == .mirroring {
                self.enableAudioOut = true
            }
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.pauseCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            if self.status == .mirroring {
                self.enableAudioOut = false
            }
            return MPRemoteCommandHandlerStatus.success
        }
        self.status = .mirroring
        self.event = .connected
    }
    
    private func stopMirroring() {
        /*
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        catch {
            DataLog.e("Setting category to AVAudioSessionCategoryPlayback failed." , tag: self.tag)
        }
        */
        let playingInfoCenter = MPNowPlayingInfoCenter.default()
        playingInfoCenter.nowPlayingInfo = nil
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    @objc func onAudioInterruption(_ notification: Notification) {
        if !self.isConnected {return}
        guard let userInfo = notification.userInfo else { return}
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? Int else { return }
        if self.status != .mirroring { return }
        if (type == AVAudioSession.InterruptionType.began.rawValue) {
            DataLog.d("AVAudioSessionInterruptionTypeBegan", tag: self.tag)
            self.event = .interruption
            self.removeClient()
        } else if (type == AVAudioSession.InterruptionType.ended.rawValue) {
            DataLog.d("AVAudioSessionInterruptionTypeEnded", tag: self.tag)
        }
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        if !self.isConnected { return }
        if self.status != .call { return }
        self.enableAudioOut = true
        self.status = .mirroring
    }
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if (call.hasConnected && !call.hasEnded) {
            DataLog.d("call.hasConnected = true, hasEnded = false", tag: self.tag)
            if self.status != .mirroring { return }
            self.enableAudioOut = false
            self.status = .call
            return
        }
        if (call.hasEnded) {
            DataLog.d("hasEnded = true", tag: self.tag)
            if !self.isConnected { return }
            if self.status != .call { return }
            self.enableAudioOut = true
            self.status = .mirroring
        }
    }
    
    
    func audioMirrorServiceConnectionLost(_ state: Int32) {
        DataLog.d("audioMirrorServiceConnectionLost", tag: self.tag)
        self.removeClient()
    }
    
    func audioMirrorServiceConnectionCompleted(_ result: Int32) {
        let resultCode = Int(result)
        DataLog.d("audioMirrorServiceConnectionCompleted " + resultCode.description, tag: self.tag)
        if resultCode == 0 {
            self.startMirroring()
        } else {
            
        }
    }
    
    func audioMirrorServicePeerChanged(_ peerCount: Int32) {
        DataLog.d("audioMirrorServicePeerChanged " + Int(peerCount).description , tag: self.tag)
    }
    
    func audioMirrorServiceCloseCompleted(_ result: Int32) {
        DataLog.d("audioMirrorServiceCloseCompleted", tag: self.tag)
        self.removeClient()
    }
    
    func audioMirrorServiceTVAudioOutEnabled(_ state: Int32) {
        DataLog.d("audioMirrorServiceTVAudioOutEnabled " + Int(state).description, tag: self.tag)
    }
    
    private var isConnectng:Bool = false
    func audioMirrorServiceFound(_ serviceJsonString: UnsafeMutablePointer<CChar>!) {
        if self.isConnected {return}
        if self.isConnectng {return}
        guard let client = self.client else {return}
        let jsonString = String(cString: serviceJsonString).replace("\n", with: "")
        guard let data = AppUtil.getJsonParam(jsonString: jsonString) else {return}
        guard let service = data["service"] as? String else {return}
        guard let address = data["address"] as? String else {return}
        guard let port = data["port"] as? String else {return}
        guard let mac = pairing.hostDevice?.convertMacAdress.replace(":", with: "").uppercased() else {return}
        if service.contains(mac) {
            self.isConnectng = true
            client.connect(
                UnsafeMutablePointer(mutating: (address as NSString).utf8String),
                serverPortNumber: Int32(port.toInt()) ,
                serverConnectionTimeout: Int32(self.connectLimitedTime))
        
        }
    }
    
    func audioMirrorServiceAudioDeviceChanged(_ state: Int32) {
        DataLog.d("audioMirrorServiceAudioDeviceChanged " + Int(state).description, tag: self.tag)
    }
}
