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
    private(set) var apiMacAdress:String = ApiConst.defaultMacAdress
    private(set) var restrictedAge:Int = -1
    private(set) var patchVersion:String? = nil
    private(set) var adultSafetyMode = false
    private(set) var agentVersion:String? = nil
    private(set) var major:Int = 0
    private(set) var minor:Int = 0
    private(set) var revision:Int = 0
    private(set) var modelViewName:String? = nil
    var modelName:String? = nil // mdns
    
    var isAppleTv:Bool {
        if self.modelViewName == "BAP-AB100" {
            return true
        }
        if self.patchVersion?.hasPrefix("22.") == true {
            return true
        }
        return false
    }
    
    var isRemoteSearchAble :Bool {
        
        if self.modelViewName == "HD/SMART1" { return false }
        guard let patchVersion = self.patchVersion else {return true}
        let pA = patchVersion.split(separator: ".")
        if pA.count >= 2 {
            if String(pA[1]).toInt() < 531 {return false}
        }
        return true
    }
    
    var playMacAdress :String{
       
        if  self.macAdress == "00:00:00:00:00:00" ||
            self.macAdress == ApiConst.defaultMacAdress ||
            self.macAdress == nil {
            return ""
        }
        return self.convertMacAdress
    }
    
    func setData(deviceData:HostDeviceData) -> HostDevice{
        self.macAdress = deviceData.stb_mac_address
        if let ma = self.macAdress {
            self.convertMacAdress = ApiUtil.getDecyptedData(
                forNps: ma,
                npsKey: NpsNetwork.AES_KEY, npsIv: NpsNetwork.AES_IV)
            let ipA = self.convertMacAdress.split(separator: ":")
            if ipA.count > 0 {
                self.apiMacAdress = ipA.dropFirst()
                    .reduce(ipA[0].description, {$0 + ":" + ( ($1.hasPrefix("0") && $1.count==2) ? $1.dropFirst() : $1 )})
            }
            //DataLog.d("self.apiMacAdress " + self.apiMacAdress , tag: "HostDevice")
           
        }
        self.modelViewName = deviceData.model_name
        self.restrictedAge = deviceData.restricted_age?.toInt() ?? -1
        self.agentVersion = deviceData.stb_src_agent_version
        self.patchVersion = deviceData.stb_patch_version
        self.adultSafetyMode = deviceData.adult_safety_mode?.toBool() ?? false
        self.setupAgentVersion()
        return self
    }
    
    private func setupAgentVersion(){
        guard let agent = self.agentVersion else { return }
        if agent.isEmpty {return}
        if agent == "null" || agent == "0" { return }
        let agents = agent.split(separator: ".")
        if agents.count != 3 {return }
        self.major = String(agents[0]).toInt()
        self.minor = String(agents[1]).toInt()
        self.revision = String(agents[2]).toInt()
    }
    
    private func checkAgentVersion()->Bool?{
        guard let agent = agentVersion else { return true }
        if agent.isEmpty {return true}
        if agent == "null" || agent == "0" {return false}
        return nil
    }
    
    func isSupportSimplePairing()->Bool{
        if let agentCheck = self.checkAgentVersion() { return agentCheck }
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
    
    func isEnableGuideKey() -> Bool {
        if let agentCheck = self.checkAgentVersion() { return agentCheck }
        if 1 == major {
            if 2 == minor && 11 <= revision{
                return true
            } else if 2 < minor {
                return true
            }
        } else if 2 == major {
            return true
        } else if 3 == major {
            if 1 == minor && 2 <= revision {
                return true
            } else if 1 < minor {
                return true
            }
        }
        return false
    }
    func isEnablePIPKey() -> Bool {
        if let agentCheck = self.checkAgentVersion() { return agentCheck }
        if 1 == major {
            if 2 == minor && 20 <= revision {
                return true
            } else if 2 < minor {
                return true
            }
        } else if 2 == major {
            if 1 == minor && 11 <= revision {
                return true
            } else if 1 < minor {
                return true
            }
        } else if 3 == major {
            if 1 == minor && 2 <= revision {
                return true
            } else if 1 < minor {
                return true
            }
        }
        return false
    }
    func isEnableStringInput() -> Bool {
        if let agentCheck = self.checkAgentVersion() { return agentCheck }
        if 1 == major {
            if 2 <= minor {
                return true
            }
        } else if 1 < major {
            return true
        }
        return false
    }
    func isEnableExitKey() -> Bool {
        if let agentCheck = self.checkAgentVersion() { return agentCheck }
        if 1 == major {
            if 2 == minor && 20 <= revision {
                return true
            } else if 2 < minor {
                return true
            }
        } else if 2 == major {
            if 1 == minor && 16 <= revision {
                return true
            } else if 1 < minor {
                return true
            }
        } else if 3 == major {
            if 1 == minor && 18 <= revision {
                return true
            } else if 1 < minor {
                return true
            }
        }
        return false
    }
}
