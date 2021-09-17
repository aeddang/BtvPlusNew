//
//  UniversalSearchManager.swift
//  BtvPlus
//
//  Created by JeongCheol Kim on 2021/02/01.
//  Copyright © 2021 skb. All rights reserved.
//

import Foundation
import VideoSubscriberAccount
import AVKit
import MediaPlayer

class UniversalSearchManager: NSObject, PageProtocol {
    private var contentId: String = ""
    private var title: String = ""
    //private var isConnected: Bool = false
    //private(set) var isPlay: Bool = false
    
    func updateMetaData(contentId:String, title:String) {
        self.contentId = contentId
        self.title = title
        DataLog.d("[UniversalSearch contentId] " + contentId, tag:self.tag)
        DataLog.d("[UniversalSearch title] " + title, tag:self.tag)
        //self.isPlay = false
    }
    
    func updatePlayNow(duration: Double, initTime: Double, isPlay: Bool = false) {
        //if !self.isConnected { return }
        //if self.contentId.isEmpty { return }
        //self.isPlay = true
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.title
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = initTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlay ? 1.0 : 0.0
        nowPlayingInfo[MPNowPlayingInfoPropertyExternalContentIdentifier] = contentId
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = 0
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        DataLog.d("[UniversalSearch updatePlayNow] " + duration.description
                        + " / " + initTime.description
                        + " / " + isPlay.description, tag:self.tag)
        
    }
    func updatePlay(time: Double, isPlay: Bool = false, rate:Float) {
        //if !self.isConnected { return }
        //if !self.isPlay { return }
        
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo
        if nowPlayingInfo != nil {
            nowPlayingInfo![MPNowPlayingInfoPropertyCurrentPlaybackDate] = Date()
            nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
            nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = isPlay ? rate : 0.0
            nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
            DataLog.d("[UniversalSearch updatePlay] " + time.description + " / " + isPlay.description, tag:self.tag)
        }
    }
    
    func updateStop() {
        //self.isPlay = false
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        DataLog.d("[updateStop]", tag:self.tag)
    }
    
    /*
    func updatePairing(_ id: String?) {
        guard let id = id else {
            self.pairingID = nil
            unsubscription()
            return
        }
        if self.pairingID != id {
            if id.isEmpty {
                DataLog.d("[UniversalSearch pairingID Empty]")
                self.pairingID = nil
                unsubscription()
                return
            }
            self.pairingID = id
            subscription()
        } else {
            self.isConnected = true
            DataLog.d("[UniversalSearch already subscription] " + (self.pairingID ?? "nil"))
        }
    }
 
    private func subscription() {
        self.isConnected = true
        UserDefaults.standard.set(self.pairingID, forKey: Self.PAIRING_KEY)
        let subscription = VSSubscription()
        subscription.expirationDate = Date.distantFuture
        subscription.accessLevel = .freeWithAccount
        let registrationCenter = VSSubscriptionRegistrationCenter.default()
        registrationCenter.setCurrentSubscription(subscription)
        DataLog.d("[UniversalSearch subscription] " + (self.pairingID ?? "nil"))
    }
    
    private func unsubscription() {
        self.isConnected = false
        UserDefaults.standard.set(nil, forKey: Self.PAIRING_KEY)
        let registrationCenter = VSSubscriptionRegistrationCenter.default()
        registrationCenter.setCurrentSubscription(nil)
        DataLog.d("[UniversalSearch unsubscription]")
    }
     */
}
