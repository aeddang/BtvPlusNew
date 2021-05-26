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
enum BroadcastingType:String{
    case VOD, IPTV, OAP
}

struct BroadcastProgram {
    var startTime: Double = 0
    var endTime: Double = 0
    var startTimeStr: String?
    var endTimeStr: String?
    var duration: String?
    var title: String?
    var contentId: String?
    var serviceId: String?
    var channel: String?
    var channelNo: String?
    var rating: Int?
    var restrictAgeIcon: String?
    var seriesNo: String?
    var image: String?
    
    var isOnAir: Bool = false
    var isAdult: Bool = false
    var isSeries: Bool = false
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
    private(set) var currentCId:String? = nil
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
                self.currentCId = cid
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
        self.currentCId = nil
        self.status = .none
    }
    
    
    func updateCurrentVod(synopsis:Synopsis){
        self.resetOnAir()
        self.currentVod = synopsis
        self.status = .none
        let isAdult = EuxpNetwork.adultCodes.contains(synopsis.contents?.adlt_lvl_cd)
        
        let isLock = !SystemEnvironment.isImageLock ? false : isAdult
        
        let title = synopsis.contents?.title
        let seriesNo = synopsis.contents?.brcast_tseq_nm
        /*
        if synopsis.contents?.sris_typ_cd == "01" {
            if let findId = synopsis.contents?.epsd_id {
                seriesNo = synopsis.series?.first(where: {findId == $0.epsd_id})?.sort_seq
            }
            
        }
        */
        var episodeTitle:String? = nil
        if isLock {
            episodeTitle = String.app.lockAdult
        } else{
            episodeTitle = (seriesNo == nil || seriesNo?.isEmpty == true)
            ? title
            : (title ?? "") + " " + seriesNo! + String.app.broCount
        }
        
        let rating = synopsis.contents?.wat_lvl_cd
        let restrictAgeIcon = rating != nil
            ? Asset.age.getIcon(age: rating!)
            : nil
        
        let duration = synopsis.contents?.play_tms_val != nil
            ? synopsis.contents!.play_tms_val! 
            : nil
        
        let image:String? = synopsis.contents?.epsd_poster_filename_v
        
        self.currentProgram = BroadcastProgram(
            duration:  duration,
            title: episodeTitle ,
            contentId: self.currentCId,
            rating: rating?.toInt(),
            restrictAgeIcon: restrictAgeIcon,
            seriesNo: seriesNo,
            image: image,
            isOnAir: false,
            isAdult: isAdult
            )
        
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
                    let image = "nsepg_" + (chInfo.ID_SVC ?? "") + ".png"
                    let rating = d.CD_RATING
                    let isAdult = (chInfo.RANK?.toInt() ?? 0) >= 19
                    let isLock = !SystemEnvironment.isImageLock ? false : isAdult
                    let episodeTitle:String? = isLock ? String.app.lockAdult : chInfo.NM_CH
                
                    if (stime <= now && now <= etime) {
                        self.currentProgram = BroadcastProgram(
                            startTime: stime,
                            endTime: etime,
                            startTimeStr: sdate.toDateFormatter(dateFormat: "HH:mm") ,
                            endTimeStr: edate.toDateFormatter(dateFormat: "HH:mm") ,
                            title: d.NM_TITLE ,
                            serviceId: chInfo.ID_SVC,
                            channel: episodeTitle,
                            channelNo: chInfo.NO_CH,
                            rating:rating?.toInt(),
                            restrictAgeIcon: Asset.age.getRemoteIcon(age:rating),
                            image:image,
                            isOnAir: true,
                            isAdult: isAdult)
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
                    serviceId: chInfo.ID_SVC,
                    channel: chInfo.NM_CH,
                    channelNo: chInfo.NO_CH,
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
