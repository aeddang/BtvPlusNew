//
//  HostDevice.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/12.
//

import Foundation

class HostDevice {
    private(set) var macAdress:String? = nil
    private(set) var convertMacAdress:String = ApiConst.defaultMacAdress
    private(set) var agentVersion:String? = nil
    private(set) var restrictedAge:Int = -1
    private(set) var adultSafetyMode = false
    var modelName:String? = nil
   
    func setData(deviceData:HostDeviceData) -> HostDevice{
        self.macAdress = deviceData.stb_mac_address
        if let ma = self.macAdress {
            self.convertMacAdress = ApiUtil.getDecyptedData(
                forNps: ma,
                npsKey: NpsNetwork.AES_KEY, npsIv: NpsNetwork.AES_IV)
        }
        self.restrictedAge = deviceData.restricted_age?.toInt() ?? -1
        self.agentVersion = deviceData.stb_src_agent_version
        self.adultSafetyMode = deviceData.adult_safety_mode?.toBool() ?? false
        return self
    }
    
    func isSupportSimplePairing()->Bool{
        guard let agent = agentVersion else { return true }
        if agent.isEmpty {return true}
        if agent == "null" || agent == "0" {return false}
        let agents = agent.split(separator: ".")
        if agents.count != 3 {return false}
        let major:Int = String(agents[0]).toInt()
        let minor = String(agents[1]).toInt()
        let revision = String(agents[2]).toInt()
        // legacy  1.2.20 이상
        if (major == 1 && ((minor == 2 && revision >= 20) || minor > 2)) {
            return true
        }
        // Smart  2.1.16 이상
        else if (major == 2 && ((minor == 1 && revision >= 16) || minor > 1)) {
            return true
        }
        // UHD 3.1.18 이상
        else if (major == 3 && ((minor == 1 && revision >= 18) || minor > 1)) {
            return true
        } else {
            return false
        }
    }
}
