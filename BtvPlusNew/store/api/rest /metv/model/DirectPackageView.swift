//
//  DirectPackageView.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/17.
//

import Foundation

struct DirectPackageView : Decodable {
    private(set) var ver: String?    // 인터페이스 버전
    private(set) var svc_name: String?   // 서비스이름
    private(set) var stb_id: String? // STB ID
    private(set) var yn_ppm: String? // 월정액 전용 게이트웨이 시놉 바로보기 확인여부 체크(Y/N)
    private(set) var resp_directList:[PackagePurchaseItem]?  // 바로보기 가능유무 응답결과 집합
}

struct PackagePurchaseItem : Decodable {
    private(set) var resp_prod_id: String?    // 바로보기 확인용 상품ID 식별자
    private(set) var resp_direct_result: String?   // 바로보기 결과값 값 설명 Y 바로보기 가능 N 바로보기 불가능

}
