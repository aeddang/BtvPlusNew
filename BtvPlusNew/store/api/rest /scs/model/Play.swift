//
//  Play.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/27.
//

import Foundation

struct ProductInfoItem : Decodable {
    private(set) var PID: String?   // 상품 ID * 해당 값을 LGS에 넘겨준다.
    private(set) var PNAME: String?   // 상품명
    private(set) var ID_MCHDSE: String?   // vod+상품 시 ID 값
    private(set) var PROD_DESC: String?   // 상품 설명
    private(set) var PRICE: String?   // 상품 가격
    private(set) var V_PRICE: String?   // 부가세 포함 상품가격
    private(set) var DUETIME: String?   // 상품 시청 가능 시간 (48)
    private(set) var DUETIME_PERIOD: String?   // 상품 시청 가능 기간 (2일)
    private(set) var DUETIME_STR: String?   // 상품 시청 가능 기간 (2017년 02월 04일 01시 까지)
    private(set) var CLTYN: String?   // 소장용 여부 Y:소장용, N or null:비소장용
    private(set) var IFTYN: String?   // 365일 여부 정보
    private(set) var PPM_PROD_TYPE: String?   // 월정액 상품 타입 0:일반 1:프리미어 월정액 2:방송사 월정액 3:지상파 월정액
    private(set) var PPM_PROD_IMG_PATH: String?   // 월정액 상품 이미지 패스정보
    private(set) var IPTV_SET_PROD_FLAG: String?   // VOD 및 VOD+IPTV채널 상품 구분 0 or null:VOD 상품 1:IPTV 채널 + VOD 세트상품
    private(set) var IPTV_SET_PROD_TYPE: String?   // IPTV채널+VOD세트상품 타입 10:VOD 단독구매 불가 20:단편구매가능 30:VOD 월정액만 구매 가능 40:단편,월정액 구매 가능
    private(set) var IPTV_CH_TITLE: String?   // 대표 채널명
    private(set) var IPTV_ID_SVC: String?   // 대표 채널 ID 서비스 정보
    private(set) var IPTV_CH_NO: String?   // 대표 채널 번호
}

struct ProductInfo : Decodable {
    private(set) var PTYPE: String?   // 상품 타입 10 : PPV(단일상품) 20 : PPS (시리즈상품) 30 : PPM(월정액 상품) 41 : PPP (패키지)
    private(set) var PTYPE_STR: String?   // 상품타입 명칭
    private(set) var TARGET_PAYMENT: String?   // 신규 결제수단 10:핸드폰, 90:후불, 2:TV페이(신용카드)
    private(set) var PROD_DTL:[ProductInfoItem]? = nil  // 상품 상세 정보
}

struct Play : Decodable {
    private(set) var IF: String?   // 인터페이스 아이디
    private(set) var ver: String?  // 인터페이스 버전
    private(set) var ui_name: String?   // UI 구분자
    private(set) var svc_name: String?  // 서비스 명
    private(set) var result: String?   // 성공여부 0000:성공, xxxx:오류
    private(set) var reason: String?  // 메시지, 오류코드 명세 참조
    private(set) var epsd_id: String?  // 에피소드 ID
    private(set) var sris_id: String?  // 시리즈 ID
    private(set) var STB_ID: String?  // STB ID
    private(set) var PREPAID: String?  // 이전 구매 여부 0:미지불, 1ㅣ지불 * 해당 값이 1이면 구매 권한이 있다(무료일때는 0으로 내려온다.)
    private(set) var PURCHASE_TIME: String?  // 구매 시간 Prepaid 가 지불인경우
    private(set) var CHARGE_PERIOD: String?  // LGS CDR_LOG(4번) 이벤트 기준 시점 (5)
    private(set) var CUR_TIME: String?  // H/E DB 서버 시간
    private(set) var POPUP: String?  // 구매창 및 시청기간 만료 창 팝업 여부 -1:error 0:이미 구매된 상품 1:유료 구매창 팝업 2:시청 만료 구매창 3:추가 광고 시청 할인 구매창(금액)
                                                                //4:추가 광고 무료 시청 5:맛보기 상품 6:상품 변경 유도 7:추가 광고 할인 && 시청 기간 만료 8:무료 9:예약 10:선물 받은 상품 * 재생 권한 은 해당 POPUP 로 판단하면 된다.
    private(set) var CTS_INFO:PlayInfo? = nil  // 컨텐츠 정보
    private(set) var PROD_INFO:[ProductInfo]? = nil  // 상품 정보
    private(set) var verf_res_data: String?  // 암호화 된 검증 data
}
