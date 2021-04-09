//
//  NpsMessage.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/05.
//

import Foundation

enum NpsCtrlType:String{
    case SeamlessLive, SeamlessVod, SendMsg, Refresh
}

enum NpsQuery:String{
    case StatusQuery
}

class NpsMessage{
    private(set) var CtrlType:NpsCtrlType = .SendMsg
    private(set) var CtrlValue:String = ""
    private(set) var RCStatusQuery:NpsQuery = .StatusQuery
    private(set) var count:Int = 0
    
    @discardableResult
    func setMessage(type:NpsCtrlType, value:String? = nil, query:NpsQuery? = nil) -> NpsMessage {
        self.CtrlType = type
        self.CtrlValue = value ?? ""
        self.RCStatusQuery = query ?? NpsQuery.StatusQuery
        self.count = NpsNetwork.controlMessageCount
        return self
    }
    
    @discardableResult
    func setPlayLiveMessage(serviceId:String) -> NpsMessage {
        self.CtrlType = NpsCtrlType.SeamlessLive
        self.CtrlValue = "svc_id=" + serviceId
        self.RCStatusQuery = NpsQuery.StatusQuery
        self.count = NpsNetwork.controlMessageCount
        return self
    }
    
    @discardableResult
    func setPlayVodMessage(contentId:String, playTime:Double) -> NpsMessage{
        self.CtrlType = NpsCtrlType.SeamlessVod
        self.CtrlValue = "cid=" + contentId + ";play_time=" + playTime.description.toDigits(0)
        self.RCStatusQuery = NpsQuery.StatusQuery
        self.count = NpsNetwork.controlMessageCount
        return self
    }
    
    var messageString:String {
        get{
            var dic = [String:Any]()
            dic["CtrlType"] = CtrlType.rawValue
            dic["CtrlValue"] = CtrlValue
            dic["RCStatusQuery"] = RCStatusQuery.rawValue
            dic["count"] = count.description
            return AppUtil.getJsonString(dic: dic) ?? ""
        }
    }
}



extension NpsNetwork{
    struct Keys {
        static let controlMessageCount = "controlMessageCount"
        static let controlLastTime = "controlLastTime"
    }
    
    static var controlMessageCount:Int {
        get{
            let storage = UserDefaults.init()
            var count:Int = storage.integer(forKey: Keys.controlMessageCount)
            let lastTime = storage.double(forKey: Keys.controlLastTime)
            let now = Date().timeIntervalSince1970
            if (now - lastTime) < (2 * 60 * 60) {
                count = 0
            }
            count += 1
            storage.setValue(count, forKey: Keys.controlMessageCount)
            storage.setValue(now, forKey: Keys.controlLastTime)
            return count
        }
    }
}