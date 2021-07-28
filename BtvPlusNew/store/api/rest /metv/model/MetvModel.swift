//
//  AddedBookMark.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/20.
//

import Foundation

struct UpdateMetv : Decodable {
    private(set) var result: String? = nil    // 요청 결과.
    private(set) var reason: String? = nil
}
/*
@property (nonatomic, strong) NSString *IF;       // 인터페이스 식별자
@property (nonatomic, strong) NSString *ver;      // 인터페이스 버전, 요청의 버전과 동일한 값이 전달 된다.
@property (nonatomic, strong) NSString *result;   // 요청 결과.
@property (nonatomic) eAppType app_type;   // 즐겨찾기 목록을 요청하는 Appliction 구분 (0: STB, 2: MobileTV)
@property (nonatomic, strong) NSString *stb_id;   // STB ID
@property (nonatomic, strong) NSString *user_id;   // MobileTV 서비스 가입자의 user ID.
@property (nonatomic, strong) NSString *content_id;   // VOD 컨텐트의 식별자
@property (nonatomic, strong) NSString *prod_id;   // 상품 식별자
@property (nonatomic) eTransType trans_type;   // 컨텐트 전송 방식 (1: D&P, 2: RTSP, 3: HLS)
@property (nonatomic) NSInteger rate;   // 컨텐트 최종 시청 위치. 단위는 %(rate)
@property (nonatomic) NSInteger end_time;   // 컨텐트 최종 시청 위치. 단위 second
*/
