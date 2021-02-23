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
        static let type01:CGSize = CGSize(width: 108, height: 154)
        static let type02:CGSize = CGSize(width: 164, height: 234)
        static let type03:CGSize = CGSize(width: 224, height: 154)
    }
    
    struct video {
       static let size:CGSize = CGSize(width: 164, height: 92)
       static let height:CGFloat = 127
    }
    
    struct thema {
       static let type01:CGSize = CGSize(width: 75, height: 75)
       static let type02:CGSize = CGSize(width: 100, height: 115)
       static let type03:CGSize = CGSize(width: 100, height: 100)
    }
    
    struct banner {
       static let size:CGSize = CGSize(width: 0, height: 80)
    }
    
    struct character {
        static let size:CGSize = CGSize(width: 62, height: 62)
    }
    
    struct people {
        static let size:CGSize = CGSize(width: 78, height: 78)
    }
    
    struct seris {
        static let size:CGSize = CGSize(width: 164, height: 92)
    }
    
    
    struct stb {
        static let size:CGSize = CGSize(width: 52, height: 52)
    }
    
    
    struct tablet {
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
           static let type03:CGSize = CGSize(width: 151, height: 151)
        }
        
        struct banner {
           static let type01:CGSize = CGSize(width: -1, height: 100)
           
        }
    }
   
}

