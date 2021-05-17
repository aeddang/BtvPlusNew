//
//  NpsMessage.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/05.
//

import Foundation

enum NpsCtrlType:String{
    case SeamlessLive, SeamlessVod, SendMsg, Refresh, PlayCtrl
}

enum NpsQuery:String{
    case StatusQuery
}

class NpsMessage{
    private(set) var ctrlType:NpsCtrlType = .SendMsg
    private(set) var ctrlValue:String = ""
    private(set) var RCStatusQuery:NpsQuery = .StatusQuery
    private(set) var count:Int = 0
    
    @discardableResult
    func setMessage(type:NpsCtrlType, value:String? = nil, query:NpsQuery? = nil) -> NpsMessage {
        self.ctrlType = type
        self.ctrlValue = value ?? ""
        self.RCStatusQuery = query ?? NpsQuery.StatusQuery
        self.count = NpsNetwork.controlMessageCount
        return self
    }
    
    @discardableResult
    func setPlayLiveMessage(serviceId:String) -> NpsMessage {
        self.ctrlType = NpsCtrlType.SeamlessLive
        self.ctrlValue = "svc_id=" + serviceId
        self.RCStatusQuery = NpsQuery.StatusQuery
        self.count = NpsNetwork.controlMessageCount
        return self
    }
    
    @discardableResult
    func setPlayVodMessage(contentId:String, playTime:Double) -> NpsMessage{
        self.ctrlType = NpsCtrlType.SeamlessVod
        self.ctrlValue = "cid=" + contentId + ";play_time=" + playTime.description.toDigits(0)
        self.RCStatusQuery = NpsQuery.StatusQuery
        self.count = NpsNetwork.controlMessageCount
        return self
    }
    
    var messageString:String {
        get{
            var dic = [String:Any]()
            dic["CtrlType"] = ctrlType.rawValue
            dic["CtrlValue"] = ctrlValue
            dic["RCStatusQuery"] = RCStatusQuery.rawValue
            dic["count"] = count.description
            return AppUtil.getJsonString(dic: dic) ?? ""
        }
    }
    
    var messageObj:[String:Any] {
        get{
            var dic = [String:Any]()
            dic["CtrlType"] = ctrlType.rawValue
            dic["CtrlValue"] = ctrlValue
            dic["RCStatusQuery"] = RCStatusQuery.rawValue
            dic["count"] = count.description
            return dic
        }
    }
}



extension NpsNetwork{
    struct Keys {
        static let controlMessageCount = "controlMessageCount1"
        static let controlLastTime = "controlLastTime1"
    }
    
    static var controlMessageCount:Int {
        get{
            let storage = UserDefaults.init()
            var count:Int = storage.integer(forKey: Keys.controlMessageCount)
            let lastTime = storage.double(forKey: Keys.controlLastTime)
            let now = Date().timeIntervalSince1970
            if (now - lastTime) > (2 * 60 * 60 * 1000) {
                count = 0
            } 
            count += 1
            storage.setValue(count, forKey: Keys.controlMessageCount)
            storage.setValue(now, forKey: Keys.controlLastTime)
            return count
        }
    }
}
