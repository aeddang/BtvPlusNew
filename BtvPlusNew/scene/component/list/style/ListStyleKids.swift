//
//  ListStyleKids.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/09.
//

import Foundation
//
//  ListStyle.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


struct ListItemKids{
    private static let isPad =  AppUtil.isPad()
    struct poster {
        static let type01:CGSize = isPad ? CGSize(width: 152, height: 219) : CGSize(width: 94, height: 135)
        
    }
    struct video {
        static let type01:CGSize = isPad ? CGSize(width: 310, height: 251) : CGSize(width: 170, height: 136)
        static let size:CGSize = isPad ? CGSize(width: 327, height: 199) : CGSize(width: 170, height: 103)
    }
    struct seris {
        static let type01:CGSize =  isPad ? CGSize(width: 172, height: 94) : CGSize(width: 106, height: 58)
        static let bottomHeight:CGFloat = isPad ? 32 : 20
        
    }
    
    struct banner {
        static let type01:CGSize = isPad ? CGSize(width: 382, height: 344) : CGSize(width: 199, height: 179)
    }
}


