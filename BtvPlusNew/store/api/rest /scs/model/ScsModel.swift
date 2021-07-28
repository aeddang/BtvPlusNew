//
//  Scs.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/27.
//

import Foundation

struct PlayInfo : Decodable {
    private(set) var CID: String? = nil     // Content ID
    private(set) var RTSP_CNT_URL: String? = nil    // 콘텐츠 경로(RTSP)
    private(set) var HLS_CNT_URL: String? = nil     // "콘텐츠 경로(HLS) 프로토콜을 HLS로 요청하지 않았을경우, 콘텐츠의 HLS 재생 URL 없을경우, 요청 시스템이 BTVPLUS인 경우 값이 내려가지 않는다."
    private(set) var CNT_URL_NS_SD: String? = nil   // "모바일 콘텐츠 경로(SD) 요청 시스템이 BTV인 경우 값이 내려가지 않는다."
    private(set) var CNT_URL_NS_HD: String? = nil  // "모바일 콘텐츠 경로(HD) 요청 시스템이 BTV인 경우 값이 내려가지 않는다."
    private(set) var CNT_URL_NS_FHD: String? = nil   // "모바일 콘텐츠 경로(FHD) 요청 시스템이 BTV인 경우 값이 내려가지 않는다."
    private(set) var CNT_URL_NS_AUTO: String? = nil     // "모바일 콘텐츠 경로(AUTO) 요청 시스템이 BTV인 경우 값이 내려가지 않는다."
    private(set) var HLS_LICENSE_URL: String? = nil     // HLS DRM 라이선스 URL
    private(set) var FGQUALITY: String? = nil   // "화질 구분 10:SD, 20:HD, 30:UHD, 35:UHD+HDR"
    private(set) var REQ_DRM: String? = nil     // DRM 종류
    private(set) var REQ_MV: String? = nil  // "매크로비전 적용 여부 0:미적용, 1:적용"
    private(set) var YN_WATER_MARK: String? = nil   // 워터마크 유무
    private(set) var EXTENSION: String? = nil   // "워터마크 관련 정보 재생 %, 반복간격, 반복횟수"
    private(set) var WM_MODE: String? = nil     // "워터마크 모드 0:invisible 1:visible 2:invisible + visible"
    private(set) var NSCREEN: String? = nil    // "N-Screen 상품여부 (Y:N-Screen 상품)"
    private(set) var YN_BIND: String? = nil     // 합본 여부
    private(set) var VOC_LAG: String? = nil     // "음성언어 (01 : 우리말, 02: 한글자막, 03: 영어자막, 04: 영어더빙, 05: 중국어더빙, 13: 기타, 15: 외국어자막서비스)"
    private(set) var PREVIEW_TIME: String? = nil    // 미리보기 시간(초)
    private(set) var QUALITY_MEDIA: String? = nil   // 미디어 품질
    private(set) var SAMPLING: String? = nil

}

struct ConfirmPassword : Decodable {
    private(set) var IF: String? = nil     // Content ID
    private(set) var verresult: String? = nil    // 콘텐츠 경로(RTSP)
    private(set) var result: String? = nil    // "콘텐츠 경로(HLS) 프로토콜을 HLS로 요청하지 않았을경우, 콘텐츠의 HLS 재생 URL 없을경우, 요청 시스템이 BTVPLUS인 경우 값이 내려가지 않는다."
   
}
