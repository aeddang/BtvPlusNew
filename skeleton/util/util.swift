//
//  Util.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/01.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

extension Date{
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

        return localDate
    }
    func currentTimeMillis() -> Double {
        return Double(self.timeIntervalSince1970 * 1000)
    }
    
}

