//
//  Synopsis.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/25.
//

import Foundation

enum LagCaptTypCd: String {
    case none = "00" // 없음
    case korean = "01" //우리말
    case subtitle = "02" //한글자막
    case ensubtitle = "03" //영어자막
    case endubbing = "04" //영어더빙
    case cndubbing = "05" //중국어더빙
    case folansubtitle = "15" //외국어자막서비스
    case etc = "13" //기타

    var name: String {
        switch self {
        case .korean: return "더빙" //원래값 우리말
        case .subtitle: return "자막" //원래값 한글자막
        case .ensubtitle: return "영어자막"
        case .endubbing: return "영어더빙"
        case .cndubbing: return "중국어더빙"
        case .folansubtitle: return "다국어자막" //외국어자막서비스
        case .etc: return "기타"
        default: return "없음.\(self)"
        }
    }
}

/**
 SRIS_TYP_CD    시리즈 유형 코드
 01    시즌
 02    타이틀
 04    콘텐츠팩 <- 요긔까지만 씀
 05    클립대표
 06    관련상품팩
 07    더빙+자막팩
 08    전시용팩
 */
public enum SrisTypCd: String {
    case none = "00" // error
    case season = "01"
    case title = "02"
    case contentsPack = "04"
    //    case repContents = "05"
    //    case relProducts = "06"
    //    case dubSubPack = "07"
    //    case exhProducts = "08"
    var name: String {
        switch self {
        case .season: return "시즌"
        case .title: return "타이틀"
        case .contentsPack: return "패키지"
        default: return "없음\(self)"
        }
    }

}

enum PpmPrdTypCd: String {
    case none = "" // 없음
    case normal = "0" //일반
    case premier = "1" //프리미어(월정액)
    case broadcaster = "2" //방송사
    case terrestrials = "3" //지상파
    var name: String {
        switch self {
        case .normal: return "일반"
        case .premier: return "프리미어"
        case .broadcaster: return "방송사"
        case .terrestrials: return "지상파"
        default: return "없음 \(self)"
        }
    }
}

enum DistStsCd: String {
    case registing = "60" //등록중(배포대기)
    case synced = "65" //동기화(배포승인)
    case stop = "70" //배포중지
    case expired = "80" //만료
    var name: String {
        switch self {
        case .registing: return "등록중"
        case .synced: return "동기화"
        case .stop: return "배포중지" //서비스 중지
        case .expired: return "배포만료" //구매했으면 가능
        }
    }
}

enum CacbroCd: String {
    case none = "" //공백
    case BS //방송사 요청 중지
    case SS //공급중단
    case BC //결방
    public init(value: String) {
        let uppercased = value.uppercased()
        switch uppercased {
        case "": self = .BC
        default: self = CacbroCd(value:uppercased)
        }
    }
}

enum PurcWatDdFgCd: String {
    case none = "00"
    case day = "10"
    case week = "20"
    case year = "30"
    case month = "40"
    var name: String {
        switch self {
        case .day: return String.app.day
        case .week: return String.app.week
        case .year: return String.app.year
        case .month: return String.app.month
        default: return ""
        }
    }
}

enum HoldbackType{
    case none // 1사 지상파 아님
    case holdIn //홀드백 기간
    case holdOut //홀드백 이후
    var name: String {
        switch self {
        case .none : return "1사 지상파 아님"
        case .holdIn: return "홀드백 기간"
        case .holdOut: return "홀드백 이후"
        }
    }
}

enum RsluTypCd: Int {
    case none = 0
    case ld = 1
    case sd = 2
    case hd = 3
    case fhd = 4
    case uhd = 5
    case uhd_hdr = 6

    public init(value: String) {
        switch value {
        case "105": self = .ld
        case "10", "110": self = .sd
        case "20", "120": self = .hd
        case "125": self = .fhd
        case "30": self = .uhd
        case "35": self = .uhd_hdr
        default: self = .none
        }
    }
    
    static func <= (lhs: Self, rhs: RsluTypCd) -> Bool {
        lhs.rawValue <= rhs.rawValue
    }
    
    static func >= (lhs: Self, rhs: RsluTypCd) -> Bool {
        lhs.rawValue >= rhs.rawValue
    }
    
    static func < (lhs: Self, rhs: RsluTypCd) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    static func > (lhs: Self, rhs: RsluTypCd) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}

