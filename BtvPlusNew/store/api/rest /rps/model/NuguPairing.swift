//
//  NuguPairing.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/10/09.
//

import Foundation

struct NuguPairing: Decodable {

    private(set) var snr_pairing_yn:String? = nil // 가족연결셋탑 페어링여부 Y: 페어링 정보가 1개 이상일시 N: 페어링 정보가 미존재시
    private(set) var single_signup_yn:String? = nil // 부모 단독가입여부
    private(set) var stb_info:[NuguStbInfoItem]? = nil // 발신자(자녀) 상세정보
    private(set) var tgt_stb_info:[NuguStbInfoItem]? = nil  // 수신자(부모) 상세정보
}


struct NuguStbInfoItem: Decodable {
    private(set) var recv_stb_id:String? = nil // 수신자 셋탑아이디
    private(set) var send_stb_id:String? = nil // 발신자 셋톱아이디 - 부모와 자녀간의 연결인 경우 : 자녀 셋톱아이디 - 부모단독연결인경우 :  빈값
    private(set) var send_snr_gft_yn:String? = nil // [발신자] 시니어 선물하기 가능여부 Y: 효상품가입자 N: 효상품 미가입자
    private(set) var recv_snr_gft_yn:String? = nil // [수신자] 시니어 선물하기 가능여부 Y: 효상품가입자 N: 효상품 미가입자
    private(set) var send_gft_hst_yn:String? = nil // [발신자] 선물이력여부 Y: 선물이력존재 N: 선물이력 미존재
    private(set) var recv_gft_hst_yn:String? = nil // [수신자] 선물이력여부 Y: 선물이력존재 N: 선물이력 미존재
}


