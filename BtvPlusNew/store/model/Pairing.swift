//
//  Pairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation

enum PairingRequest{
    case wifi , btv, user, cancel
}

enum PairingStatus{
    case disConnect , connect
}

enum PairingEvent{
    case connected, disConnected, error
}

class Pairing:ObservableObject, PageProtocol {
    @Published private(set) var request:PairingRequest? = nil
    @Published var event:PairingEvent? = nil
    @Published var status:PairingStatus = .disConnect

    private(set) var stbId:String = "{F76A4668-46EA-11EA-91F5-9D29A492214E}"
    
    func requestPairing(_ request:PairingRequest){
        self.request = request
    }
    
    func foundDevice(_ mdnsData:[MdnsDevice]){
        
    }
    func notFoundDevice(){
        
    }
}
