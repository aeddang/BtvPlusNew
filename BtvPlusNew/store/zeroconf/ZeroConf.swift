//
//  ZeroConf.swift
//  BtvPlusNew
//
//  Created by Hyun-pil Yang on 2021/10/07.
//

import Foundation
import Network

class ZeroConf {
        
    static private var connection: NWConnection?
    
    func sendZeroConf(networkObserver:NetworkObserver?) {
        
        if networkObserver?.status == .wifi,
           AppUtil.idfa != ""
        {
            let pVersion = 1        // 프로토콜 버전
            let idfa = AppUtil.idfa
            let osCode = "1"        // iOS : 1 , Android : 0, etc : 2
            let ccode = "C00000"    //SKB : C00000
            
            let variableCode = "\"os\":\"\(osCode)\",\"ccode\":\"\(ccode)\""
            let convertBase = variableCode.toBase64String()
            
            let param = "\(String(format: "%04d", pVersion))\(idfa)\(String(format: "%04d", convertBase.count))\(convertBase)"
            print(param)
            
            let zeroConfPath = ApiPath.getRestApiPath(.ZEROCONF)
            let pathArray =  zeroConfPath.components(separatedBy: ":")
            print(pathArray)
            
            if pathArray.count > 1 {

                let host: NWEndpoint.Host = .init(pathArray[0])
                let port: NWEndpoint.Port = NWEndpoint.Port(rawValue: UInt16(pathArray[1])!) ?? 0000
                
                Self.connection = NWConnection(host: host, port: port, using: .udp)

                Self.connection?.stateUpdateHandler = { (newState) in
                    switch (newState) {
                    case .ready:
                        print("ready")
                        self.sendData(param: param)
                    case .setup:
                        print("setup")
                    case .cancelled:
                        print("cancelled")
                    case .preparing:
                        print("Preparing")
                    default:
//                        Self.connection?.cancel()
                        print("waiting or failed")

                    }
                }
                Self.connection?.start(queue: .global())
            }
        }
    }
    
    private func sendData(param : String) {
        Self.connection?.send(content: param.data(using: String.Encoding.utf8), completion: NWConnection.SendCompletion.contentProcessed(({ (error) in
//                Self.connection?.cancel()
                if error != nil {
                    print(error ?? "ZeroConf Unkow Error")
                }
            })))
    }
}
