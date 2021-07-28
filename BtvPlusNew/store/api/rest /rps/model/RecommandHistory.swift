//
//  RecommandHistory.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/28.
//

import Foundation
struct RecommandHistory: Decodable {
    private(set) var result: String? = nil
    private(set) var bpoint_total: String?
    private(set) var rec_total_cnt: String?
    private(set) var rec_succ_list: [RecommandHistoryItem]?
    private(set) var IF: String? = nil
    private(set) var rec_succ_cnt: String? 
}


struct RecommandHistoryItem: Decodable {
    private(set) var rec_date: String? = nil
    private(set) var title: String? = nil
    private(set) var bpoint: String? = nil
}

