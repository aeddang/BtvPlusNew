//
//  Channels.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/05/17.
//

import Foundation
import SwiftUI

enum BroadcastingRequest{
    case updateAllChannels, updateCurrentBroadcast, updateCurrentVod(String?)
}

enum BroadcastingStatus{
    case none, loading, error, empty
}

struct BroadcastProgram {
    var startTime: Double = 0
    var endTime: Double = 0
    var startTimeStr: String?
    var endTimeStr: String?
    var duration: String?
    var title: String?
    var channel: String?
    var restrictAgeIcon: String?
    var isOnAir: Bool = false
    var isAdult: Bool = false
}

class Broadcasting:ObservableObject, PageProtocol {
    @Published private(set) var request:BroadcastingRequest? = nil
    @Published private(set) var status:BroadcastingStatus = .none
    
    @Published private(set) var currentChannel:ChannelInfo? = nil
    @Published private(set) var currentProgram: BroadcastProgram? = nil
    private(set) var wepgVersion: String? = nil
    private(set) var allChannels:[String:ChannelInfo]? = nil
    private(set) var lastChannels:[String:CurrentChannelInfo]? = nil
    private(set) var currentChannelNo:String? = nil
    private(set) var currentVod:Synopsis? = nil
    
    func reset(){
        self.resetVod()
        self.resetOnAir()
    }
    
    func requestBroadcast(_ request:BroadcastingRequest){
        self.lastChannels = nil
        switch request {
        case .updateCurrentBroadcast:
            if allChannels == nil {
                self.request = .updateAllChannels
            }
        case .updateCurrentVod(let cid):
            if cid == nil {
                self.errorCurrentVod()
                return
            }
        default: break
        }
        
        self.status = .loading
        self.request = request
    }
    
    func updateChannelNo(_ no:String?){
        self.resetVod()
        self.currentChannelNo = no
        self.updated()
    }
    
    func updateCurrentVod(synopsis:Synopsis){
        self.resetOnAir()
        self.currentVod = synopsis
        self.status = .none
        
        let isAdult = EuxpNetwork.adultCodes.contains(synopsis.contents?.adlt_lvl_cd)
        let title = synopsis.contents?.title
        let count = synopsis.contents?.brcast_tseq_nm
        let episodeTitle = (count == nil || count?.isEmpty == true)
            ? title
            : (title ?? "") + " " + count! + String.app.broCount
        
        let restrictAgeIcon = synopsis.contents?.wat_lvl_cd != nil
            ? Asset.age.getIcon(age: synopsis.contents!.wat_lvl_cd!)
            : nil
        
        let duration = synopsis.contents?.play_tms_val != nil
            ? synopsis.contents!.play_tms_val! + String.app.min
            : nil
        
        self.currentProgram = BroadcastProgram(
            duration:  duration,
            title: episodeTitle ,
            restrictAgeIcon: restrictAgeIcon,
            isOnAir: false,
            isAdult: isAdult)
        
    }
    func errorCurrentVod(){
        self.status = .error
    }
    
    func updateAllChannels(_ channels:AllChannels){
        var updateChannels:[String:ChannelInfo] = [:]
        channels.ServiceInfoArray?.forEach{ d in
            if let chNo = d.NO_CH {
                updateChannels[chNo] = d
            }
        }
        self.allChannels = updateChannels
        self.updated()
    }
    
    func errorAllChannels(){
        self.status = .error
        self.updated()
    }
    
    func updateCurrentBroadcast(_ channels:CurrentChannels){
        var updateChannels:[String:CurrentChannelInfo] = [:]
        channels.ServiceInfoArray?.forEach{ d in
            if let key = d.ID_SVC {
                updateChannels[key] = d
            }
        }
        self.lastChannels = updateChannels
        self.updated()
    }
    
    func errorCurrentBroadcast(){
        self.status = .error
    }
    
    private func resetOnAir(){
        self.lastChannels = nil
        self.status = .none
        self.currentChannel = nil
        self.currentProgram = nil
    }
    
    private func resetVod(){
        self.currentVod = nil
        self.status = .none
    }
    
    private func updated(){
        guard let allChannels = self.allChannels else { return }
        guard let currentChannels = self.lastChannels else { return }
        guard let no = self.currentChannelNo else { return }
        
        self.status = .none
        if let chInfo = allChannels[no] {
            self.currentChannel = chInfo
            if let info = currentChannels[ chInfo.ID_SVC ?? "" ] {
                let now = Double(Date().timeIntervalSince1970)
                
                if let program = info.EventInfoArray?.first(where: { d in
                    guard let sdate = d.DT_EVNT_START?.toDate(dateFormat: "yyyyMMddHHmmss") else { return false }
                    guard let edate = d.DT_EVNT_END?.toDate(dateFormat: "yyyyMMddHHmmss") else { return false }
                    let stime = Double(sdate.timeIntervalSince1970)
                    let etime = Double(edate.timeIntervalSince1970)
                    if (stime <= now && now <= etime) {
                        self.currentProgram = BroadcastProgram(
                            startTime: stime,
                            endTime: etime,
                            startTimeStr: sdate.toDateFormatter(dateFormat: "HH:mm") ,
                            endTimeStr: edate.toDateFormatter(dateFormat: "HH:mm") ,
                            title: d.NM_TITLE ,
                            channel: chInfo.NM_CH,
                            restrictAgeIcon: Asset.age.getRemoteIcon(age:d.CD_RATING),
                            isOnAir: true,
                            isAdult: (chInfo.RANK?.toInt() ?? 0) >= 19)
                        
                        return true
                    }
                    return false
                }) {
                    DataLog.d("find program " + (program.NM_TITLE ?? "no title"), tag: self.tag)
                    return
                }
                
            }
            if chInfo.TP_SVC == "128" {
                let nowDate = Date().toDateFormatter(dateFormat: "yyyyMMdd")
                let sdate = (nowDate + "000000").toDate(dateFormat: "yyyyMMddHHmmss")
                let edate = (nowDate + "235959").toDate(dateFormat: "yyyyMMddHHmmss")
                // 오디오 채널인 경우
                self.currentProgram = BroadcastProgram(
                    startTime:  Double(sdate?.timeIntervalSince1970 ?? 0) ,
                    endTime: Double(edate?.timeIntervalSince1970 ?? 0) ,
                    startTimeStr: sdate?.toDateFormatter(dateFormat: "HH:mm") ?? "",
                    endTimeStr: edate?.toDateFormatter(dateFormat: "HH:mm") ?? "",
                    title: String.remote.titleMusicBroadcast,
                    channel: chInfo.NM_CH,
                    restrictAgeIcon: nil,
                    isOnAir: true)
            } else {
                DataLog.d("notfound program", tag: self.tag)
                self.currentProgram = nil
                self.status = .empty
            }
        } else {
            self.currentProgram = nil
            self.currentChannel = nil
        }
        
    }
}
