//
//  ZeroConf.swift
//  BtvPlusNew
//
//  Created by Hyun-pil Yang on 2021/10/07.
//

import Foundation
import Network

class ZeroConf{
        
    var connection: NWConnection?
    
    func sendZeroConf(networkObserver:NetworkObserver?) {
        
//        if networkObserver?.status == .wifi,
//           AppUtil.idfa != ""
//        {
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
                
                self.connection = NWConnection(host: host, port: port, using: .udp)

                self.connection?.stateUpdateHandler = { (newState) in
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
                        self.connection?.cancel()
                        print("waiting or failed")

                    }
                }
                self.connection?.start(queue: .global())
            }
//        }
       
    }
    
    private func sendData(param : String) {
        self.connection?.send(content: param.data(using: String.Encoding.utf8), completion: NWConnection.SendCompletion.contentProcessed(({ (error) in
                self.connection?.cancel()
                if error != nil {
                    print(error ?? "ZeroConf Unkow Error")
                }
            })))
    }
}


extension String {

    func fromBase64String() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64String() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}
