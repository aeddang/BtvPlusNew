//
//  ApiConst.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

import UIKit

struct ApiPath {
    static func getRestApiPath(_ server:ApiServer) -> String {
        if let vmsPath = SystemEnvironment.serverConfig[server.configKey] {
            if vmsPath != "" { return vmsPath }
        }
        if server == .VMS {
            return "http://mobilebtv.com:9080"
        }
        if server == .NPS_V5 {
            return "http://nps.hanafostv.com:9090"
        }
    
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                return dict[ "Api" + server.rawValue ] as? String ?? ""
            }
        }
        return ""
    }
}

struct ApiGateway{
    static let API_KEY = "l7xx851d12cc66dc4d2e86a461fb5a530f4a"
    static let DEBUG_API_KEY = "l7xx159a8ca72966400b886a93895ec9e2e3"
    
    static func setGatewayheader( request:URLRequest) -> URLRequest{
        var authorizationRequest = request
        authorizationRequest.addValue(
            "application/json;charset=utf-8", forHTTPHeaderField: "Accept")
        #if DEBUG
        authorizationRequest.addValue(
            Self.DEBUG_API_KEY, forHTTPHeaderField: "Api_Key")
        #else
        authorizationRequest.addValue(
            Self.API_KEY, forHTTPHeaderField: "Api_Key")
        #endif
        let timestamp = Date().toTimestamp(dateFormat: "yyyyMMddHHmmss.SSS", local: "en_US_POSIX")
        authorizationRequest.addValue( timestamp, forHTTPHeaderField: "TimeStamp")
        authorizationRequest.addValue( timestamp.toSHA256(), forHTTPHeaderField: "Auth_Val")
        authorizationRequest.addValue( NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId , forHTTPHeaderField: "Client_ID")
        return authorizationRequest
    }
    
    static func setDefaultheader( request:URLRequest) -> URLRequest{
        var authorizationRequest = request
        authorizationRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        authorizationRequest.addValue(
            SystemEnvironment.model+"/"+SystemEnvironment.model, forHTTPHeaderField: "x-device-info")
        authorizationRequest.addValue(
            ApiPrefix.iphone+"/"+SystemEnvironment.systemVersion, forHTTPHeaderField: "x-os-info")
        authorizationRequest.addValue(
            ApiPrefix.service+"/"+SystemEnvironment.bundleVersion , forHTTPHeaderField: "x-service-info")
        authorizationRequest.addValue(
            ApiPrefix.device + SystemEnvironment.deviceId , forHTTPHeaderField: "x-did-info")
        /*
        authorizationRequest.addValue(
            "", forHTTPHeaderField: "x-auth-info")
        */
        return authorizationRequest
    }
}


struct ApiPrefix {
    static let os =  "ios"
    static let iphone = "iphone"
    static let ipad = "ipad"
    static let service = "btvplus"
    static let device = "I"
}

struct ApiConst {
    static let pageSize = 20
    static let defaultStbId = "{00000000-0000-0000-0000-000000000000}"
}

enum ApiAction:String{
    case password
}

enum ApiValue:String{
    case video
}

enum ApiServer:String{
    case WEB, NPS, NPS_V5, PSS, RVS, WEPG, VMS, STACM, SRCXPG,
    UPMC, ME, EVENT, EMS, LGS, METV, IMAGE, NAVILOG, NAVILOG_NPI, EUXP, SMD,
    IIP, METV2, SCS2, EPS, NF, RVS2, VLS, KMS, NSUTIL, PUCR, PUSH
    
    var configKey:String {
        get {
            switch self {
            // vms define
            case .STACM: return "stacm"
            case .PUCR: return "pucr"
            case .IMAGE: return "image"
            case .NAVILOG_NPI: return "navilognpi"
            case .NAVILOG: return "navilog"
            case .UPMC: return "upmc"
            case .EUXP: return "euxp"
            case .EMS: return "ems"
            case .EVENT: return "event"
            case .PSS: return "pss"
            case .IIP: return "iip"
            case .RVS2: return "rvs2"
            case .ME: return "me"
            case .LGS: return "lgs"
            case .SCS2: return "scs2"
            case .EPS: return "eps"
            case .METV: return "metv"
            case .RVS: return "rvs"
            case .PUSH: return "push"
            case .NPS: return "nps"
            case .WEPG: return "wepg"
            case .NPS_V5: return "npsv5"
            case .METV2: return "metv2"
            case .NF: return "nf"
            case .VLS: return "vls"
           
            // vms not define
            case .WEB: return "web"
            case .VMS: return "vms"
            case .SRCXPG: return "srcxpg"
            case .SMD: return "smd"
            case .KMS: return "kms"
            case .NSUTIL:return "nsutil"
            }
        }
    }
    
    static func getType(_ value:String) -> ApiServer?{
        switch value {
        case "stacm": return .STACM
        case "pucr": return .PUCR
        case "image": return .IMAGE
        case "navilognpi": return .NAVILOG_NPI
        case "navilog": return .NAVILOG
        case "upmc": return .UPMC
        case "euxp": return .EUXP
        case "ems": return .EMS
        case "event": return .EVENT
        case "pss": return .PSS
        case "iip": return .IIP
        case "rvs2": return .RVS2
        case "me": return .ME
        case "lgs": return .LGS
        case "scs2": return .SCS2
        case "eps": return .EPS
        case "metv": return .METV
        case "rvs": return .RVS
        case "push": return .PUSH
        case "nps": return .NPS
        case "wepg": return .WEPG
        case "npsv5": return .NPS_V5
        case "metv2": return .METV2
        case "nf": return .NF
        case "vls": return .VLS
        // vms not define
        case "web": return .WEB
        case "vms": return .VMS
        case "srcxpg": return .SRCXPG
        case "smd": return .SMD
        case "kms": return .KMS
        case "nsutil":return .NSUTIL
        default : return nil
        }
        
    }
}
