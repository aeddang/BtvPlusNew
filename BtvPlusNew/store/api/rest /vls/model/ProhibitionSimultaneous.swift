//
//  ProhibitionSimultaneous.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/13.
//

import Foundation


struct ProhibitionSimultaneous: Decodable {
    private(set) var request_id: String? = nil // 내부 요청번호
    private(set) var has_authority: String? = nil  // Y (권한 있음) , N (권한 없음) , U (알수없는 상태-오류) 아래의  result, message 에 따라 권한 상태를 판단하는 것이 아닌 해당 값에 따라 권한 상태를 판단 하세요. 오류 혹은 판단 불가의 상태에 있을 경우 해당 값은 Y 로 셋팅되어 리턴 됩니다 ( 서영아M )"
    private(set) var es_result: String? = nil  // "ES 리턴값 값 (해당 값을 판단하여 has_authority 값 생성) TU : 기본 값 (통신 오류등 판단할 근거를 찾지 못함) T3: ES 검색 결과 중  EVENT_TYPE=3 == (동시시청 중인 상태) T5: ES 검색 결과 중  EVENT_TYPE=5 == (동시시청 중이 아닌 상태) TB: ES 검색 결과 중  결과 없음 == (동시시청 중이 아닌 상태)"
    private(set) var es_count: String? = nil   // 인터페이스 버전
    private(set) var process_time: String? = nil   // 내부 실행 시간
    private(set) var pc_id: String? = nil  // 요청한 PC_ID
    private(set) var stb_id: String? = nil // STB id
    private(set) var episode_id: String? = nil // NCMS-EpisodeID
    private(set) var from: String? = nil   // "포맷 : "yyyy-MM-dd'T'HH:mm:ss" ES 데이터 검색을 위한  RANGE 검색 조건 입니다. 값을 셋팅하지 않을 경우 : 기본 정책(  LSD-86 - [동시시청] 정책 OPEN ) 에 의해 요청시간 -5Hour 를 기준으로 검색을 하게 됩니다. 값을 셋팅 할 경우 : 셋팅한 시간을 기준으로 검색을 시도 합니다."
    private(set) var service_code: String? = nil   // "ES 데이터 검색을 위한  서비스 코드  MATCH  검색 조건 입니다. 샘플로 기입된 (v512.cdrLogNs) 값을 사용할 경우 : BtvPlus  간의 동시시청 제한 용도로 사용 됩니다. 값을 셋팅하지 않을 경우 : Btv, BtvPlus  간의 동시시청 제한 용도로 사용 됩니다"
    private(set) var has_authority_reason: String? = nil   // has_authority 값이 'N' 일 경우 유효하며, 사유 값을 나타낸다.
    // R1 : 지상파월정액 동시 시청 불가 정책에 의한 차단
    // R2 : 동일 CP 컨텐츠 동시 시청 불가 정책에 의한 차단
    // R3 : 동일 에피소드 동시 시청 불가 정첵에 의한 차단
    private(set) var limit_flag: String? = nil   // 동시시청가능여부 Y/N
    private(set) var cp_id: String? = nil    // CP 계약코드 ( limit_flag 값이 Y 일 경우 값이 없어도 가능)
    private(set) var ppm_ids: String? = nil    // 월정액 상품 ID
}
