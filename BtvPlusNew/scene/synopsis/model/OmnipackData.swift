//
//  OmnipackModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/10.
//

import Foundation

class OmnipackData : Comparable{
    private(set) var title:String? = nil
    private(set) var pid:String? = nil
    private(set) var totalCount:String = ""
    private(set) var useCount:String = ""
    private(set) var restCount:Int = 0
    private(set) var validDate:Date? = nil
    private(set) var validTime:Double = 99999
    private(set) var unitPrice:Double = 99999

    func setData(data:PPVOmniPpmItem, price:String? = nil) -> OmnipackData {
        self.title = data.omni_m_pname
        self.pid = data.omni_m_pid
        self.totalCount = data.omni_m_total_count ?? ""
        self.restCount = data.omni_m_rest_count?.toInt() ?? 0
        self.useCount = data.omni_m_use_count ?? ""
        if let date = data.omni_m_rest_count_valid_date {
            self.validDate = date.toDate(dateFormat: "yyyyMMdd")
            self.validTime = self.validDate?.timeIntervalSinceNow ?? 0
        }
        if let price = price?.toDouble() {
            self.unitPrice = price / self.totalCount.toDouble()
        }
        return self
    }
    
    static func < (lhs: OmnipackData, rhs: OmnipackData) -> Bool {
        if lhs.unitPrice != rhs.unitPrice{
            return lhs.unitPrice < rhs.unitPrice
        } else if lhs.validDate != rhs.validDate {
            return lhs.self.validTime < rhs.validTime
        } else {
            return true
        }
    }
    
    static func == (lhs: OmnipackData, rhs: OmnipackData) -> Bool {
        return lhs.unitPrice == rhs.unitPrice && lhs.validTime == rhs.validTime
    }
}
