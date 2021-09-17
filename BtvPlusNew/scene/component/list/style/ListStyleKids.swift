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
        static let type01:CGSize = isPad ? CGSize(width: 152, height: 220) : CGSize(width: 94, height: 136)
        
    }
    struct video {
        static let type01:CGSize = isPad ? CGSize(width: 310, height: 252) : CGSize(width: 170, height: 136)
        static let type02:CGSize = isPad ? CGSize(width: 264, height: 214) : CGSize(width: 154, height: 122)
        static let size:CGSize = isPad ? CGSize(width: 328, height: 198) : CGSize(width: 170, height: 104)
    }
    struct seris {
        static let type01:CGSize =  isPad ? CGSize(width: 172, height: 94) : CGSize(width: 106, height: 58)
        static let bottomHeight:CGFloat = isPad ? 32 : 20
        
    }
    
    struct banner {
        static let type01:CGSize = isPad ? CGSize(width: 382, height: 344) : CGSize(width: 198, height: 178)
    }
}


