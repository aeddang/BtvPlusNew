//
//  MessageResult.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/05.
//

import Foundation

struct ResultMessage : Codable {
    private(set) var header:NpsCommonHeader? = nil//공통 정보
    private(set) var body:ResultMessageBody? = nil //상세 정보
}

struct ResultMessageBody : Codable {
    /*! 전송하는 Device를 구분할 수 있는 ID */
    private(set) var send_deviceid:String? = nil
    /*! 페어링 완료 시 할당된 페어링 아이디로 숫자로된 문자열 */
    private(set) var pairingid:String? = nil
    /*! 응답으로 전달되는 메시지 */
    private(set) var message:ResultMessageInfo? = nil
    /*! 서버의 아이피 */
    private(set) var ip:String? = nil
    /*! 서버의 포트 */
    private(set) var port:String? = nil
  
}

struct ResultMessageInfo : Codable {
    private(set) var CtrlType:String? = nil
    private(set) var CtrlValue:String? = nil
    private(set) var CurCID:String? = nil
    private(set) var CurChNum:String? = nil
    private(set) var CurVolume:String? = nil
    private(set) var PairingID:String? = nil
    private(set) var PlayCtrl:String? = nil
    private(set) var SID:String? = nil
    private(set) var SvcType:String? = nil
    
}
