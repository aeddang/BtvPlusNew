//
//  ListStyle.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


struct ListItem{
    
    struct poster {
        static let type01:CGSize = CGSize(width: 158, height: 224)
        static let type02:CGSize = CGSize(width: 248, height: 354)
        static let type03:CGSize = CGSize(width: 326, height: 224)
    }
    
    struct thumb {
       static let type01:CGSize = CGSize(width: 248, height: 162)
    }
    
    struct thema {
       static let type01:CGSize = CGSize(width: 113, height: 113)
       static let type02:CGSize = CGSize(width: 151, height: 151)
    }
    
    struct banner {
       static let type01:CGSize = CGSize(width: -1, height: 100)
       
    }
}

